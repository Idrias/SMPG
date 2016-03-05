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
  
  void move() {
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
  
  void reset_vars() {
    pos.x = table_width/2;
    pos.y = table_height/2;
    vel.x = 0;
    vel.y = 0;
    
    while(abs(vel.x) < 1.0 || abs(vel.y) < 0.3) {
    vel.x = random(-1.5, 1.5);
    vel.y = random(-2.5, 2.5);
    }
  }
  
  void move() {
    old.x = pos.x;
    old.y = pos.y;
    pos.x += vel.x ;
    pos.y += vel.y;
    
    if(abs(vel.x)<2.7) vel.x += 0.0001*vel.x*random(1, 5);      
    if(abs(vel.y)<3.5) vel.y += 0.0001*vel.y*random(1, 5);
    if(pos.y > table_height/2+100) pos.y-=0.01;
    if(pos.y < table_height/2-100) pos.y+=0.01;
  }
  
  void collisionCheck(char player, float ypos_paddle) {
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
  color off_color = color(30);
  color on_color = color(120);
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
  
  void draw() {
    if(switched_on) fill(on_color);
    else fill(off_color);
    rect(pos.x, pos.y, size.x, size.y, 10, 10, 10, 10);
    fill(255);
    text(text, pos.x+size.x/2, pos.y+size.y/2+5);
  }
  
  void mouseAction() {
    if(mousePressed && mouseX > pos.x && mouseX < pos.x + size.x && mouseY > pos.y && mouseY < pos.y + size.y) {
      switched_on = !switched_on; 
    }
  }
}