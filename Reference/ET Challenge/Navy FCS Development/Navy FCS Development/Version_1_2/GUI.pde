void initializeGUI() {
  cp5 = new ControlP5(this);

  cp5.addSlider("sliderYmax")
    .setPosition(725, 5)
    .setSize(30, 540)
    .setRange(0, yAxisServoMaxRotaion)
    .setValue(0)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(0);

  cp5.addSlider("sliderYmin")
    .setPosition(665, 5)
    .setSize(30, 540)
    .setRange(0, yAxisServoMaxRotaion)
    .setValue(0)
    //.setNumberOfTickMarks(180)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(0);

  cp5.addSlider("sliderXmin")
    .setPosition(10, 500)
    .setSize(250, 30)
    .setRange(0, xAxisServoMaxRotaion)
    .setValue(0)
    //.setNumberOfTickMarks(180)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(0);

  cp5.addSlider("sliderXmax")
    .setPosition(350, 500)
    .setSize(250, 30)
    .setRange(0, xAxisServoMaxRotaion)
    .setValue(0)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(0);

  cp5.addSlider("Threshold")
    .setPosition(800, 150)
    .setSize(40, 300)
    .setRange(0, 100)
    .setValue(25)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(2);

  cp5.addSlider("Distance")
    .setPosition(900, 150)
    .setSize(40, 300)
    .setRange(0, 50)
    .setValue(10)
    .setSliderMode(Slider.FLEXIBLE)
    .setDecimalPrecision(0);

  cp5.addCheckBox("checkBox")
    .setPosition(800, 20)
    .setSize(40, 40)
    .setItemsPerRow(2)
    .setSpacingColumn(60)
    .setSpacingRow(30)
    .addItem("INVERT X", 0)
    .addItem("INVERT Y", 50)
    .addItem("Movement/Colour Track", 100)
    .toggle(2);

  cp5.addCheckBox("displayDetectedPixels")
    .setPosition(800, 500)
    .setSize(40, 40)
    .setItemsPerRow(2)
    .setSpacingColumn(60)
    .setSpacingRow(30)
    .addItem("Display Detected Pixels", 0)
    .toggle(0);


  myTextlabelA = cp5.addTextlabel("Program Name")
    .setText(" FIRE CONTROL - **Under Development**")
    .setPosition(0, 570)
    .setColorValue(0xffffff00)
    .setFont(createFont("Georgia", 20));

  myTextlabelB = cp5.addTextlabel("Version")
    .setText("Version V1.2")
    .setPosition(800, 570)
    .setColorValue(0xffffff00)
    .setFont(createFont("Georgia", 18));
}

void Distance(int distance) {
  println("Distance " + distance);
}

void Threshold(float threshold) {
  println("Threshold " + threshold);
  pixelThreshold = threshold;
}

void sliderYmax() {
  int maxY = (int) Math.floor(cp5.getController("sliderYmax").getValue());
  yAxisServoMaxLimit = (int) Math.floor(constrain(maxY, yAxisServoMinLimit, 180));
  if (maxY != yAxisServoMaxLimit) {
    cp5.getController("sliderYmax").setValue(yAxisServoMaxLimit);
  }
  println("yAxisServoMaxLimit = " + yAxisServoMaxLimit);
  println("yAxisServoMinLimit = " + yAxisServoMinLimit);
}

void sliderYmin() {
  int minY = (int) Math.floor(cp5.getController("sliderYmin").getValue());
  yAxisServoMinLimit = (int) Math.floor(constrain(minY, 0, yAxisServoMaxLimit));
  if (minY != yAxisServoMinLimit) {
    cp5.getController("sliderYmin").setValue(yAxisServoMinLimit);
  }
  println("yAxisServoMaxLimit = " + yAxisServoMaxLimit);
  println("yAxisServoMinLimit = " + yAxisServoMinLimit);
}

void sliderXmax() {
  int maxX = (int) Math.floor(cp5.getController("sliderXmax").getValue());
  xAxisServoMaxLimit = (int) Math.floor(constrain(maxX, xAxisServoMinLimit, 180));
  if (maxX != xAxisServoMaxLimit) {
    cp5.getController("sliderXmax").setValue(xAxisServoMaxLimit);
  }
  println("xAxisServoMaxLimit = " + xAxisServoMaxLimit);
  println("xAxisServoMinLimit = " + xAxisServoMinLimit);
}

void sliderXmin() {
  int minX = (int) Math.floor(cp5.getController("sliderXmin").getValue());
  xAxisServoMinLimit = (int) Math.floor(constrain(minX, 0, xAxisServoMaxLimit));
  if (minX != xAxisServoMinLimit) {
    cp5.getController("sliderXmin").setValue(xAxisServoMinLimit);
  }
  println("xAxisServoMaxLimit = " + xAxisServoMaxLimit);
  println("xAxisServoMinLimit = " + xAxisServoMinLimit);
}

void checkBox(float[] list) {
  invertX =  list[0] != 0.0f;
  println("Invert X = " + invertX);
  invertY = list[1] != 0.0f;
  println("Invert Y = " + invertY);
  colorMode = list[2] != 0.0f;
}

void displayDetectedPixels(float[] list) {
  showDetectedPixels =  list[0] != 0.0f;
}
