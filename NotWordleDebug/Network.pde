import processing.net.*; 

Network network; 

// ---------- ---------- ---------- ---------- ----------

enum Host{SERVER,CLIENT,SINGLE,DEBUG};

class Network{
  
  Host host;
  
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
    host = Host.SERVER;
  } // startServer
  
  void startClient(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.CLIENT;
  } // startClient
  
  void startSingleplayer(){
    host = Host.SINGLE;
  } // startClient
  
  void startDebug(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.DEBUG;
  } // startDebug
  
  // ---------- ---------- ---------- ---------- ----------
  
  void runNetwork(){
    
  } // runNetwork
  
  void sendWord(String word){
    
  } // sendWord
  
  void sendCommand(){
    
  } // sendCommand
  
  
  
} // Network - class
