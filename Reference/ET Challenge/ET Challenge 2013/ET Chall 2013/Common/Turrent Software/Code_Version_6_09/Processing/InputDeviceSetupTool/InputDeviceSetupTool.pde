/*

---------- Project Sentry Gun:  INPUT DEVICE SETUP TOOL ----------
==================================================================
-------- An Open-Source Project, initiated by Bob Rudolph --------
   
Last updated January 2, 2013.
 
Help & Reference: http://projectsentrygun.rudolphlabs.com/make-your-own/using-the-software
Forum: http://projectsentrygun.rudolphlabs.com/forum

Description: 
Run this code before your run the main code (Processing_Turret_06_09.pde). This is a separate peice of Processing code, that
you only need to run once. It will let you set up your control scheme for an input device (such as a USB game
controller or joystick), and will save your control scheme to a file that is then used every time you run the main code.


Instructions:
1) Make sure you have installed the drivers for your input device (game controller, joystick, etc).
2) Plug in the input device.
3) Run this sketch. A window will appear.
4) Select your input device from the drop-down menu in the window. The device's buttons and sliders should appear in the window.
5) Press some of the buttons and move the control sticks. Watch the indicators in the window to verify that it is working properly.
6) For each button and slider (each slider is one axis of a joystick), select an Action from the drop-down menu.
7) When you are finished, click "Save & Exit".
8) Click "Show Sketch Folder" in the "Sketch" menu of the Processing IDE. This should bring up the '\Processing\InputDeviceSetupTool' folder.
10) Copy "settings_inputDevice.txt" from the '\Processing\InputDeviceSetupTool' folder to '\Processing\Processing_Turret_06_09\data' folder.
11) Open and run the main code (Processing_Turret_06_09.pde). The "Use Joystick/Game Controller" checkbox should now work.


*/



import procontroll.*;
import net.java.games.input.*;
import guicomponents.*;


public ControllIO controlIO;         // stuff for using a joystick or game controller for input
public ControllDevice tryDevice;
public ControllDevice inputDevice;

public ControllButton button_00;
public ControllButton button_01;
public ControllButton button_02;
public ControllButton button_03;
public ControllButton button_04;
public ControllButton button_05;
public ControllButton button_06;
public ControllButton button_07;
public ControllButton button_08;
public ControllButton button_09;
public ControllButton button_10;
public ControllButton button_11;
public ControllButton button_12;
public ControllButton button_13;
public ControllButton button_14;
public ControllButton button_15;
public ControllButton button_16;
public ControllButton button_17;
public ControllButton button_18;
public ControllButton button_19;
public ControllButton button_20;
public ControllButton button_21;
public ControllButton button_22;
public ControllButton button_23;
public ControllButton button_24;
public ControllButton button_25;
public ControllButton button_26;
public ControllButton button_27;
public ControllButton button_28;
public ControllButton button_29;

public ControllSlider slider_00;
public ControllSlider slider_01;
public ControllSlider slider_02;
public ControllSlider slider_03;
public ControllSlider slider_04;
public ControllSlider slider_05;
public ControllSlider slider_06;
public ControllSlider slider_07;
public ControllSlider slider_08;
public ControllSlider slider_09;


GPanel panel_main; // control panel

GCombo dropdown_whichDevice;

GButton saveButton;

GCombo button_00_action, button_01_action, button_02_action, button_03_action, button_04_action, button_05_action, button_06_action, button_07_action, button_08_action, button_09_action;
GCombo button_10_action, button_11_action, button_12_action, button_13_action, button_14_action, button_15_action, button_16_action, button_17_action, button_18_action, button_19_action;
GCombo button_20_action, button_21_action, button_22_action, button_23_action, button_24_action, button_25_action, button_26_action, button_27_action, button_28_action, button_29_action;

GLabel button_00_pressed, button_01_pressed, button_02_pressed, button_03_pressed, button_04_pressed, button_05_pressed, button_06_pressed, button_07_pressed, button_08_pressed, button_09_pressed;
GLabel button_10_pressed, button_11_pressed, button_12_pressed, button_13_pressed, button_14_pressed, button_15_pressed, button_16_pressed, button_17_pressed, button_18_pressed, button_19_pressed;
GLabel button_20_pressed, button_21_pressed, button_22_pressed, button_23_pressed, button_24_pressed, button_25_pressed, button_26_pressed, button_27_pressed, button_28_pressed, button_29_pressed;

GWSlider slider_00_value, slider_01_value, slider_02_value, slider_03_value, slider_04_value, slider_05_value, slider_06_value, slider_07_value, slider_08_value, slider_09_value;
GCombo slider_00_action, slider_01_action, slider_02_action, slider_03_action, slider_04_action, slider_05_action, slider_06_action, slider_07_action, slider_08_action, slider_09_action;


int whichDevice = 0;
String[] list_devices = new String[20];
int numDevices = 0;
int numButtons = 0;
int numSliders = 0;

String[] list_button_actions = {
  "No Action", "Fire", "Precise Aim", "Center Gun", "Auto Aim On", "Auto Aim Off", "Input Dev On/Off", "Random Sound"
};
String[] list_slider_actions = {
  "No Action", "Pan", "Tilt", "Pan (Invert)", "Tilt (Invert)"
};


void setup() {
  size(800, 600);

  controlIO = ControllIO.getInstance(this);

  // controlIO.printDevices();
  numDevices = controlIO.getNumberOfDevices();
  for (int i = 0; i < numDevices; i++) {
    tryDevice = controlIO.getDevice(i);
    list_devices[i] = tryDevice.getName();
    tryDevice.close();
  }
  list_devices[numDevices] = "Select Input Device";

  G4P.setColorScheme(this, GCScheme.GREEN_SCHEME);
  G4P.messagesEnabled(false);

  // create Panels
  panel_main = new GPanel(this, "Main", 0, 0, width, height);
  panel_main.setOpaque(false);
  panel_main.setCollapsed(false);

  // createCombos (dropdown boxes)
  dropdown_whichDevice = new GCombo(this, list_devices, list_devices.length, 10, 10, 200);        // this, String[] of entries, dropdown # of enteries shown at once, xPosition, yPosition, width
  dropdown_whichDevice.setSelected(numDevices);                                                  // which entry to show as selected (first entry is 0, second is 1, etc.)
  panel_main.add(dropdown_whichDevice);

  saveButton = new GButton(this, "Save & Exit", 710, 570, 80, 20);
}



void draw() {
  background(150);

  updateAllButtonsAndSliders();
}


public void handleComboEvents(GCombo combo) {
  if (combo == dropdown_whichDevice) {
    whichDevice = dropdown_whichDevice.selectedIndex();
    if (whichDevice != numDevices) { // user has selected a dropdown entry that is not "Select Input Device"
      closeDevice();
      openNewDevice(whichDevice);
    }
    else {
      closeDevice();
    }
  }
}

public void handleButtonEvents(GButton button) {
  if (button == saveButton) {
    print("Saving settings... ");
    saveSettings();
    println("Settings saved.");
    closeDevice();
    exit();
  }
}

void saveSettings() {
  // tag
  String[] saveData = new String[49];
  saveData[0] = "========================================";
  saveData[1] = "---------------- Device ----------------";
  saveData[2] = dropdown_whichDevice.selectedText();
  saveData[3] = "";

  saveData[4] = "========================================";
  saveData[5] = "--------------- Buttons ----------------";
  if (button_00_action != null) {
    saveData[6] = button_00_action.selectedText();
  }
  else {
    saveData[6] = "";
  }
  if (button_01_action != null) {
    saveData[7] = button_01_action.selectedText();
  }
  else {
    saveData[7] = "";
  }
  if (button_02_action != null) {
    saveData[8] = button_02_action.selectedText();
  }
  else {
    saveData[8] = "";
  }
  if (button_03_action != null) {
    saveData[9] = button_03_action.selectedText();
  }
  else {
    saveData[9] = "";
  }
  if (button_04_action != null) {
    saveData[10] = button_04_action.selectedText();
  }
  else {
    saveData[10] = "";
  }
  if (button_05_action != null) {
    saveData[11] = button_05_action.selectedText();
  }
  else {
    saveData[11] = "";
  }
  if (button_06_action != null) {
    saveData[12] = button_06_action.selectedText();
  }
  else {
    saveData[12] = "";
  }
  if (button_07_action != null) {
    saveData[13] = button_07_action.selectedText();
  }
  else {
    saveData[13] = "";
  }
  if (button_08_action != null) {
    saveData[14] = button_08_action.selectedText();
  }
  else {
    saveData[14] = "";
  }
  if (button_09_action != null) {
    saveData[15] = button_09_action.selectedText();
  }
  else {
    saveData[15] = "";
  }
  if (button_10_action != null) {
    saveData[16] = button_10_action.selectedText();
  }
  else {
    saveData[16] = "";
  }
  if (button_11_action != null) {
    saveData[17] = button_11_action.selectedText();
  }
  else {
    saveData[17] = "";
  }
  if (button_12_action != null) {
    saveData[18] = button_12_action.selectedText();
  }
  else {
    saveData[18] = "";
  }
  if (button_13_action != null) {
    saveData[19] = button_13_action.selectedText();
  }
  else {
    saveData[19] = "";
  }
  if (button_14_action != null) {
    saveData[20] = button_14_action.selectedText();
  }
  else {
    saveData[20] = "";
  }
  if (button_15_action != null) {
    saveData[21] = button_15_action.selectedText();
  }
  else {
    saveData[21] = "";
  }
  if (button_16_action != null) {
    saveData[22] = button_16_action.selectedText();
  }
  else {
    saveData[22] = "";
  }
  if (button_17_action != null) {
    saveData[23] = button_17_action.selectedText();
  }
  else {
    saveData[23] = "";
  }
  if (button_18_action != null) {
    saveData[24] = button_18_action.selectedText();
  }
  else {
    saveData[24] = "";
  }
  if (button_19_action != null) {
    saveData[25] = button_19_action.selectedText();
  }
  else {
    saveData[25] = "";
  }
  if (button_20_action != null) {
    saveData[26] = button_20_action.selectedText();
  }
  else {
    saveData[26] = "";
  }
  if (button_21_action != null) {
    saveData[27] = button_21_action.selectedText();
  }
  else {
    saveData[27] = "";
  }
  if (button_22_action != null) {
    saveData[28] = button_22_action.selectedText();
  }
  else {
    saveData[28] = "";
  }
  if (button_23_action != null) {
    saveData[29] = button_23_action.selectedText();
  }
  else {
    saveData[29] = "";
  }
  if (button_24_action != null) {
    saveData[30] = button_24_action.selectedText();
  }
  else {
    saveData[30] = "";
  }
  if (button_25_action != null) {
    saveData[31] = button_25_action.selectedText();
  }
  else {
    saveData[31] = "";
  }
  if (button_26_action != null) {
    saveData[32] = button_26_action.selectedText();
  }
  else {
    saveData[32] = "";
  }
  if (button_27_action != null) {
    saveData[33] = button_27_action.selectedText();
  }
  else {
    saveData[33] = "";
  }
  if (button_28_action != null) {
    saveData[34] = button_28_action.selectedText();
  }
  else {
    saveData[34] = "";
  }
  if (button_29_action != null) {
    saveData[35] = button_29_action.selectedText();
  }
  else {
    saveData[35] = "";
  }

  saveData[36] = "";
  saveData[37] = "========================================";
  saveData[38] = "--------------- Sliders ----------------";
  if (slider_00_action != null) {
    saveData[39] = slider_00_action.selectedText();
  }
  else {
    saveData[39] = "";
  }
  if (slider_01_action != null) {
    saveData[40] = slider_01_action.selectedText();
  }
  else {
    saveData[40] = "";
  }
  if (slider_02_action != null) {
    saveData[41] = slider_02_action.selectedText();
  }
  else {
    saveData[41] = "";
  }
  if (slider_03_action != null) {
    saveData[42] = slider_03_action.selectedText();
  }
  else {
    saveData[42] = "";
  }
  if (slider_04_action != null) {
    saveData[43] = slider_04_action.selectedText();
  }
  else {
    saveData[43] = "";
  }
  if (slider_05_action != null) {
    saveData[44] = slider_05_action.selectedText();
  }
  else {
    saveData[44] = "";
  }
  if (slider_06_action != null) {
    saveData[45] = slider_06_action.selectedText();
  }
  else {
    saveData[45] = "";
  }
  if (slider_07_action != null) {
    saveData[46] = slider_07_action.selectedText();
  }
  else {
    saveData[46] = "";
  }
  if (slider_08_action != null) {
    saveData[47] = slider_08_action.selectedText();
  }
  else {
    saveData[47] = "";
  }
  if (slider_09_action != null) {
    saveData[48] = slider_09_action.selectedText();
  }
  else {
    saveData[48] = "";
  }

  saveStrings("settings_inputDevice.txt", saveData);

  delay(100);
}

void closeDevice() {
  if (inputDevice != null) {
    inputDevice.close();
    println("Device Closed.");
  }
}

void updateAllButtonsAndSliders() {

  updateButton(button_00, button_00_pressed);
  updateButton(button_01, button_01_pressed);
  updateButton(button_02, button_02_pressed);
  updateButton(button_03, button_03_pressed);
  updateButton(button_04, button_04_pressed);
  updateButton(button_05, button_05_pressed);
  updateButton(button_06, button_06_pressed);
  updateButton(button_07, button_07_pressed);
  updateButton(button_08, button_08_pressed);
  updateButton(button_09, button_09_pressed);
  updateButton(button_10, button_10_pressed);
  updateButton(button_11, button_11_pressed);
  updateButton(button_12, button_12_pressed);
  updateButton(button_13, button_13_pressed);
  updateButton(button_14, button_14_pressed);
  updateButton(button_15, button_15_pressed);
  updateButton(button_16, button_16_pressed);
  updateButton(button_17, button_17_pressed);
  updateButton(button_18, button_18_pressed);
  updateButton(button_19, button_19_pressed);
  updateButton(button_20, button_20_pressed);
  updateButton(button_21, button_21_pressed);
  updateButton(button_22, button_22_pressed);
  updateButton(button_23, button_23_pressed);
  updateButton(button_24, button_24_pressed);
  updateButton(button_25, button_25_pressed);
  updateButton(button_26, button_26_pressed);
  updateButton(button_27, button_27_pressed);
  updateButton(button_28, button_28_pressed);
  updateButton(button_29, button_29_pressed);

  updateSlider(slider_00, slider_00_value);
  updateSlider(slider_01, slider_01_value);
  updateSlider(slider_02, slider_02_value);
  updateSlider(slider_03, slider_03_value);
  updateSlider(slider_04, slider_04_value);
  updateSlider(slider_05, slider_05_value);
  updateSlider(slider_06, slider_06_value);
  updateSlider(slider_07, slider_07_value);
  updateSlider(slider_08, slider_08_value);
  updateSlider(slider_09, slider_09_value);

  dropdown_whichDevice.draw();
}

void updateButton(ControllButton inputButton, GLabel indicatorLabel) {
  if (inputButton != null) {
    if (inputButton.pressed()) {
      // indicatorLabel.setText("Pressed");
      indicatorLabel.setOpaque(true);
    }
    else {
      // indicatorLabel.setText("Not Pressed");
      indicatorLabel.setOpaque(false);
    }
  }
}
void updateSlider(ControllSlider inputSlider, GWSlider indicatorSlider) {
  if (inputSlider != null) {
    indicatorSlider.setValue(inputSlider.getValue());
  }
}


void openNewDevice(int deviceNumber) {
  inputDevice = controlIO.getDevice(deviceNumber);
  println("Device Selected = " + inputDevice.getName());

  numButtons = inputDevice.getNumberOfButtons();
  String[] list_buttons = new String[numButtons + 1];
  for (int i = 0; i < numButtons; i++) {
    list_buttons[i] = inputDevice.getButton(i).getName();
  }
  list_buttons[numButtons] = "Select a Button";

  if (button_00_pressed != null) {
    button_00_pressed.setText("");
    button_00_pressed.setVisible(false);
    button_00_action.setSelected(0);
    button_00_action.setVisible(false);
  }
  if (button_01_pressed != null) {
    button_01_pressed.setText("");
    button_01_pressed.setVisible(false);
    button_01_action.setSelected(0);
    button_01_action.setVisible(false);
  }
  if (button_02_pressed != null) {
    button_02_pressed.setText("");
    button_02_pressed.setVisible(false);
    button_02_action.setSelected(0);
    button_02_action.setVisible(false);
  }
  if (button_03_pressed != null) {
    button_03_pressed.setText("");
    button_03_pressed.setVisible(false);
    button_03_action.setSelected(0);
    button_03_action.setVisible(false);
  }
  if (button_04_pressed != null) {
    button_04_pressed.setText("");
    button_04_pressed.setVisible(false);
    button_04_action.setSelected(0);
    button_04_action.setVisible(false);
  }
  if (button_05_pressed != null) {
    button_05_pressed.setText("");
    button_05_pressed.setVisible(false);
    button_05_action.setSelected(0);
    button_05_action.setVisible(false);
  }
  if (button_06_pressed != null) {
    button_06_pressed.setText("");
    button_06_pressed.setVisible(false);
    button_06_action.setSelected(0);
    button_06_action.setVisible(false);
  }
  if (button_07_pressed != null) {
    button_07_pressed.setText("");
    button_07_pressed.setVisible(false);
    button_07_action.setSelected(0);
    button_07_action.setVisible(false);
  }
  if (button_08_pressed != null) {
    button_08_pressed.setText("");
    button_08_pressed.setVisible(false);
    button_08_action.setSelected(0);
    button_08_action.setVisible(false);
  }
  if (button_09_pressed != null) {
    button_09_pressed.setText("");
    button_09_pressed.setVisible(false);
    button_09_action.setSelected(0);
    button_09_action.setVisible(false);
  }
  if (button_10_pressed != null) {
    button_10_pressed.setText("");
    button_10_pressed.setVisible(false);
    button_10_action.setSelected(0);
    button_10_action.setVisible(false);
  }
  if (button_11_pressed != null) {
    button_11_pressed.setText("");
    button_11_pressed.setVisible(false);
    button_11_action.setSelected(0);
    button_11_action.setVisible(false);
  }
  if (button_12_pressed != null) {
    button_12_pressed.setText("");
    button_12_pressed.setVisible(false);
    button_12_action.setSelected(0);
    button_12_action.setVisible(false);
  }
  if (button_13_pressed != null) {
    button_13_pressed.setText("");
    button_13_pressed.setVisible(false);
    button_13_action.setSelected(0);
    button_13_action.setVisible(false);
  }
  if (button_14_pressed != null) {
    button_14_pressed.setText("");
    button_14_pressed.setVisible(false);
    button_14_action.setSelected(0);
    button_14_action.setVisible(false);
  }
  if (button_15_pressed != null) {
    button_15_pressed.setText("");
    button_15_pressed.setVisible(false);
    button_15_action.setSelected(0);
    button_15_action.setVisible(false);
  }
  if (button_16_pressed != null) {
    button_16_pressed.setText("");
    button_16_pressed.setVisible(false);
    button_16_action.setSelected(0);
    button_16_action.setVisible(false);
  }
  if (button_17_pressed != null) {
    button_17_pressed.setText("");
    button_17_pressed.setVisible(false);
    button_17_action.setSelected(0);
    button_17_action.setVisible(false);
  }
  if (button_18_pressed != null) {
    button_18_pressed.setText("");
    button_18_pressed.setVisible(false);
    button_18_action.setSelected(0);
    button_18_action.setVisible(false);
  }
  if (button_19_pressed != null) {
    button_19_pressed.setText("");
    button_19_pressed.setVisible(false);
    button_19_action.setSelected(0);
    button_19_action.setVisible(false);
  }
  if (button_20_pressed != null) {
    button_20_pressed.setText("");
    button_20_pressed.setVisible(false);
    button_20_action.setSelected(0);
    button_20_action.setVisible(false);
  }
  if (button_21_pressed != null) {
    button_21_pressed.setText("");
    button_21_pressed.setVisible(false);
    button_21_action.setSelected(0);
    button_21_action.setVisible(false);
  }
  if (button_22_pressed != null) {
    button_22_pressed.setText("");
    button_22_pressed.setVisible(false);
    button_22_action.setSelected(0);
    button_22_action.setVisible(false);
  }
  if (button_23_pressed != null) {
    button_23_pressed.setText("");
    button_23_pressed.setVisible(false);
    button_23_action.setSelected(0);
    button_23_action.setVisible(false);
  }
  if (button_24_pressed != null) {
    button_24_pressed.setText("");
    button_24_pressed.setVisible(false);
    button_24_action.setSelected(0);
    button_24_action.setVisible(false);
  }
  if (button_25_pressed != null) {
    button_25_pressed.setText("");
    button_25_pressed.setVisible(false);
    button_25_action.setSelected(0);
    button_25_action.setVisible(false);
  }
  if (button_26_pressed != null) {
    button_26_pressed.setText("");
    button_26_pressed.setVisible(false);
    button_26_action.setSelected(0);
    button_26_action.setVisible(false);
  }
  if (button_27_pressed != null) {
    button_27_pressed.setText("");
    button_27_pressed.setVisible(false);
    button_27_action.setSelected(0);
    button_27_action.setVisible(false);
  }
  if (button_28_pressed != null) {
    button_28_pressed.setText("");
    button_28_pressed.setVisible(false);
    button_28_action.setSelected(0);
    button_28_action.setVisible(false);
  }
  if (button_29_pressed != null) {
    button_29_pressed.setText("");
    button_29_pressed.setVisible(false);
    button_29_action.setSelected(0);
    button_29_action.setVisible(false);
  }

  if (numButtons > 0) {
    button_00 = inputDevice.getButton(0);
    button_00_pressed = new GLabel(this, list_buttons[0], 10, 40, 100, 20);
    button_00_pressed.setBorder(1);
    button_00_pressed.setOpaque(false);
    button_00_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_00_pressed);
    if (button_00_action == null) {
      button_00_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 42, 105);
      button_00_action.setSelected(0);               
      panel_main.add(button_00_action);
    }
    button_00_action.setVisible(true);
  }

  if (numButtons > 1) {
    button_01 = inputDevice.getButton(1);
    button_01_pressed = new GLabel(this, list_buttons[1], 10, 70, 100, 20);
    button_01_pressed.setBorder(1);
    button_01_pressed.setOpaque(false);
    button_01_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_01_pressed);
    if (button_01_action == null) {
      button_01_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 72, 105);
      button_01_action.setSelected(0);               
      panel_main.add(button_01_action);
    }
    button_01_action.setVisible(true);
  }

  if (numButtons > 2) {
    button_02 = inputDevice.getButton(2);
    button_02_pressed = new GLabel(this, list_buttons[2], 10, 100, 100, 20);
    button_02_pressed.setBorder(1);
    button_02_pressed.setOpaque(false);
    button_02_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_02_pressed);
    if (button_02_action == null) {
      button_02_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 102, 105);
      button_02_action.setSelected(0);               
      panel_main.add(button_02_action);
    }
    button_02_action.setVisible(true);
  }

  if (numButtons > 3) {
    button_03 = inputDevice.getButton(3);
    button_03_pressed = new GLabel(this, list_buttons[3], 10, 130, 100, 20);
    button_03_pressed.setBorder(1);
    button_03_pressed.setOpaque(false);
    button_03_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_03_pressed);
    if (button_03_action == null) {
      button_03_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 132, 105);
      button_03_action.setSelected(0);               
      panel_main.add(button_03_action);
    }
    button_03_action.setVisible(true);
  }

  if (numButtons > 4) {
    button_04 = inputDevice.getButton(4);
    button_04_pressed = new GLabel(this, list_buttons[4], 10, 160, 100, 20);
    button_04_pressed.setBorder(1);
    button_04_pressed.setOpaque(false);
    button_04_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_04_pressed);
    if (button_04_action == null) {
      button_04_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 162, 105);
      button_04_action.setSelected(0);               
      panel_main.add(button_04_action);
    }
    button_04_action.setVisible(true);
  }

  if (numButtons > 5) {
    button_05 = inputDevice.getButton(5);
    button_05_pressed = new GLabel(this, list_buttons[5], 10, 190, 100, 20);
    button_05_pressed.setBorder(1);
    button_05_pressed.setOpaque(false);
    button_05_pressed.setColorScheme(GCScheme.RED_SCHEME);
    if (button_05_action == null) {
      panel_main.add(button_05_pressed);
      button_05_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 192, 105);
      button_05_action.setSelected(0);               
      panel_main.add(button_05_action);
    }
    button_05_action.setVisible(true);
  }

  if (numButtons > 6) {
    button_06 = inputDevice.getButton(6);
    button_06_pressed = new GLabel(this, list_buttons[6], 10, 220, 100, 20);
    button_06_pressed.setBorder(1);
    button_06_pressed.setOpaque(false);
    button_06_pressed.setColorScheme(GCScheme.RED_SCHEME);
    if (button_06_action == null) {
      panel_main.add(button_06_pressed);
      button_06_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 222, 105);
      button_06_action.setSelected(0);               
      panel_main.add(button_06_action);
    }
    button_06_action.setVisible(true);
  }

  if (numButtons > 7) {
    button_07 = inputDevice.getButton(7);
    button_07_pressed = new GLabel(this, list_buttons[7], 10, 250, 100, 20);
    button_07_pressed.setBorder(1);
    button_07_pressed.setOpaque(false);
    button_07_pressed.setColorScheme(GCScheme.RED_SCHEME);
    if (button_07_action == null) {
      panel_main.add(button_07_pressed);
      button_07_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 252, 105);
      button_07_action.setSelected(0);               
      panel_main.add(button_07_action);
    }
    button_07_action.setVisible(true);
  }

  if (numButtons > 8) {
    button_08 = inputDevice.getButton(8);
    button_08_pressed = new GLabel(this, list_buttons[8], 10, 280, 100, 20);
    button_08_pressed.setBorder(1);
    button_08_pressed.setOpaque(false);
    button_08_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_08_pressed);
    if (button_08_action == null) {
      button_08_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 282, 105);
      button_08_action.setSelected(0);               
      panel_main.add(button_08_action);
    }
    button_08_action.setVisible(true);
  }

  if (numButtons > 9) {
    button_09 = inputDevice.getButton(9);
    button_09_pressed = new GLabel(this, list_buttons[9], 10, 310, 100, 20);
    button_09_pressed.setBorder(1);
    button_09_pressed.setOpaque(false);
    button_09_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_09_pressed);
    if (button_09_action == null) {
      button_09_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 312, 105);
      button_09_action.setSelected(0);               
      panel_main.add(button_09_action);
    }
    button_09_action.setVisible(true);
  }

  if (numButtons > 10) {
    button_10 = inputDevice.getButton(10);
    button_10_pressed = new GLabel(this, list_buttons[10], 10, 340, 100, 20);
    button_10_pressed.setBorder(1);
    button_10_pressed.setOpaque(false);
    button_10_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_10_pressed);
    if (button_10_action == null) {
      button_10_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 342, 105);
      button_10_action.setSelected(0);               
      panel_main.add(button_10_action);
    }
    button_10_action.setVisible(true);
  }

  if (numButtons > 11) {
    button_11 = inputDevice.getButton(11);
    button_11_pressed = new GLabel(this, list_buttons[11], 10, 370, 100, 20);
    button_11_pressed.setBorder(1);
    button_11_pressed.setOpaque(false);
    button_11_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_11_pressed);
    if (button_11_action == null) {
      button_11_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 372, 105);
      button_11_action.setSelected(0);               
      panel_main.add(button_11_action);
    }
    button_11_action.setVisible(true);
  }

  if (numButtons > 12) {
    button_12 = inputDevice.getButton(12);
    button_12_pressed = new GLabel(this, list_buttons[12], 10, 400, 100, 20);
    button_12_pressed.setBorder(1);
    button_12_pressed.setOpaque(false);
    button_12_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_12_pressed);
    if (button_12_action == null) {
      button_12_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 402, 105);
      button_12_action.setSelected(0);               
      panel_main.add(button_12_action);
    }
    button_12_action.setVisible(true);
  }

  if (numButtons > 13) {
    button_13 = inputDevice.getButton(13);
    button_13_pressed = new GLabel(this, list_buttons[13], 10, 430, 100, 20);
    button_13_pressed.setBorder(1);
    button_13_pressed.setOpaque(false);
    button_13_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_13_pressed);
    if (button_13_action == null) {
      button_13_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 432, 105);
      button_13_action.setSelected(0);               
      panel_main.add(button_13_action);
    }
    button_13_action.setVisible(true);
  }

  if (numButtons > 14) {
    button_14 = inputDevice.getButton(14);
    button_14_pressed = new GLabel(this, list_buttons[14], 10, 460, 100, 20);
    button_14_pressed.setBorder(1);
    button_14_pressed.setOpaque(false);
    button_14_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_14_pressed);
    if (button_14_action == null) {
      button_14_action = new GCombo(this, list_button_actions, list_button_actions.length, 118, 462, 105);
      button_14_action.setSelected(0);               
      panel_main.add(button_14_action);
    }
    button_14_action.setVisible(true);
  }

  if (numButtons > 15) {
    button_15 = inputDevice.getButton(15);
    button_15_pressed = new GLabel(this, list_buttons[15], 240, 40, 100, 20);
    button_15_pressed.setBorder(1);
    button_15_pressed.setOpaque(false);
    button_15_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_15_pressed);
    if (button_15_action == null) {
      button_15_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 42, 105);
      button_15_action.setSelected(0);               
      panel_main.add(button_15_action);
    }
    button_15_action.setVisible(true);
  }

  if (numButtons > 16) {
    button_16 = inputDevice.getButton(16);
    button_16_pressed = new GLabel(this, list_buttons[16], 240, 70, 100, 20);
    button_16_pressed.setBorder(1);
    button_16_pressed.setOpaque(false);
    button_16_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_16_pressed);
    if (button_16_action == null) {
      button_16_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 72, 105);
      button_16_action.setSelected(0);               
      panel_main.add(button_16_action);
    }
    button_16_action.setVisible(true);
  }

  if (numButtons > 17) {
    button_17 = inputDevice.getButton(17);
    button_17_pressed = new GLabel(this, list_buttons[17], 240, 100, 100, 20);
    button_17_pressed.setBorder(1);
    button_17_pressed.setOpaque(false);
    button_17_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_17_pressed);
    if (button_17_action == null) {
      button_17_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 102, 105);
      button_17_action.setSelected(0);               
      panel_main.add(button_17_action);
    }
    button_17_action.setVisible(true);
  }

  if (numButtons > 18) {
    button_18 = inputDevice.getButton(18);
    button_18_pressed = new GLabel(this, list_buttons[18], 240, 130, 100, 20);
    button_18_pressed.setBorder(1);
    button_18_pressed.setOpaque(false);
    button_18_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_18_pressed);
    if (button_18_action == null) {
      button_18_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 132, 105);
      button_18_action.setSelected(0);               
      panel_main.add(button_18_action);
    }
    button_18_action.setVisible(true);
  }

  if (numButtons > 19) {
    button_19 = inputDevice.getButton(19);
    button_19_pressed = new GLabel(this, list_buttons[19], 240, 160, 100, 20);
    button_19_pressed.setBorder(1);
    button_19_pressed.setOpaque(false);
    button_19_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_19_pressed);
    if (button_19_action == null) {
      button_19_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 162, 105);
      button_19_action.setSelected(0);               
      panel_main.add(button_19_action);
    }
    button_19_action.setVisible(true);
  }

  if (numButtons > 20) {
    button_20 = inputDevice.getButton(20);
    button_20_pressed = new GLabel(this, list_buttons[20], 240, 190, 100, 20);
    button_20_pressed.setBorder(1);
    button_20_pressed.setOpaque(false);
    button_20_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_20_pressed);
    if (button_20_action == null) {
      button_20_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 192, 105);
      button_20_action.setSelected(0);               
      panel_main.add(button_20_action);
    }
    button_20_action.setVisible(true);
  }

  if (numButtons > 21) {
    button_21 = inputDevice.getButton(21);
    button_21_pressed = new GLabel(this, list_buttons[21], 240, 220, 100, 20);
    button_21_pressed.setBorder(1);
    button_21_pressed.setOpaque(false);
    button_21_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_21_pressed);
    if (button_21_action == null) {
      button_21_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 222, 105);
      button_21_action.setSelected(0);               
      panel_main.add(button_21_action);
    }
    button_21_action.setVisible(true);
  }

  if (numButtons > 22) {
    button_22 = inputDevice.getButton(22);
    button_22_pressed = new GLabel(this, list_buttons[22], 240, 250, 100, 20);
    button_22_pressed.setBorder(1);
    button_22_pressed.setOpaque(false);
    button_22_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_22_pressed);
    if (button_22_action == null) {
      button_22_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 252, 105);
      button_22_action.setSelected(0);               
      panel_main.add(button_22_action);
    }
    button_22_action.setVisible(true);
  }

  if (numButtons > 23) {
    button_23 = inputDevice.getButton(23);
    button_23_pressed = new GLabel(this, list_buttons[23], 240, 280, 100, 20);
    button_23_pressed.setBorder(1);
    button_23_pressed.setOpaque(false);
    button_23_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_23_pressed);
    if (button_23_action == null) {
      button_23_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 282, 105);
      button_23_action.setSelected(0);               
      panel_main.add(button_23_action);
    }
    button_23_action.setVisible(true);
  }

  if (numButtons > 24) {
    button_24 = inputDevice.getButton(24);
    button_24_pressed = new GLabel(this, list_buttons[24], 240, 310, 100, 20);
    button_24_pressed.setBorder(1);
    button_24_pressed.setOpaque(false);
    button_24_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_24_pressed);
    if (button_24_action == null) {
      button_24_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 312, 105);
      button_24_action.setSelected(0);               
      panel_main.add(button_24_action);
    }
    button_24_action.setVisible(true);
  }

  if (numButtons > 25) {
    button_25 = inputDevice.getButton(25);
    button_25_pressed = new GLabel(this, list_buttons[25], 240, 340, 100, 20);
    button_25_pressed.setBorder(1);
    button_25_pressed.setOpaque(false);
    button_25_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_25_pressed);
    if (button_25_action == null) {
      button_25_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 342, 105);
      button_25_action.setSelected(0);               
      panel_main.add(button_25_action);
    }
    button_25_action.setVisible(true);
  }

  if (numButtons > 26) {
    button_26 = inputDevice.getButton(26);
    button_26_pressed = new GLabel(this, list_buttons[26], 240, 370, 100, 20);
    button_26_pressed.setBorder(1);
    button_26_pressed.setOpaque(false);
    button_26_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_26_pressed);
    if (button_26_action == null) {
      button_26_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 372, 105);
      button_26_action.setSelected(0);               
      panel_main.add(button_26_action);
    }
    button_26_action.setVisible(true);
  }

  if (numButtons > 27) {
    button_27 = inputDevice.getButton(27);
    button_27_pressed = new GLabel(this, list_buttons[27], 240, 400, 100, 20);
    button_27_pressed.setBorder(1);
    button_27_pressed.setOpaque(false);
    button_27_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_27_pressed);
    if (button_27_action == null) {
      button_27_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 402, 105);
      button_27_action.setSelected(0);               
      panel_main.add(button_27_action);
    }
    button_27_action.setVisible(true);
  }

  if (numButtons > 28) {
    button_28 = inputDevice.getButton(28);
    button_28_pressed = new GLabel(this, list_buttons[28], 240, 430, 100, 20);
    button_28_pressed.setBorder(1);
    button_28_pressed.setOpaque(false);
    button_28_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_28_pressed);
    if (button_28_action == null) {
      button_28_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 432, 105);
      button_28_action.setSelected(0);               
      panel_main.add(button_28_action);
    }
    button_28_action.setVisible(true);
  }

  if (numButtons > 29) {
    button_29 = inputDevice.getButton(29);
    button_29_pressed = new GLabel(this, list_buttons[29], 240, 460, 100, 20);
    button_29_pressed.setBorder(1);
    button_29_pressed.setOpaque(false);
    button_29_pressed.setColorScheme(GCScheme.RED_SCHEME);
    panel_main.add(button_29_pressed);
    if (button_29_action == null) {
      button_29_action = new GCombo(this, list_button_actions, list_button_actions.length, 348, 462, 105);
      button_29_action.setSelected(0);               
      panel_main.add(button_29_action);
    }
    button_29_action.setVisible(true);
  }




  numSliders = inputDevice.getNumberOfSliders();
  String[] list_sliders = new String[numSliders];
  for (int i = 0; i < numSliders; i++) {
    list_sliders[i] = inputDevice.getSlider(i).getName();
  }
  if (slider_00_value != null) {
    slider_00_value.setVisible(false);
    slider_00_action.setSelected(0);
    slider_00_action.setVisible(false);
  }
  if (slider_01_value != null) {
    slider_01_value.setVisible(false);
    slider_01_action.setSelected(0);
    slider_01_action.setVisible(false);
  }
  if (slider_02_value != null) {
    slider_02_value.setVisible(false);
    slider_02_action.setSelected(0);
    slider_02_action.setVisible(false);
  }
  if (slider_03_value != null) {
    slider_03_value.setVisible(false);
    slider_03_action.setSelected(0);
    slider_03_action.setVisible(false);
  }
  if (slider_04_value != null) {
    slider_04_value.setVisible(false);
    slider_04_action.setSelected(0);
    slider_04_action.setVisible(false);
  }
  if (slider_05_value != null) {
    slider_05_value.setVisible(false);
    slider_05_action.setSelected(0);
    slider_05_action.setVisible(false);
  }
  if (slider_06_value != null) {
    slider_06_value.setVisible(false);
    slider_06_action.setSelected(0);
    slider_06_action.setVisible(false);
  }
  if (slider_07_value != null) {
    slider_07_value.setVisible(false);
    slider_07_action.setSelected(0);
    slider_07_action.setVisible(false);
  }
  if (slider_08_value != null) {
    slider_08_value.setVisible(false);
    slider_08_action.setSelected(0);
    slider_08_action.setVisible(false);
  }
  if (slider_09_value != null) {
    slider_09_value.setVisible(false);
    slider_09_action.setSelected(0);
    slider_09_action.setVisible(false);
  }

  if (numSliders > 0) {
    slider_00 = inputDevice.getSlider(0);
    slider_00_value = new GWSlider(this, 520, 40, 100);
    slider_00_value.setValueType(GSlider.DECIMAL);
    slider_00_value.setLimits(0.0, -1.0, 1.0);
    slider_00_value.setRenderMaxMinLabel(false);
    slider_00_value.setRenderValueLabel(false);
    slider_00_value.setTickCount(0);
    slider_00_value.setInertia(1);
    panel_main.add(slider_00_value);
    if (slider_00_action == null) {
      slider_00_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 37, 105);
      slider_00_action.setSelected(0);               
      panel_main.add(slider_00_action);
    }
    slider_00_action.setVisible(true);
  }

  if (numSliders > 1) {
    slider_01 = inputDevice.getSlider(1);
    slider_01_value = new GWSlider(this, 520, 70, 100);
    slider_01_value.setValueType(GSlider.DECIMAL);
    slider_01_value.setLimits(0.0, -1.0, 1.0);
    slider_01_value.setRenderMaxMinLabel(false);
    slider_01_value.setRenderValueLabel(false);
    slider_01_value.setTickCount(0);
    slider_01_value.setInertia(1);
    panel_main.add(slider_01_value);
    if (slider_01_action == null) {
      slider_01_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 67, 105);
      slider_01_action.setSelected(0);               
      panel_main.add(slider_01_action);
    }
    slider_01_action.setVisible(true);
  }

  if (numSliders > 2) {
    slider_02 = inputDevice.getSlider(2);
    slider_02_value = new GWSlider(this, 520, 100, 100);
    slider_02_value.setValueType(GSlider.DECIMAL);
    slider_02_value.setLimits(0.0, -1.0, 1.0);
    slider_02_value.setRenderMaxMinLabel(false);
    slider_02_value.setRenderValueLabel(false);
    slider_02_value.setTickCount(0);
    slider_02_value.setInertia(1);
    panel_main.add(slider_02_value);
    if (slider_02_action == null) {
      slider_02_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 97, 105);
      slider_02_action.setSelected(0);               
      panel_main.add(slider_02_action);
    }
    slider_02_action.setVisible(true);
  }

  if (numSliders > 3) {
    slider_03 = inputDevice.getSlider(3);
    slider_03_value = new GWSlider(this, 520, 130, 100);
    slider_03_value.setValueType(GSlider.DECIMAL);
    slider_03_value.setLimits(0.0, -1.0, 1.0);
    slider_03_value.setRenderMaxMinLabel(false);
    slider_03_value.setRenderValueLabel(false);
    slider_03_value.setTickCount(0);
    slider_03_value.setInertia(1);
    panel_main.add(slider_03_value);
    if (slider_03_action == null) {
      slider_03_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 127, 105);
      slider_03_action.setSelected(0);               
      panel_main.add(slider_03_action);
    }
    slider_03_action.setVisible(true);
  }

  if (numSliders > 4) {
    slider_04 = inputDevice.getSlider(4);
    slider_04_value = new GWSlider(this, 520, 160, 100);
    slider_04_value.setValueType(GSlider.DECIMAL);
    slider_04_value.setLimits(0.0, -1.0, 1.0);
    slider_04_value.setRenderMaxMinLabel(false);
    slider_04_value.setRenderValueLabel(false);
    slider_04_value.setTickCount(0);
    slider_04_value.setInertia(1);
    panel_main.add(slider_04_value);
    if (slider_04_action == null) {
      slider_04_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 157, 105);
      slider_04_action.setSelected(0);               
      panel_main.add(slider_04_action);
    }
    slider_04_action.setVisible(true);
  }

  if (numSliders > 5) {
    slider_05 = inputDevice.getSlider(5);
    slider_05_value = new GWSlider(this, 520, 190, 100);
    slider_05_value.setValueType(GSlider.DECIMAL);
    slider_05_value.setLimits(0.0, -1.0, 1.0);
    slider_05_value.setRenderMaxMinLabel(false);
    slider_05_value.setRenderValueLabel(false);
    slider_05_value.setTickCount(0);
    slider_05_value.setInertia(1);
    panel_main.add(slider_05_value);
    if (slider_05_action == null) {
      slider_05_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 187, 105);
      slider_05_action.setSelected(0);               
      panel_main.add(slider_05_action);
    }
    slider_05_action.setVisible(true);
  }

  if (numSliders > 6) {
    slider_06 = inputDevice.getSlider(6);
    slider_06_value = new GWSlider(this, 520, 220, 100);
    slider_06_value.setValueType(GSlider.DECIMAL);
    slider_06_value.setLimits(0.0, -1.0, 1.0);
    slider_06_value.setRenderMaxMinLabel(false);
    slider_06_value.setRenderValueLabel(false);
    slider_06_value.setTickCount(0);
    slider_06_value.setInertia(1);
    panel_main.add(slider_06_value);
    if (slider_06_action == null) {
      slider_06_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 217, 105);
      slider_06_action.setSelected(0);               
      panel_main.add(slider_06_action);
    }
    slider_06_action.setVisible(true);
  }

  if (numSliders > 7) {
    slider_07 = inputDevice.getSlider(7);
    slider_07_value = new GWSlider(this, 520, 250, 100);
    slider_07_value.setValueType(GSlider.DECIMAL);
    slider_07_value.setLimits(0.0, -1.0, 1.0);
    slider_07_value.setRenderMaxMinLabel(false);
    slider_07_value.setRenderValueLabel(false);
    slider_07_value.setTickCount(0);
    slider_07_value.setInertia(1);
    panel_main.add(slider_07_value);
    if (slider_07_action == null) {
      slider_07_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 247, 105);
      slider_07_action.setSelected(0);               
      panel_main.add(slider_07_action);
    }
    slider_07_action.setVisible(true);
  }

  if (numSliders > 8) {
    slider_08 = inputDevice.getSlider(8);
    slider_08_value = new GWSlider(this, 520, 280, 100);
    slider_08_value.setValueType(GSlider.DECIMAL);
    slider_08_value.setLimits(0.0, -1.0, 1.0);
    slider_08_value.setRenderMaxMinLabel(false);
    slider_08_value.setRenderValueLabel(false);
    slider_08_value.setTickCount(0);
    slider_08_value.setInertia(1);
    panel_main.add(slider_08_value);
    if (slider_08_action == null) {
      slider_08_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 277, 105);
      slider_08_action.setSelected(0);               
      panel_main.add(slider_08_action);
    }
    slider_08_action.setVisible(true);
  }

  if (numSliders > 9) {
    slider_09 = inputDevice.getSlider(9);
    slider_09_value = new GWSlider(this, 520, 310, 100);
    slider_09_value.setValueType(GSlider.DECIMAL);
    slider_09_value.setLimits(0.0, -1.0, 1.0);
    slider_09_value.setRenderMaxMinLabel(false);
    slider_09_value.setRenderValueLabel(false);
    slider_09_value.setTickCount(0);
    slider_09_value.setInertia(1);
    panel_main.add(slider_09_value);
    if (slider_09_action == null) {
      slider_09_action = new GCombo(this, list_slider_actions, list_slider_actions.length, 627, 307, 105);
      slider_09_action.setSelected(0);               
      panel_main.add(slider_09_action);
    }
    slider_09_action.setVisible(true);
  }
}

