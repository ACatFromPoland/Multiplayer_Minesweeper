
class Game {
  int[][] grid_client;
  int[][] grid_server;
  int m_dimensions;
  int m_bombs;

  boolean game_over = false;

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
