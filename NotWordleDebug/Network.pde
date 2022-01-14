import processing.net.*; 

Network network; 

// ---------- ---------- ---------- ---------- ----------

enum Host{SERVER,CLIENT,SINGLE};

class Network{
  
  Host host;
  
  Server s;
  Client c; 
  String input;
  int ID;
  //String data[];
  
  String ip =  "24.128.92.203";
  int port = 22985;
  
  PApplet applet;
  
  ArrayList<Player> players = new ArrayList<Player>();
  
  // ---------- ---------- ---------- ---------- ----------
  
  Network(PApplet applet_){
    applet = applet_;
    ID = int(random(0,99999));
  } // construct
  
  void startSingleplayer(){
    host = Host.SINGLE;
    gameState = 10;
  } // startClient
  
  void startClient(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.CLIENT;
    gameState = 10;
  } // startClient
  
  void startServer(){
    s = new Server(applet, port);
    host = Host.SERVER;
    gameState = 5;
  } // startServer
  
  void startDebug(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.CLIENT;
    gameState = 10;
  } // startDebug
  
  // ---------- ---------- ---------- ---------- ----------
  
  void runNetwork(){
    if(host == Host.SERVER) runServer();
    if(host == Host.CLIENT) runClient();
  } // runNetwork
  
  void runServer(){
    
  } // runServer
  
  void runClient(){
    
  } // runClient
  
  void sendWord(String word){
    
  } // sendWord
  
  void sendCommand(){
    
  } // sendCommand
  
  // ---------- ---------- ---------- ---------- ----------
  
  class Player{
    
    int ID;
    
    Player(){
      
    } // construct
    
  } // Player - subclass
  
  // ---------- ---------- ---------- ---------- ----------
  
} // Network - class
