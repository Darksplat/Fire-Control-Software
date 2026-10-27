/* 
 * LED Colour code is setup for "-" LED (CNT1) Board
 * Flip Values 0 to 255 and 255 to 0 for "+" LED (CNT1) board
 */
 void LEDOFF() //************************************* LED OFF
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 0);
}

void blueLED() //*********************************** Blue LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 255); 
}

void redLED() //*********************************** Red LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 0); 
}

void whiteLED() //******************************** White LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 255);
}

void purpleLED() //******************************** Purple LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 255);
}

void greenLED() //******************************** Green LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 0);
}

void yellowLED() //******************************** yellow LED //more olive than yellow
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 222); 
  analogWrite(B_LED, 25);
}

void aquaLED() //******************************** aqua LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 255);
}
