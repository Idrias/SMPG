

PongClient findPongClient(char whichPlayer) {
  for(PongClient pongClient : pongClients) {
    if(pongClient.player == whichPlayer)
      return pongClient;
  }
  return null;
}


void keyPressed() {
       if(key=='r') {pointsA = 0; pointsB = 0; ball.reset_vars(); background(0);}
  else if(key=='A' && findPongClient('A') != null) {myServer.disconnect(findPongClient('A').client); pongClients.remove(findPongClient('A')); println("KICKED PLAYER A");}
  else if(key=='B' && findPongClient('B') != null) {myServer.disconnect(findPongClient('B').client); pongClients.remove(findPongClient('B')); println("KICKED PLAYER B");}
  else if(key=='a') clientA_cheatmode = !clientA_cheatmode;
  else if(key=='b') clientB_cheatmode = !clientB_cheatmode;
  else if(key=='p') pause = !pause;
  else if(key=='d') debugmode = !debugmode;
}


void mousePressed() {
  for(Button button : buttons) {
    button.mouseAction();
  }
}

void game() {
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
      if(ball.pos.y > table_height) ball.vel.y = random(0.5, 1.5) * -ball.vel.y;
      if(ball.pos.y < 0) ball.vel.y = random(0.5, 1.5) * -ball.vel.y;
      if(abs(ball.vel.y) < 0.2) ball.vel.y *= 2;
    } while (abs(ball.vel.y) < 0.2);
  }
}


void giveScreenInfo() {
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
  text("Ball X: " + int(ball.pos.x), table_width/2-5, table_height/2+50);
  text("Ball Y: " + int(ball.pos.y), table_width/2-5, table_height/2+62);
  textAlign(LEFT);
  text("VX:" + float(round(ball.vel.x*100)) / 100, table_width/2+5, table_height/2+50);
  text("VY:" + float(round(ball.vel.y*100)) / 100, table_width/2+5, table_height/2+62);
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