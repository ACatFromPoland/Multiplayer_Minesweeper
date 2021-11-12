import processing.net.*;

MouseInput mouse1 = new MouseInput(LEFT);
MouseInput mouse2 = new MouseInput(RIGHT);
ButtonInput r_key = new ButtonInput('r');
ButtonInput c_key = new ButtonInput('c');

GameWindow window = new GameWindow();

String server_ip = "149.157.100.120";
//String server_ip = "79.97.212.70";
//String server_ip = "127.0.0.1";
int server_port = 5006;
Client client = new Client(this, server_ip, server_port);

void setup() {
  size(800, 600, P2D);
  window.loadTextures();
}

void draw() {
  handleInputs();
  window.drawGui();
}

// Handle Data!
void clientEvent(Client myClient) {
  String dataIn = myClient.readString();
  if (dataIn != null) {
    if (dataIn.charAt(0) == '2') {
      window.m_server_text = dataIn.substring(1, dataIn.length());
    } else {
      Packet data = new Packet(dataIn);

      if (data.m_id == 0) // Reveal cell
        window.setCell(data.m_data[0], data.m_data[1], data.m_data[2]);

      if (data.m_id == 1) {
        for (int y = 0; y < window.m_grid.length; y++) {
          for (int x = 0; x < window.m_grid.length; x++) {
            window.setCell(x, y, data.m_data[x + (window.m_grid.length * y)]);
          }
        }
      }

      if (data.m_id == 3) { // Recieve grid information
        int dim = data.m_data[data.m_data.length - 2];
        window.m_bombs = data.m_data[data.m_data.length - 3];
        window.updateGrid(600, dim);
        window.coverAll();

        for (int y = 0; y < window.m_grid.length; y++) {
          for (int x = 0; x < window.m_grid.length; x++) {
            window.setCell(x, y, data.m_data[x + (window.m_grid.length * y)]);
          }
        }
      }
      if (data.m_id == 4) {
        window.m_bombs = data.m_data[1];
        window.coverAll();
        window.updateGrid(600, data.m_data[0]);
      }
      if (data.m_id == 5) { // Flood clear
        for (int i = 0; i < data.m_data.length - 1; i += 3) {
          int x = data.m_data[0 + i];
          int y = data.m_data[1 + i];
          int type = data.m_data[2 + i];
          window.setCell(x, y, type);
        }
      }
    }
  }
}



void handleInputs() {

  if (r_key.isPressed()) {
    client.write("1:");
  }

  if (c_key.isPressed()) {
    window.coverAll();
  }

  if (mouse1.isPressed()) {
    int[] xy = window.findClickedSquare();

    if (window.valid_coordinate(xy[0], xy[1])) {
      if (window.getCell(xy[0], xy[1]) != 11) {
        client.write("0:" + str(xy[0]) + ":" + str(xy[1]) + ":");
      }
    }
  }

  if (mouse2.isPressed()) {
    int[] xy = window.findClickedSquare();

    if (window.valid_coordinate(xy[0], xy[1])) {
      int type = window.getType(xy[0], xy[1]);
      if (type != 11 && type == 0) {
        window.setCell(xy[0], xy[1], 11);
        window.m_bombs -= 1;
        client.write("4:" + str(xy[0]) + ":" + str(xy[1]) + ":");
      } else if (type == 11) {
        window.setCell(xy[0], xy[1], 0);
        window.m_bombs += 1;
        client.write("5:" + str(xy[0]) + ":" + str(xy[1]) + ":");
      }
    }
  }
}
