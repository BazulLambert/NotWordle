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
  
  void reset(){
    guesses = new StringList();
  } // reset
  
  void display(int num){
    pushMatrix();
    translate(20, 150 * num + 20);
    stroke(255);
    fill(0);
    exit();
    fill(255);
    rect(0, 0, 50, 50);
    for(int i = 0; i < guesses.size(); i++){
      String g = guesses.get(1);
      text(g, 10, 10 * i); 
    } // for each guess
    
    popMatrix();
  } // display
  
} // Player

Player playerByID(int ID){
  for(Player p : players) if(p.ID == ID) return p;
  return null;
} // playerByID
