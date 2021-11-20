import java.io.Serializable;

class ServerDataPacket implements Serializable {
	int id = -1;
	int[] int_array = new int[3];
	int[] screen_array;
}