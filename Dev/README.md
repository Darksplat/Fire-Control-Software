# Fire-Control-Software

Laser target-training turret: Raspberry Pi (or any computer) + Arduino. The camera watches a projector screen, finds targets,
and the Arduino aims a pan/tilt turret and pulses a TTL laser (pin 7, active-low) on the target.

The engine is `PSG 2021/psg.py`. This branch adds the safety and operations layer from `MASTER_FEATURES_LIST.md`:

| Feature | How it works |
|---|---|
| Arm / disarm | Starts **disarmed** on every run. Nothing fires (auto, manual, always-fire, aim-and-fire) until `POST /arm {"armed": true}`. Safety panel at the top of the web page. |
| Kill | `POST /kill` stops firing, turns off auto modes and disarms. |
| Safe-to-fire zones | Draw boxes on the video (tick "Draw safe-to-fire zone"). Enforced on the server for auto and aim-and-fire. Saved in `zones.json`. `GET/POST/DELETE /zones`, `DELETE /zones/<id>`. |
| Screen bounds | Auto-fire only targets inside the calibrated 5x5 grid area. With no calibration it never auto-fires. |
| Event log | Arm, disarm, fire start/stop, blocked fires, zone changes. `GET /log` (JSON) or `/log?format=csv`. |
| Optional token | Set `[Security] Token = ...` in `psg.ini`; state-changing requests then need an `X-Token` header. (The built-in page does not send one, so leave it empty unless you use your own client.) |
| Arduino fail-safe | While firing the host re-sends the command every 0.5 s. The sketch turns the laser off if it hears nothing for 3 s, and on the shutdown command (`z`). Re-upload `PSG 2021/Arduino Files/PSG_2020.ino`. |

Old experiments (Flask prototypes, duplicate mains, templates) are in `archive/`. Tests: `python -m pytest tests`.

---
# Fire-Control-Software

A laser target-training turret. A camera watches a projector screen, finds targets, and an Arduino aims a pan/tilt
servo turret and pulses a TTL laser on the target. Runs on a Raspberry Pi (or any computer) with an Arduino attached over USB.
You control it from a web page.

The engine is `PSG 2021/psg.py`, based on Project Sentry Gun. This version adds arm/disarm, a kill button,
safe-to-fire zones, screen bounds, an event log and an Arduino fail-safe.

## Safety first
- The system starts **disarmed** every time. Nothing can fire (auto, manual, always-fire, aim-and-fire) until you press **Arm**.
- **Kill** stops firing, switches off the auto modes and disarms.
- Auto-fire only targets inside the calibrated screen area, and never inside a safe-to-fire zone.
- With no calibration saved, auto-fire does nothing.
- The Arduino turns the laser off if the computer stops talking to it for 3 seconds.
- Use the laser only at the projector screen, with a backstop behind it, and never aim it at people or reflective surfaces.

## Hardware
- Raspberry Pi 4 (4 GB or more) or another computer, with a camera (Pi Camera V2 or a USB webcam)
- Arduino Uno Rev3 or compatible, connected by USB
- Pan and tilt servos on a turret, and a TTL laser
- Projector and screen

Arduino wiring (from `PSG 2021/Arduino Files/PSG_2020.ino`):

| Pin | Connects to |
|---|---|
| 8 | Pan servo signal |
| 9 | Tilt servo signal |
| 7 | Laser TTL input (the laser is on when this pin is LOW) |
| 14 (A0) | USB activity LED (optional) |

Power the servos and laser from a suitable supply, and share its ground with the Arduino.

## Software install
1. Upload `PSG 2021/Arduino Files/PSG_2020.ino` to the Arduino with the Arduino IDE. Re-upload it whenever the sketch changes.
2. Install Python. The project was built on Python 3.9.x. Newer versions may work, but if a package fails to install, use 3.9.
3. Install the packages:
   ```
   pip3 install --upgrade pip
   pip3 install Flask imutils opencv-contrib-python opencv-python pyserial numpy
   ```
4. On Linux, `psg.py` also imports `picamera`, which exists on Raspberry Pi OS "Buster" (legacy). Bullseye and later use a different
   camera library and will not work with the Pi Camera here.
5. Copy this repository onto the machine the Arduino is connected to.

## Configuration (`PSG 2021/psg.ini`)
```
[Web Server]
Host = localhost        ; use 0.0.0.0 to reach it from other devices (see warning below)
Port = 8080

[Arduino]
COM Port = /dev/ttyACM0 ; Mac: /dev/tty.usbmodem... (ls /dev/tty.usb*)  Windows: COM7
Baud rate = 9600

[Video]
Width = 400

[Scanning]
Pause before resuming scanning = 5
Pause between turret positions = 2
Turret pan increment = 10

[Security]
Token =                 ; optional, see below
```
Delete the `[Arduino]` section to run without hardware.

Warning: the built-in web page has no login. Leave `Host = localhost`, or only expose it on a network you trust. `Token`
protects the API for your own clients (they send an `X-Token` header), but the built-in page does not send one, so leave it empty unless you use the API directly.

Target detection settings (brightness thresholds, size and shape filters) are in `PSG 2021/detection.ini`.

## Running
```
cd "PSG 2021"
python3 psg.py
```
Then open http://localhost:8080 (or the Pi's address and port).

Options:
- `--video <file or folder>` replays recorded video instead of the camera (test clips are in `PSG 2021/Videos`)
- `--record` saves the video in timestamped files
- `--picam` uses the Raspberry Pi camera

## Using it
**1. Arm.** Use the panel at the top of the page. The status line shows Safe or ARMED. Arm before calibrating, because calibration
needs the laser on, and the laser will not light while disarmed.

**2. Calibrate** (once per camera/turret/screen position):
1. Set the turret limits. Enter a pan or tilt value in the left, right, up and down fields, press **Move** to try it, and use **Copy** to take the turret's current value.
   Find the furthest left, right, up and down positions that still land on the screen.
2. Select **Calibrating** and press **Start**. The laser turns on and the turret moves to each of the 25 grid points in turn.
3. For each point, click on the video where the laser dot appears. The coordinates fill in automatically.
4. When all 25 are done, press **Save**. This writes `calibration.json`. **Reset** clears it.
5. Switch back to **Active**.

**3. Safe-to-fire zones.** Tick *Draw safe-to-fire zone* in the safety panel and drag a box on the video. Targets inside a zone are never fired on.
*Clear zones* removes them all. Zones are saved in `zones.json` and drawn in red on the video.

**4. Fire modes** (switches on the page):
- *Click to fire*: click a spot on the video and the turret aims and fires there
- *Tracking* and *Auto-fire*: the turret follows detected targets and fires the laser on them
- *Always fire*: laser on continuously (arm first)
- *Scan when idle*: sweeps the turret while there is no target
- *Shoot colour* and *Safe colour*: only fire at one colour, or never fire at another

**5. Kill.** Press **Kill** at any time to stop everything and disarm.

## Log
Every arm, disarm, fire start/stop, blocked fire and zone change is recorded. View it at `/log`, or download it with the
*Export log* link (`/log?format=csv`). Blocked fires show why (`disarmed`, `safe-to-fire zone`, `off_screen_block`).
Detailed debug output goes to `psg.log`.

## API (for your own tools)
| Method | Path | Purpose |
|---|---|---|
| POST | `/arm` `{"armed": true}` | Arm or disarm |
| POST | `/kill` | Emergency stop |
| GET | `/safety_status` | Armed state, firing state, zones |
| GET / POST / DELETE | `/zones` | List, add (`{"x","y","w","h"}`) or clear zones |
| DELETE | `/zones/<id>` | Remove one zone |
| GET | `/log` | Event log (`?format=csv` for CSV) |
| POST | `/move`, `/fire`, `/aim`, `/controls` | Turret control (as used by the web page) |
| GET | `/calibration`, `/turret_position`, `/video` | Calibration data, turret position, MJPEG video |

## Troubleshooting
- **Laser does not light:** check it is armed, the Arduino port in `psg.ini` is correct, and the Arduino has the new sketch. The log will show `fire_blocked` if the system refused.
- **Auto-fire does nothing:** it needs a saved calibration, a target inside the calibrated area and outside every zone, and the system armed.
- **Nothing detected:** adjust `detection.ini`, check the lighting, and try the replay clips with `--video`.
- **Crashes at start on Linux with `No module named 'picamera'`:** see step 4 of the install.
- **Port in use:** another copy is still running, or change `Port` in `psg.ini`.

## Repository layout
- `PSG 2021/` - the application, Arduino sketch, web page and test videos
- `tests/` - unit tests for the zone handler (`pip install pytest`, then `python -m pytest tests`)
- `archive/` - earlier prototypes, kept for reference
- `MASTER_FEATURES_LIST.md` - the longer-term feature plan
