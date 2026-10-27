void colorDetection() {
  // Begin loop to walk through every pixel
  for (int x = 0; x < cam.width; x ++ ) {
    for (int y = 0; y < cam.height; y ++ ) {
      int pixelLocation = x + y * cam.width;
      // What is current color
      color currentColor = cam.pixels[pixelLocation];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = distSq(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current pixelLocation and current difference
      if (d < sq(pixelThreshold)) {
        if (showDetectedPixels) {
          set(x, y, #39ff14);
          avgX += x;
          avgY += y;
          count++;
        } else {
          avgX += x;
          avgY += y;
          count++;
        }
      }
    }
  }

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (count > 10) { 
   // println("Before Calculation - avgX = ", avgX, "avgY = ", avgY, "Count = ", count);
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel
    fill(255, 0, 0);
    strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 16, 16);
   // println("After Calculation - avgX = ", avgX, "avgY =", avgY);
  } else {
    avgX = 0;
    avgY = 0;
    count = 0;
  }
}
