import processing.net.*;

Menu menu_window;
Game game_window;

// Main script.
void setup() {
  size(800, 600, P2D);
  menu_window = new Menu();
  menu_window.version = "4.0.3";
}

void draw() {
  if (menu_window.running) { 
    menu_window.handleInputs();
    menu_window.drawGui();
    if (menu_window.play_selected) {
      game_window = new Game();
      if (game_window.connect_client(this, menu_window.ip, Integer.parseInt(menu_window.port))) {
        game_window.running = true;
        menu_window.running = false;
        menu_window.play_selected = false;
        menu_window.lost_connection = false;
        menu_window.cannot_connect = false;
        menu_window.console.clear();
      } else {
        menu_window.play_selected = false;
        menu_window.cannot_connect = true;
      }
    }
  } else if (game_window.running) {
    game_window.handleNetwork();
    if (game_window.initalised) {
      game_window.handleInputs();
      game_window.drawGui();
    }
    if (!game_window.m_client.active()) {
      game_window.running = false;
      menu_window.running = true;
      menu_window.lost_connection = true;
    }
  }
}
