

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
}


void game() {
  if(!pause) {
    for(PongClient pC : pongClients) {
      pC.move();
    }
  
    ball.move();
  
    if(ball.xpos < 0 && clientA_cheatmode) {ball.xvel=-ball.xvel;}
    else if(ball.xpos < 0) {pointsB++; ball.reset_vars();}
  
    if(ball.xpos > width && clientB_cheatmode) { ball.xvel=-ball.xvel;}
    else if (ball.xpos > width) {pointsA++; ball.reset_vars();}
  
    do {
      if(ball.ypos > height) ball.yvel = random(0.5, 1.5) * -ball.yvel;
      if(ball.ypos < 0) ball.yvel = random(0.5, 1.5) * -ball.yvel;
      if(abs(ball.yvel) < 0.2) ball.yvel *= 2;
    } while (abs(ball.yvel) < 0.2);
  }
}


void giveScreenInfo() {
  PongClient clientA = findPongClient('A');
  PongClient clientB = findPongClient('B');
  
  // DRAW ON SCREEN
  background(0);
  noFill();
  stroke(90, 90, 90);
  line(width/2, 0, width/2, height);
  ellipse(width/2, height/2, 30, 30);
  
  fill(255);  
  stroke(255);  

  if(clientA!=null) {line(50, clientA.ypos+25, 50, clientA.ypos-25); text(clientA.client.toString() + " - A", 60, clientA.ypos); text(clientA.client.ip(), 60, clientA.ypos+12); text("Ping = " + clientA.lastping, 65, clientA.ypos+24);}
  if(clientB!=null) {line(width-50, clientB.ypos+25, width-50, clientB.ypos-25); text(clientB.client.toString() + " - B", width-250, clientB.ypos); text(clientB.client.ip(), width-250, clientB.ypos+12); text("Ping = " + clientB.lastping, width-245, clientB.ypos+24);}

  text(pointsA + " : " + pointsB, width/2, 20);
  ellipse(ball.xpos, ball.ypos, 5, 5);
  
  text("ServerIP: " + Server.ip(), 150, height/2+50);
  text("Port ID: " + PORT_ID, 150, height/2+62);
  text("Ball X: " + int(ball.xpos), width/2+30, height/2+50);
  text("Ball Y: " + int(ball.ypos), width/2+30, height/2+62);
  text("Ball VEL: X:" + float(round(ball.xvel*100)) / 100 + " Y:" + float(round(ball.yvel*100)) / 100, width/2+30, height/2+74);
  
  if(clientA_cheatmode) text("A is cheating!", 150, height/2+86);
  if(clientB_cheatmode) text("B is cheating!", 150, height/2+98);
}