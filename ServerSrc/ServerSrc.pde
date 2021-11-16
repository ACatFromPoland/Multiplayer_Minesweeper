import processing.net.*;
import java.net.InetAddress;
Server server = new Server(this, 5006);

Game game_data;
Event client_update = new Event(6);
Event client_restart = new Event(1500);

// 185 is basically the max
int grid_dimension = 35;
int bombs = 400;
int max_players = 16;

InetAddress inet;
String myIP;

void setup() {
  frameRate(240);
  size(400, 200);
  surface.setResizable(false);
  game_data = new Game(grid_dimension, bombs);
  
  // Thank you 
  try {
    inet = InetAddress.getLocalHost();
    myIP = inet.getHostAddress();
  }
  catch (Exception e) {
    e.printStackTrace();
    myIP = "couldnt get IP";
  }
}

void draw() {
  fill(0);
  textSize(23);
  text("Server LAN IP: " + myIP, width/14, height/1.9);
  text("Port: 5006", width/14, height/1.2);

  if (client_update.active()) {
    // update client screens
    DataPacket packet = new DataPacket(grid_dimension * grid_dimension, max_players);
    packet.id = 5;
    int i = 0;
    for (int y = 0; y < grid_dimension; y++) {
      for (int x = 0; x < grid_dimension; x++) {
        packet.screen[i] = game_data.grid_client[x][y];
        i++;
      }
    }
    byte[] response = packageData(packet);
    server.write(response);
  }
  if (client_restart.active() && game_data.game_over) {
    // setup() 
    game_data = new Game(grid_dimension, bombs);
    game_data.game_over = false;
    DataPacket packet = new DataPacket(grid_dimension * grid_dimension, max_players);
    packet.id = 6;
    packet.cells[0][0] = grid_dimension;
    packet.cells[0][1] = bombs;
    int i = 0;
    for (int y = 0; y < grid_dimension; y++) {
      for (int x = 0; x < grid_dimension; x++) {
        packet.screen[i] = game_data.grid_client[x][y];
        i++;
      }
    }
    byte[] response = packageData(packet);
    server.write(response);
    // send new grid data to clients
  }

  if (game_data.m_bombs == 0 && bombs == game_data.user_flags) {
    game_data.game_over = true;
    //send win event to clients
    //start game_over sequence
  }

  Client client = server.available();
  {
    if (client != null) {
      byte[] raw_data = client.readBytes();
      if (raw_data != null) {
        DataPacket data = parseData(raw_data);
        if (data != null) {
          if (data.id == 0) { // Request for screen data
            serverEvent(client);
          } else if (data.id == 1) { // Request to reveal cell
            int type = game_data.getCell(data.cells[0][0], data.cells[0][1]);
            if (type == 9) { // Game Over
              for (int y = 0; y < game_data.grid_client.length; y++) {
                for (int x = 0; x < game_data.grid_client.length; x++) {
                  game_data.grid_client[x][y] = game_data.getCell(x, y);
                }
              }
              type = 12;
              game_data.grid_client[data.cells[0][0]][data.cells[0][1]] = type;
              game_data.game_over = true;
              client_restart.last_frame_count = frameCount;
              DataPacket packet = new DataPacket(grid_dimension * grid_dimension, max_players);
              packet.id = 5;
              int i = 0;
              for (int y = 0; y < grid_dimension; y++) {
                for (int x = 0; x < grid_dimension; x++) {
                  packet.screen[i] = game_data.grid_server[x][y];
                  i++;
                }
              }
              byte[] response = packageData(packet);
              server.write(response);
            } else if (type == 10) { // 
              game_data.floodFill(data.cells[0][0], data.cells[0][1]);
            } else {
              DataPacket packet = new DataPacket(grid_dimension * 2, max_players);
              packet.id = 1;
              packet.cells[0] = new int[]{data.cells[0][0], data.cells[0][1], type};
              game_data.grid_client[data.cells[0][0]][data.cells[0][1]] = type;
              byte[] response = packageData(packet);
              server.write(response);
            }
          } else if (data.id == 2) { // Flag request
            // Stop client from spamming id.2 && id.3 later
            if (game_data.grid_server[data.cells[0][0]][data.cells[0][1]] == 9) {
              game_data.m_bombs -= 1;
            }
            game_data.user_flags += 1;
            DataPacket packet = new DataPacket(grid_dimension * 2, max_players);
            packet.id = 2;
            packet.cells[0] = new int[] {data.cells[0][0], data.cells[0][1], 11};
            game_data.grid_client[data.cells[0][0]][data.cells[0][1]] = 11;
            byte[] response = packageData(packet);
            server.write(response);
          } else if (data.id == 3) { // Unflag request
            if (game_data.grid_server[data.cells[0][0]][data.cells[0][1]] == 9) {
              game_data.m_bombs += 1;
            }
            game_data.user_flags -= 1;
            DataPacket packet = new DataPacket(grid_dimension * 2, max_players);
            packet.id = 3;
            packet.cells[0] = new int[] {data.cells[0][0], data.cells[0][1], 0};
            game_data.grid_client[data.cells[0][0]][data.cells[0][1]] = 0;
            byte[] response = packageData(packet);
            server.write(response);
          }
          // End of similarities
        }
      }
    }
  }
}

void serverEvent(Client joining_Client) {
  DataPacket packet = new DataPacket(grid_dimension * grid_dimension, max_players);
  packet.id = 0;
  packet.max_player_size = max_players;
  packet.cells[0][0] = game_data.m_bombs;
  packet.cells[0][1] = grid_dimension;  

  int i = 0;
  for (int y = 0; y < game_data.grid_server.length; y++) {
    for (int x = 0; x < game_data.grid_server.length; x++) {
      packet.screen[i] = game_data.grid_client[x][y];
      i++;
    }
  }
  byte[] response = packageData(packet);
  joining_Client.write(response);
}
