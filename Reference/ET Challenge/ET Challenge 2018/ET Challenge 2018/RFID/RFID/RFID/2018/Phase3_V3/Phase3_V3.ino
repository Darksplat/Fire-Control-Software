/*
 * V3 - Changed descriptions in comments 02/10/2020, Changed colour codes in LEDS Tab for "-" (CNT1) LED Board
 * Pinouts RFID read/write (Duinotech RFID-RC522)
 * VCC - 3.3VDC
 * RST - 9
 * GND - GND
 * MISO - 12
 * MOSI - 11
 * SCK - 13
 * NSS - 10
 * IRQ - Not connected
 * 
 * Pinouts for RGB LED (duinotech XC-4428)
 * + - If LED (CNT1) has a "+" then connect to 5v, if LED (CNT1) has a "-" connect to GND
 * G - 3
 * R - 5
 * B - 6
 * 
 * To prevent burnout, the use of resistors is advised. Otherwise use the turn off key as quick as possible.
 * R 180Ω resistor
 * G 110Ω resistor
 * B 110Ω resistor
 */

//#include <SPI.h>//include the SPI bus library
#include <MFRC522.h>//include the RFID reader library

#define SS_PIN 10  //slave select pin
#define RST_PIN 9  //reset pin

#define G_LED 3
#define R_LED 5
#define B_LED 6

MFRC522 mfrc522(SS_PIN, RST_PIN);        // instatiate a MFRC522 reader object.
MFRC522::MIFARE_Key key;//create a MIFARE_Key struct named 'key', which will hold the card information

int block=2;//this is the block number we will write into and then read. Do not write into 'sector trailer' block, since this can make the block unusable.
byte readbackblock[18];//This array is used for reading out a block. The MIFARE_Read method requires a buffer that is at least 18 bytes to hold the 16 bytes of a block.
String rfidReadString;

boolean capture = false;

void setup() {
  // put your setup code here, to run once:
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

  pinMode(G_LED, OUTPUT);
  pinMode(R_LED, OUTPUT);
  pinMode(B_LED, OUTPUT);

analogWrite(G_LED, 255); //255 is off and 0 is hard on
analogWrite(R_LED, 255);
analogWrite(B_LED, 255);

}

void loop() {
  // put your main code here, to run repeatedly:
receiveRfidCommands();
}
