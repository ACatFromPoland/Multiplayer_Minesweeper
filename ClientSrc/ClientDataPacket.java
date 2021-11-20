import java.io.Serializable;

class ClientDataPacket implements Serializable {
	int id = -1;
	int[] cell_change_request = new int[3];
}