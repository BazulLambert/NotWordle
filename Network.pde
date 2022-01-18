import processing.net.*; 

Network network;

// ---------- ---------- ---------- ---------- ----------

enum Host{SERVER,CLIENT,SINGLE,DEBUG};

class Network{
  
  Host host;
  //Player Me;
  
  Server s;
  Client c; 
  String input;
  int ID;
  
  String ip =  "24.128.92.203";
  int port = 22985;
  
  PApplet applet;
  
  //ArrayList<Player> players = new ArrayList<Player>();
  
  String[] nullCommand = {"NULL","",""};
  
  // ---------- ---------- ---------- ---------- ----------
  
  Network(PApplet applet_){
    applet = applet_;
    ID = int(random(0,99999));
    Me = new Player(true, ID, localPlayerName);
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
    Me.ID = -1;
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
        runGame(); break;
      case CLIENT:
      case DEBUG:
        runClient(); break;
        
      default: break;
    } // switch host enum
  } // runNetwork
  
  // -----
  
  void runServer(){
    commands = getData();
    if(commands.size() == 0) commands.add(nullCommand);
    for(String[] com : commands){
      command = com;
      
      switch(gameState){
        case 0: break; // 0 waiting on game select
        
        case 5: // 5 waiting for players
        runMenu();
        if(com[0].equals("Join Game")) players.add(new Player(false, int(command[1]), command[2]));
        //initPlayers();
        break;
        
        case 6: // 6 starting game
        network.sendCommand("Clear Players");
        for(Player p : players){
          network.sendCommand("Add Player", p.ID, p.name);
        } // send each player
        network.sendCommand("Begin Game");
        setGameState(7);
        break;
        
        case 7: // 7 sending word
        word = newWord();
        resetGame(word);
        network.sendCommand("New Word", word);
        setGameState(10);
        break;
        
        case 10:
        if(getCommand("Add Guess")){
          playerByID(int(command[1])).guesses.append(command[2]);
          sendCommand(command);
        } // add guess
        break; // 10 run game
        
        default: break;
      } // switch gameState
    } // for each command
    
    if(gameState == 5) runMenu();
    if(gameState == 10) runGame();
    
    commands.clear();
  } // runServer
  
  // -----
  
  void runClient(){
    commands = getData();
    if(commands.size() == 0) commands.add(nullCommand);
    for(String[] com : commands){
      command = com;
      
      switch(gameState){
        
        case 0: break; // 0 waiting on game select
        
        case 5: // 5 joining server
        sendCommand("Join Game");
        setGameState(6);
        break;
        
        case 6: // 6 waiting for begin command from server
        if(getCommand("Clear Players")) {
          players = new ArrayList<Player>();
          println("CLEARED PLAYERS");
          Me.reset();
          players.add(Me);
        } // clear players
        if(getCommand("Add Player")){
          if(playerByID(int(command[1])) == null) players.add(new Player(false, int(command[1]), command[2]));
        }
        if(getCommand("New Word")) resetGame(dataInfo);
        if(getCommand("Begin Game")) setGameState(7);
        
        break;
        
        case 7: // 7 waiting for word
        if(getCommand("New Word")) resetGame(command[2]);
        setGameState(10);
        break;
        
        case 10:
        //runGame();
        if(getCommand("Begin Game")) setGameState(7); // reset if server prompts
        if(getCommand("Add Guess")){
          playerByID(int(command[1])).guesses.append(command[2]);
        } // receive guess from players
        break; // 10 run game
        
        
        default: break;
      } // switch gameState
    } // for each command
    
    if(gameState == 10) runGame();
    
    commands.clear();
  } // runClient
  
  // ---------- ---------- ---------- ---------- ----------
  
  void sendWord(String word){
    sendCommand("Add Guess", word);
  } // sendWord
  
  // -----
  
  void sendCommand(String[] command){
    sendCommand(command[0], int(command[1]), command[2]);
  } // sendCommand
  
  void sendCommand(String command){
    sendCommand(command, Me.ID, Me.name);
  } // sendCommand
  
  void sendCommand(String command, String info){
    sendCommand(command, Me.ID, info);
  } // sendCommand
  
  void sendCommand(String command, int ID){
    sendCommand(command, ID, "");
  } // sendCommand
  
  void sendCommand(String command, int ID, String info){
    String output = command + ',' + ID +  ',' + info + "|";
    if(host == Host.CLIENT) c.write(output);
    if(host == Host.SERVER) s.write(output);
    printInfo("COMMAND SENT: <" + output + ">");
  } // sendCommand
  
  // -----
  
  // ========== ========== ========== ========== ==========
  // ========== ======== DATA MANGEMENT ======== ==========
  // ========== ========== ========== ========== ==========
  
  ArrayList<String[]> commands = new ArrayList<String[]>();
  String[] command;
  String dataCommand;
  int dataID;
  String dataInfo;
  
  ArrayList getData(){
    if(host == Host.CLIENT) return getServerData();
    if(host == Host.SERVER) return getClientData();
    return null;
  } // getData
  
  ArrayList getClientData(){
    commands.clear();
    commands = new ArrayList<String[]>();
    c = s.available();
    String input = "";
    if(c != null) input = c.readString();
    if(c != null){
      String[] data = null;
      String dataInput = input.substring(0, input.indexOf("|"));
      data = split(dataInput, ',');
      commands.add(data);
      printInfo("RECEIVED: <" + dataInput + ">");
      c = s.available();
    } // while commands exist
    return commands;
  } // getClientData
  
  
  ArrayList getServerData(){
    commands.clear();
    commands = new ArrayList<String[]>();
    if(c.available() > 0){
      int available = c.available();
      String input = c.readString();
      //println("A0 " + c.available());
      //println("A1 " + input); // debug
      String[] lastCommand = {"","",""};
      
      String[] inputCommands = split(input, '|');
      
      for(int i = 0; i < inputCommands.length-1; i++){
        String[] inputData = split(inputCommands[i], ',');
        printInfo(input.length() + " " + "RECEIVED: <" + inputCommands[i] + ">"); // debug
        commands.add(new String[]{inputData[0], inputData[1]+"", inputData[2]});
        
      } // for each command
      
    } // if client data exists
    
    return commands;
  } // getServerData
  
  
  boolean getCommand(String get){
    if(command != null) return command[0].equals(get);
    return false;
  } // getCommand
  
  // ---------- ---------- ---------- ---------- ----------
  
  void printInfo(int output){
    printInfo(""+output);
  } // printInfo
  
  void printInfo(String output){
    if(printNetworkData) println(frameCount + " " + commands.size() + " : " + network.host + " " + Me.ID + ": " + output);
  } // printInfo
  
  
  // ---------- ---------- ---------- ---------- ----------
  
} // Network - class
