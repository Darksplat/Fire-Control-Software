//  contributed by Hugo K.

public void EEPROMbackup() {
  if (backup) {

    boolToInt(); // Convert Booleans to Integer for transmission

    //Send String to Arduino         

    println('b' + str(controlMode_i) +';'+ str(safety_i) +';'+ str(firingMode_i) +';'+ str(scanWhenIdle_i) +';'+   // booleans 
    str(trackingMotion_i) +';'+ str(trackingColor_i) +';'+ str(leadTarget_i) +';'+ str(safeColor_i) +';'+
      str(showRestrictedZones_i) +';'+ str(showDifferentPixels_i) +';'+ str(showTargetBox_i) +';'+ 
      str(showCameraView_i) +';'+ str(mirrorCam_i) +';'+ str(soundEffects_i) +';'+

      str(camWidth) +';'+ str(camHeight) +';'+ str(nbDot) +';'+ str(antSens) +';'+  str(minBlobArea) +';'+  // integers 
    str(tolerance) +';'+ str(effect) +';'+ str(trackColorTolerance) +';'+ str(trackColorRed) +';'+  
      str(trackColorGreen) +';'+ str(trackColorBlue) +';'+ str(safeColorMinSize) +';'+
      str(safeColorTolerance) +';'+ str(safeColorRed) +';'+ str(safeColorGreen) +';'+
      str(safeColorBlue) +';'+ str(idleTime) +';'+          

      str(propX) +';'+ str(propY) +';'+ str(xRatio) +';'+ str(yRatio) +';'+      // floats
    str(xMin) +';'+ str(xMax) +';'+ str(yMin) +';'+ str(yMax) +';'+'!');                                                              // floats

    if (!runWithoutArduino) {

      arduinoPort.write('b' + str(controlMode_i) +';'+ str(safety_i) +';'+ str(firingMode_i) +';'+ str(scanWhenIdle_i) +';'+   // booleans 
      str(trackingMotion_i) +';'+ str(trackingColor_i) +';'+ str(leadTarget_i) +';'+ str(safeColor_i) +';'+
        str(showRestrictedZones_i) +';'+ str(showDifferentPixels_i) +';'+ str(showTargetBox_i) +';'+ 
        str(showCameraView_i) +';'+ str(mirrorCam_i) +';'+ str(soundEffects_i) +';'+

        str(camWidth) +';'+ str(camHeight) +';'+ str(nbDot) +';'+ str(antSens) +';'+  str(minBlobArea) +';'+  // integers 
      str(tolerance) +';'+ str(effect) +';'+ str(trackColorTolerance) +';'+ str(trackColorRed) +';'+  
        str(trackColorGreen) +';'+ str(trackColorBlue) +';'+ str(safeColorMinSize) +';'+
        str(safeColorTolerance) +';'+ str(safeColorRed) +';'+ str(safeColorGreen) +';'+
        str(safeColorBlue) +';'+ str(idleTime) +';'+          

        str(propX) +';'+ str(propY) +';'+ str(xRatio) +';'+ str(yRatio) +';'+      // floats
      str(xMin) +';'+ str(xMax) +';'+ str(yMin) +';'+ str(yMax) +';'+'!');                      // send to arduino               


      delay(500);


      // PlaySong ?
    }
    else {
      println("No arduino attached. Cannot do backup to EEPROM.");
    }

    backup = false;
  } 

  if (restore) {

    if (!runWithoutArduino) {
      println('r' + str(111111111)); // We need a string >= 10 char
      arduinoPort.write('r' + str(111111111));   // send to arduino

      // Wait a response from Arduino 
      boolean noContact = true;
      while (noContact) {
        if (arduinoPort.available() > 0) {
          char c = arduinoPort.readChar();	//get the character
          if (c == 'R')	noContact = false;	//if we got a 'R'
          arduinoPort.readChar();                // For \n
        }
      }

      delay(1000);  // let time to Print the String (200 is too much)
      // Check Serial
      boolean receptionOk = false;
      while (! receptionOk) {  // Could be remove
        if (arduinoPort.available() > 0) {

          String inString = arduinoPort.readStringUntil('!');
          if (inString != null) {
            receptionOk = true;
          }
          println(inString);

          // Split The incoming String into Token in a Tab of String   
          if (inString != null) {
            inStringSplit = splitTokens(inString, "; !");
          }
        }
      }  

      // Update Values in Processing    
      decodeInStringSplit();
    }
    else {
      println("No arduino attached. Cannot do a restore from EEPROM.");
    }
    restore = false; 
    // Play Song ?
  }
}


public void saveSettings() {
  backup = true;
}

public void restoreSettings() {
  restore = true;
}

void decodeInStringSplit() {


  // Restore Values

  ////// Booleans   

  delay(50);

  // controlMode 0
  if (int(inStringSplit[0]) != int(controlMode)) {
    controlMode = !controlMode;
    checkbox_controlMode.setSelected(controlMode);
  }

  // safety 1
  if (int(inStringSplit[1]) != int(safety)) {
    safety = !safety;
    checkbox_safety.setSelected(safety);
  }

  // firingMode 2
  if (int(inStringSplit[2]) != int(firingMode)) {
    firingMode = !firingMode;
    dropdown_firingMode.setSelected(int(firingMode));
  }
  // 3 int scanWhenIdle;
  if (int(inStringSplit[3]) != int(scanWhenIdle)) {
    scanWhenIdle = !scanWhenIdle;
    checkbox_scanWhenIdle.setSelected(scanWhenIdle);
  }
  // 4 int trackingMotion;
  if (int(inStringSplit[4]) != int(trackingMotion)) {
    trackingMotion = !trackingMotion;
    checkbox_trackingMotion.setSelected(trackingMotion);
  }
  // 5 int trackingColor;
  if (int(inStringSplit[5]) != int(trackingColor)) {
    trackingColor = !trackingColor;
    checkbox_trackingColor.setSelected(trackingColor);
  }
  // 6 int leadTarget;
  if (int(inStringSplit[6]) != int(leadTarget)) {
    leadTarget = !leadTarget;
    checkbox_leadTarget.setSelected(leadTarget);
  }
  // 7 int safeColor;
  if (int(inStringSplit[7]) != int(safeColor)) {
    safeColor = !safeColor;
    checkbox_safeColor.setSelected(safeColor);
  }
  // 8 int showRestrictedZones;
  if (int(inStringSplit[8]) != int(showRestrictedZones)) {
    showRestrictedZones = !showRestrictedZones;
    checkbox_showRestrictedZones.setSelected(showRestrictedZones);
  }
  // 9 int showDifferentPixels;
  if (int(inStringSplit[9]) != int(showDifferentPixels)) {
    showDifferentPixels = !showDifferentPixels;
    checkbox_showDifferentPixels.setSelected(showDifferentPixels);
  }
  // 10 int showTargetBox;
  if (int(inStringSplit[10]) != int(showTargetBox)) {
    showTargetBox = !showTargetBox;
    checkbox_showTargetBox.setSelected(showTargetBox);
  }
  // 11 int showCameraView;
  if (int(inStringSplit[11]) != int(showCameraView)) {
    showCameraView = !showCameraView;
    checkbox_showCameraView.setSelected(showCameraView);
  }
  // 12 int mirrorCam;
  if (int(inStringSplit[12]) != int(mirrorCam)) {
    mirrorCam = !mirrorCam;
    checkbox_mirrorCam.setSelected(mirrorCam);
  }
  //13 int soundEffects;
  if (int(inStringSplit[13]) != int(soundEffects)) {
    soundEffects = !soundEffects;
    checkbox_soundEffects.setSelected(soundEffects);
  }

  ///// Integers

    // camWidth & camHeight (14 and 15)
  // why doesn't this work? can't figure it out. to fix, see method resizeCamInput() at the bottom of this section of the code

  //  int newCamWidth = int(inStringSplit[14]);      // get stored camWidth value from EEPROM
  //  int newCamHeight = int(inStringSplit[15]);     // get stored camHeight value from EEPROM
  //  if(newCamWidth != camWidth) {                  // if stored dimensions are different, we need to resize camera
  //    camWidth = newCamWidth;
  //    camHeight = newCamHeight;
  //    
  //    resizeCamInput();
  //  }

  //nbDot 16
  nbDot = int(inStringSplit[16]);
  slider_nbDot.setValue(nbDot);

  // 17 int antSens;
  antSens = int(inStringSplit[17]);
  slider_antSens.setValue(nbDot);

  // 18 int minBlobArea;
  minBlobArea = int(inStringSplit[18]);
  slider_minBlobArea.setValue(minBlobArea);

  // 19 int tolerance;
  tolerance = int(inStringSplit[19]);
  slider_tolerance.setValue(tolerance);

  // 20 int effect;
  effect = int(inStringSplit[20]);
  dropdown_effect.setSelected(effect);

  // 21 int trackColorTolerance;
  trackColorTolerance = int(inStringSplit[21]);
  slider_trackColorTolerance.setValue(trackColorTolerance);

  // 22 int trackColorRed;
  trackColorRed = int(inStringSplit[22]);

  // 23 int trackColorGreen;
  trackColorGreen = int(inStringSplit[23]);

  // 24 int trackColorBlue;
  trackColorBlue = int(inStringSplit[24]);

  // 25 int safeColorMinSize;
  safeColorMinSize = int(inStringSplit[25]);
  slider_safeColorMinSize.setValue(safeColorMinSize);

  // 26 int safeColorTolerance;
  safeColorTolerance = int(inStringSplit[26]);
  slider_safeColorTolerance.setValue(safeColorTolerance);

  // 27 int safeColorRed;
  safeColorRed = int(inStringSplit[27]);

  // 28 int safeColorGreen;
  safeColorGreen = int(inStringSplit[28]);

  // 29 int safeColorBlue;
  safeColorBlue = int(inStringSplit[29]);

  // 30 int idleTime; 
  idleTime = int(inStringSplit[30]);    // Hard code

  ////// Floats

  // PropX 31
  slider_propX.setValue(float(inStringSplit[31])); 

  // PropY 32
  slider_propY.setValue(float(inStringSplit[32]));

  // Hard code

  //  33 double xRatio;
  xRatio = float(inStringSplit[33]);
  //  34 double yRatio;
  yRatio = float(inStringSplit[34]);
  //  35 double xMin;
  xMin = float(inStringSplit[35]);
  //  36 double xMax;
  xMax = float(inStringSplit[36]);
  //  37 double yMin;
  yMin = float(inStringSplit[37]);
  //  38 double yMax;
  yMax = float(inStringSplit[38]);
}

boolean backup = false;
boolean restore = false;

void boolToInt() {

  // Convert Booleans to Integer for transmission
  // declarations in Main
  // int controlMode_i, safety_i, firingMode_i, scanWhenIdle_i, trackingMotion_i, trackingColor_i, leadTarget_i, safeColor_i,
  //   showRestrictedZones_i, showDifferentPixels_i, showTargetBox_i, showCameraView_i, mirrorCam_i, soundEffects_i;


  //// Convert Booleans to Integer
  if (controlMode) {
    controlMode_i=1;
  }
  else controlMode_i=0;

  if (safety) {
    safety_i=1;
  }
  else safety_i=0;

  if (firingMode) {
    firingMode_i=1;
  }
  else firingMode_i=0;

  if (scanWhenIdle) {
    scanWhenIdle_i=1;
  }
  else scanWhenIdle_i=0;

  if (trackingMotion) {       
    trackingMotion_i=1;
  }
  else trackingMotion_i=0;

  if (trackingColor) {
    trackingColor_i=1;
  }
  else trackingColor_i=0;

  if (leadTarget) {
    leadTarget_i=1;
  }
  else leadTarget_i=0;

  if (safeColor) {
    safeColor_i=1;
  }
  else safeColor_i=0;

  if (showRestrictedZones) {
    showRestrictedZones_i=1;
  }
  else showRestrictedZones_i=0;

  if (showDifferentPixels) {
    showDifferentPixels_i=1;
  }
  else showDifferentPixels_i=0;

  if (showTargetBox) {
    showTargetBox_i=1;
  }
  else showTargetBox_i=0;

  if (showCameraView) {
    showCameraView_i=1;
  }
  else showCameraView_i=0;

  if (mirrorCam) {
    mirrorCam_i=1;
  }
  else mirrorCam_i=0;

  if (soundEffects) {
    soundEffects_i=1;
  }
  else soundEffects_i=0;
}

public void resizeCamInput() {
  camInput.stop();                          // stop old JMron object
  camInput = new JMyron();                  // make a new JMyron object 
  camInput.start(camWidth, camHeight);      // new camera dimensions
  camInput.findGlobs(0);                    
  camInput.adaptivity(1.01);
  frame.setResizable(true);                 // now we need to resize the frame
  frame.setSize(camWidth, camHeight);        // change the camera dimensions
}

public void retryArduinoConnect() {
  connecting = true;
  if (!runWithoutArduino) {
//    try{
//      arduinoPort.stop();
//    }catch(Exception e) {
//      delay(10);
//    }
    // Find Serial Port that the arduino is on
    // The arduino is sending out a 'T' every 100 millisecs. Contributed by Don K.
    long millisStart;
    int i = 0;
    int len = Serial.list().length;		//get number of ports available
    println(Serial.list());			//print list of ports to screen

    println("Serial Port Count = " + len);	//print count of ports to screen
    if (len == 0) {
      runWithoutArduino = true;
      println("no Arduino detected. Will run without Arduino. Cheers");
    }
    for (i = 0; i < len; i++) {
      println("Testing port " + Serial.list()[i]);
      arduinoPort = new Serial(this, Serial.list()[i], 4800);      // Open 1st port in list
      millisStart = millis();
      while ( (millis () - millisStart) < 2000) ;	//wait for USB port reset (Guessed at 3 secs)
      // can't use delay() call in setup()
      arduinoPort.clear();				// empty buffer(incase of trash)
      arduinoPort.bufferUntil('T');                   //buffer until there is a 'T'
      millisStart = millis();
      while ( (millis () - millisStart) < 100) ;	//collect some chars
      if (arduinoPort.available() > 0)			//if we have a character
      {
        char c = arduinoPort.readChar();	//get the character
        if (c == 'T')				//if we got a 'T'
        {
          break;				//leave for loop
        }
      }
      else 
        arduinoPort.stop();			//if no 'T', stop port
      if (i == len - 1) {
        runWithoutArduino = true;
        println("no Arduino detected. Will run without Arduino. Cheers");
      }
    }
    if (!runWithoutArduino) {
      println("Serial Port used = " + Serial.list()[i]);
      serPortUsed = Serial.list()[i];
      millisStart = millis();
      while ( (millis () - millisStart) < 5000) ;
    }
  }
  connecting = false;
}

