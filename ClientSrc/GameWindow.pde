import processing.net.*;

class GameWindow {
  Client client;

  int[][] grid;

  int total_bombs;
  int game_state;

  int grid_size;
  float cell_size_from_center;
  float cell_size;

  TextureStruct[] textures;

  boolean running = false;
  boolean initalised = false;

  MouseInput mouse1 = new MouseInput(LEFT);
  MouseInput mouse2 = new MouseInput(RIGHT);

  GuiBox bombsGUI;
  GuiBox probabiltyGUI;
  GuiBox playersGUI;
  TextureStruct gameStateImage = new TextureStruct(null, "Content/State_Going.png");
  
  int guiX_size = (width - height) / 2;
  int guiX = height + guiX_size;

  GameWindow() {
    loadTextures();
    gameStateImage.image = loadImage(gameStateImage.image_path);

    // Stops player from pressing on grid when joining.
    mouse1.was_pressed = true;
    mouse2.was_pressed = true;

    bombsGUI = new GuiBox(guiX, (int)((height/10) * 0.95), (int)(guiX_size * 1.25), height/10, height/100, (int)(height/13));
    bombsGUI.fillColor = color(180);
    bombsGUI.borderColor = color(140);
    //(int)(guiX_size / 1.50)
    probabiltyGUI = new GuiBox(guiX + (int)((guiX_size / 1.50) / 2), (int)((height/10) * 2.25), height/10, height/10, height/100, (int)(height/13));
    probabiltyGUI.fillColor = color(180);
    probabiltyGUI.borderColor = color(140);

    playersGUI = new GuiBox(guiX, (int)((height/10) * 6.5), (int)(guiX_size * 1.25), (int)(height/1.6), height/100, (int)(height/13));
    playersGUI.fillColor = color(180);
    playersGUI.borderColor = color(140);
  }

  void checkNetwork() {
    ServerDataPacket data = getNextMessage();
    if (data != null) { 
      // 0 = Initalise game
      if (data.id == 0) {
        grid_size = data.int_array[0];
        total_bombs = data.int_array[1];
        generateGame(grid_size);
        updateGrid(data.screen_array);
        initalised = true;
      }
  
      // 1 = Update screen
      if (data.id == 1) {
        total_bombs = data.int_array[1];
        game_state = data.int_array[2];
        if (game_state == 0) {
          gameStateImage.image = loadImage("Content/State_Going.png"); 
        }
        else if (game_state == 1) {
          gameStateImage.image = loadImage("Content/State_Lost.png");
        }
        else if (game_state == 2) {
          gameStateImage.image = loadImage("Content/State_Win.png"); 
        }
        
        bombsGUI.text = Integer.toString(total_bombs);
  
        updateGrid(data.screen_array);
      }
    };
    
    if (!initalised) {
      ClientDataPacket packet = new ClientDataPacket();
      packet.id = 0;
      byte[] message = packageClientData(packet);
      if (message != null)
        client.write(message); 
      return;
    }
  }

  void handleUserInputs() {
    if (!mousePressed) {
      mouse1.was_pressed = false;
      mouse2.was_pressed = false;
      return;
    }
    int[] xy = getClickedSquare();
    int x = xy[0];
    int y = xy[1];

    if (!isValidCoordinate(x, y)) return;

    int type = grid[x][y];

    ClientDataPacket packet = new ClientDataPacket();
    packet.id = 1;
    packet.cell_change_request = new int[] {x, y, -1};

    if (mouse1.isPressed()) {
      packet.cell_change_request[2] = 0;
    }
    if (mouse2.isPressed()) {
      packet.cell_change_request[2] = 1;
    }

    if (packet.cell_change_request[2] != -1) {
      byte[] message = packageClientData(packet);
      client.write(message);
    }
  }

  void drawGui() {
    background(220);
    
    image(gameStateImage.image, guiX - (guiX_size / 1.30), ((height/10) * 1.65), height/8.35, height/8.35);

    // Draws game grid
    float CSFC = cell_size_from_center; // Will probably be removed by compiler, only here for easy reading.
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid.length; x++) {
        float offset_x = cell_size * x;
        float offset_y = cell_size * y;

        textureMode(NORMAL);
        noStroke();
        pushMatrix();
        translate(cell_size_from_center, cell_size_from_center);
        beginShape();

        texture(textures[grid[x][y]].image);

        vertex(-CSFC + offset_x, -CSFC + offset_y, 0, 0);
        vertex(CSFC + offset_x, -CSFC + offset_y, 1, 0);
        vertex(CSFC + offset_x, CSFC + offset_y, 1, 1);
        vertex(-CSFC + offset_x, CSFC + offset_y, 0, 1);

        endShape(CLOSE);
        popMatrix();
      }
    }

    playersGUI.drawGraphics();
    bombsGUI.drawGraphics();
    probabiltyGUI.drawGraphics();
  }

  void generateGame(int grid_size) {
    grid = new int[grid_size][grid_size];

    cell_size = (float)height/grid_size;
    cell_size_from_center = cell_size/2;
  }

  void updateGrid(int[] type_array) {
    int i = 0;
    for (int y = 0; y < grid_size; y++) {
      for (int x = 0; x < grid_size; x++) {
        grid[x][y] = type_array[i];
        i++;
      }
    }
  }

  void loadTextures() {
    textures = new TextureStruct[] {
      new TextureStruct(null, "Content/Hidden.png"), 
      new TextureStruct(null, "Content/1.png"), 
      new TextureStruct(null, "Content/2.png"), 
      new TextureStruct(null, "Content/3.png"), 
      new TextureStruct(null, "Content/4.png"), 
      new TextureStruct(null, "Content/5.png"), 
      new TextureStruct(null, "Content/6.png"), 
      new TextureStruct(null, "Content/7.png"), 
      new TextureStruct(null, "Content/8.png"), 
      new TextureStruct(null, "Content/Mine.png"), 
      new TextureStruct(null, "Content/Empty.png"), 
      new TextureStruct(null, "Content/Flag.png"), 
      new TextureStruct(null, "Content/MineClicked.png")
    };

    for (int i = 0; i < textures.length; i++) {
      textures[i].image = loadImage(textures[i].image_path);
    }
  }

  int[] getClickedSquare() {
    return new int[] { 
      (int)((mouseX / cell_size_from_center) / 2), 
      (int)((mouseY / cell_size_from_center) / 2)
    };
  }

  boolean isValidCoordinate(int x, int y) {
    return (
      x >= 0 && x < grid.length &&
      y >= 0 && y < grid.length
      );
  }

  boolean couldConnectTo(PApplet process, String ip, int port) {
    client = new Client(process, ip, port);
    return client.active();
  }

  boolean isInitalised() {
    return initalised;
  }

  boolean isConnected() {
    return client.active();
  }

  ServerDataPacket getNextMessage() {
    if (client.available() > 0) {
      byte[] raw_data = client.readBytes();
      if (raw_data == null) return null;
      return parseBytes(raw_data);
    } else {
      return null;
    }
  }
}
