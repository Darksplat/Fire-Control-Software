🔫 Project Sentry Gun – Master Systems Plan
Modular, GUI-based, touchscreen-friendly sentry gun platform powered by Raspberry Pi + Pico W



🛠️ HARDWARE COMPONENTS
Core Processors
	•	Raspberry Pi 5 (x3)
	◦	Fire Control GUI + Targeting
	◦	Vision AI Processing
	◦	Testbed / Target Simulation
	•	Raspberry Pi Pico W
	◦	Real-time servo and laser/trigger control (used for testing)
	•	Raspberry Pi Pico W 2
	◦	Final microcontroller upgrade (more robust control)
Sensors & Input Devices
	•	USB / Pi Camera: Video feed for OpenCV (motion/color detection)
	•	HC-SR04 Rangefinder: Distance measurement
	•	IMU (Optional): Stabilization or predictive motion
	•	Temperature Sensor (Optional): Monitoring Pi or laser temperature
	•	PS4/Xbox Controller: Joystick or D-pad for manual aim
	•	Big Red Arm Switch: Hardware toggle for arming system
	•	Emergency Kill Switch: Optional override for safety
	•	LED Indicators: Status for arm, scan, fire
	•	Piezo Buzzer: Arming and alert audio
Motion & Actuation
	•	MG996R Servo
	◦	Torque: 9–10 kg.cm @ 6V
	◦	~120° rotation
	◦	Cost-effective
	•	DS3218 Digital Servo
	◦	Torque: 20 kg.cm @ 6.8V
	◦	180° rotation
	◦	Higher torque and smoother control
Weapons / Laser Interface
	•	KY-008 Laser Module: Basic targeting, ON/OFF only
	•	TTL Laser Module (e.g., NEJE 405nm)
	◦	TTL-compatible, safe GPIO control
	•	Logic-Level N-channel MOSFETs (e.g., IRLZ44N)
	◦	Power switching for laser and servos
Power Supply
	•	18650 Battery Pack (2S/3S/4S with BMS)
	•	DC-DC Buck Converters (MP1584 or LM2596): Voltage regulation
	•	Capacitors: 470µF electrolytic + 0.1µF ceramic for smoothing
	•	Fuse: Overcurrent protection
	•	Wiring: 18–22 AWG with JST or screw connectors
	•	PCB or Perfboard: For final build and prototyping

🧱 BLOCK DIAGRAM (text-based)

                +-------------------------+
                 |  Raspberry Pi 5 (Main)  |
                 |   - OpenCV Detection    |
                 |   - GUI + Touchscreen   |
                 +-----------+-------------+
                             |
                             | USB / UART
                             v
                   +---------+---------+
                   |     Pico W (MCU)  |
                   |  - Servo Control  |
                   |  - Laser Trigger  |
                   |  - Safety Logic   |
                   +----+--------+-----+
                        |        |
                        |        |
                   [Servo X]  [Servo Y]  ← DS3218 or MG996R
                        |
                   +----+-----+
                   |  MOSFET  | ← Controls TTL Laser / Ballistic Firing
                   +----+-----+
                        |
                 [TTL-Compatible Laser]

🧰 MICROCONTROLLER FIRMWARE (PICO W)
Responsibilities
	•	PWM generation for servo control
	•	TTL or MOSFET switching for lasers/triggers
	•	Handling ARM/Disarm logic via GPIO
	•	Communication with Pi 5 via UART or WiFi
	•	Rangefinder handling and filtering
Control Logic
	•	State machine: IDLE, SCANNING, TARGET LOCK, FIRE
	•	Watchdog for emergency kill and overtemp
	•	Movement calibration routines for servos
	•	Servo preset memory
Hardware Interface
	•	Decoupled with optoisolated input if needed
	•	Debounced physical switch inputs
	•	GPIO-based LED/buzzer status outputs



💻 SOFTWARE (PI 5)
Targeting & Tracking
	•	OpenCV-based Modes
	◦	Motion detection
	◦	Color tracking
	◦	Distance filtering with rangefinder
	•	Scan Mode (Aliens-style)
	◦	Sweeping movement and sound feedback
	•	Safe-To-Fire Zones (STFZ)
	◦	Define blacklisted areas on screen
Game Mode
	•	Bubbles program for visual target training
	◦	Rendered targets on screen
	◦	Laser detection or motion recognition for hits
	◦	Scoring, timing, and session logging
Controller Input
	•	Integration of PS4/Xbox joystick for manual override
	•	Mapping: Stick for X/Y, button for fire, triggers for mode swap
Sound Effects
	•	Custom WAVs for arming, scanning, target lock, fire



📊 GUI DESIGN & FEATURES
Overview
	•	Touchscreen-friendly design
	•	Modular layout with toggles, sliders, and buttons
Key GUI Modules
	•	Servo Control Panel
	◦	X and Y sliders with calibration presets
	•	Arm/Disarm Toggle
	◦	Linked to both software and hardware switches
	•	Mode Selector
	◦	Motion vs. Color
	•	Feedback Panel
	◦	LED status (software mirroring physical LEDs)
	◦	Rangefinder feedback
	•	Score/Target Module
	◦	For Bubble game mode
Visual Feed Integration
	•	Live camera stream with overlay
	•	STFZ zones marked
	•	Target reticle displayed



🧱 DESIGN & PROTOTYPING PRACTICES
	•	Use KiCad or Eagle for PCB design (2-layer minimum)
	•	Include test points, mounting holes, and silkscreen labels
	•	Isolate high current and sensitive digital traces
	•	Standardize on JST/Screw connectors for modularity
	•	Use heat shrink, strain relief, and proper fuse rating
	•	Breadboard for initial tests, perfboard for stage 2
	•	Label wiring clearly, maintain a pinout reference doc


