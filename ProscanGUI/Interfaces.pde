interface Action {
  void run();
}

class Toolbar {
  int x, y;
  ArrayList<Interface> tools;
  int spacing = 5;
  boolean visible = true;
  
  Toolbar () {
    x = 0;
    y = 0;
    tools = new ArrayList<Interface>();
  }
  
  Toolbar (int ix, int iy) {
    x = ix;
    y = iy;
    tools = new ArrayList<Interface>();
  }
  
  Toolbar (int ix, int iy, ArrayList<Interface> iTools) {
    x = ix;
    y = iy;
    setTools(iTools);
  }
  
  void setTools (ArrayList<Interface> iTools) {
    tools = iTools;
    updatePos();
  }
  
  void updatePos() {
    int currX = x;
    for (int i=0; i<tools.size(); i++) {
      Interface currTool = tools.get(i);
      currTool.x = currX;
      currTool.y = y;
      currTool.updatePos();
      currX += currTool.w + spacing;
    }
  }
  
  void setVisible() {
    visible = true;
    for (int i=0; i<tools.size(); i++) {
      tools.get(i).visible = true;
    }
  }
  
  void setInvisible() {
    visible = false;
    for (int i=0; i<tools.size(); i++) {
      tools.get(i).visible = false;
    }
  }
  
  void display() {
    if (visible) {
      for (int i=0; i<tools.size(); i++) {
        tools.get(i).display();
      }
    }
  }
}

class Interface {
  int x, y;
  int w, h;
  boolean visible = true;
  
  Interface(int ix, int iy, int iw, int ih) {
    x = ix;
    y = iy;
    w = iw;
    h = ih;
  }
  
  void setVisible() {
    visible = true;
  }
  void setInvisible() {
    visible = false;
  }
  void updatePos(){}
  void display(){}
  void press(){}
  void release(){}
}

class Clickable extends Interface {
  color basecolor = color(230);
  color highlightcolor = color(190);
  color pressedcolor = color(190);
  boolean pressed = false;
  boolean draggable = false;
  int shapeType = 0;
  
  Clickable(int ix, int iy, int iw, int ih, boolean d) {
    super(ix, iy, iw, ih);
    draggable = d;
  }
    
  boolean over() {
    if(inRegion(mouseX, mouseY, x, y, x+w, y+h) ) {
      return true;
    } else {
      return false;
    }
  }
  
  void press() {
    if (visible) {
      if (draggable) {
        dragging = true;
      }
      pressed = true;
    }
  }
  
  void release() {
    if (visible) {
      if (draggable) {
        dragging = false;
      }
      pressed = false;
    }
  }

  void display() {
    if (visible) {
      color currentcolor;
      if(over()) {
        currentcolor = highlightcolor;
      } 
      else {
        if (pressed) {
          currentcolor = pressedcolor;
        } else {
          currentcolor = basecolor;
        }
      }
      stroke(0);
      fill(currentcolor);
      if (shapeType == 0) {
        rect(x, y, w, h);
      } else {
        ellipse(x+w/2, y+h/2, w, h);
      }
    }
  }
}

class Slider extends Interface{
  String text;
  int slideX, slideY;
  int slideLength;
  int slidePos;
  int decimals;
  String stringFormat;
  float val, maxVal;
  Clickable box;
  TextBox textBox;
  int boxSize = 10;
  
  Slider(int ix, int iy, int iw, int ih, float imv, String itext, String format, TextBox iTextBox) {
    super(ix, iy, iw, ih);
    text = itext;
    maxVal = imv;
    val = imv;
    stringFormat = format;
    textBox = iTextBox;
    textBox.setVal(parseFloat(String.format(stringFormat, val)));
    box = new Clickable(0, 0, boxSize, boxSize, true);
    box.basecolor = color(245);
    updatePos();
  }
  
  void updatePos() {
    int leftMargin = int(textWidth(text));
    
    slideX = x + leftMargin + 15;
    slideY = y + h/2;
    
    slideLength = w-leftMargin-30;
    slidePos = int(val/maxVal*slideLength);
  };
  
  void press() {
    if (visible) {
      if(box.over()) {
        box.press();
      }
    }
  }
  
  void setVal(float ival) {
    val = min(max(ival, 0), maxVal);
    slidePos = int(val/maxVal*slideLength);
  }
  
  void release() {
    if (visible) {
      box.release();
    }
  }
  
  void update() {
    if(box.pressed) {
      slidePos = min(max(mouseX-slideX, 0), slideLength);
      val = maxVal*slidePos/slideLength;
      textBox.setVal(parseFloat(String.format(stringFormat, val)));
    }
  }
  
  void display() {
    if (visible) {
      update();
      stroke(0);
      fill(230);
      rect(x, y, w, h);
      fill(0);
      text(text, x+5, slideY+fontSize/2);
      line(slideX, slideY-1, slideX+slideLength, slideY-1);
      line(slideX, slideY+1, slideX+slideLength, slideY+1);
      stroke(redblueColor(val, maxVal));
      line(slideX, slideY, slideX+slidePos, slideY);
      box.x = slideX+slidePos-box.w/2;
      box.y = slideY - box.w/2;
      box.display();
    }
  }
}

class TextBox extends Interface {
  String name;
  String text;
  float val;
  int textY;
  boolean selected;
  Clickable box;
  Action action;
  char[] numeric = new char[]{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-'};
  
  TextBox(int ix, int iy, int iw, int ih, String iName, float iVal, Action iAction) {
    super(ix, iy, iw, ih);
    name = iName;
    int leftMargin = int(textWidth(name))+10;
    box = new Clickable(0, 0, w-leftMargin-5, h-6, false);
    box.basecolor = color(255);
    box.pressedcolor = box.highlightcolor = color(237, 237, 255);
    val = iVal;
    action = iAction;
    text = str(val);
    updatePos();
  }
  
  void press() {
    if (visible) {
      if (box.over()) {
        selected = true;
        selectedText = this;
        box.press();
        if (mouseEvent.getClickCount() == 2) {
          text = "";
        }
      } else {
        if (selected) {
          selected = false;
          selectedText = null;
          box.release();
          if (text.length() > 0) {
            val = parseFloat(text);
          }
          text = str(val);
        }
      }
    }
  }
  
  void setVal(float iVal) {
    if (!selected) {
      val = iVal;
      text = str(val);
    }
  }
  
  void type() {
    if (visible && selected) {
      if (keyCode == BACKSPACE) {
        delete();
      } else
      if (keyCode == ENTER) {
        if (action != null) {
          action.run();
        }
      } else {
        for (int i=0; i<numeric.length; i++) {
          if (key == numeric[i]) {
            text += key;
            val = parseFloat(text);
          }
        }
      }
    }
  }
  
  void delete() {
    if (visible) {
      if (selected) {
        if (text.length() > 0) {
          text = text.substring(0, text.length()-1);
          val = parseFloat(text);
        }
      }
    }
  }
  
  void updatePos() {
    int leftMargin = int(textWidth(name))+10;
    box.x = x + leftMargin;
    box.y = y+3;
    box.w = w-leftMargin-5;
    box.h = h-6;
    textY = box.y+(box.h+fontSize)/2;
  };
  
  void display() {
    if (visible) {
      stroke(0);
      fill(230);
      rect(x, y, w, h);
      box.display();
      fill(0);
      text(name, x+5, textY);
      text(text, box.x+5, textY);
      stroke(0, 0, 255);
      if (selected) {
        if (second()%2 == 0) {
          int cursorX = box.x+5+int(textWidth(text));
          line(cursorX, box.y+3, cursorX, box.y+box.h-3);
        }
      }
    }
  }
}

class TextButton extends Clickable {
  String text;
  Action action;
  
  TextButton (int ix, int iy, int iw, int ih, String iText, Action iAction) {
    super(ix, iy, iw, ih, false);
    text = iText;
    action = iAction;
    if (w == 0) {
      w = int(textWidth(text))+20;
    }
  }
  
  void press () {
    if (over()) {
      if (action != null) {
        action.run();
      }
    }
  }
  
  void display () {
    super.display();
    fill(0);
    text(text, x+10, y+h/2+fontSize/2);
  }
}

