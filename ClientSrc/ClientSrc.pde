import processing.net.*; // git-test

String server_ip = "127.0.0.1";
int server_port = 5006;
//Client client = new Client(this, server_ip, server_port);

MouseInput mouse1 = new MouseInput(LEFT);
MouseInput mouse2 = new MouseInput(RIGHT);

GameWindow window = new GameWindow();

void setup() {
  size(1200, 800, P2D);
  window.loadTextures();
  
  window.updateGrid(800, 25);
  window.coverAll();
}

void draw() {
  handleInputs();
  
  window.drawGui();
}

void handleInputs() {
  if (mouse2.isPressed()) {
    int[] xy = window.findClickedSquare();
    
    if (window.valid_coordinate(xy[0], xy[1])) {
      if (window.getType(xy[0], xy[1]) != 11) {
        window.setCell(xy[0], xy[1], 11);
      }
      else {
        window.setCell(xy[0], xy[1], 0);
      }
    }
  }
}

class texture_data {
  PImage image;
  String path;
  texture_data (PImage _null, String _path) {
    image = _null;
    path = _path;
  }
}

class GameWindow {
  float m_window_size;

  int[][] m_grid;

  texture_data[] m_textures;

  float m_grid_size_x;
  float m_grid_size_y;
  float m_cell_width;
  float m_cell_height;
  
  int[] findClickedSquare() {
    int[] grid_index_xy = {(int)((mouseX / m_grid_size_x)/2), (int)((mouseY / m_grid_size_y)/2)};
    return grid_index_xy;
  }
  
  int getType(int x, int y) {
    return m_grid[x][y];
  }
  
  void setCell(int x, int y, int cell_type) {
    m_grid[x][y] = cell_type;
  }
  
  boolean valid_coordinate(int x, int y) {
    if ((x >= 0) && (x < m_grid.length) && (y >= 0) && y < (m_grid.length)) {
      return true;
    }
    else {
      return false;
    }
  }
  
  void coverAll() {
    for (int y = 0; y < m_grid.length; y++) {
      for (int x = 0; x < m_grid.length; x++) {
        m_grid[x][y] = 0;
      }
    }
  }

  void updateGrid(int window_size, int grid_size) {
    m_window_size = window_size;
    m_grid = new int[grid_size][grid_size];
    
    // I need to change these names...
    m_grid_size_x = ((float)window_size/m_grid.length)/2;
    m_grid_size_y = ((float)window_size/m_grid.length)/2;
    
    // These are fine.
    m_cell_width = (float)window_size/m_grid.length;
    m_cell_height = (float)window_size/m_grid.length;
  }

  void drawGui() {
    background(120);
    for (int y = 0; y < m_grid.length; y++) {
      for (int x = 0; x < m_grid.length; x++) {
        float offset_x = m_cell_width * x;
        float offset_y = m_cell_height * y;

        textureMode(NORMAL);
        noStroke();
        pushMatrix();
        translate(m_grid_size_x, m_grid_size_y);
        beginShape();
        
        texture(m_textures[m_grid[x][y]].image);
        
        vertex(-m_grid_size_x + offset_x, -m_grid_size_y + offset_y, 0, 0);
        vertex(m_grid_size_x + offset_x, -m_grid_size_y + offset_y, 1, 0);
        vertex(m_grid_size_x + offset_x, m_grid_size_y + offset_y, 1, 1);
        vertex(-m_grid_size_x + offset_x, m_grid_size_y + offset_y, 0, 1);
        
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

class ButtonInput {
  char m_key;
  boolean m_pressed;

  ButtonInput(char button) {
    m_pressed = false;
    m_key = button;
  }

  boolean isPressed() {
    if (keyPressed && key == m_key) {
      if (!m_pressed) {
        m_pressed = true;
        return true;
      }
    } else {
      m_pressed = false;
    }

    return false;
  }
}

class MouseInput {
  int m_button;
  boolean m_pressed;

  MouseInput(int button) {
    m_pressed = false;
    m_button = button;
  }

  boolean isPressed() {
    if (mousePressed && (mouseButton == m_button)) {
      if (!m_pressed) {
        m_pressed = true;
        return true;
      }
    } else {
      m_pressed = false;
    }

    return false;
  }
}
