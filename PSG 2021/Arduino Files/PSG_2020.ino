/*
  -------------------- Project Sentry Gun --------------------
  ============================================================
  ----- An Open-Source Project, initiated by Bob Rudolph -----
*/

/* Help & Reference: http://projectsentrygun.rudolphlabs.com/make-your-own
  Forum: http://projectsentrygun.rudolphlabs.com/forum

  This is a heavily modified version of the file programming credit goes to Jason 'TEO' Etheridge
  @jasonetheridge, I just imspired and tested - Jeremy Younger @darksplat

  ATTACHMENT INSTRUCTIONS: (for using an Arduino board)
  attach x-axis (pan) standard servo to digital I/O pin 8
  attach y-axis (tilt) standard servo to digital I/O pin 9
  attach USB indicator LED to digital pin 11
  attach firing indicator LED to digital I/O pin 12
  attach reloading switch to digital I/O pin 3 (low-active: when on, connects pin to GND)
  attach diable plate momentary button to digital I/O pin 2 (low-active: when on, connects pin to GND)
  attach electric trigger MOSFET circuit to digital I/O pin 7

  adjust the values below to the values that work for your gun:

*/
//   <=========================================================================>
//   Begin custom values - change these servo positions to work with your turret
//   <=========================================================================>

//   <=========================================================================>
//                      End custom values
//   <=========================================================================>

int panServoPin = 8;              // Arduino pin for pan servo
int tiltServoPin = 9;             // Arduino pin for tilt servo
int USBIndicatorLEDPin = 14;      // Arduino pin for USB indicator LED
int electricTriggerPin = 7;       // Arduino pin for output to trigger MOSFET

#include <Servo.h>

Servo pan;                            // x axis servo
Servo tilt;                           // y axis servo

int pan_position = 90;
int tilt_position = 90;
int fire = 0;                         // if 1, fire; else, don't fire

void setup() {
  pan.attach(panServoPin);             // set up the x axis servo
  tilt.attach(tiltServoPin);           // set up the y axis servo

  pinMode(electricTriggerPin, OUTPUT);     // electric trigger, set as output
  ceaseFire();

  pinMode(USBIndicatorLEDPin, OUTPUT);        // set up USB indicator LED

  Serial.begin(9600);                     // start communication with computer
}

void loop() {
  // Check to see if a new set of commands is available
  if (Serial.available() < 8) {
    // Back to waiting...
    delay(25);
    return;
  }

  // Read first byte in buffer
  byte indicator = Serial.read();

  // Check for 'a' (indicates start of message)
  if (indicator != 'a') {
    // We keep looking for the start of the message
    return;
  }

  // Light up the USB indicator LED to indicate we're processing a message
  digitalWrite(USBIndicatorLEDPin, HIGH);

  // Read the message, byte by byte
  byte pan100_byte = Serial.read();
  byte pan010_byte = Serial.read();
  byte pan001_byte = Serial.read();
  byte tilt100_byte = Serial.read();
  byte tilt010_byte = Serial.read();
  byte tilt001_byte = Serial.read();
  byte fire_byte = Serial.read();

  // If any of the bytes failed to be read (indicated by Serial.read()
  // returning -1), we ignore and wait for another 8 bytes
  if (pan100_byte < 0 || pan010_byte < 0 || pan001_byte < 0 ||
      tilt100_byte < 0 || tilt010_byte < 0 || tilt001_byte < 0 ||
      fire_byte < 0) {

    digitalWrite(USBIndicatorLEDPin, LOW);
    return;
  }

  // Decode those message bytes into two 3-digit numbers

  int updated_pan_position =
    (100 * ((int)pan100_byte - 48)) +
    (10  * ((int)pan010_byte - 48)) +
    (       (int)pan001_byte - 48);

  int updated_tilt_position =
    (100 * ((int)tilt100_byte - 48)) +
    (10  * ((int)tilt010_byte - 48)) +
    (       (int)tilt001_byte - 48);

  // Convert byte to integer
  fire = (int)fire_byte - 48;

  if (updated_pan_position != pan_position || updated_tilt_position != tilt_position) {
    pan_position = updated_pan_position;
    tilt_position = updated_tilt_position;

    // Stop firing so we can move
    ceaseFire();

    pan.write(pan_position);
    tilt.write(tilt_position);
  }

  if (fire) {
    // Wait to give the servos time to move, otherwise they will be blocked!
    delay(100);
    Fire();
  } else {
    ceaseFire();
  }

  digitalWrite(USBIndicatorLEDPin, LOW);
  delay(50);
}

void Fire() {
  // TTL laser, so active when low
  digitalWrite(electricTriggerPin, LOW);
}

void ceaseFire() {
  digitalWrite(electricTriggerPin, HIGH);
}
