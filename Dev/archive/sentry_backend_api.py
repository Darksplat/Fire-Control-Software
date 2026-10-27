# backend.py
from collections import deque
from datetime import datetime, timezone
from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
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


class Zone(BaseModel):
    x: int
    y: int
    w: int
    h: int


# State variables
stfz = STFZHandler(config_file='config.json')
stfz.load_zones()
armed = False
mode = "manual"  # manual, motion, color
event_log = deque(maxlen=500)
last_zone_violation = False

target_box = (100, 100, 50, 50)  # dummy target for now

# Camera setup
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)


def log_event(event_type: str, details: dict | None = None) -> None:
    event_log.append({
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "type": event_type,
        "details": details or {},
    })

def gen_frames():
    global last_zone_violation, target_box
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
        in_zone = stfz.is_target_in_zone(target_box)
        if armed:
            status_text = "IN STFZ - DO NOT FIRE" if in_zone else "CLEAR - CAN FIRE"
            color = (0, 0, 255) if in_zone else (0, 255, 0)
            cv2.putText(frame, status_text, (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

        if in_zone != last_zone_violation:
            last_zone_violation = in_zone
            if in_zone:
                log_event("zone_violation", {"target_box": target_box})
            else:
                log_event("zone_clear", {"target_box": target_box})

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
def add_zone(zone: Zone):
    stfz.add_zone((zone.x, zone.y, zone.w, zone.h))
    stfz.save_zones()
    log_event("zone_added", {"zone": zone.model_dump()})
    return {"message": "Zone added."}


@app.delete("/zones")
def clear_zones():
    stfz.clear_zones()
    stfz.save_zones()
    log_event("zones_cleared")
    return {"message": "Zones cleared."}

@app.delete("/zones/{zone_id}")
def delete_zone(zone_id: int):
    try:
        removed = stfz.remove_zone(zone_id)
        stfz.save_zones()
        log_event("zone_removed", {"zone_id": zone_id, "zone": removed})
        return {"message": f"Zone {zone_id} removed."}
    except IndexError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@app.post("/zones/save")
def save_zones():
    stfz.save_zones()
    log_event("zones_saved", {"count": len(stfz.zones)})
    return {"message": "Zones saved."}


@app.post("/zones/load")
def load_zones():
    stfz.load_zones()
    log_event("zones_loaded", {"count": len(stfz.zones)})
    return {"message": "Zones loaded.", "count": len(stfz.zones)}

@app.post("/arm_toggle")
def toggle_arm():
    global armed
    armed = not armed
    log_event("arm_toggle", {"armed": armed})
    return {"armed": armed}

@app.post("/set_mode")
async def set_mode(request: Request):
    global mode
    data = await request.json()
    mode = data.get("mode", "manual")
    log_event("mode_change", {"mode": mode})
    return {"mode": mode}

@app.post("/fire")
def fire():
    if not armed:
        log_event("fire_blocked", {"reason": "not_armed"})
        return JSONResponse(status_code=400, content={"error": "System not armed."})
    # Fire logic here (GPIO or Arduino)
    log_event("fire", {"mode": mode})
    return {"message": "FIRE!"}

@app.get("/status")
def get_status():
    return {
        "armed": armed,
        "mode": mode,
        "zone_count": len(stfz.zones),
        "last_violation": last_zone_violation,
    }


@app.get("/log")
def get_log():
    return {"events": list(event_log)}


@app.delete("/log")
def clear_log():
    event_log.clear()
    log_event("log_cleared")
    return {"message": "Log cleared."}
