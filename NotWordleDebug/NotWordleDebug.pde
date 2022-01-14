// commentsAreForChumps = false;

// Missing features:
// 1. multiplayer
// 2. sound
// 3. animations
// 4. better graphics

// Bugs:
// 1. Games freezes when pressing a ton of keys at once [DONE]
// 2. Showing yellow letters when a green version is present
// 3. Wordlist is really bad
// 4. There is a lack of good words in the wordlist
// 5. Have onscreen feedback when an unknown word is entered [DONE]

String[] wordlist;
String[] wordlistUncommon;

int[] letters = new int[26];

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

int gameState = 0;

void settings(){
  
  size(800, 800);
  smooth(4);
} // settings

void setup(){
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
    
  word = wordlist[int(random(0, wordlist.length+1))].toString();
  word.toLowerCase();

  for(int i = 0; i < 26; i++)
    letters[i] = textColor;
  pos = new PVector(width/2-(5*letterSize*letterBoxRatio)/2, height/8);
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
  textSize(letterSize);
  String menuText = "";
  if(gameState == 0) menuText = "1 - Start singleplayer\n2 - Connect to server\n3 - Host server\n4 - Self client (debug)";
  if(gameState == 5) menuText = "Players ready: " + network.players.size() + "\n1 - Start game";
  text(menuText, 50, 100);
  
} // runMenu

void runGame(){
  background(background);
  textSize(letterSize);
  
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
  
  // Color the letter squares
  for(int g = 0; g < guesses.size(); g++){
    for(int i = 0; i < 5; i++){
      boolean p = false;
      for(int c = 0; c < 5; c++){
        if(guesses.get(g).charAt(i) == word.charAt(c)){
          if(letters[(guesses.get(g).charAt(i) - 'a')] == textColor || letters[(guesses.get(g).charAt(i) - 'a')] == absent)
            letters[(guesses.get(g).charAt(i) - 'a')] = present;
          fill(present);
          p = true;
        } else {
          if(letters[(guesses.get(g).charAt(i) - 'a')] == textColor)
            letters[(guesses.get(g).charAt(i) - 'a')] = absent;
        }
      }
     if(guesses.get(g).charAt(i) == word.charAt(i)){
       if(letters[(guesses.get(g).charAt(i) - 'a')] == textColor || letters[(guesses.get(g).charAt(i) - 'a')] == present)
         letters[(guesses.get(g).charAt(i) - 'a')] = correct;
        fill(correct);
      } else if(!p){
        fill(absent);
      }
      rect(pos.x + letterSize*letterBoxRatio*i, pos.y + letterSize*letterBoxRatio*g, letterSize*letterBoxRatio, letterSize*letterBoxRatio, rectRadii);
    }

    // Draw each letter in the current guess
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
        fill(letters[inputWord[i]-'a']);
        textAlign(CENTER, TOP);
        text(Character.toUpperCase(inputWord[i]), pos.x + (letterSize*letterBoxRatio*i) + letterSize*letterBoxRatio/2, (pos.y + letterSize*letterBoxRatio*guesses.size())+letterSize/6);
    }
  }
  textAlign(CENTER, BOTTOM);
  textSize(letterSize/1.6);
  for(int i = 0; i < 26; i++){
    fill(letters[i]);
    text(Character.toUpperCase((char)(i + 97)), (width/2 - (26*(letterSize/1.6)*1.0)/2) + (letterSize/1.6)*i*0.95 + (letterSize/1.6), height-(letterSize/1.6)/2);
  }
} // runGame

void keyPressed(){
  if(gameState == 0){
    if(key == '1') network.startSingleplayer();
    if(key == '2') network.startClient(network.ip, network.port);
    if(key == '3') network.startServer();
    if(key == '4') network.startDebug("localhost", network.port);
  } else if(gameState == 5){ // waiting for players
    if(key == '1') {
      network.sendCommand("BEGIN");
      setGameState(10);
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
  } else {
    invalidWordTimerCur = invalidWordTimerMax;
    invalidWord = newGuess;
    invalidWordType = InvalidWordEnum.UNKNOWN;
    if(!isNewWord){
      invalidWordType = InvalidWordEnum.REUSED;
    }
  }
  inputWord = new char[5];
  cursorIndex = 0;
} // submitWord

void resetGame(){
  victory = false;
      defeat = false;
      word = wordlist[int(random(0, wordlist.length+1))].toString();
      word.toLowerCase();
      
      println("Word to guess is: "+ word);
      for(int i = 0; i < 26; i++)
        letters[i] = textColor;
      guesses = new StringList();
} // resetGame

void setGameState(int gameState_){
  gameState = gameState_;
  network.printInfo("gameState " + gameState);
} // setGameState
