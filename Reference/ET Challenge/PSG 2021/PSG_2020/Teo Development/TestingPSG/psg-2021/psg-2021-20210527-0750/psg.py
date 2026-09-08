#!/usr/bin/python3

import cv2
import imutils.video
import threading
import serial

import flask

import json
import dataclasses
import enum
import configparser
import argparse
import time
import logging
import logging.handlers
import sys
import os
import pathlib
import copy
import queue
import http
import datetime
import abc

class Events:
    def __init__(self):
        self.lock = threading.Lock()
        self.condition = threading.Condition(self.lock)

        self.last = None
        self.current = None
        self.running = True

    def publishTurretStatus(self, pan, tilt, firing):
        with self.condition:
            if not self.running:
                return

            event = (pan, tilt, firing)


            # Do not generate an event if nothing has changed
            if self.last and self.last == event:
                logging.debug(f"Not publishing {pan}, {tilt}, {firing} because same as last time")
                return

            logging.debug(f"Publishing {pan}, {tilt}, {firing}")

            self.current = event
            self.condition.notify()

    def nextEvent(self):
        with self.condition:
            while self.running and not self.current:
                self.condition.wait()

            event = {
                "pan": self.current[0],
                "tilt": self.current[1],
                "firing": self.current[2]
            }

            if controls.alwaysfire():
                event["firing"] = True

            self.last = self.current
            self.current = None

            logging.debug(f"Sending {event['pan']}, {event['tilt']}, {event['firing']}")

            yield f"data: {json.dumps(event)}\nretry:100\n\n"

    def terminate(self):
        with self.condition:
            self.running = False
            self.condition.notify()

event_queue = Events()

class Daemon(threading.Thread):
    def __init__(self, thread_name):
        super().__init__(name = thread_name)
        self.daemon = True
        self.done = False

        self.lock = threading.Lock()
        self.condition = threading.Condition(self.lock)
        self.cleanup_complete = threading.Event()

    def terminate(self):
        # Note that the 'done' field does not need to be synchronised
        self.done = True

        with self.condition:
            self.condition.notify()

        self.cleanup_complete.wait()

@dataclasses.dataclass
class ScreenCoords:
    x: int
    y: int

class Colour(enum.Enum):
    BLACK = enum.auto()
    WHITE = enum.auto()
    GREY = enum.auto()
    RED = enum.auto()
    YELLOW = enum.auto()
    GREEN = enum.auto()
    CYAN = enum.auto()
    BLUE = enum.auto()
    MAGENTA = enum.auto()

    @classmethod
    def classifyHSV(cls, point):
        hue = point[0]/179 * 360
        saturation = point[1]/255 * 100
        lightness = point[2]/255 * 100

        #logging.debug(f"{hue}, {saturation}, {lightness}")

        if lightness < 20: return cls.BLACK
        if saturation < 25:
            if lightness > 80: return cls.WHITE
            else: return cls.GREY
        if hue < 30: return cls.RED
        if hue < 90: return cls.YELLOW
        if hue < 150: return cls.GREEN
        if hue < 210: return cls.CYAN
        if hue < 270: return cls.BLUE
        if hue < 330: return cls.MAGENTA

        return cls.RED

class TurretControls:
    def __init__(self):
        self.config_lock = threading.Lock()
        self.config = {
            "tracking": False,
            "autofire": False,
            "alwaysfire": False,
            "scanwhenidle": False,
            "shoot_colours": [],
            "safe_colours": []
        }

    def get(self):
        logging.debug(f"Retrieving controls: {self.config}")

        with self.config_lock:
            config = copy.deepcopy(self.config)
            config["shoot_colours"] = [ c.name for c in config["shoot_colours"] ]
            config["safe_colours"] = [ c.name for c in config["safe_colours"] ]

            return config

    def set(self, config):
        logging.debug(f"New controls: {config}")

        with self.config_lock:
            self.config = config
            self.config["shoot_colours"] = [ Colour[c] for c in config["shoot_colours"] ]
            self.config["safe_colours"] = [ Colour[c] for c in config["safe_colours"] ]

    def autofire(self):
        with self.config_lock:
            return self.config["autofire"]

    def tracking(self):
        with self.config_lock:
            return self.config["tracking"]

    def alwaysfire(self):
        with self.config_lock:
            return self.config["alwaysfire"]

    def scanwhenidle(self):
        with self.config_lock:
            return self.config["scanwhenidle"]

    def shootable_colours(self):
        with self.config_lock:
            return self.config["shoot_colours"]

    def safe_colours(self):
        with self.config_lock:
            return self.config["safe_colours"]

    def is_shootable_colour(self, colour):
        with self.config_lock:
           # If there are no shootable colours, all colours are shootable
            if not self.config["shoot_colours"]:
                return True

            return colour in self.config["shoot_colours"]
                

    def is_safe_colour(self, colour):
        with self.config_lock:
            # If there are no safe colours, supplied colour is NOT safe
            if not self.config["safe_colours"]:
                return False

            return colour in self.config["safe_colours"]

#
# x:[
#     [ x1,1, x1,2, x1,3, x1,4, x1,5 ],
#     [ x2,1, x2,2, x2,3, x2,4, x2,5 ],
#     [ x3,1, x3,2, x3,3, x3,4, x3,5 ],
#     [ x4,1, x4,2, x4,3, x4,4, x4,5 ],
#     [ x5,1, x5,2, x5,3, x5,4, x5,5 ]
# ]
#
# x[row][col]
#

class Calibration:
    CONFIG_FILE = "calibration.json"

    NUM_ROWS = 5
    NUM_COLS = 5

    def __init__(self):
        self.lock = threading.Lock()
        self.data = None,

        # self.data = {
        #    "pan_left": 180,
        #    "pan_right": 0,
        #    "tilt_up": 0,
        #    "tilt_down": 180,
        #    "grid": {
        #        "x": [
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ]
        #        ],
        #        "y": [
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ],
        #            [ -1, -1, -1, -1, -1 ]
        #        ],
        #        "pan": [ -1, -1, -1, -1, -1 ],
        #        "tilt": [ -1, -1, -1, -1, -1 ]
        #    }
        # }

    def pan_limits(self):
        with self.lock:
            return (self.data["pan_left"], self.data["pan_right"])

    def tilt_limits(self):
        with self.lock:
            return (self.data["tilt_up"], self.data["tilt_down"])

    def calculate_turret_position(self, target: ScreenCoords) -> (int, int):
        with self.lock:
            row, col = 0, 0

            grid = self.data["grid"]

            while row < self.NUM_ROWS - 2 and col < self.NUM_COLS - 2:
                if target.y > grid["y"][row+1][col]:
                    row = row + 1
                    continue

                if target.x > grid["x"][row][col+1]:
                    col = col + 1
                    continue

                break

            if row == self.NUM_ROWS - 1 or col == self.NUM_COLS - 1:
                logging.warning(f"Could not find grid square for ({target.x}, {target.y})")
                return (grid["pan"][2], grid["tilt"][2])

            logging.debug(f"Using grid square ({row}, {col}), with corners "\
                f"nw ({grid['x'][row][col]}, {grid['y'][row][col]}) "\
                f"ne ({grid['x'][row][col+1]}, {grid['y'][row][col+1]}) "\
                f"se ({grid['x'][row+1][col+1]}, {grid['y'][row+1][col+1]}) "\
                f"sw ({grid['x'][row+1][col]}, {grid['y'][row+1][col]}), "\
                f"left pan {grid['pan'][col]}, right pan {grid['pan'][col+1]}, "\
                f"top tilt {grid['tilt'][row]}, bottom tilt {grid['tilt'][row+1]}")

            pan_ratio = (target.x - grid["x"][row][col])/(grid["x"][row][col+1] - grid["x"][row][col])
            pan_delta = grid["pan"][col] - grid["pan"][col+1]

            logging.debug(f"Pan delta: {pan_delta}, pan ratio: {pan_ratio}")

            pan = grid["pan"][col] - round(pan_ratio * pan_delta)

            tilt_ratio = (target.y - grid["y"][row][col])/(grid["y"][row+1][col] - grid["y"][row][col])
            tilt_delta = grid["tilt"][row+1] - grid["tilt"][row]

            logging.debug(f"Tilt delta: {tilt_delta}, tilt ratio: {tilt_ratio}")

            tilt = grid["tilt"][row] + round(tilt_ratio * tilt_delta)

            logging.debug(f"Calculated turret position for ({target.x}, {target.y}): pan {pan}, tilt {tilt}")

            return (pan, tilt)

    def calibration(self):
        with self.lock:
            return copy.deepcopy(self.data)

    def load(self):
        try:
            with self.lock, open(self.CONFIG_FILE, "r") as calibration_file:
                self.data = json.load(calibration_file)

                self.__calibrate()
        except FileNotFoundError:
            logging.warning(f"Calibration file {self.CONFIG_FILE} not found")

    def calibrate(self, data):
        with self.lock:
            self.data = data
            self.__calibrate()
            self.__save()

    def __calibrate(self):
        # TBD - Nothing really to do?
        pass

    def __save(self):
        logging.debug(f"Saving updated configuration: {self.data} into {self.CONFIG_FILE}")

        with open(self.CONFIG_FILE, "w") as calibration_file:
            json.dump(self.data, calibration_file)

class BlobFinder:
    CONFIG_FILE_NAME = "detection.ini"

    @staticmethod
    def __params_to_string(params):
        s = f"threshold from {params.minThreshold} to {params.maxThreshold} via {params.thresholdStep} steps, "

        if params.filterByColor:
          s += f"filter: colour is {params.blobColor}, "

        if params.filterByArea:
          s += f"filter: {params.minArea:6.2} < area < {params.maxArea:6.2}, "

        if params.filterByCircularity:
          s += f"filter: {params.minCircularity:6.2} < circularity < {params.maxCircularity:6.2}, "

        if params.filterByConvexity:
          s += f"filter: {params.minConvexity:6.2} < convexity < {params.maxConvexity:6.2}, "

        if params.filterByInertia:
          s += f"filter: {params.minInertiaRatio:6.2} < inertia ratio < {params.maxInertiaRatio:6.2}, "

        s += f"minimum distance between blobs is {int(params.minDistBetweenBlobs)}, "
        s += f"minimum repeatability is {params.minRepeatability}"

        return s

    @staticmethod
    def __update_option(config, params, option, param_name, activate_if_found_param = None):
        if not config.has_option("Parameters", option):
            return

        value = getattr(params, param_name)

        if isinstance(value, int):
            value = config.getint("Parameters", option)
        elif isinstance(value, float):
            value = config.getfloat("Parameters", option)
        else:
            value = config.get("Parameters", option)

        setattr(params, param_name, value)

        if activate_if_found_param:
            setattr(params, activate_if_found_param, True)

    def __init__(self, controls):
        self.detector = None
        self.controls = controls
        self.detector_lock = threading.Lock()
        self.when_config_file_last_modified = 0
        self.__update_detector()

    def __update_detector(self):
        with self.detector_lock:
            config_file_path = pathlib.Path(self.CONFIG_FILE_NAME)

            # Only check for non-existence of file on startup
            if not self.when_config_file_last_modified and not config_file_path.exists():
                params = cv2.SimpleBlobDetector_Params()

                logging.info(f"{self.CONFIG_FILE_NAME} not found, using defaults for blob detection: {self.__params_to_string(params)}")

                config = configparser.ConfigParser()

                config["Parameters"] = {};
                config["Parameters"]["threshold.min"] = str(params.minThreshold)
                config["Parameters"]["threshold.step"] = str(params.thresholdStep)
                config["Parameters"]["threshold.max"] = str(params.maxThreshold)
                config["Parameters"]["distance_between_blobs.min"] = str(params.minDistBetweenBlobs)
                config["Parameters"]["repeatability.min"] = str(params.minRepeatability)
                config["Parameters"]["filter.color"] = str(params.blobColor)
                config["Parameters"]["filter.area.min"] = str(params.minArea)
                config["Parameters"]["filter.area.max"] = str(params.maxArea)
                config["Parameters"]["filter.circularity.min"] = str(params.minCircularity)
                config["Parameters"]["filter.circularity.max"] = str(params.maxCircularity)
                config["Parameters"]["filter.convexity.min"] = str(params.minConvexity)
                config["Parameters"]["filter.convexity.max"] = str(params.maxConvexity)
                config["Parameters"]["filter.inertia.min"] = str(params.minInertiaRatio)
                config["Parameters"]["filter.inertia.max"] = str(params.maxInertiaRatio)

                with open(self.CONFIG_FILE_NAME, "w") as config_file:
                    config.write(config_file)

                self.detector = cv2.SimpleBlobDetector_create(params)

                return self.detector

            try:
                last_modified = config_file_path.stat().st_mtime

                if last_modified <= self.when_config_file_last_modified:
                    return self.detector

                logging.debug(f"Loading {self.CONFIG_FILE_NAME}")

                config = configparser.ConfigParser()

                config.read(self.CONFIG_FILE_NAME)
            except FileNotFoundError:
                # This odd case arises when the file is re-written using gvim, as the file temporarily
                # vanishes as gvim backs it up; we simply do nothing, as it'll be back momentarily.
                return self.detector

            params = cv2.SimpleBlobDetector_Params()

            params.filterByColor = False
            params.filterByArea = False
            params.filterByCircularity = False
            params.filterByConvexity = False
            params.filterByInertia = False

            self.__update_option(config, params, "filter.color", "blobColor", activate_if_found_param = "filterByColor")
            self.__update_option(config, params, "filter.area.min", "minArea", activate_if_found_param = "filterByArea")
            self.__update_option(config, params, "filter.area.max", "maxArea", activate_if_found_param = "filterByArea")
            self.__update_option(config, params, "filter.circularity.min", "minCircularity", activate_if_found_param = "filterByCircularity")
            self.__update_option(config, params, "filter.circularity.max", "maxCircularity", activate_if_found_param = "filterByCircularity")
            self.__update_option(config, params, "filter.convexity.min", "minConvexity", activate_if_found_param = "filterByConvexity")
            self.__update_option(config, params, "filter.convexity.max", "maxConvexity", activate_if_found_param = "filterByConvexity")
            self.__update_option(config, params, "filter.inertia.min", "minInertiaRatio", activate_if_found_param = "filterByInertia")
            self.__update_option(config, params, "filter.inertia.max", "maxInertiaRatio", activate_if_found_param = "filterByInertia")
            self.__update_option(config, params, "threshold.min", "minThreshold")
            self.__update_option(config, params, "threshold.step", "thresholdStep")
            self.__update_option(config, params, "threshold.max", "maxThreshold")
            self.__update_option(config, params, "distance_between_blobs.min", "minDistBetweenBlobs")
            self.__update_option(config, params, "repeatability.min", "minRepeatability")

            logging.info(f"Loaded configuration from {self.CONFIG_FILE_NAME}, using {self.__params_to_string(params)}")

            self.detector = cv2.SimpleBlobDetector_create(params)

            self.when_config_file_last_modified = last_modified

            return self.detector

    def __threshold_and_invert(self, img):
        _, threshed = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
        return cv2.bitwise_not(threshed)

    def identify_blobs(self, frame, calibration, turret):
        # mask = cv2.inRange(frame, colour_lower, colour_upper)
        # mask = cv2.erode(mask, None, iterations = 0)
        # mask = cv2.dilate(mask, None, iterations = 0)
        # frame = cv2.bitwise_and(frame, frame, mask = mask)

        #detection_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

        masked_blue = self.__threshold_and_invert(frame[:,:,0])
        masked_green = self.__threshold_and_invert(frame[:,:,1])
        masked_red = self.__threshold_and_invert(frame[:,:,2])

        masked = cv2.bitwise_or(cv2.bitwise_or(masked_blue, masked_green), masked_red)
        mask = cv2.merge((masked, masked, masked))

        detection_frame = cv2.bitwise_and(frame, mask)
        hsv_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

        detector = self.__update_detector()

        keypoints = detector.detect(detection_frame)

        #logging.debug(f"Detected {len(keypoints)} sets of keypoints")

        shootable_keypoints = []

        if not keypoints and controls.autofire() and turret.is_firing():
            logging.debug("No targets")
            turret.fire(False)

        if keypoints:
            safe_keypoints = []
            other_keypoints = []

            for keypoint in keypoints:
                point = hsv_frame[int(keypoint.pt[1])][int(keypoint.pt[0])]
                point_colour = Colour.classifyHSV(point)

                #logging.debug(point_colour.name)

                if self.controls.is_safe_colour(point_colour):
                    safe_keypoints.append(keypoint)
                elif self.controls.is_shootable_colour(point_colour):
                    shootable_keypoints.append(keypoint)
                else:
                    other_keypoints.append(keypoint)

            shootable_colour = (0, 0, 255)

            if not controls.autofire():
                safe_colour = (0, 255, 0)
                other_colour = (0, 255, 255) # bgr

                frame = cv2.drawKeypoints(
                    frame,
                    shootable_keypoints,
                    frame,
                    color = shootable_colour,
                    flags = cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

                frame = cv2.drawKeypoints(
                    frame,
                    safe_keypoints,
                    frame,
                    color = safe_colour,
                    flags = cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

                frame = cv2.drawKeypoints(
                    frame,
                    other_keypoints,
                    frame,
                    color = other_colour,
                    flags = cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
            else:
                if shootable_keypoints:
                    lowest_cost = None
                    target = None

                    pan, tilt = turret.turret_position()

                    target_pan = pan
                    target_tilt = tilt
                    target_keypoint = None

                    for keypoint in shootable_keypoints:
                        point = ScreenCoords(int(keypoint.pt[0]), int(keypoint.pt[1]))
                        new_pan, new_tilt = calibration.calculate_turret_position(point)

                        cost = abs(pan - new_pan) + abs(tilt - new_tilt)

                        if lowest_cost is None or cost < lowest_cost:
                            lowest_cost = cost
                            target_pan = new_pan
                            target_tilt = new_tilt
                            target_keypoint = keypoint

                    frame = cv2.drawKeypoints(
                        frame,
                        [ target_keypoint ],
                        frame,
                        color = shootable_colour,
                        flags = cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

                    turret.move(target_pan, target_tilt)
                    turret.fire(True)
                elif turret.is_firing():
                    logging.debug("No shootable targets")
                    turret.fire(False)

        return frame

class Scanner(Daemon):
    def __init__(
        self,
        turret,
        calibration,
        pause_before_resuming_scanning,
        pause_between_turret_positions,
        turret_pan_increment
    ):
        super().__init__("ScannerThread")
        self.turret = turret
        self.calibration = calibration
        self.__turret_active()
        self.enabled = False
        self.when_next_move = None
        self.panning_left = True # otherwise panning right
        self.pause_before_resuming_scanning = pause_before_resuming_scanning
        self.pause_between_turret_positions = pause_between_turret_positions
        self.turret_pan_increment = turret_pan_increment

    def __turret_active(self):
        self.when_last_active = datetime.datetime.now().timestamp()

    def turret_active(self):
        with self.condition:
            self.__turret_active()

            self.condition.notify()

    def enable(self, enabled):
        with self.condition:
            self.enabled = enabled

            self.condition.notify()

    def run(self):
        while not self.done:
            with self.condition:
                if not self.enabled:
                    self.when_next_move = None

                    logging.debug("Waiting for scanner to be enabled")
                    self.condition.wait()
                    continue

                now = datetime.datetime.now().timestamp()

                if self.when_last_active + self.pause_before_resuming_scanning > now:
                    self.when_next_move = None

                    self.condition.wait(self.pause_before_resuming_scanning - (now - self.when_last_active))
                    continue

                if self.when_next_move and self.when_next_move > now:
                    self.condition.wait(self.when_next_move - now)
                    continue

                # Time to move the turret!

                logging.debug("Moving turret as part of scan")

                current_pan, _ = self.turret.turret_position()

                (pan_left_limit, pan_right_limit) = self.calibration.pan_limits()
                (tilt_up_limit, tilt_down_limit) = self.calibration.tilt_limits()

                new_tilt = tilt_up_limit + int((tilt_down_limit - tilt_up_limit)/2)

                if self.panning_left:
                    if current_pan + self.turret_pan_increment > pan_left_limit:
                        self.panning_left = False
                        continue

                    new_pan = current_pan + self.turret_pan_increment
                else:
                    if current_pan - self.turret_pan_increment < pan_right_limit:
                        self.panning_left = True
                        continue

                    new_pan = current_pan - self.turret_pan_increment

                self.turret.move(new_pan, new_tilt)
                self.when_next_move = now + self.pause_between_turret_positions
                continue

        logging.info("Stopping scanner")

        self.cleanup_complete.set()

class TurretController(Daemon):
    def __init__(self, comport = None, baudrate = None, frequency = 0.5):
        super().__init__("TurretThread")
        self.serial = serial.Serial(port = comport, baudrate = baudrate) if comport else None

        self.pan = 0
        self.tilt = 0
        self.firing = False
        self.frequency = frequency
        self.always_fire = False

        self.last_message = None

        self.move(self.pan, self.tilt)

    def alwaysfire(self, enabled):
        with self.condition:
            self.always_fire = enabled
            self.firing = enabled

            self.condition.notify()

    def turret_position(self):
        with self.condition:
            return (self.pan, self.tilt)

    def turret_position_str(self):
        with self.condition:
            return self.__turret_position_str()
            

    def __turret_position_str(self):
        return f"({self.pan}\N{DEGREE SIGN}, {self.tilt}\N{DEGREE SIGN})"

    def is_firing(self):
        with self.condition:
            return self.firing

    def fire(self, firing):
        with self.condition:
            if self.always_fire:
                return

            if self.firing == firing:
                return

            self.firing = firing

            self.condition.notify()

    def move(self, pan, tilt):
        if pan < 0 or pan > 180:
            logging.warning(f"Pan {pan}\N{DEGREE SIGN} out of range, changing to be within 0..180")
            pan = 0 if pan < 0 else pan
            pan = 180 if pan > 180 else pan

        if tilt < 0 or tilt > 180:
            logging.warning(f"Tilt {tilt}\N{DEGREE SIGN} out of range, changing to be within 0..180")
            tilt = 0 if tilt < 0 else tilt
            tilt = 180 if tilt > 180 else tilt

        with self.condition:
            if pan == self.pan and tilt == self.tilt:
                logging.debug(f"Turret already at {self.__turret_position_str()}, not moving")
                return

            logging.info(f"Moving turret to pan {pan}\N{DEGREE SIGN}, tilt {tilt}\N{DEGREE SIGN}")

            self.pan = pan
            self.tilt = tilt

            self.condition.notify()

    def run(self):
        while True:
            with self.condition:
                self.condition.wait()

                if self.done:
                    break

                message = f"a{self.pan:03d}{self.tilt:03d}{int(self.firing)}"

                #if controls.autofire():
                event_queue.publishTurretStatus(self.pan, self.tilt, self.firing)

                self.__write_to_device(message)

                #self.condition.wait(0.1)
                #if self.frequency:
                #    self.condition.wait(1.0/self.frequency)
                #else:
                #    self.condition.wait()

        logging.info("Stopping serial controller")

        self.__write_to_device("z0000000")

        self.cleanup_complete.set()

    def __write_to_device(self, message):
        if self.last_message and self.last_message == message:
            logging.debug(f"Not sending {message} as identical to last sent")
            return

        logging.debug(f"Sending to device: {message}")

        if self.serial:
            self.serial.write(bytearray(message, "utf_8"))
            self.last_message = message

class VideoSource(Daemon):
    def __init__(self, record, width):
        super().__init__("VideoSource")
        self.record = record
        self.frame = None
        self.capture = None
        self.width = width

    def received_frame(self, frame):
        if not self.record:
            return

        if not self.capture:
            self.__start_recording()

        self.capture.write(frame)

    def configuration(self, *args):
        return None

    def end_of_video(self):
        self.__stop_recording()

    def __start_recording(self):
        if not self.record:
            return

        self.__stop_recording()

        output_filename = f"recording-{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}.avi"

        (fps, width, height) = self.get_video_properties()

        logging.debug(f"Writing video ({width}x{height} @ {fps} fps to {output_filename}")

        self.capture = cv2.VideoWriter(
            output_filename,
            cv2.VideoWriter_fourcc(*'XVID'),
            20.0,
            (int(width), int(height))
        )
    
    def __stop_recording(self):
        if self.capture:
            self.capture.release()

    def read(self):
        while True:
            with self.condition:
                if self.frame is None:
                    self.condition.wait(1) # 1 second
                    continue

                frame = self.frame
                frame = imutils.resize(frame, width = self.width)

                self.frame = None

                return frame

class WebCam(VideoSource):
    def __init__(self, record, width):
        super().__init__(record, width)

        self.video_stream = cv2.VideoCapture()
        self.video_stream.open(index = 0)

    def get_video_properties(self):
        return (
            self.video_stream.get(cv2.CAP_PROP_FPS),
            self.video_stream.get(cv2.CAP_PROP_FRAME_WIDTH),
            self.video_stream.get(cv2.CAP_PROP_FRAME_HEIGHT)
        )

    def run(self):
        while not self.done:
            (grabbed_frame, frame) = self.video_stream.read()

            if not grabbed_frame:
                continue

            with self.condition:
                self.received_frame(frame)

                self.frame = frame.copy()
                self.condition.notify_all()

        self.cleanup_complete.set()

if sys.platform == "linux":
    import picamera.array
    import picamera

    class PiCam(VideoSource):
        CONFIG_FILE = "picam.json"

        DEFAULT_CONFIGURATION = {
            "type": "picam",
            "brightness": 50,
            "contrast": 0,
            "saturation": 0,
            "exposure_mode": "auto",
            "ISO": 0,
            "awb_mode": "auto"
        }

        def __init__(self, record, width, brightness, contrast, saturation, exposure_mode, iso, awb_mode):
            super().__init__(record, width)
            self.height = int(width * 3/4)

            try:
                with self.lock, open(self.CONFIG_FILE, "r") as config_file:
                    self.__configuration = json.load(config_file)

            except FileNotFoundError:
                self.__configuration = self.DEFAULT_CONFIGURATION

            self.camera = picamera.PiCamera()
            self.camera.resolution = (self.width, self.height)
            self.camera.framerate = 32

            self.__apply_configuration()

            time.sleep(0.1)

        def __apply_configuration(self):
            logging.debug(self.__configuration)

            self.camera.brightness = self.__configuration["brightness"]
            self.camera.contrast = self.__configuration["contrast"]
            self.camera.saturation = self.__configuration["saturation"]
            self.camera.exposure_mode = self.__configuration["exposure_mode"]
            self.camera.ISO = self.__configuration["ISO"]
            self.camera.awb_mode = self.__configuration["awb_mode"]

        def configuration(self, *args):
            with self.condition:
                if len(args):
                    self.__configuration = args[0]

                    self.__apply_configuration()

                with open(self.CONFIG_FILE, "w") as config_file:
                    json.dump(self.__configuration, config_file)

                return self.__configuration

        def get_video_properties(self):
            return (
                self.camera.framerate,
                self.width,
                self.height
            )

        def run(self):
            raw_capture = picamera.array.PiRGBArray(self.camera, size = (self.width, self.height))

            for frame in self.camera.capture_continuous(raw_capture, format = "bgr", use_video_port = True):
                if self.done:
                    break

                with self.condition:
                    self.received_frame(frame.array)

                    self.frame = frame.array.copy()
                    self.condition.notify_all()

                raw_capture.truncate(0)

            self.cleanup_complete.set()

class VideoFiles(VideoSource):
    def __init__(self, record, width, videos):
        super().__init__(record, width)

        self.video_stream = cv2.VideoCapture()
        self.fps = None
        self.videos = videos

        self.__load_video()

    def __load_video(self):
        video = self.videos.pop(0)
        self.videos.append(video)

        self.end_of_video()

        logging.debug(f"Playing {video}")

        self.video_stream.open(video)

    def get_video_properties(self):
        return (
            self.fps,
            self.video_stream.get(cv2.CAP_PROP_FRAME_WIDTH),
            self.video_stream.get(cv2.CAP_PROP_FRAME_HEIGHT)
        )

    def run(self):
        while not self.done:
            (grabbed_frame, frame) = self.video_stream.read()

            if not grabbed_frame:
                self.__load_video()
                continue

            with self.condition:
                if not self.fps:
                    self.fps = self.video_stream.get(cv2.CAP_PROP_FPS)

            time.sleep(1.0/self.fps)

            with self.condition:
                self.received_frame(frame)

                self.frame = frame.copy()
                self.condition.notify_all()

        self.cleanup_complete.set()

class VideoProcessor(Daemon):
    def __init__(self, controls, calibration, turret, video_source):
        super().__init__("VideoThread")

        self.frame = None
        self.video_source = video_source
        self.controls = controls
        self.calibration = calibration
        self.turret = turret
        self.blob_finder = BlobFinder(self.controls)

    def run(self):
        while not self.done:
            frame = self.video_source.read()

            if self.controls.tracking() or self.controls.autofire():
                frame = self.blob_finder.identify_blobs(frame, self.calibration, self.turret)

            with self.condition:
                self.frame = frame.copy()
                self.condition.notify_all()

        logging.info("Stopping video stream")
        self.cleanup_complete.set()

    # Generator function to produce frames
    def get_next_frame(self):
        while True:
            with self.condition:
                if self.frame is None:
                    logging.info("Waiting for video...")
                    self.condition.wait(1) # 1 second
                    continue

                (flag, encoded_image) = cv2.imencode("*.jpg", self.frame)

                if not flag:
                    logging.error("Failed to encode video frame")
                    continue

            # Build output frame

            yield(
                b"--frame\r\n"
                b"Content-Type: image/jpeg\r\n\r\n" +
                bytearray(encoded_image) +
                b"\r\n")

logging.basicConfig(
    format = "{asctime}|{levelname:<5}|{threadName:>12}|{message}",
    style = "{",
    datefmt = "%Y%m%d|%H:%M:%S",
    level = logging.DEBUG,
    handlers = [
        logging.handlers.RotatingFileHandler(
            "psg.log",
            maxBytes = 1000000,
            backupCount = 5
        ),
        logging.StreamHandler()
    ]
)

#if __name__ != "__main__":
#    logging.error(f"{sys.argv[0]} is not intended to be imported")
#    sys.exit(1)

logging.info("Starting PSG")

config = configparser.ConfigParser()
config.read("psg.ini")

if not config:
    print(f"{sys.argv[0]} requires a configuration file named psg.ini")
    sys.exit(1)

http_host = config.get("Web Server", "Host", fallback = "localhost")
http_port = config.getint("Web Server", "Port", fallback = 80)

argument_parser = argparse.ArgumentParser()
argument_parser.add_argument(
    "--video",
    type = str,
    required = False,
    help = "Name of video file, or directory containing video files")
argument_parser.add_argument(
    "--record",
    action = 'store_true',
    help = "Record the video in one or more timestamped files")
argument_parser.add_argument(
    "--picam",
    action = 'store_true',
    help = "Attempt to utilise the Raspberry Pi camera")

args = argument_parser.parse_args()

controls = TurretControls()
video_processor = None

command_frequency = config.getfloat("Controller", "Command frequency (Hz)", fallback = 5)

if config.has_section("Arduino"):
    if not config.has_option("Arduino", "COM Port"):
        print(f"{sys.argv[0]} configuration file psg.ini needs a value for COM Port under [Arduino]")
        sys.exit(1)

    arduino_comport = config.get("Arduino", "COM port")
    arduino_baudrate = config.getint("Arduino", "Baud rate", fallback = 9600)

    controller = TurretController(arduino_comport, arduino_baudrate, frequency = command_frequency)
else:
    controller = TurretController(frequency = command_frequency)

videos = []

if args.video:
# Is it a file or directory?
    if os.path.isfile(args.video):
        # It's a file
        videos.append(args.video)
    elif os.path.isdir(args.video):
        # It's a directory, so scan it looking for files
        for entry in os.scandir(args.video):
            # Skip non-files
            if not entry.is_file():
                continue

            videos.append(entry.path)
    else:
        raise ValueError(f"{args.video} is not a file or directory")

videos.sort(key = lambda s: os.path.splitext(s)[0])

logging.debug(videos)

calibration = Calibration()
calibration.load()

video_width = config.getint("Video", "Width", fallback = 400)

if videos:
    video_source = VideoFiles(args.record, video_width, videos)
elif args.picam:
    video_source = PiCam(
        args.record,
        video_width,
        config.getint("Pi Camera", "Brightness", fallback = 50),
        config.getint("Pi Camera", "Contrast", fallback = 0),
        config.getint("Pi Camera", "Saturation", fallback = 0),
        config.get("Pi Camera", "Exposure mode", fallback = "auto"),
        config.getint("Pi Camera", "ISO", fallback = 0),
        config.get("Pi Camera", "Automatic white balance mode", fallback = "auto")
    )
else:
    video_source = WebCam(args.record, video_width)

video_processor = VideoProcessor(controls, calibration, controller, video_source)

scanner = Scanner(
    controller,
    calibration,
    config.getfloat("Scanning", "Pause before resuming scanning", fallback = 2.0),
    config.getfloat("Scanning", "Pause between turret positions", fallback = 0.7),
    config.getint("Scanning", "Turret pan increment", fallback = 10)
)

app = flask.Flask(__name__, static_url_path = "", static_folder = "static")

@app.route("/")
def index():
    return flask.render_template(
        "index.html",
        grid_ids = [ f"{x}-{y}" for x in range(0, Calibration.NUM_ROWS) for y in range(0, Calibration.NUM_COLS) ]
    )

@app.route("/video")
def video():
    global video_processor

    return flask.Response(
        video_processor.get_next_frame(),
        mimetype = "multipart/x-mixed-replace; boundary=frame")

@app.route("/<path:path>")
def send_static(path):
    return flask.send_from_directory("static", path)

@app.route("/calibrate", methods = [ 'POST' ])
def calibrate():
    logging.debug(flask.request.json)

    calibration.calibrate(flask.request.json)

    return ("", http.HTTPStatus.NO_CONTENT)

@app.route("/calibration", methods = [ 'GET' ])
def get_calibration():
    logging.debug("Retrieving calibration")

    current_calibration = calibration.calibration();

    if not current_calibration:
        # Return 204 (No Content)
        return ("", http.HTTPStatus.NO_CONTENT)

    return json.dumps(current_calibration)

@app.route("/turret_position", methods = [ 'GET' ])
def turret_position():
    logging.debug(f"Get turret position: {controller.turret_position_str()}")

    pan, tilt = controller.turret_position()
    return json.dumps({ "pan": pan, "tilt": tilt })

@app.route("/move", methods = [ 'POST' ])
def move():
    logging.debug(f"Moving to pan {flask.request.json['pan']}, tilt {flask.request.json['tilt']})")

    scanner.turret_active()
    controller.move(flask.request.json["pan"], flask.request.json["tilt"])

    return ("", http.HTTPStatus.NO_CONTENT)

@app.route("/target", methods = [ 'POST' ])
def target():
    logging.debug(f"Targeting ({flask.request.form['x']}, {flask.request.form['y']})")

    return ("", http.HTTPStatus.NO_CONTENT)

@app.route("/fire", methods = [ 'POST' ])
def fire():
    logging.debug(f"Firing: {flask.request.json['firing']} at {controller.turret_position_str()}")

    scanner.turret_active()
    controller.fire(flask.request.json["firing"])

    return ("", http.HTTPStatus.NO_CONTENT)

@app.route("/aim", methods = [ 'POST' ])
def aim():
    logging.debug(f"Aim: {flask.request.json}")

    pan, tilt = calibration.calculate_turret_position(
        ScreenCoords(flask.request.json["x"], flask.request.json["y"])
    )

    if "move_and_fire" in flask.request.json:
        controller.move(pan, tilt)
        controller.fire(True)

    return json.dumps({ "pan": pan, "tilt": tilt })

@app.route("/trackablecolours", methods = [ 'GET' ])
def trackablecolours():
    logging.debug(f"Retrieving colours that are trackable")

    return json.dumps([ colour.name for colour in Colour if colour not in [ Colour.BLACK ] ])

@app.route("/controls", methods = [ 'GET' ])
def get_controls():
    return json.dumps(controls.get())

@app.route("/controls", methods = [ 'POST' ])
def set_controls():
    old_autofire = controls.autofire()

    controls.set(flask.request.json)

    if controls.autofire() != old_autofire and controller.is_firing():
        controller.fire(False)

    scanner.enable(controls.scanwhenidle() and not controls.alwaysfire() and not controls.autofire())

    controller.alwaysfire(controls.alwaysfire())

    return ("", http.HTTPStatus.NO_CONTENT)

@app.route("/camera_configuration", methods = [ 'GET' ])
def get_camera_config():
    return json.dumps(video_source.configuration())

@app.route("/camera_configuration", methods = [ 'POST' ])
def set_camera_config():
    config = video_source.configuration(flask.request.json)

    if config:
        return json.dumps(config)

    return ("", http.HTTPStatus.BAD_REQUEST)

@app.route("/events")
def events():
    event = event_queue.nextEvent()
    logging.debug(f"Returning event: {event}")

    response = flask.Response(event, mimetype = "text/event-stream")
    response.headers.set("Cache-Control", "no-cache")

    return response

if __name__ == "__main__":
    video_processor.start()
    video_source.start()
    controller.start()

    controller.move(90, 90)

    scanner.start()

    logging.info("Waiting for HTTP requests")
    app.run(host = http_host, port = http_port, debug = True, threaded = True, use_reloader = False)
    logging.info("Web server exiting")

    scanner.terminate()
    controller.terminate()
    video_processor.terminate()
    video_source.terminate()
    event_queue.terminate()
                

