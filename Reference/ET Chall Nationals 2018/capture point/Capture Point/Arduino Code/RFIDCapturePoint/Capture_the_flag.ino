/*
Each team is to race to the flag and take it back to their home base. Best out of three.
 Need 3 capture points. One flag and a home base for each team.
 Full contact allowed.
 Once the flag is captured the enemy turret is activated and has a chance to defend by shooting at a target range using only the ammunition loaded from the start of the round. 
 
 Turn on Capture points before starting the processing code, all LEDs should be yellow. Once the Capture the flag processing code is started the LEDs will flash red for red team, blue for blue team and white for flag. If they don't then it should be an IP address
 issue or an overall communications issue. The processing code will need to started again or reset pressed. This needs to be correct before starting the round.
 Once the start button is pressed on processing the flag LED will be solid white and the team base LEDs will turn off. Once a team captures the flag the flag LED will turn off and that teams base will flash the respective colour. 
 Only the person with the flag will be able to capture the flag. Once the flag is fully captured all LEDs will be solid on with the colour of the winning team. Processing will need to be reset.
 
 */

void captureTheFlag()
{
  // Initiate
  // if "team capture the flag round" is set, then set flag led white, blue team led blue and red team led red.
  // This needs to be sent from the central computer telling each udp what colour/role it is.  
  // if start countdown command received flash leds for 10 seconds
  // start
  // set homebase leds off and leave flag led on as white


  //************************************
  if(flag){
    
    
    if(!start)
    {
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

    if(start)
    {
      // if not captured LED ON
      // if captured LED OFF and send RFID info to range
      if(!blueCaptured && !redCaptured){  
      whiteLED();
      }
      
      else if(blueCaptured || redCaptured){
        LEDOFF();
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
    
  }

  //*****************************************
  if(blueBase){
    if(!start && !blueCapturedComplete && !redCapturedComplete){
      //flash all leds
      initiateFlash++;
      if(initiateFlash < onTime){
        blueLED();
      }
      if(initiateFlash >= onTime){
        LEDOFF();
      }
      if(initiateFlash > resetTime){
        initiateFlash = 0; 
      }
    }
      
      if(!start && blueCapturedComplete){
          //turn led solid blue 
          blueLED;
        }
        if(!start && redCapturedComplete){
          //turn led solid red 
          redLED;
        }
 

      if(start){
        if(!blueCaptured && !redCaptured && !blueCapturedComplete && !redCapturedComplete){
          LEDOFF();
        }
        
        if(blueCaptured){
          //flash led
          initiateFlash++;
          if(initiateFlash < 5){
            blueLED();
          }
          if(initiateFlash >= 5){
            LEDOFF();
          }
          if(initiateFlash > 10){
            initiateFlash = 0; 
          }
        }
        
      } 
    }
  


  //*******************************************
  if(redBase){
    if(!start && !blueCapturedComplete && !redCapturedComplete){
      //flash all leds
      initiateFlash++;
      if(initiateFlash < onTime){
        redLED();
      }
      if(initiateFlash >= onTime){
        LEDOFF();
      }
      if(initiateFlash > resetTime){
        initiateFlash = 0; 
      }
    }
    if(!start && blueCapturedComplete){
          //turn led solid blue 
          blueLED;
        }
        if(!start && redCapturedComplete){
          //turn led solid red 
          redLED;
        }
    

      if(start){
        if(!blueCaptured && !redCaptured && !blueCapturedComplete && !redCapturedComplete){
          LEDOFF();
        }
        if(redCaptured){
          //flash led
          initiateFlash++;
          if(initiateFlash < 5){
            redLED();
          }
          if(initiateFlash >= 5){
            LEDOFF();
          }
          if(initiateFlash > 10){
            initiateFlash = 0; 
          }
        }
        
        
      }
    }
  }








