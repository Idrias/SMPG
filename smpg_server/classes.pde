class PongClient {
  // Ein verbundener Spieler ist ein PongClient
  
  Client client;  // Der "normale" Client, der dem Server Nachrichten schickt
  boolean up = false;
  boolean down = false;
  char player;
  int ypos = 100; 
  int lastping = -1234;
  
  PongClient(Client iclient, char iplayer) {
    client = iclient;
    player = iplayer;
  }
  
  void move() {
    if(up && ypos > 25) ypos-=2;
    if(down && ypos < height-25) ypos+=2;
    
    if(player=='A') {
      if(ball.oldX>50 && ball.xpos < 50) {
        if(ball.oldY <= ypos+30 && ball.oldY >= ypos-30) {
          ball.xvel = -ball.xvel;
          ball.yvel = -ball.yvel;
        }
      }
    }  
     if(player=='B') {
      if(ball.oldX<width-50 && ball.xpos > width-50) {
        if(ball.oldY <= ypos+30 && ball.oldY >= ypos-30) {
          ball.xvel = -ball.xvel;
          ball.yvel = -ball.yvel;
        }
      }
    }
  }
}


class Ball {
  float oldX;
  float oldY;
  float xpos;
  float ypos;
  float xvel = 0;
  float yvel = 0;
  
  Ball() {
    reset_vars();
  }
  
  void reset_vars() {
    xpos = width/2;
    ypos = height/2;
    xvel = 0;
    yvel = 0;
    while(abs(xvel) < 1.0 || abs(yvel) < 0.3) {
    xvel = random(-1.5, 1.5);
    yvel = random(-2.5, 2.5);
    }
  }
  
  void move() {
    oldX = xpos;
    oldY = ypos;
    xpos += xvel;
    ypos += yvel;
    
    if(abs(xvel)<2.7) xvel += 0.0001*xvel*random(1, 5);      
    if(abs(yvel)<3.5) yvel += 0.0001*yvel*random(1, 5);
    if(ypos > height/2+100) ypos-=0.01;
    if(ypos < height/2-100) ypos+=0.01;
  }
}