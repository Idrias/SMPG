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
String VERSION = "1.2";
/// /// /// /// /// /// /// /// ///

/// IMPORTANT CONNECTION VARS ///
int    PORT_ID = 6878; 
/// /// /// /// /// /// /// /// ///



Server myServer;
Ball ball;
ArrayList<PongClient> pongClients;
ArrayList<Button> buttons;


int table_width = 600;
int table_height = 300;
int pointsA = 0;
int pointsB = 0;
int timer = 0;
boolean clientA_cheatmode = false;
boolean clientB_cheatmode = false;
boolean pause = false;
boolean debugmode = false;

void setup() {
  size(600, 500);
  background(0);
  frameRate(120);
   textAlign(CENTER);

  myServer = new Server(this, PORT_ID);
  pongClients = new ArrayList<PongClient>();
  buttons = new ArrayList<Button>();
  
  buttons.add(new Button(table_width/2-50, table_height+50, 100, 30, "Pause game", 'p'));
  buttons.add(new Button(table_width/2-50, table_height+100, 100, 30, "Reset game", 'r'));
  buttons.add(new Button(width-30, 0, 30, 20, "D", 'd'));
  
  buttons.add(new Button(50, table_height+50, 100, 30, "Cheatmode A", 'a'));
  buttons.add(new Button(50, table_height+100, 100, 30, "Kick A", 'A'));
  buttons.add(new Button(table_width-150, table_height+50, 100, 30, "Cheatmode B", 'b'));
  buttons.add(new Button(table_width-150, table_height+100, 100, 30, "Kick B", 'B'));
    

  ball = new Ball();
}


void draw() {
  checkIncomingMail();  
  game();
  send(); 
  giveScreenInfo();
}