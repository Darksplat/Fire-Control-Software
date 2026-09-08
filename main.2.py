import cv2
import numpy as np
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk

# --- Configuration ---
video_width = 1280
video_height = 720

# --- State Variables ---
armed = False
detection_mode = "motion"  # or "color"
motion_sensitivity = 30
color_sensitivity = 30
tracking_hsv_color = None
avg_frame = None

# --- Initialize Camera ---
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, video_width)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, video_height)

# Fallback frame if something fails
current_frame = np.zeros((video_height, video_width, 3), dtype=np.uint8)

# --- UI Setup ---
root = tk.Tk()
root.title("Fire-Control")
root.configure(bg="black")

# --- Helper Functions ---
def toggle_arm():
    global armed
    armed = not armed
    arm_status_label.config(
        text="ARMED" if armed else "DISARMED",
        fg="red" if armed else "green"
    )
    print("🔒 System ARMED" if armed else "🔓 System DISARMED")

def toggle_mode(mode):
    global detection_mode
    detection_mode = mode
    print(f"🌀 Switched to {mode.upper()} detection")
    update_status_bar()

def update_motion_sensitivity(val):
    global motion_sensitivity
    motion_sensitivity = int(float(val))
    print(f"🎛 Motion Sensitivity: {motion_sensitivity}")
    update_status_bar()

def update_color_sensitivity(val):
    global color_sensitivity
    color_sensitivity = int(float(val))
    print(f"🎛 Color Sensitivity: {color_sensitivity}")
    update_status_bar()

def update_status_bar():
    status_text = f"MODE: {detection_mode.upper()} | ARM: {'YES' if armed else 'NO'} | MSENS: {motion_sensitivity} | CSENS: {color_sensitivity}"
    status_label.config(text=status_text)

def quit_app():
    print("👋 Quitting app...")
    root.quit()
    cap.release()
    cv2.destroyAllWindows()

def select_color(event):
    global tracking_hsv_color
    x = event.x
    y = event.y
    if 0 <= x < video_width and 0 <= y < video_height:
        frame = current_frame.copy()
        if frame is not None:
            hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
            pixel = hsv[y, x]
            tracking_hsv_color = pixel
            print(f"🖌️ Selected HSV color: {pixel}")
        else:
            print("⚠️ No frame to sample from")

def detect_motion(gray):
    global avg_frame
    frame_delta = cv2.absdiff(gray, cv2.convertScaleAbs(avg_frame))
    thresh = cv2.threshold(frame_delta, motion_sensitivity, 255, cv2.THRESH_BINARY)[1]
    dilated = cv2.dilate(thresh, None, iterations=2)
    contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def detect_color_areas(frame):
    if tracking_hsv_color is None:
        return []

    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    h, s, v = map(int, tracking_hsv_color)

    lower_bound = np.array([
        max(h - 10, 0),
        max(s - color_sensitivity, 50),
        max(v - color_sensitivity, 50)
    ], dtype=np.uint8)

    upper_bound = np.array([
        min(h + 10, 179),
        min(s + color_sensitivity, 255),
        min(v + color_sensitivity, 255)
    ], dtype=np.uint8)

    mask = cv2.inRange(hsv, lower_bound, upper_bound)
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.erode(mask, kernel, iterations=1)
    mask = cv2.dilate(mask, kernel, iterations=2)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    return contours


def update_video():
    global avg_frame, current_frame

    ret, frame = cap.read()
    if not ret or frame is None:
        print("⚠️ Failed to grab frame")
        root.after(10, update_video)
        return

    frame = cv2.resize(frame, (video_width, video_height))
    current_frame = frame.copy()

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    if avg_frame is None or avg_frame.shape != gray.shape:
        avg_frame = gray.astype("float32")
        print("✅ avg_frame initialized")
    else:
        cv2.accumulateWeighted(gray, avg_frame, 0.5)

    if armed:
        if detection_mode == "motion":
            contours = detect_motion(gray)
            if contours:
                largest = max(contours, key=cv2.contourArea)
                if cv2.contourArea(largest) > 500:
                    x, y, w, h = cv2.boundingRect(largest)
                    cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 255, 0), 2)
        elif detection_mode == "color":
            contours = detect_color_areas(frame)
            for cnt in contours:
                if cv2.contourArea(cnt) > 300:
                    x, y, w, h = cv2.boundingRect(cnt)
                    cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 255), 2)

    # Draw current selected color (top-left swatch)
    if tracking_hsv_color is not None:
        swatch = np.full((50, 50, 3), fill_value=0, dtype=np.uint8)
        bgr_color = cv2.cvtColor(np.uint8([[tracking_hsv_color]]), cv2.COLOR_HSV2BGR)[0][0]
        swatch[:] = bgr_color
        frame[10:60, 10:60] = swatch

    img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    img = Image.fromarray(img)
    imgtk = ImageTk.PhotoImage(image=img)
    video_label.imgtk = imgtk
    video_label.configure(image=imgtk)

    root.after(10, update_video)

# --- GUI Layout ---

video_label = tk.Label(root)
video_label.pack()
video_label.bind("<Button-1>", select_color)

controls_frame = tk.Frame(root, bg="black")
controls_frame.pack(pady=10)

tk.Button(controls_frame, text="Motion Mode", command=lambda: toggle_mode("motion"),
          bg="#444", fg="black", font=("Arial", 12), width=12).grid(row=0, column=0, padx=5)
tk.Button(controls_frame, text="Color Mode", command=lambda: toggle_mode("color"),
          bg="#444", fg="black", font=("Arial", 12), width=12).grid(row=0, column=1, padx=5)
tk.Button(controls_frame, text="Arm / Disarm", command=toggle_arm,
          bg="#222", fg="black", font=("Arial", 12), width=12).grid(row=0, column=2, padx=5)
tk.Button(controls_frame, text="Quit", command=quit_app,
          bg="red", fg="black", font=("Arial", 12, "bold"), width=12).grid(row=0, column=3, padx=5)

# Sliders
tk.Label(controls_frame, text="Motion Sensitivity", bg="black", fg="yellow").grid(row=1, column=0, columnspan=2)
motion_slider = tk.Scale(controls_frame, from_=10, to=100, orient=tk.HORIZONTAL, command=update_motion_sensitivity,
                         bg="black", fg="white", troughcolor="#888")
motion_slider.set(motion_sensitivity)
motion_slider.grid(row=2, column=0, columnspan=2, pady=5)

tk.Label(controls_frame, text="Color Sensitivity", bg="black", fg="yellow").grid(row=1, column=2, columnspan=2)
color_slider = tk.Scale(controls_frame, from_=10, to=100, orient=tk.HORIZONTAL, command=update_color_sensitivity,
                        bg="black", fg="white", troughcolor="#888")
color_slider.set(color_sensitivity)
color_slider.grid(row=2, column=2, columnspan=2, pady=5)

# Status frame
status_frame = tk.Frame(root, bg="black")
status_frame.pack(fill=tk.X)

arm_status_label = tk.Label(status_frame, text="DISARMED", fg="green", bg="black", font=("Arial", 14, "bold"))
arm_status_label.pack(side=tk.LEFT, padx=10)

status_label = tk.Label(status_frame, text="", fg="yellow", bg="black", font=("Arial", 10))
status_label.pack(side=tk.RIGHT, padx=10)

update_status_bar()
update_video()
root.mainloop()
