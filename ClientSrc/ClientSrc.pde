import processing.net.*;

MenuWindow MainMenu;
GameWindow Game;

/* 
Valid resolutions ->
  size(800, 600);
  size(800, 600);
  size(1120 , 840);
  size(800, 600);
  size(1440, 1080);
  Resolution ratio = 4 : 3
*/
void setup() {
  size(800, 600, P2D);
  MainMenu = new MenuWindow();
  MainMenu.version = "4.1.0";
}

void draw() {
  if (MainMenu.running) {
    MainMenu.handleUserInputs();
    MainMenu.drawGui();

    if (MainMenu.playSelected) {
      Game = new GameWindow();
      if (Game.couldConnectTo(this, MainMenu.getIp(), MainMenu.getPort())) {
        Game.running = true;
        MainMenu.running = false;
        MainMenu.clearErrors();
      }
      else {
        MainMenu.cantConnect();
      }
      MainMenu.playSelected = false;
    }
  }
  else if (Game.running) {
    Game.checkNetwork();
    if (Game.initalised) {
      Game.handleUserInputs();
      Game.drawGui();
    }

    if (!Game.isConnected()) {
      Game.running = false;
      MainMenu.running = true;
      MainMenu.lostConnection();
    }
  }
}
