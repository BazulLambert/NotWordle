// commentsAreForChumps = false;

String word = new String("blaze");
StringList guesses = new StringList();

PVector pos;
int letterSize = 50;
float letterBoxRatio = 1.5f;
float rectRadii = letterSize/4;

int guessesMax = 5;

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
    for(int i = 0; i < 5; i++){
      fill(textColor);
      textAlign(CENTER, TOP);
      text(guesses.get(g).toUpperCase().charAt(i), pos.x + (letterSize*letterBoxRatio*i) + letterSize*letterBoxRatio/2, (pos.y + letterSize*letterBoxRatio*g)+letterSize/6);
    }
  }
} // draw
