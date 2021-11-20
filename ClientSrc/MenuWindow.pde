
class MenuWindow {
	String version = "";

	boolean playSelected = false;
	boolean ipSelected = false;
	boolean portSelected = false;

	boolean wasKeyPressed = false;

	boolean running = true;

	ArrayList<String> console = new ArrayList<String>();

	MouseInput mouse1 = new MouseInput(LEFT);

	TextureStruct background = new TextureStruct(null, "Content/MenuBackground.png");

  	GuiBox ipTextBox;
	GuiBox portTextBox;
	GuiBox playButton;

	MenuWindow() {
		background.image = loadImage(background.image_path); // loadImage can't be used in a decleration.

    	/*                       x         y        w            h                                           text Size  */
		ipTextBox = new GuiBox(width/2, height/2, width/2, (int)(height/8.5), 5 /*<- Border thickness */, (int)(height/13));
		ipTextBox.fillColor = color(180);
		ipTextBox.borderColor = color(140);
		ipTextBox.text = "127.0.0.1";

		portTextBox = new GuiBox(width/2, (int)(height/1.5), (int)(width/4.5), (int)(height/8.5), 5, (int)(height/13));
		portTextBox.fillColor = color(180);
		portTextBox.borderColor = color(140);
		portTextBox.text = "5006";

		playButton = new GuiBox(width/2, (int)(height/1.20), width/5, (int)(height/8.5), 5, (int)(height/8.75));
		playButton.fillColor = color(180);
		playButton.borderColor = color(140);
		playButton.text = "PLAY";	
	}

	void handleUserInputs() {
		if (mouse1.isPressed()) {
			if (ipTextBox.isClicked()) {
				ipSelected = !ipSelected;
				portSelected = false;
			}
			else if (portTextBox.isClicked()) {
				portSelected = !portSelected;
				ipSelected = false;
			}
			else if (playButton.isClicked()) {
				if (ipTextBox.text.length() <= 0) {
					console.add("You did not enter an ip!");
				}
				else if (portTextBox.text.length() <= 0) {
					console.add("You did not enter a port!");
				}
				else {
					ipSelected = false;
					portSelected = false;
					playSelected = true;
				}
			}
		}
		if (keyPressed) {
			if (!wasKeyPressed) {
				wasKeyPressed = true;
				if (ipSelected) {
					if (validIPchar((int)key)) {
						if (ipTextBox.text.length() < 15)
							ipTextBox.text += key;
					}
					if ((int)key == 8 /* Backspace */) {
						if (ipTextBox.text.length() != 0) 
							ipTextBox.text = ipTextBox.text.substring(0, ipTextBox.text.length() - 1);
					}
				}
				else if (portSelected) {
					if (validPortchar((int)key)) {
						if (portTextBox.text.length() < 6) 
							portTextBox.text += key;
					}
					if ((int)key == 8 /* Backspace */) {
						if (portTextBox.text.length() != 0)
							portTextBox.text = portTextBox.text.substring(0, portTextBox.text.length() - 1);	
					}
				}
			}
		}
		else {
			wasKeyPressed = false;
		}
	}

	void drawGui() {
		background(220);
		image(background.image, 0, 0, width, height);
     
    ipTextBox.hasTextBox = ipSelected;
		ipTextBox.drawGraphics();

    portTextBox.hasTextBox = portSelected;
		portTextBox.drawGraphics();
		playButton.drawGraphics();

		textSize(50);
		text("IP", width/2 - (width/4) - 50, height/2 + 32);
		text("PORT", width/2 - (width/6) - 120, (int)(height/1.5) + 32);

		// Error log
		int text_size = 16;
		textSize(text_size);
		if (console.size() > 6) {
			console.remove(0);
		}
		int color_fade = 255 - (80 * (console.size()-1));
		int position_y = height - (text_size * console.size());
		for (String error : console) {
			fill(255, 0, 0, color_fade);
			text(error, width - ((text_size/2) * error.length()) - (text_size/2), position_y);
			position_y += text_size;
			color_fade += 80;
		}

		// Version
		fill(0);
		textSize(20);
		text("BETA: " + version, 5, height-5);
	}

	void clearErrors() {
		console.clear();
	}

  	boolean validIPchar(int nKey) {
    	return (
    		(nKey >= 48 && nKey <= 57) || //'0-9'
    		nKey == 46 // '.'
    		);
  	}
  
  	boolean validPortchar(int nKey) {
    	return (nKey >= 48 && nKey <= 57);
  	}

  	void lostConnection() {
  		console.add("Server Connection Lost...");
  	}

  	void cantConnect() {
  		console.add("Could not connect to Server...");
  	}

  	String getIp() {
  		return ipTextBox.text;
  	}

  	int getPort() {
  		return Integer.parseInt(portTextBox.text);
  	}
}
