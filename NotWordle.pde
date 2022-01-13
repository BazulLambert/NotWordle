// commentsAreForChumps = false;
boolean victory = false;

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
} // settings

void setup(){
  pos = new PVector(width/2-(5*letterSize*letterBoxRatio)/2, height/8);
  noStroke();
  
  guesses.append("based");
  guesses.append("blase");
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
    for(int j = 0; j < 5; j++){
            rect(pos.x + letterSize*letterBoxRatio*j,
            pos.y + letterSize*letterBoxRatio*i,
            letterSize*letterBoxRatio,
            letterSize*letterBoxRatio,
            rectRadii);
    }
  }
  popStyle();
  
  // Color the letter squares
  for(int g = 0; g < guesses.size(); g++){
    for(int i = 0; i < 5; i++){
      boolean p = false;
      for(int c = 0; c < 5; c++){
        if(guesses.get(g).charAt(i) == word.charAt(c)){
          fill(present);
          p = true;
        }
      }
     if(guesses.get(g).charAt(i) == word.charAt(i)){
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
  
  if(guesses.get(guesses.size()-1).equals(word)){
    victory = true;
  }
  
  if(victory){
    pushStyle();
    textSize(50);
    text("A winner is (You)!", width/2, 0);
    popStyle();
  }
  
  if(!victory){
    // Draw text cursor
    float x = letterSize*letterBoxRatio*cursorIndex;
    float y = letterSize*letterBoxRatio*guesses.size();
    float cursorThick = letterSize/11;
    if(cursorIndex < 5){
      fill(textColor, sin(frameCount/8)*255);
      rect(pos.x + x + letterSize/4,pos.y + y + letterSize*letterBoxRatio-cursorThick, letterSize, cursorThick);
    }
    for(int i = 0; i < cursorIndex; i++){
        fill(textColor);
        textAlign(CENTER, TOP);
        text(Character.toUpperCase(inputWord[i]), pos.x + (letterSize*letterBoxRatio*i) + letterSize*letterBoxRatio/2, (pos.y + letterSize*letterBoxRatio*guesses.size())+letterSize/6);
    }
  }
} // draw

void keyPressed(){
  if(!victory){
    if(cursorIndex == 5 && keyCode == ENTER){
      guesses.append(new String(inputWord));
      inputWord = new char[5];
      println("append");
      cursorIndex = 0;
    }
    if(cursorIndex < 5 && Character.isLetter(key)){
      inputWord[cursorIndex] = key;
      cursorIndex++;
      println(cursorIndex);
    }
    if(cursorIndex > 0 && keyCode == BACKSPACE){
        // Backspace
        cursorIndex--;
        inputWord[cursorIndex] = 0;
    }
  }
}
