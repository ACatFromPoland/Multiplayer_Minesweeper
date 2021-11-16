import processing.net.*;

class Game extends PWindow {
  Client m_client;
  int client_id;

  float m_window_size;
  int screen_size;
  int[][] m_grid;
  int m_bombs;
  String m_message = "";
  int max_players;
  boolean initalised = false;

  float m_cell_size_center;
  float m_cell_size;

  MouseInput mouse1 = new MouseInput(LEFT);
  MouseInput mouse2 = new MouseInput(RIGHT);

  Game() {
    loadTextures();

    // Stops user from pressing square when joining.
    mouse1.m_pressed = true;
    mouse2.m_pressed = true;
  }

  void handleNetwork() {
    if (!initalised) {
      DataPacket packet = new DataPacket(screen_size, max_players);
      packet.id = 0;
      byte[] response = packageData(packet);
      m_client.write(response);
    } 
    if (m_client.available() > 0) { 
      byte[] raw_data = m_client.readBytes();
      if (raw_data != null) {
        DataPacket data = parseData(raw_data);
        if (data != null) {
          if (data.id == 0) { // GAME_INF
            client_id = data.player_id;
            max_players = data.max_player_size;
            m_bombs = data.cells[0][0]; // Re-purposing some memory

            screen_size = data.cells[0][1];
            newGrid(600, screen_size);
            int i = 0;
            for (int y = 0; y < m_grid.length; y++) {
              for (int x = 0; x < m_grid.length; x++) {
                setCell(x, y, data.screen[i]);
                i++;
              }
            }
            initalised = true;
          } 
          if (initalised) {
            if (data.id == 1) { // REVEAL_CELL
              setCell(data.cells[0][0], data.cells[0][1], data.cells[0][2]);
            } else if (data.id == 2) { // FLAG_CELL
              setCell(data.cells[0][0], data.cells[0][1], 11);
              m_bombs -= 1;
              // Bomb counter -1
            } else if (data.id == 3) { // UNFLAG_CELL
              setCell(data.cells[0][0], data.cells[0][1], 0);
              m_bombs += 1;
              // Bomb counter +1
            } else if (data.id == 4) { // FLOOD_FILL
              for (int[] cell : data.cells) {
                setCell(cell[0], cell[1], cell[2]);
              }
            } else if (data.id == 5) { // UPDATE_SCREEN
              int i = 0;
              for (int y = 0; y < m_grid.length; y++) {
                for (int x = 0; x < m_grid.length; x++) {
                  setCell(x, y, data.screen[i]);
                  i++;
                }
              }
            } else if (data.id == 6) { // RESTART_GAME
              int i = 0;
              for (int y = 0; y < m_grid.length; y++) {
                for (int x = 0; x < m_grid.length; x++) {
                  setCell(x, y, data.screen[i]);
                  i++;
                }
              }
              newGrid(600, data.cells[0][0]); // Re-purposing array for screen cells here
              coverAll();
            }
          }
        }
      }
    }
  }

  void handleInputs() {
    if (mouse1.isPressed()) {
      int[] xy = findClickedSquare();
      if (valid_coordinate(xy[0], xy[1])) {   
        if (getCell(xy[0], xy[1]) == 0) {
          DataPacket packet = new DataPacket(screen_size * 2, max_players);
          packet.id = 1;
          packet.cells[0] = new int[]{xy[0], xy[1]};
          byte[] response = packageData(packet);
          m_client.write(response);
        }
      }
    }

    if (mouse2.isPressed()) {
      int[] xy = findClickedSquare();
      if (valid_coordinate(xy[0], xy[1])) {
        int type = getCell(xy[0], xy[1]);
        if (type != 11 && type == 0) {
          // Bomb counter -1
          DataPacket packet = new DataPacket(screen_size * 2, max_players);
          packet.id = 2;
          packet.cells[0] = new int[]{xy[0], xy[1], 11};
          byte[] response = packageData(packet);
          m_client.write(response);
        } else if (type == 11) {
          // Bomb counter +1
          DataPacket packet = new DataPacket(screen_size * 2, max_players);
          packet.id = 3;
          packet.cells[0] = new int[]{xy[0], xy[1], 0};
          byte[] response = packageData(packet);
          m_client.write(response);
        }
      }
    }
  }

  boolean connect_client(PApplet pWindow, String ip, int port) {
    m_client = new Client(pWindow, ip, port);
    return m_client.active();
  }

  int[] findClickedSquare() {
    int[] grid_index_xy = {(int)((mouseX / m_cell_size_center)/2), (int)((mouseY / m_cell_size_center)/2)};
    return grid_index_xy;
  }

  boolean valid_coordinate(int x, int y) {
    if ((x >= 0) && (x < m_grid.length) && (y >= 0) && y < (m_grid.length)) {
      return true;
    } else {
      return false;
    }
  }

  void setCell(int x, int y, int cell_type) {
    m_grid[x][y] = cell_type;
  }

  int getCell(int x, int y) {
    return m_grid[x][y];
  }

  void coverAll() {
    for (int y = 0; y < m_grid.length; y++) {
      for (int x = 0; x < m_grid.length; x++) {
        m_grid[x][y] = 0;
      }
    }
  }

  void newGrid(int window_size, int grid_size) {
    m_window_size = window_size;
    m_grid = new int[grid_size][grid_size];

    m_cell_size = (float)window_size/m_grid.length;

    m_cell_size_center = m_cell_size/2;
  }

  void drawGui() {
    background(120);
    // Grid
    for (int y = 0; y < m_grid.length; y++) {
      for (int x = 0; x < m_grid.length; x++) {
        float offset_x = m_cell_size * x;
        float offset_y = m_cell_size * y;

        textureMode(NORMAL);
        noStroke();
        pushMatrix();
        translate(m_cell_size_center, m_cell_size_center);
        beginShape();

        texture(m_textures[m_grid[x][y]].image);

        vertex(-m_cell_size_center + offset_x, -m_cell_size_center + offset_y, 0, 0);
        vertex(m_cell_size_center + offset_x, -m_cell_size_center + offset_y, 1, 0);
        vertex(m_cell_size_center + offset_x, m_cell_size_center + offset_y, 1, 1);
        vertex(-m_cell_size_center + offset_x, m_cell_size_center + offset_y, 0, 1);

        endShape(CLOSE);
        popMatrix();
      }
    }

    // UI
    textureMode(NORMAL);
    noStroke();
    pushMatrix();
    translate(600, 0);
    beginShape();

    texture(m_textures[13].image);

    vertex(0, 0, 0, 0);
    vertex(200, 0, 1, 0);
    vertex(200, 600, 1, 1);
    vertex(0, 600, 0, 1);

    endShape(CLOSE);
    popMatrix();

    fill(0);
    text("Bombs:" + m_bombs, 30 + 600, 65);
    text("You:" + m_message, 30 + 600, 165);
  }

  void loadTextures() {
    m_textures = new texture_data[] {
      new texture_data(null, "Content/Hidden.png"), // 0

      new texture_data(null, "Content/1.png"), 
      new texture_data(null, "Content/2.png"), 
      new texture_data(null, "Content/3.png"), 
      new texture_data(null, "Content/4.png"), 
      new texture_data(null, "Content/5.png"), 
      new texture_data(null, "Content/6.png"), 
      new texture_data(null, "Content/7.png"), 
      new texture_data(null, "Content/8.png"), 

      new texture_data(null, "Content/Mine.png"), // 9
      new texture_data(null, "Content/Empty.png"), // 10
      new texture_data(null, "Content/Flag.png"), // 11
      new texture_data(null, "Content/MineClicked.png"), // 12
      new texture_data(null, "Content/GameUI.png") // 13
    };

    // Load the image for every path provided.
    for (int i = 0; i < m_textures.length; i++) {
      m_textures[i].image = loadImage(m_textures[i].path);
    }
  }
}
