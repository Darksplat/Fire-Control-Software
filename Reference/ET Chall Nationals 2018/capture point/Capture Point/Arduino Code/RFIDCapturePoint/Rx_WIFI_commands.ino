/*

 LIST OF COMMANDS
 
 'r' = reset
 's' = start
 'd' = defend
 'C' = Capture the flag
 'D' = Domination
 'I' = Infiltrate
 'F' = Flag
 'B' = Blue base
 'R' = Red base
 
 '1' = blue1
 '2' = blue2
 '3' = blue3
 '4' = blue4
 
 '5' = red1
 '6' = red2
 '7' = red3
 '8' = red4
 
 */

void receiveWifiCommands()
{
  if(Serial.available())
  {
    rxChar = Serial.read();
    Serial.flush();

    if(rxChar == 'r' && CTF) //********************* Reset Capture the flag
    { 
      start = false;
      blue1 = false;
      blue2 = false;
      blue3 = false;
      blue4 = false;
      red1 = false;
      red2 = false;
      red3 = false;
      red4 = false;
      blueCaptured = false;
      redCaptured = false;
      blueCapturedComplete = false;
      redCapturedComplete = false;
      Serial.print("Reset");  
    }
    
    if(rxChar == 'r' && DOM) //********************* Reset Domination
    { 
      start = false;
      blueCaptured = false;
      redCaptured = false;
      blueCapturedComplete = false;
      redCapturedComplete = false;
      Serial.print("Reset");  
    }

    if(rxChar == 'd' && start) //************************** Defend
    { 
      blue1 = false;
      blue2 = false;
      blue3 = false;
      blue4 = false;
      red1 = false;
      red2 = false;
      red3 = false;
      red4 = false;
      blueCaptured = false;
      redCaptured = false;
      blueCapturedComplete = false;
      redCapturedComplete = false;
      Serial.print("Defend");
      rfidReadString = "";
    }

    if(rxChar == 's' && !start) //********************** Start
    { 
      start = true;
      Serial.print("Start");
    }


    if(rxChar == 'C' && !CTF){
      CTF = true; // Capture The Flag
      DOM = false; // Domination
      INF = false; // Infiltrate
      Serial.print("CTF Set");  
}

    if(rxChar == 'D' && !DOM){
      CTF = false; // Capture The Flag
      DOM = true; // Domination
      INF = false; // Infiltrate
      Serial.print("DOM Set");
  }

    if(rxChar == 'I' && !INF){
      CTF = false; // Capture The Flag
      DOM = false; // Domination
      INF = true; // Infiltrate
      Serial.print("INF Set");
    }
  }
  
  if(rxChar == 'a' && !pointA){
      pointA = true;
      pointB = false;
      pointC = false;
    }
      if(rxChar == 'b' && !pointB){
      pointA = false;
      pointB = true;
      pointC = false;
      }
        if(rxChar == 'c' && !pointC){
      pointA = false;
      pointB = false;
      pointC = true;
        }

  // designate role
  if(rxChar == 'F' && !flag){
    redBase = false;
    blueBase = false;
    flag = true;
    Serial.print("Flag");
  }

  if(rxChar == 'B' && !blueBase){
    redBase = false;
    blueBase = true;
    flag = false;
    Serial.print("Blue base");
  }

  if(rxChar == 'R' && !redBase){
    redBase = true;
    blueBase = false;
    flag = false;
    Serial.print("Red Base");
  }

  if(start && CTF){
    if(rxChar == '1' && !blue1){
      blue1 = true;
      blueCaptured = true;
      Serial.print("Blue 1 Captured"); 
    }
    if(rxChar == '2' && !blue2){
      blue2 = true;
      blueCaptured = true;
      Serial.print("Blue 2 Captured"); 
    }
    if(rxChar == '3' && !blue3){
      blue3 = true;
      blueCaptured = true;
      Serial.print("Blue 3 Captured"); 
    }
    if(rxChar == '4' && !blue4){
      blue4 = true;
      blueCaptured = true;
      Serial.print("Blue 4 Captured"); 
    }
    if(rxChar == '5' && !red1){
      red1 = true;
      redCaptured = true;
      Serial.print("Red 1 Captured"); 
    }
    if(rxChar == '6' && !red2){
      red2 = true;
      redCaptured = true;
      Serial.print("Red 2 Captured"); 
    }
    if(rxChar == '7' && !red3){
      red3 = true;
      redCaptured = true;
      Serial.print("Red 3 Captured"); 
    }
    if(rxChar == '8' && !red4){
      red4 = true;
      redCaptured = true;
      Serial.print("Red 4 Captured"); 
    }
  }
}



