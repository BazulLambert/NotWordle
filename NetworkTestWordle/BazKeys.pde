// ========== ========== ========== ========== ==========
// ==========       BAZKEYS CUSTOM CLASS       ==========
// ========== ========== ========== ========== ==========
//
// VERSION CHANGELOG
// V0.1-  Created
// V0.2-  Arrays now private, accessed by public functions for compatibility
//        All class updates should now be backwards compatible.
//        Replaced pressed[] and lastPressed[] with a single 2d array to add timing functionality
//        Added Pre() function, no longer need to call keys.controls()
// V0.3-  Renamed to BazKeys, split apart BazMouse, added class name as meta information.
//          This is in preparation of a super class "BazModule" (impossible until actually using a library)
//        BETA - Added character support. replace keyCode with character when calling function
//          This only applies to letters for now, numerals/symbols are all over the place
//          Currently struggles to differentiate between upper/lower case
//        Added a repeating function to pressed: pressed(keyCode, duration); examples below
// V0.4- added released() same as tapped but triggers for 1 frame on key release
// ---------- ---------- ---------- ---------- ----------
// EXAMPLES:
// (keyCode 65 is the value for 'a')
//
// if(pressed(65)) // true as long as 'a' is held
// if(pressed('a')) // true as long as 'a' is held - NOTE: Struggles with case sensitivity
// if(pressedUpper(65)) // true as long as 'a' is held and shift is also held
// if(pressedLower(65)) // true as long as 'a' is held and shift is NOT held
// if(tapped(65)) // true for one frame when 'a' is pressed
//
// Duration example
// if(pressed(65, 20)) // triggers for one frame when 'a' is held, triggers every 20 frames as long as it remains held
//
// ---------- ---------- ---------- ---------- ----------
//
// TODO:
// Add input parameters, including an enumerator for allowing character input maybe?
// Fix case sensitivity when using character input 
//
// ========== ========== ========== ========== ==========
//

public class BazKeys{
  public String name = "BazKeys";
  
  public PApplet parent = null;
  
  public boolean debug = false;
  public boolean errors = true;
  
  // ----------
  
  public int keyCodeAmount = 256;
  private int keyShift = 16; // Turn this into an enumerator, pre-load modifier keys?
  
  private boolean[][] pressed = new boolean[keyCodeAmount][3]; // stores previous states
  
  private int[] repeat = new int[keyCodeAmount]; // stores previous states
  
  // ========== ========== ========== ========== ==========
  
  public BazKeys(PApplet parent_){
    parent = parent_;
    parent.registerMethod("keyEvent", this);
    parent.registerMethod("pre", this);
    
  } // construct
  
  // ========== ========== ========== ========== ==========
  
  public void pre(){
    controls();
  } // pre

// ========== ========== ========== ========== ==========
  
  public void controls(){ 
    for(int i = 0; i < keyCodeAmount; i++){  // for each keycode
      for(int p = pressed[0].length - 1; p > 0; p--){
        pressed[i][p] = pressed[i][p-1];
      } // for each lastPress
    } // for each keyCode
  } // controls
  
  // ========== ========== ========== ========== ==========
  // REGULAR PRESSES
  
  public boolean pressed(int i){
    if(i > keyCodeAmount || i < 0){
      printError("Requested keycode " + i + " does not fit in array length " + keyCodeAmount);
      return false;
    } // if keyCode not in array
    return pressed[i][0];
  } // pressed
  
  public boolean tapped(int i){
    return pressed[i][0] && !pressed[i][2];
  } // tapped
  
  public boolean released(int i){
    return !pressed[i][0] && pressed[i][2];
  } // tapped
  
  // ----------
  
  public boolean pressedLower(int i){
    return (pressed(i) && !pressed(keyShift));
  } // pressedLower
  
  public boolean pressedUpper(int i){
    return (pressed(i) && pressed(keyShift));
  } // pressedUpper
  
  public boolean tappedLower(int i){
    return (tapped(i) && !pressed(keyShift));
  } // tappedLower
  
  public boolean tappedUpper(int i){
    return (tapped(i) && pressed(keyShift));
  } // tappedUpper
  
  // ---------- ---------- ---------- ---------- ----------
  // CHAR TO INT
  
  public boolean pressed(char c){
    return pressed(charToInt(c));
  } // pressed
  
  public boolean tapped(char c){
    //return tapped[i];
    return tapped(charToInt(c));
  } // tapped
  
  // ----------
  
  public boolean pressedLower(char c){
    return pressedLower(charToInt(c)) && !isUpper(c);
  } // pressedLower
  
  public boolean pressedUpper(char c){
    return pressedUpper(charToInt(c)) && isUpper(c);
  } // pressedUpper
  
  public boolean tappedLower(char c){
    return tappedLower(charToInt(c)) && !isUpper(c);
  } // tappedLower
  
  public boolean tappedUpper(char c){
    return tappedUpper(charToInt(c)) && isUpper(c);
  } // tappedUpper
  
  // ---------- ---------- ---------- ---------- ----------
  // WITH DURATION
  
  
  public boolean initDuration(int i, boolean pressed, int duration){
    if(!pressed(i)){
      repeat[i] = -1;
      return false;
    }
    if(tapped(i)) repeat[i] = frameCount-1;
    
    if(pressed(i) && (frameCount-repeat[i]) % duration == 1) return true;
    
    return false;
  } // initDuration
  
  // ----------
  
  public boolean pressed(int i, int duration){
    return initDuration(i, pressed(i), duration);
  } // pressed
  
  public boolean pressedLower(int i, int duration){
    return pressed(i, duration) && !pressed(keyShift);
    //return (pressed(i) && !pressed(keyShift));
  } // pressedLower
  
  public boolean pressedUpper(int i, int duration){
    return pressed(i, duration) && pressed(keyShift);
    //return (pressed(i) && pressed(keyShift));
  } // pressedUpper
  
  public boolean pressed(char c, int duration){
    return pressed(charToInt(c), duration);
    //return pressed(charToInt(c));
  } // pressed
  
  public boolean pressedLower(char c, int duration){
    return pressedLower(charToInt(c), duration);
  } //return pressedLower(charToInt(c));// pressedLower
  
  public boolean pressedUpper(char c, int duration){
    return pressedUpper(charToInt(c), duration);
    //return pressedUpper(charToInt(c));
  } // pressedUpper
  
  // ---------- ---------- ---------- ---------- ----------
  
  public int charToInt(char c){
    char cUp = (str(c).toUpperCase().charAt(0));
    boolean upper = (c == cUp);
    if(upper) return int(c);
    return(int(c) - 32);
  } // charToInt
  
  public boolean isUpper(char c){
    String s = str(c).toUpperCase();
    char u = s.charAt(0);
    if(c == u) return true;
    return false;
  } // isUpper
  
  // ========== ========== ========== ========== ==========
  
  public void keyEvent(KeyEvent e){    
    switch (e.getAction()) {
      case KeyEvent.PRESS:
        pressed[keyCode][0] = true;
        break;
      case KeyEvent.RELEASE:
        pressed[keyCode][0] = false;
        break;
      case KeyEvent.TYPE:
        // unused event at the moment
        break;
    } // event switch
    
  } // keyEvent
  
  // ========== ========== ========== ========== ==========
  // ======== STUFF TO ADD TO EVENTUAL SUPERCLASS  ========
  // Turn this into a contained class? specifically for handling console?
  
  public void printError(String text){
    text = "ERROR: "+ name +" - " + text;
    println(text);
  } // printError
  
} // BazKeys

// ========== ========== ========== ========== ==========
