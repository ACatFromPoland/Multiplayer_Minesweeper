import processing.net.*;
Server server;

Game_Data game_data = new Game_Data();

void setup() {
  frameRate(240);
  size(400, 200); // Window not currently used.
  server = new Server(this, 5006);

  game_data.dim = 25;
  game_data.bombs = 20;
  game_data.createGame(game_data.dim, game_data.bombs);
}

int last_update_count = 0;
int update_offset = 8;

int last_reset_count = 0;
int reset_offset = 1500;

void draw() {

  // Server Events
  if (frameCount > last_update_count + update_offset) {
    game_data.update_client(); // Update screen
    last_update_count = frameCount;
  }

  if (game_data.game_over) {
    if (frameCount > last_reset_count + reset_offset) {
      game_data.createGame(game_data.dim, game_data.bombs);
      server.write("4:");
      game_data.game_over = false;
    }
  }

  Client client = server.available();
  {
    if (client != null) {
      String raw_data = client.readString();

      if (raw_data != null) {
        // Handle client message through seperate thread to make room for others.
        new ServerThread(raw_data).start();
      }
    }
  }
}

// Code taken from Kevin Workman
// On the post https://forum.processing.org/two/discussion/8435/how-to-pass-parameter-to-function-in-separated-thread.html
// Summary ./
// Processing thread() function doesn't allow parameeters.
// This class extends the Java thread and so we can store the parameeters in this new classes memory to use during the run time on this thread
class ServerThread extends Thread {
  Packet data;

  public ServerThread(String raw_data) {
    data = new Packet(raw_data);
  }

  public void run() {
    if (data.m_id == 0) { // Request Cell
      int type = game_data.getCell(data.m_data[0], data.m_data[1]);
      if (type == 9) { // Game over
        type = 12;
        game_data.m_grid_client[data.m_data[0]][data.m_data[1]] = type;
        game_data.game_over = true;
        game_data.reveal_game();
        last_reset_count = frameCount;
      } else if (type == 10) { // hidden
        game_data.floodFill(data.m_data[0], data.m_data[1]);
      } else {
        game_data.m_grid_client[data.m_data[0]][data.m_data[1]] = type;
        server.write(str(data.m_id) + ":" + str(data.m_data[0]) + ":" + str(data.m_data[1]) + ":" + str(type) + ":");
      }
    } else if (data.m_id == 1) { // Remove this option later
      game_data.reveal_game();
    } else if (data.m_id == 4) { // Flag 
      game_data.m_grid_client[data.m_data[0]][data.m_data[1]] = 11;
      server.write("0:" + str(data.m_data[0]) + ":" + str(data.m_data[1]) + ":11:");
    } else if (data.m_id == 5) { // Unflag
      game_data.m_grid_client[data.m_data[0]][data.m_data[1]] = 0;
      server.write("0:" + str(data.m_data[0]) + ":" + str(data.m_data[1]) + ":0:");
    }
  }
}

void serverEvent(Server this_Server, Client joining_Client) {
  String id = "3:";
  String cells = "";
  for (int y = 0; y < game_data.dim; y++) {
    for (int x = 0; x < game_data.dim; x++) {
      cells +=  str(game_data.m_grid_client[x][y]) + ":";
    }
  }
  String dim = str(game_data.dim) + ":";
  joining_Client.write(id + cells + dim);
}
