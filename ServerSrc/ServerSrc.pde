import processing.net.*;
Server server;

class Game_Data {
  int[][] m_grid_client;
  int[][] m_grid_server;
  int dim;

  int[][] checks = { 
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1, 0}, {1, 0}, 
    {-1, 1}, {0, 1}, {1, 1} };

  int getCell(int x, int y) {
    return m_grid_server[x][y];
  }

  boolean validCoordinate(int x, int y) {
    return ( (x >= 0) && (x < dim) && (y >= 0) && (y < dim));
  }

  void createGame(int dimensions, int bombs) {
    dim = dimensions;
    m_grid_client = new int[dimensions][dimensions];
    m_grid_server = new int[dimensions][dimensions];

    // Fresh template
    for (int y = 0; y < dimensions; y++) {
      for (int x = 0; x < dimensions; x++) {
        m_grid_client[x][y] = 0;
        m_grid_server[x][y] = 10;
      }
    }

    // Place bombs
    int bombs_placed = 0;
    while (true) {
      if (bombs_placed == bombs) {
        break;
      }
      int x = (int)random(0, dimensions);
      int y = (int)random(0, dimensions);

      if (m_grid_server[x][y] == 10) {
        m_grid_server[x][y] = 9;
        bombs_placed++;
      }
    }

    // Calculate numbers for bomb neighbours
    for (int y = 0; y < dimensions; y++) {
      for (int x = 0; x < dimensions; x++) {
        if (getCell(x, y) == 10) {
          int bombs_nearby = 0;
          for (int i = 0; i < checks.length; i++) {
            int new_x = x + checks[i][0];
            int new_y = y + checks[i][1];
            if (validCoordinate(new_x, new_y)) {
              if (getCell(new_x, new_y) == 9) {
                bombs_nearby ++;
              }
            }
          }

          if (bombs_nearby > 0) 
            m_grid_server[x][y] = bombs_nearby;
        }
      }
    }
  }
}

Game_Data game_data = new Game_Data();
void setup() {
  frameRate(240);
  size(400, 200); // Window not currently used.
  server = new Server(this, 5006);

  game_data.createGame(25, 50);
}

int last_frame_count = 0;
int update_offset = 4;
void draw() {

  if (frameCount > last_frame_count + update_offset) {
    // Update screen
    last_frame_count = frameCount;
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
    if (data.m_id == 0) {
      int type = game_data.getCell(data.m_data[0], data.m_data[1]);
      server.write(str(data.m_id) + ":" + str(data.m_data[0]) + ":" + str(data.m_data[1]) + ":" + str(type) + ":");
    }
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
}

class Packet {
  int m_id;
  int[] m_data;

  Packet(String r_data) {
    parseData(r_data);
  }

  void parseData(String raw_data) {
    int[] output;
    int size = 0;

    if (raw_data == null) {
      return;
    }

    for (int i = 0; i < raw_data.length(); i++) { 
      char c = raw_data.charAt(i);
      if (c == ':') {
        size ++;
      }
    }
    size ++;
    output = new int[size];

    int index = 0;
    String section = "";
    for (int i = 0; i < raw_data.length(); i++) {
      char c = raw_data.charAt(i);
      if (c != ':') {
        section += raw_data.charAt(i);
      } else {
        output[index] = Integer.parseInt(section);
        section = "";
        index ++;
      }
    }

    m_id = output[0];
    m_data = new int[output.length-1];
    for (int i = 1; i < output.length; i++) {
      m_data[i - 1] = output[i];
    }
  }
}
