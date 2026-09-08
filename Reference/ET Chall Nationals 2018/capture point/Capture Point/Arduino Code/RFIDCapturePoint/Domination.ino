// Timed round. The team with the most points by the end of the round is the winner. If you control a point you gain points for the time
void domination()
{
  //if(pointA){
  if(!start){
    //flash all leds
    initiateFlash++;
    if(initiateFlash < onTime){
      whiteLED();
    }
    if(initiateFlash >= onTime){
      LEDOFF();
    }
    if(initiateFlash > resetTime){
      initiateFlash = 0; 
    }
  }

  if(start){
    // if not captured LED white
    // if captured LED ON as capturing teams colour
    if(!blueCaptured && !redCaptured){
      whiteLED();
    }
    if(blueCaptured && !redCaptured){
      blueLED();
    }
    if(!blueCaptured && redCaptured){
      redLED();
    }
  }

  if(blueCapturedComplete){
    //turn led solid blue
    blueLED(); 
  }
  if(redCapturedComplete){
    //turn led solid red 
    redLED(); 
  }
}




