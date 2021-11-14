import processing.net.*;

class Game extends PWindow {
  Client m_client;

  float m_window_size;
  int[][] m_grid;
  int m_bombs;
  int max_players;

  float m_cell_size_center;
  float m_cell_size;

  MouseInput mouse1 = new MouseInput(LEFT);

  Game() {
    loadTextures();

    // window_size should always be height
    newGrid(600, 25);
    coverAll();
  }

  void handleInputs() {
    if (mouse1.isPressed()) {
      int[] xy = findClickedSquare();
      if (valid_coordinate(xy[0], xy[1])) {
        if (getCell(xy[0], xy[1]) != 11) {
          DataPacket packet = new DataPacket((int)m_window_size, max_players);
          packet.id = 1;
          packet.cells[0][0] = xy[0];
          packet.cells[0][1] = xy[1];

          byte[] response = packageData(packet);
          m_client.write(response);
        }
      }
    }
  }

  void handleNetwork() {
    if (m_client.available() > 0) { 
      byte[] raw_data = m_client.readBytes();
      if (raw_data != null) {
        DataPacket data = parseData(raw_data);
        if (data != null) {
          if (data.id == 1) {
            setCell(data.cells[0][0], data.cells[0][1], data.cells[0][2]);
          }
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
      new texture_data(null, "Content/MineClicked.png") // 12
    };

    // Load the image for every path provided.
    for (int i = 0; i < m_textures.length; i++) {
      m_textures[i].image = loadImage(m_textures[i].path);
    }
  }
}
