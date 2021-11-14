import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;

// Everything here has been the bane of my existance. (Including DataPacket.java)
// Literally been reading through fourms for 3 hours to figure out how to serialise an object and deserialise it.
// Kept running into problems where Exceptions were being thrown
// 
// The key ingridents to get `Class serialization` working is ->
// Place the class into a seperate .java file
// Put implements Serializable onto the classq

// https://www.tutorialspoint.com/How-to-convert-an-object-to-byte-array-in-java
// The code from that link was tweaked into a function.
byte[] writeToByteArray(DataPacket p) throws IOException {
  ByteArrayOutputStream bos = new ByteArrayOutputStream(); 
  ObjectOutputStream obj_Outs = new ObjectOutputStream(bos);
  obj_Outs.writeObject(p);
  obj_Outs.flush();
  obj_Outs.close();
  byte[] data = bos.toByteArray();
  return data;
}

static Object writeToObject(byte[] raw_data) throws IOException, ClassNotFoundException {
  ByteArrayInputStream bA_inpS = new ByteArrayInputStream(raw_data);
  ObjectInputStream obj_inpS = new ObjectInputStream(bA_inpS);
  return obj_inpS.readObject();
}

// I don't know how to use this :/
// Keeps giving me weird errors that I think have to do with processing.
enum pt {
  GAME_INF, // 0
  REVEAL_CELL, // 1
  FLAG_CELL, // 2
  UNFLAG_CELL, // 3
  FLOOD_FILL, // 4
  UPDATE_SCREEN, // 5
  RESTART_GAME // 6
}

DataPacket parseData(byte[] raw_data) {
  try {
    return (DataPacket) writeToObject(raw_data);
  }
  catch (IOException e) {
    println("Packet io exception");
    return null;
  }
  catch (ClassNotFoundException e) {
    println("Packet class exception");
    return null;
  }
}

byte[] packageData(DataPacket data) {
  try {
    return writeToByteArray(data);
  }
  catch (IOException e) {
    println("Packet io exception");
    return null;
  }
}
