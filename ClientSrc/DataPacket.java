import java.io.Serializable;

// https://forum.processing.org/one/topic/serializable-problem.html
class DataPacket implements Serializable {
  int id = -1;
  int player_id = -1;
  int max_player_size = -1;
  int[] screen;
  int[][] cells;
  char[] game_state;
  int[][] player_cursors;
  
  DataPacket(int grid_size, int max_players) {
    screen = new int[grid_size];
    cells = new int [grid_size][3];
    game_state = new char[6];
    player_cursors = new int[max_players][3];
  }
}
