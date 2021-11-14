class texture_data {
  PImage image;
  String path;
  texture_data (PImage _null, String _path) {
    image = _null;
    path = _path;
  }
}

class PWindow {
  boolean running;
  texture_data[] m_textures;
  
  PWindow() {
    running = false;
  }
  
}
