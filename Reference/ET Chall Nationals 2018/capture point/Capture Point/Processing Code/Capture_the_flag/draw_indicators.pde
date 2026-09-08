  void startButton()
  {
  if(!roundStarted && !blueCaptured && !redCaptured){
    fill(0,255,0);
    stroke(0);
    rectMode(CENTER);
    rect(width*0.15,height*0.30,100,40);
    
    fill(0,0,0);
  textAlign(CENTER);
  text("Start",width*0.15,height*0.30+10);
  
  
 if(mousePressed == true && (mouseX > width*0.15-50 &&  mouseX < width*0.15+50 && mouseY > height*0.30-20 && mouseY < height*0.30+20)){
    roundStarted = true;
    startRoundTimer = millis();
    startFlashTimer1sec = millis()/1000;
    startFlashTimerHalfSec = millis();
    udp.send("s", flagIP, portRange);
    println("Start: " +flagIP);
    udp.send("s", blueTeamIP, portRange);
    udp.send("s", redTeamIP, portRange);
  }
 }
}
  
  
  void resetButton()
  {
   if(roundStarted || redCaptured || blueCaptured){ 
  fill(0,0,0);
  stroke(0);
  rectMode(CENTER);
  rect(width*0.85,height*0.30,100,40);
  
  fill(255, 255, 255);
  textAlign(CENTER);
  text("Reset", width*0.85,height*0.30+10);
   
  
  if(mousePressed == true && (mouseX > width*0.85-50 &&  mouseX < width*0.85+50 && mouseY > height*0.30-20 && mouseY < height*0.30+20)){
  fill(200,0,0);
  stroke(0);
  rect(width*0.85,height*0.30,100,40);
  
  udp.send("r", flagIP, portRange);
  udp.send("r", blueTeamIP, portRange);
  udp.send("r", redTeamIP, portRange);
  roundStarted = false;
  blueFlag = false;
  redFlag = false;
  blueCaptured = false;
  redCaptured = false;
  startRoundTimer = 0;
  startCaptureTimer = 0;
  blueCaptureCount = 0;
  redCaptureCount = 0;
  Blue1 = false;
  Blue2 = false;
  Blue3 = false;
  Blue4 = false;
  Red1 = false;
  Red2 = false;
  Red3 = false;
  Red4 = false;
  activateBlueTurret = false;
  activateRedTurret = false;
  designateCapturePoints();
  }

 
  
  if(!roundStarted){
  blueFlag = false;
  redFlag = false;
  startRoundTimer = 0;
  startCaptureTimer = 0;
  activateBlueTurret = false;
  activateRedTurret = false;
  
  blueCaptureCount = 0; // For test buttons
  redCaptureCount = 0; // For test buttons
  }
  }
  }
  
  void designateButton()
  {
  fill(0,0,0);
  stroke(0);
  rectMode(CENTER);
  rect(width*0.85,height*0.40,100,40);
  
  fill(255, 255, 255);
  textAlign(CENTER);
  text("Designate", width*0.85,height*0.40+10);
   
  
  if(mousePressed == true && (mouseX > width*0.85-50 &&  mouseX < width*0.85+50 && mouseY > height*0.40-20 && mouseY < height*0.40+20)){
  fill(200,0,0);
  stroke(0);
  rect(width*0.85,height*0.40,100,40);
  designateCapturePoints();
  }
  
  }
  
  
  void drawFlag()
  {
   // if no one has the flag; fill equals white
  // if red or blue team has the flag; fill flashes the respective teams colour
  if(blueFlag){   
    if(textOnHalfSec){
    fill(0,0,255);
   }
   if(!textOnHalfSec){
    fill(255,255,255); 
   } 
   }
     
  if(redFlag){ 
   if(textOnHalfSec){
    fill(255,0,0);
   }
   if(!textOnHalfSec){
    fill(255,255,255); 
   }
 }
 
 if(blueCaptured){
  fill(0,0,255);
 }
 if(redCaptured){
  fill(255,0,0); 
 }
  if(!redFlag && !blueFlag && !redCaptured && !blueCaptured){
   fill(255,255,255); 
  }
  
  //flag position and shape
  if(!redCaptured && !blueCaptured){  
  rectMode(CENTER);
  rect(width*0.53,height*0.75,100,60);
  
  fill(0,0,0);
  rect(width*0.53-50,height*0.75+30,7,120);
  }
  
  if(redCaptured){
   rectMode(CENTER);
  rect(width*0.21,height*0.65,100,60);
  
  fill(0,0,0);
  rect(width*0.21-50,height*0.65+30,7,120); 
  }
  
  if(blueCaptured){
   rectMode(CENTER);
  rect(width*0.91,height*0.65,100,60);
  
  fill(0,0,0);
  rect(width*0.91-50,height*0.65+30,7,120); 
  }
  }
  
  void drawTeamHomeBases()
  {
    fill(255,0,0);
    rectMode(CENTER);
    rect(width*0.15,height*0.85,100,60);
    
    fill(0,0,255);
    rect(width*0.85,height*0.85,100,60);
  }
  
  void flagCaptured()
  {
   if(redCaptured){
    roundStarted = false;
  }
  
  if(blueCaptured){
    roundStarted = false;
  }
  }
  
  void defend()
  {
    blueFlag = false;
    redFlag = false;
    blueCaptured = false;
    redCaptured = false;
    activateBlueTurret = false;
    activateRedTurret = false;
    udp.send("d", flagIP, portRange);
    udp.send("d", blueTeamIP, portRange);
    udp.send("d", redTeamIP, portRange);
  }
  
  