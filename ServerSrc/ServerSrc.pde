import processing.net.*;
Server server;

void setup() {
  size(400, 200); // Window not currently used.
  server = new Server(this, 5006);

}

void draw() {
  Client client = server.available();
  {
    if (client != null) {
      String raw_data = client.readString();
      
      if (raw_data != null) {
        Packet data = new Packet(raw_data);
        
        server.write(str(data.m_id) + ":" + str(data.m_data[0]) + ":" + str(data.m_data[1]) + ":" + str(2) + ":");
      }
    }
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
}

class Packet {
  int m_id;
  int[] m_data;
  
  Packet(String r_data) {
    parseData(r_data);
  }
  
  void parseData(String raw_data) {
    int[] output;
    int size = 0;
    
    if (raw_data == null) {
      return;
    }
    
    for (int i = 0; i < raw_data.length(); i++) { 
      char c = raw_data.charAt(i);
      if (c == ':') {
        size ++;
      }
    }
    size ++;
    output = new int[size];
    
    int index = 0;
    String section = "";
    for (int i = 0; i < raw_data.length(); i++) {
      char c = raw_data.charAt(i);
      if (c != ':') {
        section += raw_data.charAt(i);
      }
      else {
        output[index] = Integer.parseInt(section);
        section = "";
        index ++;
      }
    }
    
    m_id = output[0];
    m_data = new int[output.length-1];
    for (int i = 1; i < output.length; i++) {
      m_data[i - 1] = output[i];
    }
  }
}
