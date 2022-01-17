Player Me;

ArrayList<Player> players = new ArrayList<Player>();

// -----

class Player{
  
  boolean isMe;
  int ID;
  String name;
  
  // -----
  
  StringList guesses = new StringList();
  
  // -----
  
  Player(boolean isMe_, int ID_, String name_){
    isMe = isMe_;
    ID = ID_;
    name = name_;
    println("Player added: " + ID + " " + name);
  } // construct
  
  void reset(){
    guesses = new StringList();
  } // reset
  
  void display(int num){
    pushMatrix();
    translate(20, 150 * num + 200);
    stroke(255);
    noFill();
    rect(0, 0, 80, 100);
    fill(255);
    textSize(16);
    
    textAlign(LEFT,BOTTOM);
    text(name + " " + ID, 0, 0);
    
    for(int i = 0; i < guesses.size(); i++){
      String g = guesses.get(i);
      for(int j = 0; j < g.length(); j++){
        char ch = g.charAt(j);
        text(ch, 15*j + 5, 15*i + 20);
      } // for each letter
       
    } // for each guess
    
    popMatrix();
  } // display
  
  // -----
  
  void drawGrid(){
    pushStyle();
  noFill();
  stroke(absent);
  strokeWeight(2);
  for(int i = 0; i < guessesMax; i++){
    for(int j = 0; j < 5; j++)
      rect(pos.x + letterSize*letterBoxRatio*j, pos.y + letterSize*letterBoxRatio*i, letterSize*letterBoxRatio, letterSize*letterBoxRatio, rectRadii);
  }
  popStyle();
  
  // Color the letter squares v2
  int fill = absent;
  for(int g = 0; g < guesses.size(); g++){
    for(int i = 0; i < word.length(); i++){
      for(int l = 0; l < guesses.get(g).length(); l++){
        fill = absent;
        char letterCur = guesses.get(g).charAt(i);
        if(word.contains(Character.toString(letterCur))){
          if(letterCur == word.charAt(i)){
            fill = correct;
          }
          if(letterCur != word.charAt(i) && fill != correct){
            fill = present;
          }
        } else {
          fill = absent;
        }
      }
      fill(fill);
      rect(pos.x + letterSize*letterBoxRatio*i, pos.y + letterSize*letterBoxRatio*g, letterSize*letterBoxRatio, letterSize*letterBoxRatio, rectRadii);
    }
  }
  
  // Draw each letter in the current guess
  for(int g = 0; g < guesses.size(); g++){
    for(int i = 0; i < 5; i++){
      fill(textColor);
      textAlign(CENTER, TOP);
      text(guesses.get(g).toUpperCase().charAt(i), pos.x + (letterSize*letterBoxRatio*i) + letterSize*letterBoxRatio/2, (pos.y + letterSize*letterBoxRatio*g)+letterSize/6);
    }
  }
  
  } // gridColors
  
  // -----
  
} // Player

// ---------- ---------- ---------- ---------- ----------

Player playerByID(int ID){
  for(Player p : players) if(p.ID == ID) return p;
  return null;
} // playerByID
