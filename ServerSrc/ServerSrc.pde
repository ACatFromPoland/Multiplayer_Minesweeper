import processing.net.*;
import java.net.InetAddress;

// Change port here if needed.
Server GameServer = new Server(this, 5006);

Game GameData;
Event UpdateClient = new Event(6);
Event ResetClient = new Event(1000);

int g_GridSize = 8;
int g_Bombs = 5;

InetAddress inet;
String myIP;

void setup() {
  frameRate(240);
  size(400, 200);
  surface.setResizable(false);
  GameData = new Game();

  // Thank you CS171 
  try {
    inet = InetAddress.getLocalHost();
    myIP = inet.getHostAddress();
  }
  catch (Exception e) {
    e.printStackTrace();
    myIP = "Could not get IP";
  }

  fill(0);
  textSize(23);
}

void draw() {
  text("Server LAN IP: " + myIP, width/14, height/1.9);
  text("Port: 5006", width/14, height/1.2);

  if (UpdateClient.active()) {
    ServerDataPacket packet = new ServerDataPacket();
    packet.id = 1;
    packet.int_array[1] = g_Bombs - GameData.client_flags;
    packet.int_array[2] = GameData.game_state;
    packet.screen_array = new int[g_GridSize * g_GridSize];

    int i = 0;
    for (int y = 0; y < g_GridSize; y++) {
      for (int x = 0; x < g_GridSize; x++) {
        packet.screen_array[i] = GameData.client_grid[x][y];
        i++;
      }
    }

    byte[] message = packageServerData(packet);
    GameServer.write(message);
  }
  
  if (ResetClient.active() && GameData.isGameOver()) {
    GameData = new Game();
  }
  
  if (GameData.client_flags == g_Bombs && GameData.bombs_left == 0 && !GameData.game_over) {
    GameData.game_over = true;
    GameData.game_state = 2;
    ResetClient.last_frame_count = frameCount;
    GameData.revealGameOver();
  }
  
  Client client = GameServer.available();
  ClientDataPacket data = getNextMessage();
  GameData.handleData(data);
}

void serverEvent(Client joining_client) {
  ServerDataPacket packet = new ServerDataPacket();
  packet.id = 0;
  packet.int_array[0] = g_GridSize;
  packet.int_array[1] = g_Bombs - GameData.client_flags;
  packet.screen_array = new int[g_GridSize * g_GridSize];

  int i = 0;
  for (int y = 0; y < g_GridSize; y++) {
    for (int x = 0; x < g_GridSize; x++) {
      packet.screen_array[i] = GameData.client_grid[x][y];
      i++;
    }
  }

  byte[] message = packageServerData(packet);
  GameServer.write(message);
}

ClientDataPacket getNextMessage() {
  Client client = GameServer.available();
  if (client == null) return null;
  byte[] raw_data = client.readBytes();
  if (raw_data == null) return null;
  return parseBytes(raw_data);
}
