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
  String unit;
  int slideX, slideY;
  int slideLength;
  int slidePos;
  int val, maxVal;
  Clickable box;
  int boxSize = 10;
  
  Slider(int ix, int iy, int iw, int ih, int imv, String itext, String iunit) {
    super(ix, iy, iw, ih);
    text = itext;
    unit = iunit;
    maxVal = imv;
    val = imv;
    box = new Clickable(0, 0, boxSize, boxSize, true);
    box.basecolor = color(245);
    updatePos();
  }
  
  void updatePos() {
    int leftMargin = int(textWidth(text));
    int rightMargin = int(textWidth(str(maxVal)+unit));
    
    slideX = x + leftMargin + 15;
    slideY = y + h/2;
    
    slideLength = w-leftMargin-rightMargin-30;
    slidePos = int((float)val/maxVal*slideLength);
  };
  
  void press() {
    if (visible) {
      if(box.over()) {
        box.press();
      }
    }
  }
  
  void release() {
    if (visible) {
      box.release();
    }
  }
  
  void update() {
    if(box.pressed) {
      slidePos = min(max(mouseX-slideX, 0), slideLength);
      val = int((float(slidePos)/slideLength)*maxVal);
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
      stroke(0);
      fill(0);
      text(str(val)+unit, slideX+slideLength + 10, slideY+fontSize/2);
      box.x = slideX+slidePos-box.w/2;
      box.y = slideY - box.w/2;
      box.display();
    }
  }
}

class TextBox extends Interface {
  String name;
  String text;
  float value;
  int textY;
  boolean selected;
  Clickable box;
  
  TextBox(int ix, int iy, int iw, int ih, String iName, float iValue) {
    super(ix, iy, iw, ih);
    name = iName;
    int leftMargin = int(textWidth(name))+10;
    box = new Clickable(0, 0, w-leftMargin-5, h-6, false);
    box.basecolor = color(255);
    box.pressedcolor = box.highlightcolor = color(237, 237, 255);
    value = iValue;
    text = str(value);
    updatePos();
  }
  
  void press() {
    if (visible) {
      if (box.over()) {
        box.press();
        selected = true;
        if (mouseEvent.getClickCount() == 2) {
          text = "";
        }
      } else {
        release();
      }
    }
  }
  
  void release() {
    if (visible) {
      box.release();
      selected = false;
      if (text.equals("")) {
        value = 0;
      } else {
        value = parseFloat(text);
      }
      text = str(value);
    }
  }
  
  void setVal(float iValue) {
    value = iValue;
    text = str(value);
  }
  
  void type(char c) {
    if (visible) {
      if (selected) {
        text += c;
        value = parseFloat(text);
      }
    }
  }
  
  void delete() {
    if (visible) {
      if (selected) {
        if (text.length() > 0) {
          text = text.substring(0, text.length()-1);
          value = parseFloat(text);
        }
      }
    }
  }
  
  int intVal() {
    return int(value*10);
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
  
  TextButton (int ix, int iy, int iw, int ih, String iText) {
    super(ix, iy, iw, ih, false);
    text = iText;
    if (w == 0) {
      w = int(textWidth(text))+20;
    }
    
  }
  
  void display () {
    super.display();
    fill(0);
    text(text, x+10, y+h/2+fontSize/2);
  }
}
