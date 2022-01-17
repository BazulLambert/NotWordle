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
  } // construct
  
  void display(int x, int y){
    stroke(255);
    fill(0);
    rect(x, y, 20, 20);
  } // display
  
} // Player
