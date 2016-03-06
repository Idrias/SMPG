import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class smpg_server extends PApplet {

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

public void setup() {
  
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


public void draw() {
  checkIncomingMail();  
  game();
  send(); 
  giveScreenInfo();
}
class PongClient {
  // Ein verbundener Spieler ist ein PongClient
  
  Client client;  // Der "normale" Client, der dem Server Nachrichten schickt
  boolean up = false;
  boolean down = false;
  String name = "";
  char player;
  int ypos = 100; 
  int lastping = -1234;
  
  PongClient(Client iclient, char iplayer) {
    client = iclient;
    player = iplayer;
  }
  
  public void move() {
    if(up && ypos > 25) ypos-=2;
    if(down && ypos < table_height-25) ypos+=2;
    ball.collisionCheck(player, ypos);
  }
}


class Ball {
  PVector old;
  PVector pos;
  PVector vel;
  
  Ball() {
    old = new PVector();
    pos = new PVector();
    vel = new PVector();
    
    reset_vars();
  }
  
  public void reset_vars() {
    pos.x = table_width/2;
    pos.y = table_height/2;
    vel.x = 0;
    vel.y = 0;
    
    while(abs(vel.x) < 1.0f || abs(vel.y) < 0.3f) {
    vel.x = random(-1.5f, 1.5f);
    vel.y = random(-2.5f, 2.5f);
    }
  }
  
  public void move() {
    old.x = pos.x;
    old.y = pos.y;
    pos.x += vel.x ;
    pos.y += vel.y;
    
    if(abs(vel.x)<2.7f) vel.x += 0.0001f*vel.x*random(1, 5);      
    if(abs(vel.y)<3.5f) vel.y += 0.0001f*vel.y*random(1, 5);
    if(pos.y > table_height/2+100) pos.y-=0.01f;
    if(pos.y < table_height/2-100) pos.y+=0.01f;
  }
  
  public void collisionCheck(char player, float ypos_paddle) {
    if(player=='A') {
      if(old.x>50 && pos.x < 50) {
        if(old.y <= ypos_paddle +30 && old.y >= ypos_paddle-30) {
          vel.x = -vel.x;
          vel.y = -vel.y;
        }
      }
    }  
     if(player=='B') {
      if(old.x<table_width-50 && pos.x > table_width-50) {
        if(old.y <= ypos_paddle+30 && old.y >= ypos_paddle-30) {
          vel.x = -vel.x;
          vel.y = -vel.y;
        }
      }
    }
  }
}


class Button {
  PVector pos;
  PVector size;
  String text;
  boolean switched_on = false;
  int off_color = color(30);
  int on_color = color(120);
  char my_key;
  
  Button(int ixpos, int iypos, int ixsize, int iysize, String itext, char ikey) {
    pos = new PVector();
    size = new PVector();
    
    pos.x = ixpos;
    pos.y = iypos;
    size.x = ixsize;
    size.y = iysize;
    text = itext;
    my_key = ikey;
  }
  
  public void draw() {
    if(switched_on) fill(on_color);
    else fill(off_color);
    rect(pos.x, pos.y, size.x, size.y, 10, 10, 10, 10);
    fill(255);
    text(text, pos.x+size.x/2, pos.y+size.y/2+5);
  }
  
  public void mouseAction() {
    if(mousePressed && mouseX > pos.x && mouseX < pos.x + size.x && mouseY > pos.y && mouseY < pos.y + size.y) {
      switched_on = !switched_on; 
    }
  }
}


public PongClient findPongClient(char whichPlayer) {
  for(PongClient pongClient : pongClients) {
    if(pongClient.player == whichPlayer)
      return pongClient;
  }
  return null;
}


public void keyPressed() {
       if(key=='r') {pointsA = 0; pointsB = 0; ball.reset_vars(); background(0);}
  else if(key=='A' && findPongClient('A') != null) {myServer.disconnect(findPongClient('A').client); pongClients.remove(findPongClient('A')); println("KICKED PLAYER A");}
  else if(key=='B' && findPongClient('B') != null) {myServer.disconnect(findPongClient('B').client); pongClients.remove(findPongClient('B')); println("KICKED PLAYER B");}
  else if(key=='a') clientA_cheatmode = !clientA_cheatmode;
  else if(key=='b') clientB_cheatmode = !clientB_cheatmode;
  else if(key=='p') pause = !pause;
  else if(key=='d') debugmode = !debugmode;
}


public void mousePressed() {
  for(Button button : buttons) {
    button.mouseAction();
  }
}

public void game() {
  if(!pause) {
    for(PongClient pC : pongClients) {
      pC.move();
    }
  
    ball.move();
  
    if(ball.pos.x < 0 && clientA_cheatmode) {ball.vel.x=-ball.vel.x;}
    else if(ball.pos.x < 0) {pointsB++; ball.reset_vars();}
  
    if(ball.pos.x > table_width && clientB_cheatmode) { ball.vel.x=-ball.vel.x;}
    else if (ball.pos.x > table_width) {pointsA++; ball.reset_vars();}
  
    do {
      if(ball.pos.y > table_height) ball.vel.y = random(0.5f, 1.5f) * -ball.vel.y;
      if(ball.pos.y < 0) ball.vel.y = random(0.5f, 1.5f) * -ball.vel.y;
      if(abs(ball.vel.y) < 0.2f) ball.vel.y *= 2;
    } while (abs(ball.vel.y) < 0.2f);
  }
}


public void giveScreenInfo() {
  PongClient clientA = findPongClient('A');
  PongClient clientB = findPongClient('B');
  
  // DRAW ON SCREEN
  background(0);
  noFill();
  stroke(90, 90, 90);
  strokeWeight(2);
  line(table_width/2, 0, table_width/2, table_height);
  line(0, table_height, table_width, table_height);
  ellipse(table_width/2, table_height/2, 30, 30);

  
  fill(255);  
  stroke(255);  

  if(clientA!=null) {
    text(clientA.name, width/4, 12);
    line(50, clientA.ypos+25, 50, clientA.ypos-25);
    if(debugmode) {
      textAlign(LEFT);
      text(clientA.client.toString() + " - A", 60, clientA.ypos); 
      text(clientA.client.ip(), 60, clientA.ypos+12); 
      text("Ping = " + clientA.lastping, 65, clientA.ypos+24);
      textAlign(CENTER);
    }
    

  }
  
  if(clientB!=null) {
  line(table_width-50, clientB.ypos+25, table_width-50, clientB.ypos-25);
  text(clientB.name, 3*width/4, 12);
  if(debugmode) {
    textAlign(RIGHT);
    text(clientB.client.toString() + " - B", table_width-60, clientB.ypos);
    text(clientB.client.ip(), table_width-60, clientB.ypos+12);
    text("Ping = " + clientB.lastping, table_width-60, clientB.ypos+24);
    textAlign(CENTER);
  }

}
  
  strokeWeight(1);
  textSize(15);
  text(pointsA, table_width/2 - 40, 20);
  text(pointsB,  table_width/2 + 40, 20);
  ellipse(ball.pos.x, ball.pos.y, 5, 5);
  textSize(12);
  


  text("ServerIP: " + Server.ip(), table_width/4, table_height-7);
  text("Port ID: " + PORT_ID, 3*table_width/4, table_height-7);
  
  if(clientA_cheatmode) text("A is cheating!", 150, table_height/2+86);
  if(clientB_cheatmode) text("B is cheating!", 150, table_height/2+98);
  
  if(debugmode) {
  textAlign(RIGHT);
  text("Ball X: " + PApplet.parseInt(ball.pos.x), table_width/2-5, table_height/2+50);
  text("Ball Y: " + PApplet.parseInt(ball.pos.y), table_width/2-5, table_height/2+62);
  textAlign(LEFT);
  text("VX:" + PApplet.parseFloat(round(ball.vel.x*100)) / 100, table_width/2+5, table_height/2+50);
  text("VY:" + PApplet.parseFloat(round(ball.vel.y*100)) / 100, table_width/2+5, table_height/2+62);
  textAlign(CENTER);
  }
  

  
  for(Button button : buttons) {
    button.draw();
    if(button.switched_on) {
      key = button.my_key;
      button.switched_on = !button.switched_on;
      keyPressed();
    }
  }
  
}
public void send() {
  PongClient clientA = findPongClient('A');
  PongClient clientB = findPongClient('B');
  
  if(frameCount%240==0) {myServer.write("<PING>"); timer = millis();}
  
  if(clientA!=null) myServer.write("<YposA=" + clientA.ypos + ">");
  else myServer.write("<YposA=" + -50 + ">");
  if(clientB!=null) myServer.write("<YposB=" + clientB.ypos + ">");
  else myServer.write("<YposB=" + -50 + ">");
  
  myServer.write("<YposC=" + PApplet.parseInt(ball.pos.y) + ">");
  myServer.write("<XposC=" + PApplet.parseInt(ball.pos.x) + ">");
  myServer.write("<PointsA=" + pointsA + ">");
  myServer.write("<PointsB=" + pointsB + ">");
}


public void checkIncomingMail(){
  // Empfangene Nachricht auslesen!
  Client next_client = myServer.available();
  
  while(next_client != null) {
    String whateveritsaid = next_client.readString();
  
    if(whateveritsaid != null) {
        for(PongClient pC : pongClients) {
          if(next_client == pC.client) {
            
           if(whateveritsaid.contains("PONG")) pC.lastping = millis() - (timer+8);
           
           if(whateveritsaid.contains("NAME")) {
             pC.name = whateveritsaid.substring(5, whateveritsaid.length());
             if(findPongClient('A') != null) myServer.write("<NAMEA=" + findPongClient('A').name + ">");
             if(findPongClient('B') != null) myServer.write("<NAMEB=" + findPongClient('B').name + ">");
           }

           else if(whateveritsaid.charAt(0) == 'U' && whateveritsaid.length()  >= 10) {
               if(whateveritsaid.charAt(3) == '1') pC.up = true;
               else pC.up = false;
              
               if(whateveritsaid.charAt(9) == '1') pC.down = true;
               else pC.down = false;
            }  
            
            else if(whateveritsaid.charAt(0) == 'D' && whateveritsaid.length()  >= 10) {
              if(whateveritsaid.charAt(9) == '1') pC.up = true;
              else pC.up = false;
              if(whateveritsaid.charAt(5) == '1') pC.down = true;
              else pC.down = false;
            }  
          }
       }
    }
    next_client = myServer.available();
  }
}


public void serverEvent(Server theServer, Client newClient) {
  println(newClient + " connected to " + theServer);
  
  if(pongClients.size() >= 2) {
    println("Already got 2 clients...");
    myServer.disconnect(newClient);
    return;
  }
  
  if(findPongClient('A') == null) pongClients.add(new PongClient(newClient, 'A'));
  else pongClients.add(new PongClient(newClient, 'B'));
}


public void disconnectEvent(Client whoLeft) {
  println(whoLeft + " left the server :(");
  
  for(PongClient pC : pongClients) {
    if(pC.client == whoLeft) pongClients.remove(pC);
  }
}
  public void settings() {  size(600, 500); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "smpg_server" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
