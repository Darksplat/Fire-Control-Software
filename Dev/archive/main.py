import tkinter as tk
from tkinter import ttk
import cv2
from PIL import Image, ImageTk
import numpy as np

# Initialize video capture
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

# Globals
is_armed = False
mode = "motion"
motion_sensitivity = 30
color_sensitivity = 30
tracking_hsv_color = None
avg_frame = None

# New settings
brightness = 0
contrast = 1.0
gamma = 1.0

def apply_brightness_contrast_gamma(frame):
    global brightness, contrast, gamma
    frame = cv2.convertScaleAbs(frame, alpha=contrast, beta=brightness)
    if gamma != 1.0:
        inv_gamma = 1.0 / gamma
        table = np.array([((i / 255.0) ** inv_gamma) * 255 for i in np.arange(256)]).astype("uint8")
        frame = cv2.LUT(frame, table)
    return frame

def toggle_arm():
    global is_armed
    is_armed = not is_armed
    arm_status_label.config(text="ARMED" if is_armed else "DISARMED",
                            fg="red" if is_armed else "green")

def toggle_mode(selected_mode):
    global mode
    mode = selected_mode
    mode_label.config(text=f"Mode: {mode.upper()}")

def update_motion_sensitivity(val):
    global motion_sensitivity
    motion_sensitivity = int(float(val))
    motion_sensitivity_label.config(text=f"Motion Sensitivity: {motion_sensitivity}")

def update_color_sensitivity(val):
    global color_sensitivity
    color_sensitivity = int(float(val))
    color_sensitivity_label.config(text=f"Color Sensitivity: {color_sensitivity}")

def update_brightness(val):
    global brightness
    brightness = int(float(val))
    brightness_label.config(text=f"Brightness: {brightness}")

def update_contrast(val):
    global contrast
    contrast = float(val)
    contrast_label.config(text=f"Contrast: {contrast:.2f}")

def update_gamma(val):
    global gamma
    gamma = float(val)
    gamma_label.config(text=f"Gamma: {gamma:.2f}")

def reset_adjustments():
    brightness_slider.set(0)
    contrast_slider.set(1.0)
    gamma_slider.set(1.0)

def select_color(event):
    global tracking_hsv_color
    x, y = event.x, event.y
    if frame is not None and x < frame.shape[1] and y < frame.shape[0]:
        selected_bgr = frame[y, x]
        tracking_hsv_color = cv2.cvtColor(np.uint8([[selected_bgr]]), cv2.COLOR_BGR2HSV)[0][0]
        print(f"🖌️ Selected HSV color: {tracking_hsv_color}")

def detect_color_areas(frame):
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    sensitivity = color_sensitivity
    lower_bound = np.array([
        max(tracking_hsv_color[0] - sensitivity, 0),
        max(tracking_hsv_color[1] - sensitivity, 50),
        max(tracking_hsv_color[2] - sensitivity, 50)
    ], dtype=np.uint8)
    upper_bound = np.array([
        min(tracking_hsv_color[0] + sensitivity, 179),
        min(tracking_hsv_color[1] + sensitivity, 255),
        min(tracking_hsv_color[2] + sensitivity, 255)
    ], dtype=np.uint8)
    mask = cv2.inRange(hsv, lower_bound, upper_bound)
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_DILATE, kernel)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def update_video():
    global frame, avg_frame
    ret, frame = cap.read()
    if not ret:
        root.after(10, update_video)
        return

    frame = apply_brightness_contrast_gamma(frame)
    display_frame = frame.copy()

    if is_armed:
        if mode == "motion":
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray = cv2.GaussianBlur(gray, (21, 21), 0)
            if avg_frame is None:
                avg_frame = gray.copy().astype("float")
            cv2.accumulateWeighted(gray, avg_frame, 0.5)
            frame_delta = cv2.absdiff(gray, cv2.convertScaleAbs(avg_frame))
            thresh = cv2.threshold(frame_delta, motion_sensitivity, 255, cv2.THRESH_BINARY)[1]
            thresh = cv2.dilate(thresh, None, iterations=2)
            contours, _ = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            motion_boxes = [cv2.boundingRect(c) for c in contours if cv2.contourArea(c) >= 500]
            if motion_boxes:
                x_min = min([x for (x, y, w, h) in motion_boxes])
                y_min = min([y for (x, y, w, h) in motion_boxes])
                x_max = max([x + w for (x, y, w, h) in motion_boxes])
                y_max = max([y + h for (x, y, w, h) in motion_boxes])
                cv2.rectangle(display_frame, (x_min, y_min), (x_max, y_max), (0, 255, 255), 2)

        elif mode == "color" and tracking_hsv_color is not None:
            contours = detect_color_areas(frame)
            for c in contours:
                (x, y, w, h) = cv2.boundingRect(c)
                cv2.rectangle(display_frame, (x, y), (x + w, y + h), (255, 0, 255), 2)

    if tracking_hsv_color is not None:
        selected_bgr = cv2.cvtColor(np.uint8([[tracking_hsv_color]]), cv2.COLOR_HSV2BGR)[0][0]
        cv2.rectangle(display_frame, (10, 10), (60, 60), selected_bgr.tolist(), -1)

    img = cv2.cvtColor(display_frame, cv2.COLOR_BGR2RGB)
    img = Image.fromarray(img)
    imgtk = ImageTk.PhotoImage(image=img)
    video_label.imgtk = imgtk
    video_label.configure(image=imgtk)
    root.after(10, update_video)

def quit_app():
    print("👋 Quitting app...")
    cap.release()
    root.destroy()

# GUI setup
root = tk.Tk()
root.title("Fire Control System")

video_label = tk.Label(root)
video_label.pack()
video_label.bind("<Button-1>", select_color)

controls_frame = tk.Frame(root, bg="black")
controls_frame.pack(pady=10)

button_font = ("Arial", 12)
tk.Button(controls_frame, text="Motion Mode", command=lambda: toggle_mode("motion"),
          bg="#444", fg="black", font=button_font, width=12).grid(row=0, column=0, padx=5)
tk.Button(controls_frame, text="Color Mode", command=lambda: toggle_mode("color"),
          bg="#444", fg="black", font=button_font, width=12).grid(row=0, column=1, padx=5)
tk.Button(controls_frame, text="Arm / Disarm", command=toggle_arm,
          bg="#222", fg="black", font=button_font, width=12).grid(row=0, column=2, padx=5)
tk.Button(controls_frame, text="Quit", command=quit_app,
          bg="red", fg="black", font=("Arial", 12, "bold"), width=12).grid(row=0, column=3, padx=5)

status_frame = tk.Frame(root, bg="black")
status_frame.pack()

arm_status_label = tk.Label(status_frame, text="DISARMED", fg="green", bg="black", font=("Arial", 12))
arm_status_label.grid(row=0, column=0, padx=10)
mode_label = tk.Label(status_frame, text="Mode: MOTION", fg="yellow", bg="black", font=("Arial", 12))
mode_label.grid(row=0, column=1, padx=10)

sliders_frame = tk.Frame(root, bg="black")
sliders_frame.pack(pady=10)

motion_sensitivity_label = tk.Label(sliders_frame, text=f"Motion Sensitivity: {motion_sensitivity}", fg="yellow", bg="black")
motion_sensitivity_label.grid(row=0, column=0, padx=5)
tk.Scale(sliders_frame, from_=1, to=100, orient="horizontal", command=update_motion_sensitivity).grid(row=0, column=1)

color_sensitivity_label = tk.Label(sliders_frame, text=f"Color Sensitivity: {color_sensitivity}", fg="yellow", bg="black")
color_sensitivity_label.grid(row=1, column=0, padx=5)
tk.Scale(sliders_frame, from_=1, to=100, orient="horizontal", command=update_color_sensitivity).grid(row=1, column=1)

brightness_label = tk.Label(sliders_frame, text=f"Brightness: {brightness}", fg="yellow", bg="black")
brightness_label.grid(row=2, column=0)
brightness_slider = tk.Scale(sliders_frame, from_=-100, to=100, orient="horizontal", command=update_brightness)
brightness_slider.set(brightness)
brightness_slider.grid(row=2, column=1)

contrast_label = tk.Label(sliders_frame, text=f"Contrast: {contrast}", fg="yellow", bg="black")
contrast_label.grid(row=3, column=0)
contrast_slider = tk.Scale(sliders_frame, from_=0.5, to=3.0, resolution=0.1, orient="horizontal", command=update_contrast)
contrast_slider.set(contrast)
contrast_slider.grid(row=3, column=1)

gamma_label = tk.Label(sliders_frame, text=f"Gamma: {gamma}", fg="yellow", bg="black")
gamma_label.grid(row=4, column=0)
gamma_slider = tk.Scale(sliders_frame, from_=0.1, to=3.0, resolution=0.1, orient="horizontal", command=update_gamma)
gamma_slider.set(gamma)
gamma_slider.grid(row=4, column=1)

reset_button = tk.Button(sliders_frame, text="Reset Adjustments", command=reset_adjustments,
                         bg="#333", fg="black", font=("Arial", 10))
reset_button.grid(row=5, column=0, columnspan=2, pady=10)

update_video()
root.mainloop()
