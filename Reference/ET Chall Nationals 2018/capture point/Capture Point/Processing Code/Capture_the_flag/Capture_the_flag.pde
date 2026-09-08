import ddf.minim.*;
PImage bannerImage;

String judge = "Turrent14-HP";            // The hostname of the judge PC
int port       = 6000;                    // the destination port for UDP


Minim minim; //audio context


void setup()
{
  UDP_Init();
  
  designateCapturePoints();
  
  size(800,600);
  minim = new Minim(this);
  labelFont = createFont("Georgia",16);
  titleFont = createFont("Georgia",26);
}

void draw()
{
  background(backgroundColour);
   
  textAlign(CENTER);
  fill(#2E6BA7);
  textFont(titleFont);
  text("2018 Engineering Challenge",width/2,(height/20)*1.5);
  text("Capture the flag",width/2,(height/20)*2.5);

  
  drawFlag();
  drawTeamHomeBases();
  roundTimer();
  captureTimer();
  flashTimer(); // on/off timer
  flagCaptured();
  range();
  //testButtons(); // For testing. Uncomment function in "Test_buttons" tab
  startButton();
  resetButton();
  designateButton();
}