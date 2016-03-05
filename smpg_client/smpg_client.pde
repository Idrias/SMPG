/*
  SMPG - Simple Multiplayer Pong Game
    written by Rouven Grenz (02/2016)
  
  A pong clone that works over the network! Yeah!
*/

import processing.net.*;

/// /// /// /// /// /// /// /// ///
String VERSION = "1.2";
/// /// /// /// /// /// /// /// ///

/// IMPORTANT CONNECTION VARS ///
String HOST_IP = "127.0.0.1";
int    PORT_ID = 6878; 
String PLAYERNAME = "PLAYER";
/// /// /// /// /// /// /// /// ///



Client myClient;
String msg = "";
String playerB = "lorem";
int YposA = 0;
int YposB = -25;
int YposC = 0; // C ist der Ball
int XposC = 0;
int pointsA = 0;
int pointsB = 0;
boolean pressedUP = false; 
boolean pressedDOWN = false;
char oppopos = 'a';


void setup() {
  size(600, 300);
  background(0);
  strokeWeight(2);
  frameRate(120);
 
  
  myClient = new Client(this, HOST_IP, PORT_ID);
  myClient.write("NAME="+PLAYERNAME);
}


void draw() { 
  background(0);
  if(!myClient.active()) background(255, 0, 0); // Client wurde vom Host getrennt!
  
  // Spielfeld zeichnen
  noFill();
  stroke(90, 90, 90);
  line(width/2, 0, width/2, height);
  ellipse(width/2, height/2, 30, 30);
  
  textSize(15);
  text(pointsA, width/2 - 40, 20);
  text(pointsB,  width/2 + 30, 20);
  textSize(12);
  
  // Balken und Ball zeichnen
  fill(255);  
  stroke(255);  
  line(50, YposA+25, 50, YposA-25);
  line(width-50, YposB+25, width-50, YposB-25);
  ellipse(XposC, YposC, 5, 5);
  
  /////
  if(playerB!="lorem") {
    textAlign(CENTER);
    if(oppopos=='l') {text(playerB, width/4, 12); text(PLAYERNAME, 3*width/4, 12);}
    else {text(playerB, 3*width/4, 12); text(PLAYERNAME, width/4, 12);};
    textAlign(LEFT);
  }
  
  // Aktuell gedrückte Tasten übermitteln
  myClient.write("UP=" + int(pressedUP) + "DOWN=" + int(pressedDOWN));
}