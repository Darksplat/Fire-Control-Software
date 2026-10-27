
void receiveRfidCommands()
{
  mfrc522.PCD_Init();        // Init MFRC522 card (in case you wonder what PCD means: proximity coupling device)
  /*****************************************establishing contact with a tag/card**********************************************************************/


  // Look for new cards (in case you wonder what PICC means: proximity integrated circuit card)
  if ( ! mfrc522.PICC_IsNewCardPresent()) {//if PICC_IsNewCardPresent returns 1, a new card has been found and we continue
    return;//if it did not find a new card is returns a '0' and we return to the start of the loop
  }

  //pauseForRead();

  // Select one of the cards
  if ( ! mfrc522.PICC_ReadCardSerial()) {//if PICC_ReadCardSerial returns 1, the "uid" struct (see MFRC522.h lines 238-45)) contains the ID of the read card.
    return;//if it returns a '0' something went wrong and we return to the start of the loop
  }


  //mfrc522.PICC_DumpToSerial(&(mfrc522.uid));//uncomment this if you want to see the entire 1k memory with the block written into it.

  readBlock(block, readbackblock);//read the block back
  for (int j=0 ; j<16 ; j++)//print the block contents
  {
    rfidReadString += char(readbackblock[j]); 
  }

  //Serial.print(rfidReadString);
  
  if(capture == false && rfidReadString == "1"){
    blueLED();
    capture = true;
    //Serial.print("1");
  }

  if(capture == false && rfidReadString == "2"){
    redLED();
    capture = true;
  }

  if(capture == false && rfidReadString == "3"){
    greenLED();
    capture = true;
  }

  if(capture == false && rfidReadString == "4"){
    purpleLED();
    capture = true;
  }

  if(capture == false && rfidReadString == "5"){
    yellowLED();
    capture = true;
  }

  if(rfidReadString == "6"){
    LEDOFF();
    capture = false;
  }
  
  rfidReadString = "";
}


