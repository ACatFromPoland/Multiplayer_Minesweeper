
class Game {
	int[][] client_grid;
	int[][] server_grid;

	boolean game_over = false;
  int game_state = 0;

  int[][] checks = {
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1, 0}, {1, 0}, 
    {-1, 1}, {0, 1}, {1, 1} 
  };

  int client_flags = 0;
  int bombs_left = g_Bombs;

	Game() {
		client_grid = new int [g_GridSize][g_GridSize];
		server_grid = new int [g_GridSize][g_GridSize];

		for (int y = 0; y < g_GridSize; y++) {
			for (int x = 0; x < g_GridSize; x++) {
				client_grid[x][y] = 0;
				server_grid[x][y] = 10;
			}
		}

		int bombs_placed = 0;
		while (true) {
			if (bombs_placed == g_Bombs) {
				break;
			}
			int x = (int)random(0, g_GridSize);
			int y = (int)random(0, g_GridSize);

			if (server_grid[x][y] == 10) {
				server_grid[x][y] = 9;
				bombs_placed ++;
			}
		}

		for (int y = 0; y < g_GridSize; y++) {
			for (int x = 0; x < g_GridSize; x++) {
				if (server_grid[x][y] == 10) {
					int bombs_nearby = 0;
					for (int i = 0; i < checks.length; i++) {
						int new_x = x + checks[i][0];
						int new_y = y + checks[i][1];
						if (validCoordinate(new_x, new_y)) {
							if (server_grid[new_x][new_y] == 9) {
								bombs_nearby ++;
							}
						}
					}

					if (bombs_nearby > 0)
						server_grid[x][y] = bombs_nearby;
				}
			}
		}
	}

	void handleData(ClientDataPacket data) {
		if (data == null) return;
		if (data.id == 0) {
			ServerDataPacket packet = new ServerDataPacket();
			packet.id = 0;
			packet.int_array[0] = g_GridSize;
			packet.int_array[1] = g_Bombs - client_flags;
      packet.screen_array = new int[g_GridSize * g_GridSize];

			int i = 0;
			for (int y = 0; y < g_GridSize; y++) {
				for (int x = 0; x < g_GridSize; x++) {
					packet.screen_array[i] = client_grid[x][y];
					i++;
				}
			}
			byte[] message = packageServerData(packet);
			GameServer.write(message);
		}
		else if (data.id == 1) {
    
			int x = data.cell_change_request[0];
			int y = data.cell_change_request[1];
			int click_type = data.cell_change_request[2];

			if (click_type == 0) {// Left click 
				if (client_grid[x][y] == 0) {
          if (server_grid[x][y] == 10) {
            floodFill(x, y);
          }
          else if (server_grid[x][y] == 9) {
            client_grid[x][y] = 12;
            game_over = true;
            game_state = 1;
            ResetClient.last_frame_count = frameCount;
            revealGameOver();
          }
          else {
					  client_grid[x][y] = server_grid[x][y];
          }
				}
			}
			else if (click_type == 1) {// Right click
				if (client_grid[x][y] == 0 && client_grid[x][y] != 11) {
					client_grid[x][y] = 11;
          client_flags += 1;
          if (server_grid[x][y] == 9)
            bombs_left -= 1;
				}
				else if (client_grid[x][y] == 11) {
					client_grid[x][y] = 0;
          client_flags -= 1;
          if (server_grid[x][y] == 9)
            bombs_left -= 1;
				}
			}
		}
	}

  void revealGameOver() {
    for (int y = 0; y < g_GridSize; y++) {
      for (int x = 0; x < g_GridSize; x++) {
        if (client_grid[x][y] != 12)
          client_grid[x][y] = server_grid[x][y];
      }
    }
  }

	void floodFill(int origin_x, int origin_y) {
		int n = client_grid.length;
		ArrayList<int[]> queue = new ArrayList<int[]>();
		int[] org = {origin_x, origin_y};
		queue.add(org);

		while (!queue.isEmpty()) {
			int[] xy = queue.get(queue.size() - 1);
			int x = xy[0];
			int y = xy[1];
			queue.remove(queue.size()-1);

			if (validCoordinate(x, y)) {
				int server_type = server_grid[x][y];
				if (server_type == 10) {
					if (client_grid[x][y] == 0) {
						client_grid[x][y] = 10;

			            int[][] new_xys = {
			            	{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}, // Right, left, Down, Up
			            	{x - 1, y - 1}, {x + 1, y - 1}, {x - 1, y + 1}, {x + 1, y + 1} // U_right, U_left, D_right, D_Left
			            };

			            for (int[] new_cord : new_xys) {
			            	queue.add(new_cord);
			            }
					}
				}
				else {
					client_grid[x][y] = server_type;
				}
			}
		}
	}

	boolean validCoordinate(int x, int y) {
    	return ( (x >= 0) && (x < g_GridSize) && (y >= 0) && (y < g_GridSize));
  	}

	boolean isGameOver() {
		return game_over;
	}
}

class Event {
	int last_frame_count;
	int frame_offset;

	Event (int n) {
		frame_offset = n;
	}

	boolean active() {
		if (frameCount > last_frame_count + frame_offset) {
			last_frame_count = frameCount;
			return true;
		}
		else {
			return false;
		}
	}
}
