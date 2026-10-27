void LEDOFF() //************************************* LED OFF
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 255);
}

void blueLED() //*********************************** Blue LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 0); 
}

void redLED() //*********************************** Red LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 255); 
}

void whiteLED() //******************************** White LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 0);
}

void purpleLED() //******************************** Purple LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 255); 
  analogWrite(B_LED, 0);
}

void greenLED() //******************************** Green LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 255);
}

void yellowLED() //******************************** yellow LED
{
  analogWrite(R_LED, 0); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 255);
}

void aquaLED() //******************************** aqua LED
{
  analogWrite(R_LED, 255); 
  analogWrite(G_LED, 0); 
  analogWrite(B_LED, 0);
}
