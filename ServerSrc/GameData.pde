
class Game {
  int[][] grid_client;
  int[][] grid_server;
  int m_dimensions;
  int m_bombs;

  boolean game_over = false;

  Game(int dims, int bombs) {
    m_dimensions = dims;
    m_bombs = bombs;

    grid_client = new int[m_dimensions][m_dimensions];
    grid_server = new int[m_dimensions][m_dimensions];

    for (int y = 0; y < m_dimensions; y++) {
      for (int x = 0; x < m_dimensions; x++) {
        grid_client[x][y] = 0;
        grid_server[x][y] = 10;
      }
    }

    int bombs_placed = 0;
    while (true) {
      if (bombs_placed == bombs) {
        break;
      }
      int x = (int)random(0, m_dimensions);
      int y = (int)random(0, m_dimensions);

      if (getCell(x, y) == 10) {
        setCell(x, y, 9);
        bombs_placed++;
      }
    }

    for (int y = 0; y < m_dimensions; y++) {
      for (int x = 0; x < m_dimensions; x++) {
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
            grid_server[x][y] = bombs_nearby;
        }
      }
    }
  }

  int[][] checks = { // Used for flood-clear
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1, 0}, {1, 0}, 
    {-1, 1}, {0, 1}, {1, 1} 
  };

  int getCell(int x, int y) {
    return grid_server[x][y];
  }

  void setCell(int x, int y, int t) { 
    grid_server[x][y] = t;
  }

  boolean validCoordinate(int x, int y) {
    return ( (x >= 0) && (x < m_dimensions) && (y >= 0) && (y < m_dimensions));
  }

  void floodFill(int origin_x, int origin_y) {
    DataPacket packet = new DataPacket(grid_dimension * grid_dimension, max_players);
    packet.id = 4;

    //packet.cells[0] = new int[]{origin_x, origin_y, 10};

    int n = grid_client.length;
    ArrayList<int[]> queue = new ArrayList<int[]>();
    int[] org = {origin_x, origin_y};
    queue.add(org);

    int i = 0;
    while (!queue.isEmpty()) {
      int[] xy = queue.get(queue.size()-1);
      int x = xy[0];
      int y = xy[1];
      queue.remove(queue.size()-1);

      if (validCoordinate(x, y)) {
        int server_type = grid_server[x][y];
        if (server_type == 10) {
          if (grid_client[x][y] == 0) {
            grid_client[x][y] = 10;
            packet.cells[i] = new int[]{x, y, server_type};
            i ++;

            int[][] new_xys = {
              {x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}, // Right, left, Down, Up
              {x - 1, y - 1}, {x + 1, y - 1}, {x - 1, y + 1}, {x + 1, y + 1} // U_right, U_left, D_right, D_Left
            };

            for (int[] new_cord : new_xys) {
              queue.add(new_cord);
            }
          }
        } else {
          int[] numbered_cell = new int[]{x, y, server_type};
          boolean in_array = false;
          for (int[] cell : packet.cells) {
            if (numbered_cell[0] == cell[0] &&
              numbered_cell[1] == cell[1] &&
              numbered_cell[2] == cell[2]) {
              in_array = true;
            }
          }

          if (!in_array) {
            packet.cells[i] = new int[]{x, y, server_type};
            i++;
            grid_client[x][y] = server_type;
          }
        }
      }
    }

    byte[] response = packageData(packet);
    server.write(response);
  }
}

class Event {
  int last_frame_count;
  int frame_offset;

  Event (int n) {
    frame_offset = n;
  }

  boolean active() {
    if (frameCount > last_frame_count + frame_offset) {
      last_frame_count = frameCount;
      return true;
    } else {
      return false;
    }
  }
}
