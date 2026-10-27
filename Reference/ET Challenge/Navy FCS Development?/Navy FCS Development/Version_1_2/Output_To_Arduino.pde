
void sendToArduino(float avgX, float avgY) {
  //String a = "axxxyyyfffs";
  //myPort.write(a);
  int iXDegrees = calculateRotationX(avgX);
  int iYDegrees = calculateRotationY(avgY);
  String strXDegrees = xModifyIntStr(iXDegrees);
  if(invertX){
    strXDegrees = xModifyIntStr(abs(iXDegrees - 180));
  }
  String strYDegrees = yModifyIntStr(iYDegrees);
  if (invertY){
    strYDegrees = yModifyIntStr(abs(iYDegrees - 180));
  }
  //convert that into the arduino turret communication protocole
  String outputPacket = buildPacket(strXDegrees, strYDegrees);
  //package all the infomation into one packet
  println("strXDegrees = ", strXDegrees, "strYDegrees = ", strYDegrees, "avgX = ", avgX, "avgY =", avgY);
  
  if (myPort != null){
    if(arduinoReturnMessage){
    println("outputPacket =", outputPacket);
    myPort.write(outputPacket);
    arduinoReturnMessage = false;
    }
  }
  else{
    setDropDownRed();
  }
  /* for(int i = 0; i< 181; i++){
   float x = cam.width/xAxisServoMaxRotaion;
   println(i, "= ", i*x);
   println(x);
   }*/
}

int calculateRotationX(float avgX) {
  /*  Calculates how many pixels per 1 degree of rotaion is needed to get the turret on target...This is where the calibration will become vital
   as the default setting is unrealistic as in what the camera sees is less than the degrees that the servo turns*/
  float widthPixelsPerDegree = cam.width/xAxisServoMaxRotaion;
  int iXDegrees = (int) Math.floor(round(avgX/widthPixelsPerDegree));
  return iXDegrees;
}
int calculateRotationY(float avgY) {
  /*  Calculates how many pixels per 1 degree of rotaion is needed to get the turret on target...This is where the calibration will become vital
   as the default setting is unrealistic as in what the camera sees is less than the degrees that the servo turns*/
  float heightPixelsPerDegree = cam.height/yAxisServoMaxRotaion;
  int iYDegrees = (int) Math.floor(round(avgY/heightPixelsPerDegree));
  return iYDegrees;
}

String modifyStringLength() {
  return "somthing";
}

String xModifyIntStr(int iXDegrees) {
  String sXDegrees = str(iXDegrees);
  if (sXDegrees.length() == 1) {
    sXDegrees = "00"+sXDegrees;
    //println("Modified sXDegrees = ", sXDegrees);
  } else if (sXDegrees.length() == 2) {
    sXDegrees = "0" + sXDegrees;
    //println("Modified sXDegrees = ", sXDegrees);
  } else if (sXDegrees.length() >= 3) {
    if (iXDegrees > xAxisServoMaxRotaion) {
      println("***Error - Average Above Screen Limits", "iXDegrees = ", iXDegrees, "sXDegrees = ", sXDegrees, "avgX = ", avgX);
      sXDegrees = "000";
      println("Set sXDegrees to '000'");
      //while (true);
    }
   // println("sXDegrees = ", sXDegrees);
  } else {
    sXDegrees = "000";
    println("***Error- ", "iXDegrees = ", iXDegrees, "sXDegrees = ", sXDegrees, "avgX = ", avgX);
  }

  return sXDegrees;
}

String yModifyIntStr(int iYDegrees) {
  String sYDegrees = str(iYDegrees);
  if (sYDegrees.length() == 1) {
    sYDegrees = "00"+sYDegrees;
   // println("Modified sYDegrees = ", sYDegrees);
  } else if (sYDegrees.length() == 2) {
    sYDegrees = "0" + sYDegrees;
   // println("Modified sYDegrees = ", sYDegrees);
  } else if (sYDegrees.length() >= 3) {
    if (iYDegrees > yAxisServoMaxRotaion) {
      println("***Error - Average Above Screen Limits", "iYDegrees = ", iYDegrees, "sYDegrees = ", sYDegrees, "avgY = ", avgY);
      sYDegrees = "000";
      println("Set sYDegrees to '000'");
      //while (true);
    }
   // println("sYDegrees = ", sYDegrees);
  } else {
    sYDegrees = "000";
    println("***Error- ", "iYDegrees = ", iYDegrees, "sYDegrees = ", sYDegrees, "avgY = ", avgX);
  }

  return sYDegrees;
}

String buildPacket(String x, String y) {
  String packet = "a";
  packet = packet + x + y + "000";
  return packet;
}
