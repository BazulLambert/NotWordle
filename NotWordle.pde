// commentsAreForChumps = false;

// Missing features:
// 1. multiplayer
// 2. sound
// 3. animations
// 4. better graphics

String[] wordlist;

int[] letters = new int[26];

boolean victory = false;
boolean defeat = false;

String word = new String("blaze");
StringList guesses = new StringList();

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

void settings(){
  
  size(800, 800);
  smooth(4);
} // settings

void setup(){
  PImage icon = loadImage("source/icon.png");
  surface.setIcon(icon);
  frameRate(60);
  
  wordlist = loadStrings("source/wordlist.txt");
  if(wordlist == null)
    println("ERROR: wordlist.txt not found");
  
  word = wordlist[int(random(0, wordlist.length+1))].toString();
  word.toLowerCase();
  for(int i = 0; i < 26; i++)
    letters[i] = textColor;
  pos = new PVector(width/2-(5*letterSize*letterBoxRatio)/2, height/8);
  noStroke();
} // setup

void draw(){
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
} // draw

void keyPressed(){
  if(!victory && !defeat){
    if(keyCode == 112){ //F1
      println("Word to guess is: "+ word);  
    }
    if(cursorIndex == 5 && keyCode == ENTER){
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
        for(int i = 0; i < wordlist.length; i++){
          if(wordlist[i].equals(newGuess)){
            isInWordlist = true;
            break;
          }
        }
      }
      if(isNewWord && isInWordlist){
        guesses.append(newGuess);
      } else {
        println("'" + newGuess + "' is not in the list of valid words.");
      }
      inputWord = new char[5];
      cursorIndex = 0;
    }
    if(cursorIndex < 5 && Character.isLetter(key))
      inputWord[cursorIndex++] = key;
    if(cursorIndex > 0 && keyCode == BACKSPACE)
        inputWord[--cursorIndex] = 0;
  } else {
    if(keyCode == 82){ // 'r' to restart
      victory = false;
      defeat = false;
      word = wordlist[int(random(0, wordlist.length+1))].toString();
      word.toLowerCase();
      
      println("Word to guess is: "+ word);
      for(int i = 0; i < 26; i++)
        letters[i] = textColor;
      guesses = new StringList();
    }
  }
}
