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
    
    //String squares = "5:";
    
    while (!queue.isEmpty()) {
      int[] get_xy = queue.get(queue.size()-1);
      queue.remove(queue.size() - 1);
      int x = get_xy[0];
      int y = get_xy[1];
      
      if ((x < 0) || (x >= n) || (y < 0) || (y >= n)) {
        continue;
      }
      
      if (m_grid_server[x][y] != 10)
        continue;
      
      m_grid_client[x][y] = 0;
      String message = "0:" + str(x) + ":" + str(y) + ":0:";
      println(message);
      server.write(message);
      
      int[] xy1 = {x + 1, y};
      int[] xy2 = {x - 1, y};
      int[] xy3 = {x, y + 1};
      int[] xy4 = {x, y - 1};
        
      queue.add(xy1);
      queue.add(xy2);
      queue.add(xy3);
      queue.add(xy4);
    }
    
    //server.write(squares);
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
