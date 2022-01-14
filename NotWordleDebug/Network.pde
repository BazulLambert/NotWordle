import processing.net.*; 

Network network;

// ---------- ---------- ---------- ---------- ----------

enum Host{SERVER,CLIENT,SINGLE,DEBUG};

class Network{
  
  Host host;
  Player Me;
  
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
    Me = new Player(true, ID, "Player");
    players.add(Me);
  } // construct
  
  void startSingleplayer(){
    host = Host.SINGLE;
    setGameState(10);
  } // startClient
  
  void startClient(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.CLIENT;
    setGameState(5);
  } // startClient
  
  void startServer(){
    s = new Server(applet, port);
    host = Host.SERVER;
    setGameState(5);
  } // startServer
  
  void startDebug(String ip, int port){
    c = new Client(applet, ip, port);
    host = Host.CLIENT;
    setGameState(10);
  } // startDebug
  
  // ---------- ---------- ---------- ---------- ----------
  
  void runNetwork(){
    switch(host){
      case SERVER:
        runServer(); break;
      
      case SINGLE:
        if(gameState == 0) setGameState(10);
      case CLIENT:
      case DEBUG:
        runClient(); break;
        
      default: break;
    } // switch host enum
  } // runNetwork
  
  // -----
  
  void runServer(){
    switch(gameState){
      case 0: break;
      
      case 5:
      runMenu();
      initPlayers();
      break;
      
      case 10: runGame(); break;
      
      default: break;
    } // switch gameState
  } // runServer
  
  // -----
  
  void runClient(){
    switch(gameState){
      case 0: break;
      
      case 5:
      sendCommand("JOIN");
      setGameState(6);
      break;
      
      case 6:
      if(getCommand("BEGIN")) setGameState(10);
      break;
      
      case 10: runGame(); break;
      
      default: break;
    } // switch gameState
  } // runClient
  
  // -----
  
  void sendWord(String word){
    
  } // sendWord
  
  void sendCommand(String command){
    sendCommand(command, Me.ID, "");
  } // sendCommand
  
  void sendCommand(String command, String info){
    sendCommand(command, Me.ID, info);
  } // sendCommand
  
  void sendCommand(String command, int ID){
    sendCommand(command, ID, "");
  } // sendCommand
  
  void sendCommand(String command, int ID, String info){
    String output = command + ',' + ID +  ',' + info + "\n";
    if(host == Host.CLIENT) c.write(output);
    if(host == Host.SERVER) s.write(output);
    printInfo("COMMAND SENT: " + output);
  } // sendCommand
  
  // -----
  
  void initPlayers(){
   String[] data = getData();
   if(data != null){
     if(data[0].equals("JOIN")) players.add(new Player(false, int(data[1]), "Player"));
   } // if data exists
  } // initGame
  
  // -----
  
  String[] getData(){
    if(host == Host.CLIENT) return getServerData();
    if(host == Host.SERVER) return getClientData();
    return null;
  } // getData
  
  String[] getClientData(){
    String[] data = null;
    c = s.available();
    if(c != null){
      String input = c.readString();
      input = input.substring(0, input.indexOf("\n"));
      data = split(input, ',');
    } // if client data exists
    return data;
  } // getClientData
  
  boolean getCommand(String get){
    String[] data = getData();
    if(data != null) return data[0].equals(get);
    return false;
  } // getCommand
  
  String[] getServerData(){
    String[] data = null;
    if(c.available() > 0){
      String input = c.readString();
      input = input.substring(0, input.indexOf("\n"));
      data = split(input, ',');
    } // if client data exists
    return data;
  } // getClientData
  
  // ---------- ---------- ---------- ---------- ----------
  
  void printInfo(int output){
    printInfo(""+output);
  } // printInfo
  
  void printInfo(String output){
    println(network.host + " " + Me.ID + ": " + output);
  } // printInfo
  
  
  // ---------- ---------- ---------- ---------- ----------
  
  class Player{
    
    boolean isMe;
    int ID;
    String name;
    
    Player(boolean isMe_, int ID_, String name_){
      isMe = isMe_;
      ID = ID_;
      name = name_;
    } // construct
    
  } // Player - subclass
  
  // ---------- ---------- ---------- ---------- ----------
  
} // Network - class
