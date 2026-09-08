void motionTracking(float avgX, float avgY, int count) {

  // Begin loop to walk through every pixel
  for (int x = 0; x < cam.width; x ++ ) {
    for (int y = 0; y < cam.height; y ++ ) {
      int pixelLocation = x + y * cam.width;
      // What is current color
      color currentColor = cam.pixels[pixelLocation];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      color prevColor = prev.pixels[pixelLocation];
      float r2 = red(prevColor);
      float g2 = green(prevColor);
      float b2 = blue(prevColor);

      // Using euclidean distance to compare colors
      float d = distSq(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      boolean trackingAssist = false;
      if (x > (motionX - 50) && x < (motionX + 50) && y > (motionY-50) && y < (motionY + 50)) {
        d += sq(pixelThreshold-110)*0.7;
        trackingAssist = true;
      }
      if (d > sq(pixelThreshold-110)) {
        // set(x, y, #39ff14);
        avgX += x;
        avgY += y;
        count++;
        if (trackingAssist) {
          if (showDetectedPixels) {
            set(x, y, #39ff14);
          }
        } else {
          if (showDetectedPixels) {
            set(x, y, #ffffff);
          }
        }
      } else {
        if (showDetectedPixels) {
          set(x, y, #000000);
        }
      }
    }
  }
  //updatePixels();
  if (count > 250) { 
    motionX = avgX / count;
    motionY = avgY / count;
  }
  // Draw a circle at the tracked pixel
  fill(255, 0, 255);
  strokeWeight(4);
  stroke(0);
  ellipse(motionX, motionY, 16, 16);
  if (showDetectedPixels) {
    image(cam, 0, 0, 160, 120);
  }
}