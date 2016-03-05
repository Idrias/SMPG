/*
  SMPG - Simple Multiplayer Pong Game
    written by Rouven Grenz (02/2016)
  
  A pong clone that works over the network! Yeah!
*/

/*
  TODO: 
    - Server GUI (buttons)
    - better ball physics
*/

import processing.net.*;

/// /// /// /// /// /// /// /// ///
String VERSION = "1.1";
/// /// /// /// /// /// /// /// ///

/// IMPORTANT CONNECTION VARS ///
int    PORT_ID = 6878; 
/// /// /// /// /// /// /// /// ///



Server myServer;
Ball ball;
ArrayList<PongClient> pongClients;

int pointsA = 0;
int pointsB = 0;
int timer = 0;
boolean clientA_cheatmode = false;
boolean clientB_cheatmode = false;
boolean pause = false;

void setup() {
  size(600, 300);
  background(0);
  frameRate(120);

  myServer = new Server(this, PORT_ID);
  pongClients = new ArrayList<PongClient>();
  ball = new Ball();
}


void draw() {
  checkIncomingMail();  
  game();
  send(); 
  giveScreenInfo();
}