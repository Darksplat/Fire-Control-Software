int pastPortSelection = 999; //999 represents that no port has been choosen yet.
int serialPortIndexNumber = 999;//999 represents that no port has been choosen yet.
void serialPorts() {
  updateSerialPorts();
  updateDropDownGUI();
  if (serialGetValue() != 999) {
    serialPortIndexNumber = serialGetValue() - 1;
    OpenSerialPort(serialPortIndexNumber);
  }
  //println(serialGetValue(), startTime, serialTimeout, connectionTimeout(), millis());
}

void updateSerialPorts() {
  serial = Serial.list();
  updateSerialDropDown();
}

void updateDropDownGUI() {
  if (serialGetValue() == 999) {
    setDropDownDefault();
  } else if (connectionTimeout()) {
    setDropDownRed();
  } else if (serialGetValue() > 0 && serialPortIndexNumber != 999) {
    setDropDownGreen();
  }
}

void OpenSerialPort(int portNumber) {
  // Print all serial ports if there is any
  if (portNumber != pastPortSelection) {
    if (pastPortSelection != 999) {
      myPort.stop();
    }
    myPort = new Serial(this, Serial.list()[portNumber], 9600);
    myPort.bufferUntil(35);
    pastPortSelection = portNumber;
  }
}

void serialEvent(Serial myPort) {
  if (myPort.available() > 30) {
    String inString = myPort.readStringUntil(35);
    inString = inString.substring(0, inString.length()-1);
    if (inString != null) {
      println(inString);
      arduinoReturnMessage = true;
      myPort.clear();
    }
      
  }
  setTimeout();
}

boolean connectionTimeout() {
  if (startTime != 0 && millis() >= serialTimeout) {
    return true;
  }
  return false;
}

void setTimeout() {
  startTime = millis(); 
  serialTimeout = startTime + 2000;
}
