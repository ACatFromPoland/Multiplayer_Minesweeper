import processing.net.*;
Server server = new Server(this, 5006);

Game game_data;
Event client_update = new Event(10);
Event client_restart = new Event(1500);

int grid_dimension = 25;
int bombs = 80;
int max_players = 16;

void setup() {
  frameRate(240);
  size(400, 200);
  surface.setResizable(false);
  game_data = new Game(grid_dimension, bombs);
}

void draw() {
  if (client_update.active()) {
    // update client screens
  }
  if (client_restart.active()) {
    // setup() 
    // send new grid data to clients
  }

  //if (game_data.bombs_flagged == game_data.bombs) {
    // send win event to clients
    // start game_over sequence
  //}

  Client client = server.available();
  {
    if (client != null) {
      byte[] raw_data = client.readBytes();
      if (raw_data != null) {
        DataPacket data = parseData(raw_data);
        if (data != null) {
          if (data.id == 1) {
            int type = game_data.getCell(data.cells[0][0], data.cells[0][1]);
            
            DataPacket packet = new DataPacket(grid_dimension, max_players);
            packet.id = 1;
            packet.cells[0][0] = data.cells[0][0];
            packet.cells[0][1] = data.cells[0][1];
            packet.cells[0][2] = type;
            
            byte[] response = packageData(packet);
            server.write(response);
          }
        }
      }
    }
  }
}

void serverEvent(Client joining_Client) {
  // Send client current grid
  // Send client bombs
  // Send client dimensions
}
