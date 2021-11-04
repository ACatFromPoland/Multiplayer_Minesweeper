import processing.net.*;
Server server;

int[][] hidden_grid = new int[25][25]; // This is the actual grid.
int[][] cleared_grid = new int[25][25]; // This currently isn't being used but will be used later.

// Game data
int bombs = 100;

boolean game_over = false;
boolean restart = false;

boolean active_flood_fill = false;

void setup() {
  size(400, 200); // Window not currently used.
  server = new Server(this, 5006);

  // Generate grid
  emptyGrid(hidden_grid);
  placeBombs(hidden_grid);
  calculateCells(hidden_grid);

  emptyGrid(cleared_grid);
}

String previous_message = null;
void draw() {
  Client m_client = server.available();
  String server_response = "";

  if (game_over) { // Reveal client screens.
    game_over_clear_screen_individually();
  } 
  
  else if (restart) { // Game has reset
    server.write("2:"); // Basically telling all clients to hide screens
    restart = false;
  } 
  
  else {
    // Continue handeling the user.
    if (m_client != null) {
      String client_message = m_client.readString();
      server_response = "";

      if (client_message != null) {
        int[] data = parseData(client_message);
        
        switch (data[0]) {
          case 0: // Uncover cell request.
            server_response = unCoverSquare(data[1], data[2]);
            server.write(server_response);
            break;
  
          case 1: // Flag cell request
            server.write("3:" + str(data[1]) + ":" + str(data[2]) + ":" + str(11) + ":");
            break;
  
          case 2: // Unflag cell request
            server.write("4:" + str(data[1]) + ":" + str(data[2]) + ":" + str(0) + ":");
            break;
  
          case 3: // Request game size
            break;
  
          case 4: // Request game layer
            break;
        }
      }
    }
  }
}
// This function is used for uncovering cells when requested by the player
String unCoverSquare(int x, int y) {
  String response = "-1:";
  String m_x = str(x);
  String m_y = str(y);
  int cell_type = hidden_grid[x][y]; // Get requested cell information

  if (cell_type == 9) { // Clicked bomb
    response = "1:" + m_x + ":" + m_y + ":" + str(12) + ":";
    cleared_grid[x][y] = cell_type; // Update servers layer
    game_over = true;
    return response;
  }
  if ((cell_type == 10) && (active_flood_fill)) { // Clicked hidden square
    response = revealNearbyEmpties(x, y);
    return response;
  } 
  else if (cell_type != 11) { // As long as its not a flag
    response = "0:" + m_x + ":" + m_y + ":" + str(cell_type) + ":";
    return response;
  }

  return response;
}


// These will later be replaced when I overhaul the networking system.
// Both of them are fundamentally the same, but one sends cell by cell, and the other sends it line by line.
int uncover_x = 0;
int uncover_y = 0;

void game_over_clear_screen_individually() {
  String server_response = "";
  
  server_response = "6:" + str(uncover_x) + ":" + str(uncover_y) + ":" + str(hidden_grid[uncover_x][uncover_y]) + ":";
  server.write(server_response);
  
  uncover_x ++;
  if (uncover_x >= hidden_grid.length) {
    uncover_x = 0;
    uncover_y ++;
    if (uncover_y >= hidden_grid.length) {
      emptyGrid(hidden_grid);
      placeBombs(hidden_grid);
      calculateCells(hidden_grid);
  
      emptyGrid(cleared_grid);
  
      uncover_x = 0;
      uncover_y = 0;
      restart = true;
      game_over = false;
    }
  }
}

void game_over_clear_screen() {
  String server_response = "";

  for (int x = 0; x < hidden_grid.length; x++) {
    server_response += (str(x) + ":" + str(uncover_y) + ":" + str(hidden_grid[x][uncover_y]) + ":");
  }

  // Sending new and previous layer every time.
  if (previous_message != null) {
    server.write("5:" + previous_message + server_response);
    previous_message = server_response;
  } 
  else {
    server.write("5:" + server_response);
    previous_message = server_response;
  }
  uncover_y ++;

  if (uncover_y == hidden_grid.length) { // Restart game
    emptyGrid(hidden_grid);
    placeBombs(hidden_grid);
    calculateCells(hidden_grid);

    emptyGrid(cleared_grid);

    uncover_y = 0;
    restart = true;
    game_over = false;
  }
}
