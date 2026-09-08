//background color variable
color backgroundColour = color(200);

PFont labelFont;
PFont titleFont;

int flashColour = 0;
int flashTimer = 0;
int startFlashTimer1sec;
int startFlashTimerHalfSec;
boolean textOn1Sec = true;
boolean textOnHalfSec = true;
long startCaptureTimer = 0;
long startRoundTimer = 0;



// Used to indicate who has the flag
boolean blueFlag = false;
boolean redFlag = false;
int blueCaptureCount = 0;
int redCaptureCount = 0;

// Used to finalise capture
boolean blueCaptured = false;
boolean redCaptured = false;

// round start
boolean roundStarted = false;

boolean mouseClicked = false;

//Blue team cars
boolean Blue1 = false;
boolean Blue2 = false;
boolean Blue3 = false;
boolean Blue4 = false;

//Red team cars
boolean Red1 = false;
boolean Red2 = false;
boolean Red3 = false;
boolean Red4 = false;

boolean range = false;
boolean activateBlueTurret = false;
boolean activateRedTurret = false;