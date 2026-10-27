# backend.py
from flask import Flask, Response, request, jsonify
import cv2
import threading

app = Flask(__name__)

# Global states
armed = False
mode = "manual"  # can be: manual, motion, color
zones = []
video_capture = cv2.VideoCapture(0)


def generate_frames():
    while True:
        success, frame = video_capture.read()
        if not success:
            break
        else:
            # Draw existing zones
            for zone in zones:
                x, y, w, h = zone
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)

            # Encode frame as JPEG
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')


@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/toggle_arm', methods=['POST'])
def toggle_arm():
    global armed
    armed = not armed
    return jsonify({"armed": armed})


@app.route('/set_mode', methods=['POST'])
def set_mode():
    global mode
    data = request.get_json()
    mode = data.get("mode", "manual")
    return jsonify({"mode": mode})


@app.route('/zones', methods=['GET', 'POST', 'DELETE'])
def handle_zones():
    global zones
    if request.method == 'GET':
        return jsonify(zones)
    elif request.method == 'POST':
        data = request.get_json()
        new_zone = data.get("zone")
        if new_zone:
            zones.append(tuple(new_zone))
        return jsonify(zones)
    elif request.method == 'DELETE':
        zones.clear()
        return jsonify({"status": "cleared"})


@app.route('/status')
def get_status():
    return jsonify({"armed": armed, "mode": mode, "zones": zones})


if __name__ == '__main__':
    app.run(debug=True)
