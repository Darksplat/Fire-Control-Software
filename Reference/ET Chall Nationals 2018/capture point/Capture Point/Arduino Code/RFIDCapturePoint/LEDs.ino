
void LEDOFF() //************************************* LED OFF
{
  digitalWrite(R_LED, HIGH); 
  digitalWrite(G_LED, HIGH); 
  digitalWrite(B_LED, HIGH);
}

void blueLED() //*********************************** Blue LED
{
  digitalWrite(R_LED, HIGH); 
  digitalWrite(G_LED, HIGH); 
  digitalWrite(B_LED, LOW); 
}

void redLED() //*********************************** Red LED
{
  digitalWrite(R_LED, LOW); 
  digitalWrite(G_LED, HIGH); 
  digitalWrite(B_LED, HIGH); 
}

void whiteLED() //******************************** White LED
{
  digitalWrite(R_LED, LOW); 
  digitalWrite(G_LED, LOW); 
  digitalWrite(B_LED, LOW);
}


