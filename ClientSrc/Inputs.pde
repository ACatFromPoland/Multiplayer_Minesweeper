

class ButtonInput {
  char m_key;
  boolean m_pressed;

  ButtonInput(char button) {
    m_pressed = false;
    m_key = button;
  }

  boolean isPressed() {
    if (keyPressed && key == m_key) {
      if (!m_pressed) {
        m_pressed = true;
        return true;
      }
    } else {
      m_pressed = false;
    }

    return false;
  }
}

class MouseInput {
  int m_button;
  boolean m_pressed;

  MouseInput(int button) {
    m_pressed = false;
    m_button = button;
  }

  boolean isPressed() {
    if (mousePressed && (mouseButton == m_button)) {
      if (!m_pressed) {
        m_pressed = true;
        return true;
      }
    } else {
      m_pressed = false;
    }

    return false;
  }
}
