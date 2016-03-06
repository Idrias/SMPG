void send() {
  PongClient clientA = findPongClient('A');
  PongClient clientB = findPongClient('B');
  
  if(frameCount%240==0) {myServer.write("<PING>"); timer = millis();}
  
  if(clientA!=null) myServer.write("<YposA=" + clientA.ypos + ">");
  else myServer.write("<YposA=" + -50 + ">");
  if(clientB!=null) myServer.write("<YposB=" + clientB.ypos + ">");
  else myServer.write("<YposB=" + -50 + ">");
  
  myServer.write("<YposC=" + int(ball.pos.y) + ">");
  myServer.write("<XposC=" + int(ball.pos.x) + ">");
  myServer.write("<PointsA=" + pointsA + ">");
  myServer.write("<PointsB=" + pointsB + ">");
}


void checkIncomingMail(){
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


void serverEvent(Server theServer, Client newClient) {
  println(newClient + " connected to " + theServer);
  
  if(pongClients.size() >= 2) {
    println("Already got 2 clients...");
    myServer.disconnect(newClient);
    return;
  }
  
  if(findPongClient('A') == null) pongClients.add(new PongClient(newClient, 'A'));
  else pongClients.add(new PongClient(newClient, 'B'));
}


void disconnectEvent(Client whoLeft) {
  println(whoLeft + " left the server :(");
  
  for(PongClient pC : pongClients) {
    if(pC.client == whoLeft) pongClients.remove(pC);
  }
}