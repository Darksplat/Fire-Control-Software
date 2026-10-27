// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/r0lvsMPGEoY

class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;
      
  int id = 0;
  
  boolean taken = false;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }
    
  void show() {
    stroke(0);
    fill(255, 100);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);
    
    
        textAlign(LEFT);

    textSize(18);
    fill(255, 0, 0);
    text("TARGET ACQUIRED",20,20);

    
        textAlign(CENTER);

    fill(0);
    //text(id, minx + (maxx-minx)*0.5, maxy - 10);
    
    
     textSize(14);
    text("X:",20,40);
    
    float x=(maxx - minx)* 0.5 + minx;
    float y=(maxy - miny)* 0.5 + miny;

    text((maxx - minx)* 0.5 + minx,60,40);
     
 text("Y:",120,40);
    text((maxy - miny)* 0.5 + miny,160,40);
     

   stroke(255);
   strokeWeight(10);

   point((maxx - minx)* 0.5 + minx,(maxy - miny)* 0.5 + miny);
   
                     //if we clicked in the window
  // myPort.write('X');         //send a 1
  //myPort.write('\n');         //send a 1

    x=map(x,640,0,0,127);
    y=map(y,480,0,0,127);

   byte bytex=byte(x);
   
      byte bytey=byte(y);

   
   println(bytey);


   myPort.write(Integer.toString(bytex));         //send a 1
   myPort.write('x');
   
   myPort.write(Integer.toString(bytey));         //send a 1
   myPort.write('y');
 
    myPort.write('f');

 
 print("x-");
   print(Integer.toString(bytex));
   
    print(" y-");
   println(Integer.toString(bytey));
   
   
 
 
    
  }
  


  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }
  
  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }
  
  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x,y); 
  }

  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
