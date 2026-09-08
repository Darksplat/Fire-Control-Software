
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
    //Serial.write (readbackblock[j]); //Serial.write() transmits the ASCII numbers as human readable characters to serial monitor
    //Serial.print(",");
    //Serial.print(rfidReadString);
  }

  //Serial.print(rfidReadString);
  
  // If blue team activates point
  if(!redCaptured && !blueCaptured && flag && rfidReadString == "1,blue"){
    //blue1 = true;
    blueCaptured = true;
    Serial.print("1");
  }
  if(!redCaptured && !blueCaptured && flag && rfidReadString == "2,blue"){
    //blue2 = true;
    blueCaptured = true;
    Serial.print("2");
  }
  if(!redCaptured && !blueCaptured && flag && rfidReadString == "3,blue"){
    //blue3 = true;
    blueCaptured = true;
    Serial.print("3");
  }
  if(!redCaptured && !blueCaptured && flag && rfidReadString == "4,blue"){
    //blue4 = true;
    blueCaptured = true;
    Serial.print("4");
  }
  if(!blueCaptured && !redCaptured && flag && rfidReadString == "1,red"){
    //red1 = true;
    redCaptured = true;
    Serial.print("5");
  }
  if(!blueCaptured && !redCaptured && flag && rfidReadString == "2,red"){
    //red2 = true;
    redCaptured = true;
    Serial.print("6");
  }
  if(!blueCaptured && !redCaptured && flag && rfidReadString == "3,red"){
    //red3 = true;
    redCaptured = true;
    Serial.print("7");
  }
  if(!blueCaptured && !redCaptured && flag && rfidReadString == "4,red"){
    //red4 = true;
    redCaptured = true;
    Serial.print("8");
  }

  if(blueBase && blue1 && rfidReadString == "1,blue"){
    Serial.print("1");
    blueCapturedComplete = true;
  }
  if(blueBase && blue2 && rfidReadString == "2,blue"){
    Serial.print("2");
    blueCapturedComplete = true;
  }
  if(blueBase && blue3 && rfidReadString == "3,blue"){
    Serial.print("3");
    blueCapturedComplete = true;
  }
  if(blueBase && blue4 && rfidReadString == "4,blue"){
    Serial.print("4");
    blueCapturedComplete = true;
  }

  if(redBase && red1 && rfidReadString == "1,red"){
    Serial.print("5");
    redCapturedComplete = true;
  }
  if(redBase && red2 && rfidReadString == "2,red"){
    Serial.print("6");
    redCapturedComplete = true;
  }
  if(redBase && red3 && rfidReadString == "3,red"){
    Serial.print("7");
    redCapturedComplete = true;
  }
  if(redBase && red4 && rfidReadString == "4,red"){
    Serial.print("8");
    redCapturedComplete = true;
  }


if(pointA){
  if(DOM && rfidReadString == "1,blue"){
    Serial.print("1");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "2,blue"){
    Serial.print("2");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "3,blue"){
    Serial.print("3");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "4,blue"){
    Serial.print("4");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "1,red"){
    Serial.print("5");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "2,red"){
    Serial.print("6");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "3,red"){
    Serial.print("7");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "4,red"){
    Serial.print("8");
    blueCaptured = false;
    redCaptured = true;
  }
}
if(pointB){
  if(DOM && rfidReadString == "1,blue"){
    Serial.print("1");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "2,blue"){
    Serial.print("2");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "3,blue"){
    Serial.print("3");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "4,blue"){
    Serial.print("4");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "1,red"){
    Serial.print("5");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "2,red"){
    Serial.print("6");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "3,red"){
    Serial.print("7");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "4,red"){
    Serial.print("8");
    blueCaptured = false;
    redCaptured = true;
  }
}
if(pointC){
  if(DOM && rfidReadString == "1,blue"){
    Serial.print("1");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "2,blue"){
    Serial.print("2");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "3,blue"){
    Serial.print("3");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "4,blue"){
    Serial.print("4");
    blueCaptured = true;
    redCaptured = false;
  }
  if(DOM && rfidReadString == "1,red"){
    Serial.print("5");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "2,red"){
    Serial.print("6");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "3,red"){
    Serial.print("7");
    blueCaptured = false;
    redCaptured = true;
  }
  if(DOM && rfidReadString == "4,red"){
    Serial.print("8");
    blueCaptured = false;
    redCaptured = true;
  }
}
  rfidReadString = "";
}


