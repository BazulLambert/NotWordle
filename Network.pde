import processing.net.*; 

Network network; 

// ---------- ---------- ---------- ---------- ----------

class Network{
  
  Server s;
  Client c; 
  String input;
  //String data[];
  
  String ip =  "24.128.92.203";
  int port = 22985;
  
  PApplet applet;
  
  // ---------- ---------- ---------- ---------- ----------
  
  Network(PApplet applet_){
    applet = applet_;
  } // construct
  
  void startServer(){
    s = new Server(applet, port);
  } // startServer
  
  void startClient(String ip, int port){
    c = new Client(applet, ip, port);
  } // startClient
  
  void startSingleplayer(){
    
  } // startClient
  
  // ---------- ---------- ---------- ---------- ----------
  
  void runNetwork(){
    
  } // runNetwork
  
  void sendWord(String word){
    
  } // sendWord
  
  void sendCommand(){
    
  } // sendCommand
  
  
  
} // Network - class
