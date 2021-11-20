class ButtonInput {
  char given_key;
  boolean was_pressed;

  ButtonInput(char button) {
    was_pressed = false;
    given_key = button;
  }

  boolean isPressed() {
    if (keyPressed && key == given_key) {
      if (!was_pressed) {
        was_pressed = true;
        return true;
      }
    } else {
      was_pressed = false;
    }
    return false;
  }
}

class MouseInput {
  int given_button;
  boolean was_pressed;

  MouseInput(int button) {
    was_pressed = false;
    given_button = button;
  }

  boolean isPressed() {
    if (mousePressed && (mouseButton == given_button)) {
      if (!was_pressed) {
        was_pressed = true;
        return true;
      }
    } else {
      was_pressed = false;
    }
    return false;
  }
}