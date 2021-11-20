
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;

byte[] packageClientData(ClientDataPacket p) {
	try {
		return writeToByteArray(p);
	}
	catch (IOException e) {
		println("Packet io exception");
		return null;
	}
}

ServerDataPacket parseBytes(byte[] raw_data) {
	try {
		return (ServerDataPacket) writeToObject(raw_data);
	}
	catch (IOException e) {
		println("Packet io exception");
		return null;
	}
	catch (ClassNotFoundException e) {
		println("Class not found exception");
		return null;
	}
}

byte[] writeToByteArray(Object obj) throws IOException {
	ByteArrayOutputStream bos = new ByteArrayOutputStream();
	ObjectOutputStream obj_Outs = new ObjectOutputStream(bos);
	obj_Outs.writeObject(obj);
	obj_Outs.flush();
	obj_Outs.close();
	return bos.toByteArray();
}

static Object writeToObject(byte[] raw_data) throws IOException, ClassNotFoundException {
	ByteArrayInputStream bA_inpS = new ByteArrayInputStream(raw_data);
	ObjectInputStream obj_inpS = new ObjectInputStream(bA_inpS);
	return obj_inpS.readObject();
}