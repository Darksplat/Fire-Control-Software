
void flashTimer()
{
if((millis()/1000 - startFlashTimer1sec) < 1){
 textOn1Sec = true; 
}
if((millis()/1000 - startFlashTimer1sec) >= 1){
  textOn1Sec = false;
}
if((millis()/1000 - startFlashTimer1sec) >= 2){
  startFlashTimer1sec = millis()/1000;
}

if((millis() - startFlashTimerHalfSec) < 500){
 textOnHalfSec = true; 
}
if((millis() - startFlashTimerHalfSec) >= 500){
  textOnHalfSec = false;
}
if((millis() - startFlashTimerHalfSec) >= 1000){
  startFlashTimerHalfSec = millis();
}
}

void roundTimer()
{
  if(!blueCaptured && !redCaptured){
  textAlign(CENTER);
  text("Time left in round",width*0.5,height*0.30);
  
  //convert roundTimer to display
  long roundTimerMin = (roundTimer/1000)/60;
  long roundTimerSec = roundTimer/1000;
  
  if(roundStarted == false){
    fill(0,0,0);
    textAlign(CENTER);
    if(roundTimerSec>= 60){
    text(roundTimerMin+ " Min",width*0.5,height*0.30+25);
    }
    if(roundTimerSec < 60){
    text(roundTimerSec+ " Sec",width*0.5,height*0.30+25);
    }
    
  }
  
  if(roundStarted == true){
   roundTimerSec = (roundTimerSec) + ((startRoundTimer/1000) - (millis()/1000));
   roundTimerMin = (roundTimerMin) + ((startRoundTimer/1000)/60 - (millis()/1000)/60);
   if(roundTimerSec <= 0){
    roundStarted = false;
    blueFlag = false;
    redFlag = false;
   }
   
   if((roundTimerSec >= 60) && textOn1Sec){
     
    fill(0,0,0);
    textAlign(CENTER);
    text(roundTimerMin+" Min ",width*0.5,height*0.30+25);
   }
   
   if(roundTimerSec < 60 && textOnHalfSec){
    
    fill(0,0,0);
    textAlign(CENTER);
    text(roundTimerSec+" Sec ",width*0.5,height*0.30+25);
   }
  }
}
if(blueCaptured){
  textAlign(CENTER);
  text("BLUE WINS!!!",width*0.5,height*0.30);
}
if(redCaptured){
  textAlign(CENTER);
  text("RED WIN!!!",width*0.5,height*0.30);
}

}

void captureTimer()
{
  long captureTimerSec = captureTimer/1000;
  
  if(blueFlag && roundStarted){
    activateBlueTurret = false;
    activateRedTurret = true;
    range();
    captureTimerSec = (captureTimerSec) + ((startCaptureTimer/1000) - (millis()/1000));
    
  fill(0,0,0);
  textAlign(CENTER);
  text(captureTimerSec+" Sec", width*0.85,height*0.75);
  
  fill(0,0,0);
  textAlign(CENTER);
  text("DEFEND!", width*0.15,height*0.75);
  
  if(captureTimerSec <= 0){
    println("timer1");
    defend();
   }
  }
  
  if(redFlag && roundStarted){
    activateBlueTurret = true;
    activateRedTurret = false;
    range();
    captureTimerSec = (captureTimerSec) + ((startCaptureTimer/1000) - (millis()/1000));
  
  fill(0,0,0);
  textAlign(CENTER);
  text(captureTimerSec+" Sec", width*0.15,height*0.75);
  
  fill(0,0,0);
  textAlign(CENTER);
  text("DEFEND!", width*0.85,height*0.75);
  
  if(captureTimerSec <= 0){
    println("timer2");
    defend();
  }
  }
  }