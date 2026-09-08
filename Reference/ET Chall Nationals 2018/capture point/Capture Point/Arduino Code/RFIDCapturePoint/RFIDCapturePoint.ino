
#include <SPI.h>//include the SPI bus library
#include <MFRC522.h>//include the RFID reader library

#define SS_PIN 10  //slave select pin
#define RST_PIN 9  //reset pin

#define R_LED 6
#define G_LED 7
#define B_LED 8

char rxChar;

boolean CTF = false; // Team Capture The Flag
boolean DOM = false; // Domination
boolean INF = false; // King Of The Hill

boolean start = false;
int initiateFlash = 0;
int onTime = 10000;
int resetTime = onTime * 2;

//************************ Capture the flag
boolean redBase = false;
boolean blueBase = false;
boolean flag = false;

boolean blueCaptured = false;
boolean redCaptured = false;
boolean blueCapturedComplete = false;
boolean redCapturedComplete = false;
boolean blueWin = false;
boolean redWin = false;

boolean blue1 = false;
boolean blue2 = false;
boolean blue3 = false;
boolean blue4 = false;
boolean red1 = false;
boolean red2 = false;
boolean red3 = false;
boolean red4 = false;

//**************************** Domination

boolean pointA = false;
boolean pointB = false;
boolean pointC = false;


MFRC522 mfrc522(SS_PIN, RST_PIN);        // instatiate a MFRC522 reader object.
MFRC522::MIFARE_Key key;//create a MIFARE_Key struct named 'key', which will hold the card information

void setup() {
  Serial.begin(9600);        // Initialize serial communications with the PC
  SPI.begin();               // Init SPI bus
  mfrc522.PCD_Init();        // Init MFRC522 card (in case you wonder what PCD means: proximity coupling device)
  //        Serial.println("Scan a MIFARE Classic card");

  // Prepare the security key for the read and write functions - all six key bytes are set to 0xFF at chip delivery from the factory.
  // Since the cards in the kit are new and the keys were never defined, they are 0xFF
  // if we had a card that was programmed by someone else, we would need to know the key to be able to access it. This key would then need to be stored in 'key' instead.

  for (byte i = 0; i < 6; i++) {
    key.keyByte[i] = 0xFF;//keyByte is defined in the "MIFARE_Key" 'struct' definition in the .h file of the library
  }

  pinMode(R_LED, OUTPUT);
  pinMode(G_LED, OUTPUT);
  pinMode(B_LED, OUTPUT);

  // High is off
  digitalWrite(R_LED, HIGH);
  digitalWrite(G_LED, HIGH);
  digitalWrite(B_LED, HIGH);

}

int block=2;//this is the block number we will write into and then read. Do not write into 'sector trailer' block, since this can make the block unusable.
byte readbackblock[18];//This array is used for reading out a block. The MIFARE_Read method requires a buffer that is at least 18 bytes to hold the 16 bytes of a block.
String rfidReadString;

void loop()
{
  // Only if told to start then allow point to send RFID information
  if(start){
    receiveRfidCommands(); // check for incoming RFID commands
  }

  receiveWifiCommands(); // check for incoming WIFI commands


    if(CTF){
    captureTheFlag(); 
  }

  if(DOM){
    domination(); 
  }

  if(INF){
    infiltrate(); 
  }

  if(!CTF && !DOM && !INF){
    // All LEDs set yellow if while no initial comms
    digitalWrite(R_LED, LOW);
    digitalWrite(G_LED, LOW);
    digitalWrite(B_LED, HIGH);
  }
}









