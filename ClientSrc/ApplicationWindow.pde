
class GuiBox {
	int x, y;
	int w, h;
	int textSize = -1;

	int bx, by, bw, bh;

	PImage texture;

	String text;
	color fillColor = 255;
	color borderColor = 255;
	color textColor = 0;

	boolean hasTexture = false;
	boolean hasTextBox = false;

	GuiBox(int x, int y, int w, int h, int borderThickness, int textSize) {
		this.x = x - (w/2);
		this.y = y - (h/2);
		this.w = w;
		this.h = h;
		this.textSize = textSize;
		if (this.textSize == -1) {
			this.textSize = (int)(h/1.6);
		}

		this.bx = this.x - borderThickness;
		this.by = this.y - borderThickness;
		this.bw = this.w + (borderThickness * 2);
		this.bh = this.h + (borderThickness * 2);

		text = "";
	}

	boolean isClicked() {
		return (
			mouseX > this.bx && 
			mouseX < this.bx + this.bw && 
			mouseY > this.by && 
			mouseY < this.by + this.bh
		);
	}	

	void drawGraphics() {
		noStroke();
		fill(borderColor);
		rect(bx, by, bw, bh);
		fill(fillColor);
		rect(x, y, w, h);

		fill(textColor);
		textSize(h/2);

		int i = 0;
		if (text.length() > 0) { // This needs to be refactored...
			fill(textColor);
			textSize(textSize);
			for (i = 0; i < text.length(); i++) { 	// Don't worry about it.
				text(text.charAt(i), x + (i * (textSize*0.5)) + (i * (textSize * 0.05)), y + h - (textSize/7));
			}
		}
		if (hasTextBox) {
			stroke(0);
			strokeWeight(3);
			line(x + (i * (textSize*0.5)) + (i * (textSize * 0.05)) + (textSize/10), y + h - (textSize/7), x + (textSize/2) + (i * (textSize*0.5)) + (i * (textSize * 0.05))	, y + h - (textSize/7));
		}
	}
}

class TextureStruct {
	PImage image;
	String image_path;
	TextureStruct(PImage img, String file_path) {
		image = img;
		image_path = file_path;
	}
}