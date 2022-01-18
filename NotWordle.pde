// commentsAreForChumps = false;

// TODO LIST:
// * multiplayer - NOW FUNCTIONAL
// * sound
// * animations
// * better graphics
// * convert to using some kind of hashmap for characters
// * japanese version
// * allow players to add usernames

// Bugs:
// * Showing yellow letters when a green version is present

String[] wordlist;
String[] wordlistUncommon;

IntDict glyphs = new IntDict();

boolean victory = false;
boolean defeat = false;

String word = new String("blaze");
StringList guesses = new StringList();

float invalidWordTimerCur = 0;
float invalidWordTimerMax = 1.5;
String invalidWord = null;
enum InvalidWordEnum{
  REUSED, UNKNOWN
};
InvalidWordEnum invalidWordType = null;

PVector pos;
int letterSize = 50;
float letterBoxRatio = 1.5f;
float rectRadii = letterSize/4;

int guessesMax = 6;

int cursorIndex = 0;
char inputWord[] = new char[5];

color correct = #538d4e;
color present = #b59f3b;
color absent = #3a3a3c;
color background = #121213;
color textColor = #d7dadc;

PFont mochi;
PFont lucida; // BAZ - Default font is "Lucida Sans Regular";

int gameState = 0;

String localPlayerName = null;

boolean japanese = false;
//MUNA - Does the current editor font support japanese? "かわいい"

void settings(){
  size(800, 800);
  smooth(4);
} // settings

void setup(){
  mochi = createFont("source/MochiyPopOne-Regular.ttf", 50);
  lucida = createFont("Lucida Sans Regular", 50);

  // MUNA - Load config and set localPlayerName
  String[] lines = loadStrings("config.txt");
  if(lines == null){
    lines = new String[1];
    lines[0] = "playerName: Player";
    saveStrings("config.txt", lines);
  }
  lines = loadStrings("config.txt");
  for(int i = 0; i < lines.length; i++){
    if(lines[i].startsWith("playerName: ")){
      localPlayerName = lines[i].split(": ")[1];
      println("Local Name: "+ localPlayerName);
    }
  }

  if(bazDebug) surface.setLocation(windowDebug,60);
  
  network = new Network(this);
  
  PImage icon = loadImage("source/icon.png");
  surface.setIcon(icon);
  frameRate(60);
  
  
  
  wordlist = loadStrings("source/wordlist.txt");
  if(wordlist == null)
    println("ERROR: wordlist.txt not found");
  
  wordlistUncommon = loadStrings("source/wordlist-uncommon.txt");
  if(wordlistUncommon == null)
    println("ERROR: wordlist-uncommon.txt not found");
    
  word = wordlist[int(random(0, wordlist.length))].toString();
  word.toLowerCase();

  glyphs = new IntDict();
  
  pos = new PVector(width/2-(5*letterSize*letterBoxRatio)/2, height/8);
  
  // MUNA Debug stuff
  /*
  word = "teams";
  guesses.append("tests");
  guesses.append("mines");
  guesses.append("quirk");
  */
  noStroke();
} // setup

void draw(){
  if(gameState == 0){
    runMenu();
  } else {
    network.runNetwork();
  } // gameState check
} // draw

void runMenu(){
  background(0);
  fill(textColor);
  textSize(letterSize);
  String menuText = "";
  if(gameState == 0) menuText = "1 - Start singleplayer\n2 - Connect to server\n3 - Host server\n4 - Self client (debug)";
  if(gameState == 5) menuText = "Players ready: " + players.size() + "\n1 - Start game";
  text(menuText, 50, 100);
  textSize(letterSize/2);
  fill(MGREY);
  if(localPlayerName.equals("Player")){
    text("Username: Player (edit config.txt to change)", 50, height-20);
  } else {
    text("Username: "+localPlayerName, 50, height-20);
  }
  
} // runMenu

void runGame(){
  background(background);
  textSize(letterSize);
  if(japanese){
    textFont(mochi, letterSize);
  } else {
    textFont(lucida, letterSize);
  }
  // Draw empty grid squares
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
  
  if(guesses.size() > 0){
    if(guesses.get(guesses.size()-1).equals(word)){
      victory = true;
    } else if(guesses.size() == guessesMax){
      defeat = true;
    }
  }
  
  pushStyle();
  textSize(letterSize);
  if(victory)
    text("A winner is (You)!", width/2, 0);
  if(defeat)
    text("You lost ("+word+")", width/2, 0);
  if(victory || defeat){
    textSize(letterSize/3);
    textAlign(CENTER, BOTTOM);
    text("Press 'r' to restart", width/2, letterSize+letterSize/2);
  }
  if(invalidWord != null && invalidWordTimerCur >= 0){
    fill(textColor, (invalidWordTimerCur/invalidWordTimerMax) * 255);
    textSize(letterSize/2);
    if(invalidWordType == InvalidWordEnum.UNKNOWN){
      text("'"+invalidWord+"'"+" is not in the word list.", width/2, height-height/4);
    } else {
      text("'"+invalidWord+"'"+" was already used.", width/2, height-height/4);
    }
    if(invalidWordTimerCur > 0)
      invalidWordTimerCur -= 1.0/frameRate;
  }
  popStyle();
  
  pushStyle();
  int playerNum = 0;
  for(int i = 0; i < players.size(); i++){    
    Player p = players.get(i);
    if(p != Me && p.ID != -1){
      p.display(playerNum);
      playerNum++;
    } // if not me
  } // display all players
  popStyle();
  
  if(!victory && !defeat){
    // Draw text cursor
    float x = letterSize*letterBoxRatio*cursorIndex;
    float y = letterSize*letterBoxRatio*guesses.size();
    float cursorThick = letterSize/11;
    if(cursorIndex < 5){
      fill(textColor, sin(frameCount/8)*255);
      rect(pos.x + x + letterSize/4,pos.y + y + letterSize*letterBoxRatio-cursorThick, letterSize, cursorThick);
    }
    for(int i = 0; i < cursorIndex; i++){
        String k = Character.toString(inputWord[i]);
        if(glyphs.hasKey(k))
          fill(glyphs.get(k));
        else
          fill(textColor);

        textAlign(CENTER, TOP);
        text(Character.toUpperCase(inputWord[i]), pos.x + (letterSize*letterBoxRatio*i) + letterSize*letterBoxRatio/2, (pos.y + letterSize*letterBoxRatio*guesses.size())+letterSize/6);
    }
  }
  textAlign(CENTER, BOTTOM);
  textSize(letterSize/1.6);
  for(int i = 0; i < 26; i++){
    String k = Character.toString((char)(i + 'a'));
    if(glyphs.hasKey(k)){
          fill(glyphs.get(k));
    } else {
          fill(textColor);
    }
    text(Character.toUpperCase((char)(i + 97)), (width/2 - (26*(letterSize/1.6)*1.0)/2) + (letterSize/1.6)*i*0.95 + (letterSize/1.6), height-(letterSize/1.6)/2);
  }
} // runGame

// ---------- ---------- ---------- ---------- ----------

void submitWord(){
  boolean isInWordlist = false;
  boolean isNewWord = true;
  String newGuess = new String(inputWord);
  for(int i = 0; i < guesses.size(); i++){
    if(guesses.get(i).equals(newGuess)){
      isNewWord = false;
      break;
    }
  }
  if(isNewWord){
    for(int i = 0; i < wordlistUncommon.length; i++){
      if(wordlistUncommon[i].equals(newGuess)){
        isInWordlist = true;
        break;
      }
    }
  }
  if(isNewWord && isInWordlist){
    guesses.append(newGuess);
    if(network.host == Host.CLIENT) network.sendWord(newGuess);
    updateGlyphs(newGuess);
  } else {
    invalidWord(isNewWord, newGuess);
  }
  resetCursor();
} // submitWord

void invalidWord(boolean isNewWord, String newGuess){
  invalidWordTimerCur = invalidWordTimerMax;
  invalidWord = newGuess;
  invalidWordType = InvalidWordEnum.UNKNOWN;
  if(!isNewWord){
    invalidWordType = InvalidWordEnum.REUSED;
  }
} // invalidWord

void resetCursor(){
  inputWord = new char[5];
  cursorIndex = 0;
} // resetCursor

String newWord(int wordLength){
  String word = "";
  word = wordlist[int(random(0, wordlist.length+1))].toString();
  word.toLowerCase();
  return word;
} // newWord

String newWord(){
  return newWord(5);
} // newWord - overloaded, default to 5

void resetGame(){
  resetGame(newWord());
} // resetGame - overloaded, pick random word if no input

void resetGame(String newWord){
  victory = false;
  defeat = false;
  word = newWord;
  glyphs = new IntDict();
  guesses = new StringList();
  for(Player p : players) p.reset();
} // resetGame

void setGameState(int gameState_){
  gameState = gameState_;
  network.printInfo("gameState " + gameState);
} // setGameState

// Update colors for each letter based on the input
void updateGlyphs(String guess){
  for(int i = 0; i < guess.length(); i++){
    String k = Character.toString(guess.charAt(i));
    //if we haven't ever guessed this letter k
    if(!glyphs.hasKey(k)){
      // add k to the dict with the default color
      glyphs.set(k, textColor);
      
      //figure out if k should be yellow by testing against each letter in the target word
      for(int c = 0; c < word.length()-1; c++){
        if(k.equals(Character.toString(word.charAt(c)))){
          glyphs.set(k, present);
        }
      }
      if(k.equals(Character.toString(word.charAt(i)))){
          glyphs.set(k, correct);
      } else {
        if(glyphs.get(k) == textColor){
          glyphs.set(k, absent);
        }
      }
    } else {
      if(glyphs.get(k) != absent){
        if(k.equals(Character.toString(word.charAt(i)))){
          glyphs.set(k, correct);
        }
      }
    }
  }
}

// ---------- ---------- ---------- ---------- ----------

void keyPressed(){
  if(keyCode == 114){
    if(network.host == Host.SERVER) gameState = 5;
  }else if(keyCode == 113){ // F2
    japanese = !japanese;
    print(japanese);
  } // custom keys
  
  if(gameState == 0){
    if(key == '1') network.startSingleplayer();
    if(key == '2') network.startClient(network.ip, network.port);
    if(key == '3') network.startServer();
    if(key == '4') network.startDebug("localhost", network.port);
  } else if(gameState == 5){ // waiting for players
    if(key == '1') {
      setGameState(6);
    }
  } else if(gameState == 10){
    if(!victory && !defeat){
      if(keyCode == 112){ //F1
        println("Word to guess is: "+ word);  
      }
      
      if(cursorIndex == 5 && keyCode == ENTER){
        submitWord();
      } // submit word
      
      if(cursorIndex < 5 &&  Character.toString(key).matches("[a-z]+")){
        inputWord[cursorIndex++] = key;
      }
      if(cursorIndex > 0 && keyCode == BACKSPACE)
          inputWord[--cursorIndex] = 0;
    } else {
      if(keyCode == 82){ // 'r' to restart
        resetGame();
      } // press r to reset
    } // if victory or defeat
  } // gameState
} // keyPressed
