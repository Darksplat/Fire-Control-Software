# backend.py
from fastapi import FastAPI, Request, Response
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import cv2
import threading
import time
import io
from stfz_handler import STFZHandler

app = FastAPI()

# Allow frontend from any origin (for dev; tighten later)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# State variables
stfz = STFZHandler(config_file='config.json')
stfz.load_zones()
armed = False
mode = "manual"  # manual, motion, color

target_box = (100, 100, 50, 50)  # dummy target for now

# Camera setup
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

def gen_frames():
    global target_box
    while True:
        success, frame = cap.read()
        if not success:
            break
        frame = cv2.resize(frame, (1280, 720))

        # Draw zones
        frame = stfz.draw_zones(frame)

        # Draw target
        tx, ty, tw, th = target_box
        cv2.rectangle(frame, (tx, ty), (tx+tw, ty+th), (0, 255, 0), 2)

        # Draw status text
        if armed:
            in_zone = stfz.is_target_in_zone(target_box)
            status_text = "IN STFZ - DO NOT FIRE" if in_zone else "CLEAR - CAN FIRE"
            color = (0, 0, 255) if in_zone else (0, 255, 0)
            cv2.putText(frame, status_text, (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

        # Encode frame
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.get("/video_feed")
def video_feed():
    return StreamingResponse(gen_frames(), media_type="multipart/x-mixed-replace; boundary=frame")

@app.get("/zones")
def get_zones():
    return JSONResponse(content=stfz.get_all_zones())

@app.post("/zones")
def add_zone(zone: dict):
    box = (zone["x"], zone["y"], zone["w"], zone["h"])
    stfz.add_zone(box)
    return {"message": "Zone added."}

@app.delete("/zones/{zone_id}")
def delete_zone(zone_id: int):
    try:
        stfz.remove_zone(zone_id)
        return {"message": f"Zone {zone_id} removed."}
    except Exception as e:
        return JSONResponse(status_code=400, content={"error": str(e)})

@app.post("/arm_toggle")
def toggle_arm():
    global armed
    armed = not armed
    return {"armed": armed}

@app.post("/set_mode")
def set_mode(request: Request):
    global mode
    data = await request.json()
    mode = data.get("mode", "manual")
    return {"mode": mode}

@app.post("/fire")
def fire():
    if not armed:
        return JSONResponse(status_code=400, content={"error": "System not armed."})
    # Fire logic here (GPIO or Arduino)
    return {"message": "FIRE!"}

@app.get("/status")
def get_status():
    return {"armed": armed, "mode": mode, "zone_count": len(stfz.zones)}
