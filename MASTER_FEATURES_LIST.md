🔫 Project Sentry Gun – Master Systems Plan
Modular, GUI-based, touchscreen-friendly sentry gun platform powered by Raspberry Pi + Pico W

🛠️ HARDWARE COMPONENTS
Core Processors
Raspberry Pi 5 (x3)
Fire Control GUI + Targeting
Vision AI Processing
Testbed / Target Simulation
Raspberry Pi Pico W
Real-time servo and laser/trigger control (used for testing)
Raspberry Pi Pico W 2
Final microcontroller upgrade (more robust control)
Sensors & Input Devices
USB / Pi Camera: Video feed for OpenCV (motion/color detection)
HC-SR04 Rangefinder: Distance measurement
IMU (Optional): Stabilization or predictive motion
Temperature Sensor (Optional): Monitoring Pi or laser temperature
PS4/Xbox Controller: Joystick or D-pad for manual aim
Big Red Arm Switch: Hardware toggle for arming system
Emergency Kill Switch: Optional override for safety
LED Indicators: Status for arm, scan, fire
Piezo Buzzer: Arming and alert audio
Motion & Actuation
MG996R Servo
Torque: 9–10 kg.cm @ 6V
~120° rotation
Cost-effective
DS3218 Digital Servo
Torque: 20 kg.cm @ 6.8V
180° rotation
Higher torque and smoother control
Weapons / Laser Interface
KY-008 Laser Module: Basic targeting, ON/OFF only
TTL Laser Module (e.g., NEJE 405nm)
TTL-compatible, safe GPIO control
Logic-Level N-channel MOSFETs (e.g., IRLZ44N)
Power switching for laser and servos
Power Supply
18650 Battery Pack (2S/3S/4S with BMS)
DC-DC Buck Converters (MP1584 or LM2596): Voltage regulation
Capacitors: 470µF electrolytic + 0.1µF ceramic for smoothing
Fuse: Overcurrent protection
Wiring: 18–22 AWG with JST or screw connectors
PCB or Perfboard: For final build and prototyping
Optional support for network-controlled PTZ cameras or webcams that support MJPEG streams.
Raspberry Pi or Jetson Nano as a self-contained server device (if not using a desktop).
Power/data for embedded web control system (could run locally or serve wirelessly).
Updates:
Emphasize modularity: webcams, servos, and GPIO components are connected to a headless host (RPi/Nano) and not bound to local display.


         +-------------------------+
                 |  Raspberry Pi 5 (Main)  |
                 |   - OpenCV Detection    |
                 |   - GUI + Touchscreen   |
                 +-----------+-------------+
                             |
                             | USB / UART
                             v
                   +---------+---------+
                   |     Pico W (MCU)  |
                   |  - Servo Control  |
                   |  - Laser Trigger  |
                   |  - Safety Logic   |
                   +----+--------+-----+
                        |        |
                        |        |
                   [Servo X]  [Servo Y]  ← DS3218 or MG996R
                        |
                   +----+-----+
                   |  MOSFET  | ← Controls TTL Laser / Ballistic Firing
                   +----+-----+
                        |
                 [TTL-Compatible Laser]



🧰 MICROCONTROLLER FIRMWARE (PICO W)
Responsibilities
PWM generation for servo control
TTL or MOSFET switching for lasers/triggers
Handling ARM/Disarm logic via GPIO
Communication with Pi 5 via UART or WiFi
Rangefinder handling and filtering
Control Logic
State machine: IDLE, SCANNING, TARGET LOCK, FIRE
Watchdog for emergency kill and overtemp
Movement calibration routines for servos
Servo preset memory
Hardware Interface
Decoupled with optoisolated input if needed
Debounced physical switch inputs
GPIO-based LED/buzzer status outputs

💻 SOFTWARE (PI 5)
Targeting & Tracking
OpenCV-based Modes
Motion detection
Color tracking
Distance filtering with rangefinder
Scan Mode (Aliens-style)
Sweeping movement and sound feedback
Safe-To-Fire Zones (STFZ)
Define blacklisted areas on screen
Game Mode
Bubbles program for visual target training
Rendered targets on screen
Laser detection or motion recognition for hits
Scoring, timing, and session logging
Controller Input
Integration of PS4/Xbox joystick for manual override
Mapping: Stick for X/Y, button for fire, triggers for mode swap
Sound Effects
Custom WAVs for arming, scanning, target lock, fire
Additions:
FastAPI or Flask REST API server to:
Control armed/disarmed state
Load/save Safe-To-Fire Zones (STFZs)
Set operation mode (motion, color, manual)
Toggle firing system
MJPEG streaming endpoint for live camera feed
Endpoints Sample:
Method
Endpoint
Purpose
GET
/video_feed
Live stream of camera
POST
/zones
Add a new zone
GET
/zones
Get all STFZs
DELETE
/zones/:id
Remove a zone
POST
/set_mode
Switch between modes
POST
/fire
Manually fire
POST
/arm_toggle
Toggle armed mode




📊 GUI DESIGN & FEATURES
Overview
Touchscreen-friendly design
Modular layout with toggles, sliders, and buttons
Key GUI Modules
Servo Control Panel
X and Y sliders with calibration presets
Arm/Disarm Toggle
Linked to both software and hardware switches
Mode Selector
Motion vs. Color
Feedback Panel
LED status (software mirroring physical LEDs)
Rangefinder feedback
Score/Target Module
For Bubble game mode
Visual Feed Integration
Live camera stream with overlay
STFZ zones marked
Target reticle displayed
Major Overhaul:
New Features:
Web-based layout (HTML + CSS + JS)
Live video with overlaid STFZs using <canvas> or SVG
Drawing interface for zones (mouse drag = box)
Toggle buttons for:
Arming/disarming
Mode selection (motion/color/manual)
Saving/loading zones
Mobile-friendly layout with touch support
Suggested Tech Stack:
Static HTML/CSS/JS for the frontend
Optionally: React or Vue.js if you want component reusability
HTMX or Alpine.js for lightweight dynamic interactions

Networking / Remote Access
Additions:
HTTP-based interface accessible on LAN
Optional authentication layer for safety (e.g., token-based)
mDNS support for http://sentry.local access
Security & Safety System
Updates:
Safety toggle must be visible on web UI
Optional two-step confirm to fire (toggle + click fire)
STFZ logic handled server-side, so clients can’t override it easily
Optional password or admin lock to prevent remote tampering

Logging and Debugging
Additions:
Add /log API or UI section showing:
Zone violations
Fire events
Mode changes
Manual override activity
Optional CSV/JSON log export

Deployment & Hosting
Additions:
Runs on local machine or embedded device (Raspberry Pi)
systemd service or Docker container for auto-start
Separate "development" and "deployment" configs for ports, debug flags, etc.


🧱 DESIGN & PROTOTYPING PRACTICES
Use KiCad or Eagle for PCB design (2-layer minimum)
Include test points, mounting holes, and silkscreen labels
Isolate high current and sensitive digital traces
Standardize on JST/Screw connectors for modularity
Use heat shrink, strain relief, and proper fuse rating
Breadboard for initial tests, perfboard for stage 2
Label wiring clearly, maintain a pinout reference doc


