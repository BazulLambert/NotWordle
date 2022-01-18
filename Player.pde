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
    translate(20, 200 * num + 20);
    stroke(255);
    noFill();
    rect(0, 0, 130, 160);
    fill(255);
    textSize(18);
    
    textAlign(LEFT,BOTTOM);
    text(name, 0, 0);
    
    //
    //// change this to all use centered coords
    //
    
    textAlign(LEFT, CENTER);
    for(int i = 0; i < guesses.size(); i++){
      String g = guesses.get(i);
      color[] colors = getColors(g, word);
      
      for(int j = 0; j < g.length(); j++){
        char ch = g.charAt(j);
        int x = 24*j + 10;
        int y = 24*i + 10;
        
        fill(colors[j]);
        noStroke();
        rect(x, y, 20, 20);
        
        fill(255);
        if(victory || defeat) text((""+ch).toUpperCase(), x+5, y+7);
      } // for each letter
       
    } // for each guess
    
    popMatrix();
  } // display
  
  // -----
  
  color[] getColors(String guess, String word){
    int len = word.length();
    color[] col = new color[len];
    
    for(int i = 0; i < len; i++){
      col[i] = absent;
      char cG = guess.charAt(i);
      char cW = word.charAt(i);
      if(cG == cW) col[i] = correct;
    } // for each pair of letters
    
    for(int c = 0; c < len; c++){
      for(int w = 0; w < len; w++){
        char cG = guess.charAt(c);
        char cW = word.charAt(w); 
          if(col[c] != correct){
            if(cG == cW) col[c] = present;
          } // if not already green
      } // for each letter in word
    } // for each letter in guess
    
    return col;
  } // getColors
  
  // -----
  
} // Player

// ---------- ---------- ---------- ---------- ----------

Player playerByID(int ID){
  for(Player p : players) if(p.ID == ID) return p;
  return null;
} // playerByID
