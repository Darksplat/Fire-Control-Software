INSTRUCTIONS:

(These instructions assume you have already installed the Processing IDE and Arduino IDE to your 'My Documents' folder.

1) Copy the 'Arduino' and 'Processing' folders to your 'My Documents' folder (or to whichever
	folder 'arduino-1.0.3' and 'processing-1.5.1' are located in). If you already have folders
	called 'Arduino' or 'Processing', then merge these with them.

2) Copy "myron_ezcam.dll" and "DSVL.dll" to the 'processing-1.5.1' folder.

3) Open "Arduino_Turret_06_09.ino" in the Arduino IDE, select the proper type in
	the "#define type" line, and upload it to your Arduino or Standalone controller.
	You only need to do this once ever, so close the Arduino IDE.

4) If you want to use an input device, such as a game controller or joystick, to control the sentry,
	then open "InputDeviceSetupTool.pde" in the Processing IDE. Follow the directions in the 
	comments at the top of the code on how to use this tool. Like uploading the Arduino code,
	you will only need to do this once ever, so close it when you are done.

5) Finally, open "Processing_Turret_06_09.pde" in the Processing IDE. Click run, and the Project
	Sentry Gun code should start up for you. Enjoy!