import processing.net.*; 

Server s;
Client c; 
String input;
char data[];

String ip =  "24.128.92.203";
int port = 22985;

int gameState = 0;

BazKeys keys;

void setup(){
  size(450, 255);
  
  keys = new BazKeys(this);
} // setup

void startServer(){
  s = new Server(this, port);
  gameState = 1;
} // startServer

void startClient(String ip, int port){
  c = new Client(this, ip, port);
  gameState = 1;
} // startClient



void draw(){
  background(0);
  if(gameState == 0){
    runMenu();
  } else if(gameState == 1){
    if(s == null) runClient();
    if(s != null) runServer();
  } // gameState 1
  
} // draw

void runMenu(){
  fill(255);
  text("1 - Start server\n2 - Start client\n3 - Self client (debug)", 50, 50);
  if(keys.released('1')) startServer();
  if(keys.released('2')) startClient(ip, port);
  if(keys.released('3')) startClient("localhost", port);
} // runMenu

String testString = "";

void keyPressed(){
  if(gameState == 1) sendChar(key);
} // keyPressed

void sendChar(char output){
  if(s == null) c.write(output);
  if(s != null) s.write(output);
  addChar(output);
} // sendChar

void addChar(char ch){
  testString += ch;
} // addChar


void runGame(){
  textSize(16);
  textAlign(LEFT,CENTER);
  text(testString, 30, 30);
} // runGame




void runClient(){
  println(c.available());
  if(c.available() > 0){
    println("C AV");
    input = c.readString();
    char ch = char(input.charAt(0));
    addChar(ch);
  } // network availability
  
  
  fill(color(#6666FF));
  runGame();
} // runClient




void runServer(){
  c = s.available();
  if(c != null){
    println("S AV");
    input = c.readString();
    char ch = char(input.charAt(0));
    addChar(ch);
  } // network availability
  
  
  fill(color(#66FF66));
  runGame();
} // runServer




  
