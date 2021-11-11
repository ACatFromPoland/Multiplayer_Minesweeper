class Game_Data {
  int[][] m_grid_client;
  int[][] m_grid_server;
  int dim;
  boolean game_over = false;

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

  void update_client() {
    String id = "1:";
    String cells = "";
    for (int y = 0; y < game_data.dim; y++) {
      for (int x = 0; x < game_data.dim; x++) {
        cells +=  str(game_data.m_grid_client[x][y]) + ":";
      }
    }

    server.write(id + cells);
  }

  void reveal_game() {
    String id = "1:";
    String cells = "";
    for (int y = 0; y < game_data.dim; y++) {
      for (int x = 0; x < game_data.dim; x++) {
        cells +=  str(game_data.getCell(x, y)) + ":";
      }
    }

    server.write(id + cells);
  }

  void floodFill(int origin_x, int origin_y) {
    int n = m_grid_client.length;

    ArrayList<int[]> queue = new ArrayList<int[]>();
    int[] org = {origin_x, origin_y};
    queue.add(org);

    String squares = "5:";

    while (!queue.isEmpty()) {
      int[] xy = queue.get(queue.size()-1);
      int x = xy[0];
      int y = xy[1];
      queue.remove(queue.size()-1);

      println(queue.size());
      if (validCoordinate(x, y)) {
        if (m_grid_server[x][y] == 10) {
          if (m_grid_client[x][y] == 0) {
            println("Hello!");
            m_grid_client[x][y] = 10;
            server.write("0:" + str(x) + ":" + str(y) + ":10:");
            squares += (str(x) + ":" + str(y) + ":" + str(m_grid_server[x][y]) + ":");

            // , {x - 1, y}, {x, y + 1}, {x, y - 1} 
            int[][] new_xys = { {x + 1, y}, {x - 1, y} };
            for (int[] new_cord : new_xys) { 
              queue.add(new_cord);
            }
          }
        }
      }
    }

    server.write(squares);
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
