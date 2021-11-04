import processing.net.*; // git-test

MouseInput mouse1 = new MouseInput(LEFT);
MouseInput mouse2 = new MouseInput(RIGHT);

GameWindow window = new GameWindow();

//String server_ip = "127.0.0.1";
//int server_port = 5006;
//Client client = new Client(this, server_ip, server_port);

void setup() {
  size(800, 600, P2D);
  window.loadTextures();

  window.updateGrid(600, 25);
  window.coverAll();
}

void draw() {

  handleInputs();
  window.drawGui();
}

void handleInputs() {

  if (mouse1.isPressed()) {
    int[] xy = window.findClickedSquare();

    if (window.valid_coordinate(xy[0], xy[1])) {
      
    }
  }


  if (mouse2.isPressed()) {
    int[] xy = window.findClickedSquare();

    if (window.valid_coordinate(xy[0], xy[1])) {
      if (window.getType(xy[0], xy[1]) != 11) {
        window.setCell(xy[0], xy[1], 11);
      } else {
        window.setCell(xy[0], xy[1], 0);
      }
    }
  }
}

void clientEvent(Client someClient) {
  String dataIn = someClient.readString();
  
  Packet data = new Packet(dataIn);
  
  
}
