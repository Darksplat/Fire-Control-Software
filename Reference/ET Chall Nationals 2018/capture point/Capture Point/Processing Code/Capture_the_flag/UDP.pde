/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Create a communication between Processing<->Pure Data @ http://puredata.info/
 * This program also requires to run a small program on Pd to exchange data  
 * (hum!!! for a complete experimentation), you can find the related Pd patch
 * at http://hypermedia.loeil.org/processing/udp.pd
 * 
 */

// import UDP library
import hypermedia.net.*;
import java.net.InetAddress;

InetAddress inet;
String ip;

UDP udp;  // define the UDP object

/**
 * init
 */
void UDP_Init() {
  
  try {
    InetAddress address = InetAddress.getByName(judge);
    ip = address.getHostAddress();
  }
  catch(Exception e) {
    ip = "192.168.2.3";
  }
  println("Judge IP Address: " + ip);


  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}

// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  
  String message = new String( data );
  String[] udpParts = split(message, ",");
  
// print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
  

  
//if(!blueFlag && !redFlag && udpParts[0].equals("1") && udpParts[1].equals("blue")){
// blueFlag = true;
//}

//if(ip.equals(flagIP) == true){
//  println("Test for flagIP worked");
//}

//if(ip.equals(blueTeamIP) == true){
//  println("Test for blueTeamIP worked");
//}  
//  if(ip.equals("192.168.2.4") == true){
//  println("Test for phoneIP worked");
//}


//if(ip.equals(flagIP) == true && udpParts[0].equals("1")){
//  Blue1 = true;
//  blueFlag = true;
//  udp.send("1", blueTeamIP, portRange);
//}

//if(ip.equals(blueTeamIP) == true && Blue1 == true && udpParts[0].equals("1")){
//  blueCaptured = true;
//}
  
    // UDP receive for when blue car 1 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("1"))
    {
      Blue1 = true;
      Blue2 = false;
      Blue3 = false;
      Blue4 = false;
      Red1 = false;
      Red2 = false;
      Red3 = false;
      Red4 = false;
      blueFlag = true;
      //udp.send("1", flagIP, portRange);
      udp.send("1", blueTeamIP, portRange);
      //udp.send("1", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Blue 1 has flag");
    }
    
     // UDP receive for when blue car 2 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("2"))
    {
      Blue1 = false;
      Blue2 = true;
      Blue3 = false;
      Blue4 = false;
      Red1 = false;
      Red2 = false;
      Red3 = false;
      Red4 = false;
      blueFlag = true;
      //udp.send("2", flagIP, portRange);
      udp.send("2", blueTeamIP, portRange);
      //udp.send("2", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Blue 2 has flag");
    }
    
     // UDP receive for when blue car 3 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("3"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = true;
      Blue4 = false;
      Red1 = false;
      Red2 = false;
      Red3 = false;
      Red4 = false;
      blueFlag = true;
      //udp.send("3", flagIP, portRange);
      udp.send("3", blueTeamIP, portRange);
      //udp.send("3", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Blue 3 has flag");
    }
    
     // UDP receive for when blue car 4 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("4"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = false;
      Blue4 = true;
      Red1 = false;
      Red2 = false;
      Red3 = false;
      Red4 = false;
      blueFlag = true;
      //udp.send("4", flagIP, portRange);
      udp.send("4", blueTeamIP, portRange);
      //udp.send("4", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Blue 4 has flag");
    }
    
    
     // UDP receive for when red car 1 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("5"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = false;
      Blue4 = false;
      Red1 = true;
      Red2 = false;
      Red3 = false;
      Red4 = false;
      redFlag = true;
      //udp.send("5", flagIP, portRange);
      //udp.send("5", blueTeamIP, portRange);
      udp.send("5", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Red 1 has flag");
    }
    
    // UDP receive for when red car 2 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("6"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = false;
      Blue4 = false;
      Red1 = false;
      Red2 = true;
      Red3 = false;
      Red4 = false;
      redFlag = true;
      //udp.send("6", flagIP, portRange);
      //udp.send("6", blueTeamIP, portRange);
      udp.send("6", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Red 2 has flag");
    }
    
    // UDP receive for when red car 3 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("7"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = false;
      Blue4 = false;
      Red1 = false;
      Red2 = false;
      Red3 = true;
      Red4 = false;
      redFlag = true;
      //udp.send("7", flagIP, portRange);
      //udp.send("7", blueTeamIP, portRange);
      udp.send("7", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Red 3 has flag");
    }
    
    // UDP receive for when red car 4 picked up flag
    if(!blueFlag && !redFlag && udpParts[0].equals("8"))
    {
      Blue1 = false;
      Blue2 = false;
      Blue3 = false;
      Blue4 = false;
      Red1 = false;
      Red2 = false;
      Red3 = false;
      Red4 = true;
      redFlag = true;
      //udp.send("8", flagIP, portRange);
      //udp.send("8", blueTeamIP, portRange);
      udp.send("8", redTeamIP, portRange);
      startCaptureTimer = millis();
      println("Red 4 has flag");
    }
        
    // UDP receive blue team captured flag
    if(ip.equals(blueTeamIP) == true && Blue1 && udpParts[0].equals("1")){
      if(blueFlag == true){
       blueCaptured = true;
       startCaptureTimer = millis();
       udp.send("B"+"r", flagIP, portRange);
       udp.send("B"+"r", blueTeamIP, portRange);
       udp.send("B"+"r", redTeamIP, portRange);
      }
    }
    
    // UDP receive blue team captured flag
    if(ip.equals(blueTeamIP) == true && Blue2 && udpParts[0].equals("2"))
    {
      if(blueFlag == true){
       blueCaptured = true;
       startCaptureTimer = millis();
       udp.send("B"+"r", flagIP, portRange);
       udp.send("B"+"r", blueTeamIP, portRange);
       udp.send("B"+"r", redTeamIP, portRange);
      }
    }
    
    // UDP receive blue team captured flag
    if(ip.equals(blueTeamIP) == true && Blue3 && udpParts[0].equals("3"))
    {
      if(blueFlag == true){
       blueCaptured = true;
       startCaptureTimer = millis();
       udp.send("B"+"r", flagIP, portRange);
       udp.send("B"+"r", blueTeamIP, portRange);
       udp.send("B"+"r", redTeamIP, portRange);
      }
    }
    
    // UDP receive blue team captured flag
    if(ip.equals(blueTeamIP) == true && Blue4 && udpParts[0].equals("4"))
    {
      if(blueFlag == true){
       blueCaptured = true;
       startCaptureTimer = millis();
       udp.send("B"+"r", flagIP, portRange);
       udp.send("B"+"r", blueTeamIP, portRange);
       udp.send("B"+"r", redTeamIP, portRange);
      }
    }
    
    // UDP receive blue team captured flag
    if(ip.equals(redTeamIP) == true && Red1 && udpParts[0].equals("5"))
    {
      if(redFlag == true){
       redCaptured = true;
       startCaptureTimer = millis();
       udp.send("R"+"r", flagIP, portRange);
       udp.send("R"+"r", blueTeamIP, portRange);
       udp.send("R"+"r", redTeamIP, portRange);
      }
    }
    
    if(ip.equals(redTeamIP) == true && Red2 && udpParts[0].equals("6"))
    {
      if(redFlag == true){
       redCaptured = true;
       startCaptureTimer = millis();
       udp.send("R"+"r", flagIP, portRange);
       udp.send("R"+"r", blueTeamIP, portRange);
       udp.send("R"+"r", redTeamIP, portRange);
      }
    }
    
    if(ip.equals(redTeamIP) == true && Red3 && udpParts[0].equals("7"))
    {
      if(redFlag == true){
       redCaptured = true;
       startCaptureTimer = millis();
       udp.send("R"+"r", flagIP, portRange);
       udp.send("R"+"r", blueTeamIP, portRange);
       udp.send("R"+"r", redTeamIP, portRange);
      }
    }
    
    if(ip.equals(redTeamIP) == true && Red4 && udpParts[0].equals("8"))
    {
      if(redFlag == true){
       redCaptured = true;
       startCaptureTimer = millis();
       udp.send("R"+"r", flagIP, portRange);
       udp.send("R"+"r", blueTeamIP, portRange);
       udp.send("R"+"r", redTeamIP, portRange);
      }
    }
}

void designateCapturePoints()
{
  //Set capture points to Team Capture the flag
 udp.send("C", flagIP, portRange);
 udp.send("C", blueTeamIP, portRange);
 udp.send("C", redTeamIP, portRange);
 
 //Designate each point its role
 udp.send("F", flagIP, portRange);
 udp.send("B", blueTeamIP, portRange);
 udp.send("R", redTeamIP, portRange);
}

void range()
{
  // Turn on blue turret
 if(activateBlueTurret){
   udp.send("1", blueTurret, portRange); // 1 = ON; 0 = OFF;
   udp.send("0", redTurret, portRange); // 1 = ON; 0 = OFF;
 }
 
 // Turn on red turret
 if(activateRedTurret){
   udp.send("1", redTurret, portRange); // 1 = ON; 0 = OFF;
   udp.send("0", blueTurret, portRange); // 1 = ON; 0 = OFF;
 }
 
 // Turn off turrets
 if(!activateBlueTurret && !activateRedTurret){
   udp.send("0", blueTurret, portRange); // 1 = ON; 0 = OFF;
   udp.send("0", redTurret, portRange); // 1 = ON; 0 = OFF;
 }
}

//void StartBots()
//{
//  udpFromTurret.send( "S", "192.168.0.152", 9002 );
//  udpFromTurret.send( "S", "192.168.0.153", 9000 );
//  startSent = true;
//  stopSent = false;
  
//}

//void StopBots()
//{
//  udpFromTurret.send( "P", "192.168.0.152", 9002);
//  udpFromTurret.send( "P", "192.168.0.153", 9000 );
//  stopSent = true;
//  startSent = false;
//}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */