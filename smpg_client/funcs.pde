void keyPressed() {
       if(key=='w') pressedUP = true;
  else if(key=='s') pressedDOWN = true;
}


void keyReleased() {
       if(key=='w') pressedUP = false;
  else if(key=='s') pressedDOWN = false;
}


void clientEvent(Client receiver) { 
  // Wir basteln uns unsere Nachricht aus einzeln empfangenen Zeichen zusammen!
  // Diese Funktion wird jedes mal aufgerufen, wenn ein neues Zeichen empfangen wurde.
  char letter = receiver.readChar();
       if(letter == '<') msg = "";         // Beginn der Nachricht, alte Nachricht löschen
  else if(letter == '>') update_vars();    // Ende der Nachricht, diese nun auswerten
  else                   msg += letter;    // Der bisher empfangenen Nachricht das neu empfangene Zeichen hinzufügen
}


void update_vars() {
  // Rausfinden, wo sich der auszulesende Wert befindet und diesen in "number" speichern!
  int index_equals = msg.indexOf("=");
  int number = int(msg.substring(index_equals+1, msg.length()));
  
  // Je nachdem, welcher Wert übermittelt wurde, soll dieser lokal angepasst werden
       if(msg.contains("YposA")) YposA = number;
  else if(msg.contains("YposB")) YposB = number;
  else if(msg.contains("YposC")) YposC = number;
  else if(msg.contains("XposC")) XposC = number;
  else if(msg.contains("PointsA")) PointsA = number;
  else if(msg.contains("PointsB")) PointsB = number;
  else if(msg.contains("PING")) myClient.write("PONG");
}