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
  int boxx, boxy;
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
      slidePos = lock(mouseX-slideX, 0, slideLength);
      val = int((float(slidePos)/slideLength)*maxVal);
    }
  }
  
  int lock(int val, int minv, int maxv) { 
    return  min(max(val, minv), maxv); 
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
      stroke(colorMap(val, maxVal));
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

class TextBox extends Clickable {
  String text;
  boolean selected;
  
  TextBox(int ix, int iy, int iw, int ih, String itext) {
    super(ix, iy, iw, ih, false);
    basecolor = color(255);
    pressedcolor = highlightcolor = color(230, 230, 255);
    text = itext;
  }
  
  void display() {
    super.display();
    fill(0);
    text(text, x+5, y+h/2+fontSize/2);
  }
}

class TextButton extends Clickable {
  String txt;
  
  TextButton (int ix, int iy, int iw, int ih, String s) {
    super(ix, iy, iw, ih, false);
    txt = s;
    if (w == 0) {
      w = int(textWidth(txt))+20;
    }
    
  }
  
  void display () {
    super.display();
    fill(0);
    text(txt, x+10, y+h/2+fontSize/2);
  }
}

class Tool extends Clickable {
  Toolbar toolbar;
  ArrayList<Interface> tools;
  int tx, ty;
  String name;
  
  Tool(int ix, int iy, String iName, Toolbar iToolbar) {
    super(ix, iy, 24, 24, false);
    name = iName;
    toolbar = iToolbar;
    tools = new ArrayList<Interface>();
  }
  
  void press() {
    for (int i=0; i<drawingTools.length; i++) {
      Tool currTool = drawingTools[i];
      currTool.release();
    }
    pressed = true;
    currentTool = name;
    toolbar.setTools(tools);
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.get(i).endEdit();
    }
  }
}

class PointButton extends Tool {
  
  PointButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Point", iToolbar);
  }
  
  void display () {
    super.display();
    fill(0);
    ellipse(x+w/2, y+h/2, 6, 6);
  }
}

class LineButton extends Tool {
  
  LineButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Line", iToolbar);
  }
  
  void display () {
    super.display();
    line(x+3, y+h-3, x+21, y+3);
  }
}

class CurveButton extends Tool {
  
  CurveButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Curve", iToolbar);
  }
  
  void display () {
    super.display();
    bezier(x+3, y+h-3, x+21, y+h-3, x+3, y+3, x+21, y+3);
  }
}

class RectButton extends Tool {
  
  RectButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Rect", iToolbar);
  }
  
  void display () {
    super.display();
    rect(x+3, y+3, 18, 18);
  }
}

class EllipseButton extends Tool {
  
  EllipseButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Ellipse", iToolbar);
  }
  
  void display () {
    super.display();
    ellipse(x+12, y+12, 18, 18);
  }
}

class ZoomInButton extends Tool {
  
  ZoomInButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "ZoomIn", iToolbar);
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
    line(x+10, y+6, x+10, y+14);
  }
}

class ZoomOutButton extends Tool {
  
  ZoomOutButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "ZoomOut", iToolbar);
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
  }
}

class EditButton extends Tool {
  
  EditButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "Edit", iToolbar);
  }
  
  void press() {
    super.press();
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.get(i).beginEdit();
    }
  }
  
  void display () {
    super.display();
    fill(255);
    beginShape();
    vertex(x+4, y+4);
    vertex(x+19, y+9);
    vertex(x+15, y+13);
    vertex(x+21, y+19);
    vertex(x+19, y+21);
    vertex(x+13, y+15);
    vertex(x+9, y+19);
    endShape(CLOSE);
  }
}
