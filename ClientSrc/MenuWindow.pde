class Menu extends PWindow {
  String version = "";

  String port = "";
  String ip = "";

  boolean port_selected = false;
  boolean ip_selected = false;

  boolean play_selected = false;

  boolean key_pressed = false;

  ArrayList<String> console = new ArrayList<String>();

  boolean lost_connection = false;
  boolean cannot_connect = false;

  MouseInput mouse1 = new MouseInput(LEFT);

  Menu() {
    loadTextures();
    running = true;
  }

  void handleInputs() {
    if (mouse1.isPressed()) {
      // Clicked IP
      if ((mouseX > 200) && (mouseX < 600) && (mouseY > 270) && (mouseY < 318)) {
        ip_selected = !ip_selected;
        port_selected = false;
      }

      // Clicked PORT
      if ((mouseX > 300) && (mouseX < 500) && (mouseY > 360) && (mouseY < 400)) {
        port_selected = !port_selected;
        ip_selected = false;
      }

      // Clicked Play
      if ((mouseX > 300) && (mouseX < 500) && (mouseY > 450) && (mouseY < 530)) {
        if (ip.length() == 0) {
          console.add("You did not enter an ip");
        } else if (port.length() == 0) {
          console.add("You did not enter a port");
        } else {
          ip_selected = false;
          port_selected = false;
          play_selected = true;
          lost_connection = false;
          cannot_connect = false;
        }
      }
    }

    if (keyPressed) {
      if (!key_pressed) {
        key_pressed = true;
        if (ip_selected) {
          if (((int)key >= 48 && (int)key <= 57) || (int)key == 46) { // `0` - `9` && `.`
            if (ip.length() < 16) 
              ip += key;
          }
          if ((int)key == 8) {
            if (ip.length() > 0) {
              ip = ip.substring(0, ip.length()-1);
            }
          }
        } else if (port_selected) { 
          if ((int)key >= 48 && (int)key <= 57) { // '0' - '9'
            if (port.length() < 6)
              port += key;
          }
          if ((int)key == 8) { // Backspace
            if (port.length() != 0) {
              port = port.substring(0, port.length()-1);
            }
          }
        }
      }
    } else {
      key_pressed = false;
    }
  }

  void drawGui() {
    // Background
    background(220);
    textureMode(NORMAL);
    noStroke();
    pushMatrix();
    translate(0, 0);
    beginShape();

    texture(m_textures[0].image);

    vertex(0, 0, 0, 0);
    vertex(width-1, 0, 1, 0);
    vertex(width, height-1, 1, 1);
    vertex(0, height-1, 0, 1);
    endShape(CLOSE);
    popMatrix();

    fill(0);
    // Ip
    textSize(30);
    text(ip, 240, 305);

    // Port
    textSize(30);
    text(port, 340, 390);

    // Version
    textSize(15);
    text(version, 65, 593);

    // Typing marker
    stroke(0);
    strokeWeight(3);
    if (ip_selected) {
      line(240 + (ip.length() * 19), 305, 240 + (ip.length() * 19) + 20, 305);
    } else if (port_selected) {
      line(340 + (port.length() * 19), 390, 340 + (port.length() * 19) + 20, 390);
    } else if (play_selected) {
      fill(0,0,0, 50);
      rect(300, 450, 200, 80);
    }

    textSize(16);
    fill(255, 0, 0);
    if (cannot_connect) {
      console.add("Could Not Connect To Server...");
      cannot_connect = false;
    }

    if (lost_connection) {
      console.add("Server Connection Lost...");
      lost_connection = false;
    }
    
    // Print console
    if (console.size() > 6) {
      console.remove(0);
    }
    int color_fade = 255 - (80 * (console.size()-1));
    int position_y = 595 - (16 * console.size());
    for (String error : console) {
      fill(255,0,0, color_fade);
      text(error, 800 - (8 * error.length()) - 8, position_y);
      position_y += 16;
      color_fade += 80;
    }
  }

  void loadTextures() {
    surface.setResizable(false); // Shhh pretend this isn't here.
    m_textures = new texture_data[] {
      new texture_data(null, "Content/MenuBackground.png"), 
    };

    // Load textures
    for (int i = 0; i < m_textures.length; i++) {
      m_textures[i].image = loadImage(m_textures[i].path);
    }
  }
}
