
import processing.video.*;

Capture cam;
PImage prev;
import controlP5.*;
ControlP5 cp5;

Textlabel myTextlabelA;
Textlabel myTextlabelB;
Slider Distance;
Slider Threshold;


Slider sliderYmax;
Slider sliderYmin;
int yAxisServoMaxLimit = 0;//Initialize Y Servo With the 
int yAxisServoMinLimit = 0;

Slider sliderXmax;
Slider sliderXmin;
int xAxisServoMaxLimit = 0;
int xAxisServoMinLimit = 0;

CheckBox checkbox;

boolean showDetectedPixels = true;
boolean colorMode = true;
boolean invertX = false;
boolean invertY = false;
int xAxisServoMaxRotaion = 180;//sets the X Axis servo command limits
int yAxisServoMaxRotaion = 180;//sets the Y Axis servo command limits


int trackColor = 0;
int lastClosestX = 0;
int lastClosestY = 0;
float pixelThreshold = 100;

float motionX = 0;
float motionY = 0;

void setup() {
  size(1000, 600);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[1]);
    cam.start();
    prev = createImage(640, 480, RGB);
  }      

  initializeGUI();
}



void draw() {

  background(51);  
  
  float avgX = 0;
  float avgY = 0;
  int count = 0;
  
  image(cam, 0, 0);
  if (colorMode) {
    colorDetection(avgX, avgY, count);
  }
  else {
  prev.loadPixels();
  motionTracking(avgX, avgY, count);
}
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable  
  if (mouseX <= cam.width && mouseY <= cam.height)
  {   
    int pixelLocation = mouseX + mouseY*cam.width;
 
    trackColor = cam.pixels[pixelLocation];
    println(trackColor);
    println(red(trackColor), green(trackColor), blue(trackColor));
  } else
  {
    println("Mouse Click Was Not On Capture Area");
  }
}

void captureEvent(Capture cam) {
  prev.copy(cam, 0, 0, cam.width, cam.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  cam.read();
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2){
  float d = sq(x2-x1) + sq(y2-y1) + sq(z2-z1);
  return d;
}