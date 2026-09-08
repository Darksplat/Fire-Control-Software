 //Comment/uncomment below code when testing/not testing

void testButtons()
{
  if(roundStarted){
  
  // capture blue
  if(redCaptureCount < 1){
  fill(0,0,255);
  stroke(0);
  rectMode(CENTER);
  rect(width*0.5,height*0.50,100,40);
  
  if(mouseClicked && mousePressed && (mouseX > width*0.5-50 &&  mouseX < width*0.5+50 && mouseY > height*0.50-20 && mouseY < height*0.50+20)){
    mouseClicked = false;
    blueCaptureCount++;
    redCaptureCount = 0;
    delay(50);
  if(blueCaptureCount == 1){
    
      blueFlag = true;
      redFlag = false;
      blueCaptured = false;
      redCaptured = false;
      startCaptureTimer = millis();
      }
      if(blueCaptureCount == 2){
      blueFlag = false;
      redFlag = false;
      blueCaptured = true;
      redCaptured = false;
      } 
  }
  
  fill(255, 255, 255);
  textAlign(CENTER);
  text("Capture", width*0.5,height*0.50+10);
  }
  // capture red
  if(blueCaptureCount < 1){ 
  fill(255,0,0);
  stroke(0);
  rectMode(CENTER);
  rect(width*0.5,height*0.60,100,40);
  
 
  if(mouseClicked && mousePressed && (mouseX > width*0.5-50 &&  mouseX < width*0.5+50 && mouseY > height*0.60-20 && mouseY < height*0.60+20)){
    mouseClicked = false;
    redCaptureCount++;
    blueCaptureCount = 0;
   
    //delay(50);
    
    if(redCaptureCount == 1){
      blueFlag = false;
      redFlag = true;
      blueCaptured = false;
      redCaptured = false;
      startCaptureTimer = millis();
      }
      if(redCaptureCount == 2){
      blueFlag = false;
      redFlag = false;
      blueCaptured = false;
      redCaptured = true;
      } 
  }
  
  
  fill(255, 255, 255);
  textAlign(CENTER);
  text("Capture", width*0.5,height*0.60+10);
}
  }
//Defend
if(roundStarted && (blueFlag || redFlag)){
  
    
  if(blueFlag){
  fill(255,0,0);
  }
  if(redFlag){
   fill(0,0,255); 
  }
  stroke(0);
  rectMode(CENTER);
  rect(width*0.5,height*0.40,100,40);
  
  if(mousePressed == true && (mouseX > width*0.5-50 &&  mouseX < width*0.5+50 && mouseY > height*0.40-20 && mouseY < height*0.40+20)){
   // mouseClicked();
    blueCaptureCount = 0;
    redCaptureCount = 0;  
    blueFlag = false;
      redFlag = false;
      blueCaptured = false;
      redCaptured = false;
  }
  
  fill(255, 255, 255);
  textAlign(CENTER);
  text("Defend", width*0.5,height*0.40+10);
}

}

void mouseClicked(){
 
  mouseClicked = true; 
}