# main.py
import cv2
import json
from stfz_handler import STFZHandler

# Initialize STFZ handler
stfz = STFZHandler(config_file='config.json')
stfz.load_zones()

# Dummy target box for testing (x, y, w, h)
target_box = (100, 100, 50, 50)

# Camera setup
cap = cv2.VideoCapture(0)

# Mouse callback state
drawing = False
ix, iy = -1, -1
new_zone = None

def mouse_draw(event, x, y, flags, param):
    global drawing, ix, iy, new_zone

    if event == cv2.EVENT_LBUTTONDOWN:
        drawing = True
        ix, iy = x, y

    elif event == cv2.EVENT_MOUSEMOVE:
        if drawing:
            new_zone = (ix, iy, x, y)

    elif event == cv2.EVENT_LBUTTONUP:
        drawing = False
        x0, y0 = min(ix, x), min(iy, y)
        x1, y1 = max(ix, x), max(iy, y)
        width = x1 - x0
        height = y1 - y0
        stfz.add_zone((x0, y0, width, height))
        new_zone = None

cv2.namedWindow("Video")
cv2.setMouseCallback("Video", mouse_draw)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Draw existing STFZ zones
    frame = stfz.draw_zones(frame)

    # Draw in-progress zone
    if new_zone:
        x0, y0, x1, y1 = new_zone
        cv2.rectangle(frame, (x0, y0), (x1, y1), (0, 0, 255), 1)

    # Draw dummy target box
    tx, ty, tw, th = target_box
    cv2.rectangle(frame, (tx, ty), (tx+tw, ty+th), (0, 255, 0), 2)

    # Check if target in STFZ
    in_zone = stfz.is_target_in_zone(target_box)
    if in_zone:
        cv2.putText(frame, "IN STFZ - DO NOT FIRE", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 2)
    else:
        cv2.putText(frame, "CLEAR - CAN FIRE", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)

    cv2.imshow("Video", frame)
    key = cv2.waitKey(1) & 0xFF

    if key == ord('q'):
        break
    elif key == ord('c'):
        stfz.clear_zones()
    elif key == ord('s'):
        stfz.save_zones()

cap.release()
cv2.destroyAllWindows()
