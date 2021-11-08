import processing.net.*; // git-test

MouseInput mouse1 = new MouseInput(LEFT);
MouseInput mouse2 = new MouseInput(RIGHT);

GameWindow window = new GameWindow();

String server_ip = "127.0.0.1";
int server_port = 5006;
Client client = new Client(this, server_ip, server_port);

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

void clientEvent(Client server) { // Handle Data!
  String dataIn = server.readString();
  
  Packet data = new Packet(dataIn);
  if (data.m_id == 0)
    window.setCell(data.m_data[0], data.m_data[1], data.m_data[2]);
  if (data.m_id == 1) {
    for (int y = 0; y < window.m_grid.length; y++) {
      for (int x = 0; x < window.m_grid.length; x++) {
        window.setCell(x, y, data.m_data[x + (window.m_grid.length * y)]);
      }
    }
  }
}

void handleInputs() {

  if (mouse1.isPressed()) {
    int[] xy = window.findClickedSquare();

    if (window.valid_coordinate(xy[0], xy[1])) {
      client.write("0:" + str(xy[0]) + ":" + str(xy[1]) + ":");
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
