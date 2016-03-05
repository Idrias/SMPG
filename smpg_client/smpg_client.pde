/*
  SMPG - Simple Multiplayer Pong Game
    written by Rouven Grenz (02/2016)
  
  A pong clone that works over the network! Yeah!
*/

import processing.net.*;

/// /// /// /// /// /// /// /// ///
String VERSION = "1.1";
/// /// /// /// /// /// /// /// ///

/// IMPORTANT CONNECTION VARS ///
String HOST_IP = "127.0.0.1";
int    PORT_ID = 6878; 
/// /// /// /// /// /// /// /// ///



Client myClient;
String msg = "";
int YposA = 0;
int YposB = -25;
int YposC = 0; // C ist der Ball
int XposC = 0;
int PointsA = 0;
int PointsB = 0;
boolean pressedUP = false; 
boolean pressedDOWN = false;


void setup() {
  size(600, 300);
  background(0);
  strokeWeight(3);
  frameRate(120);
  
  myClient = new Client(this, HOST_IP, PORT_ID);
}


void draw() { 
  background(0);
  if(!myClient.active()) background(255, 0, 0); // Client wurde vom Host getrennt!
  
  // Spielfeld zeichnen
  noFill();
  stroke(90, 90, 90);
  line(width/2, 0, width/2, height);
  ellipse(width/2, height/2, 30, 30);
  text(PointsA + " : " + PointsB, width/2, 20);
  
  // Balken und Ball zeichnen
  fill(255);  
  stroke(255);  
  line(50, YposA+25, 50, YposA-25);
  line(width-50, YposB+25, width-50, YposB-25);
  ellipse(XposC, YposC, 5, 5);
  
  // Aktuell gedrückte Tasten übermitteln
  myClient.write("UP=" + int(pressedUP) + "DOWN=" + int(pressedDOWN));
}