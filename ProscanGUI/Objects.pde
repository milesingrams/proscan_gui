class DrawingObj {
  boolean selected;
  
  DrawingObj() {
    selected = false;
  }
  
  void update(){}
  void display(){}
  void press(){}
  void release(){}
  void select(){}
  void deselect(){}
  void makeCommands(){}
  int minX(){return 0;}
  int minY(){return 0;}
  int maxX(){return 0;}
  int maxY(){return 0;}
  boolean inBounds(int ix1, int iy1, int ix2, int iy2){return false;}
}

class LineObj extends DrawingObj {
  int speed; // single bar width
  int x1, y1;
  int x2, y2;
  int px1, py1;
  int px2, py2;
  Clickable button1;
  Clickable button2;
 
  LineObj(int s, int ix1, int iy1, int ix2, int iy2) {
    super();
    speed = s;
    x1 = ix1;
    y1 = iy1;
    x2 = ix2;
    y2 = iy2;
    px1 = localToGlobalX(x1);
    py1 = localToGlobalY(y1);
    px2 = localToGlobalX(x2);
    py2 = localToGlobalY(y2);
    button1 = new Clickable(px1-3, py1-2, 6, 6, true);
    button2 = new Clickable(px2-3, py2-2, 6, 6, true);
    button1.visible = false;
    button2.visible = false;
    selected = false;
  }
  
  void update() {
    if(button1.pressed) {
      x1 = toGrid(globalToLocalX(mouseX));
      y1 = toGrid(globalToLocalY(mouseY));
      px1 = localToGlobalX(x1);
      py1 = localToGlobalY(y1);
      button1.x = px1-3;
      button1.y = py1-3;
    } else
    if(button2.pressed) {
      x2 = toGrid(globalToLocalX(mouseX));
      y2 = toGrid(globalToLocalY(mouseY));
      px2 = localToGlobalX(x2);
      py2 = localToGlobalY(y2);
      button2.x = px2-3;
      button2.y = py2-3;
    }
  }
  
  void press() {
    if(button1.over()) {
      button1.press();
    }
    if(button2.over()) {
      button2.press();
    }
  }
  
  void release() {
    button1.release();
    button2.release();
  }
  
  void select() {
    selected = true;
    button1.visible = true;
    button2.visible = true;
  }
  
  void deselect() {
    selected = false;
    button1.visible = false;
    button2.visible = false;
  }
  
  int minX() {
    return min(x1, x2);
  }
  int minY() {
    return min(y1, y2);
  }
  int maxX() {
    return max(x1, x2);
  }
  int maxY() {
    return max(y1, y2);
  }
  
  boolean inBounds(int ix1, int iy1, int ix2, int iy2) {
    if (inRegion(x1, y1, ix1, iy1, ix2-ix1, iy2-iy1) && inRegion(x2, y2, ix1, iy1, ix2-ix1, iy2-iy1)) {
      return true;
    }
    return false;
  }
 
  void display() {
    update();
    stroke(colorMap(speed, maxSpeed));
    line(px1, py1, px2, py2);
    button1.display();
    button2.display();
  }
  
  void makeCommands() {
    addCommand(new TextCommand("SMS", str(baseMoveSpeed)));
    addCommand(new MoveCommand(x1, y1, false));
    addCommand(new TextCommand("SMS", str(speed)));
    addCommand(new MoveCommand(x2, y2, true));
  }
  
  String toString() {
    return "LINE "+speed+" "+x1+" "+y1+" "+x2+" "+y2;
  }
}

class PointObj extends DrawingObj {
  int time; // single bar width
  int x, y;
  int px, py;
  Clickable button;
 
  PointObj(int it, int ix, int iy) {
    super();
    time = it;
    x = ix;
    y = iy;
    px = localToGlobalX(x);
    py = localToGlobalY(y);
    button = new Clickable(px-3, py-3, 6, 6, true);
    button.visible = false;
    selected = false;
  }
  
  void update() {
    if(button.pressed) {
      x = toGrid(globalToLocalX(mouseX));
      y = toGrid(globalToLocalY(mouseY));
      px = localToGlobalX(x);
      py = localToGlobalY(y);
      button.x = px-3;
      button.y = py-3;
    }
  }
  
  void press() {
    if(button.over()) {
      button.press();
    }
  }
  
  void release() {
    button.release();
  }
  
  void select() {
    selected = true;
    button.visible = true;
  }
  
  void deselect() {
    selected = false;
    button.visible = false;
  }
  
  int minX() {
    return x;
  }
  int minY() {
    return y;
  }
  int maxX() {
    return x;
  }
  int maxY() {
    return y;
  }
  
  boolean inBounds(int ix1, int iy1, int ix2, int iy2) {
    if (inRegion(x, y, ix1, iy1, ix2-ix1, iy2-iy1)) {
      return true;
    }
    return false;
  }
 
  void display() {
    update();
    stroke(0);
    fill(colorMap(time, maxTime));
    ellipse(px, py, 10, 10);
    button.display();
  }
  
  void makeCommands() {

  }
  
  String toString() {
    return "POINT "+time+" "+x+" "+y;
  }
}

class RectObj extends DrawingObj {
  int speed; // single bar width
  int x1, y1;
  int x2, y2;
  int px1, py1;
  int px2, py2;
  Clickable button1;
  Clickable button2;
 
  RectObj(int s, int ix1, int iy1, int ix2, int iy2) {
    super();
    speed = s;
    x1 = ix1;
    y1 = iy1;
    x2 = ix2;
    y2 = iy2;
    px1 = localToGlobalX(x1);
    py1 = localToGlobalY(y1);
    px2 = localToGlobalX(x2);
    py2 = localToGlobalY(y2);
    button1 = new Clickable(px1-3, py1-3, 6, 6, true);
    button2 = new Clickable(px2-3, py2-3, 6, 6, true);
    button1.visible = false;
    button2.visible = false;
    selected = false;
  }
  
  void update() {
    if (button1.pressed) {
      x1 = toGrid(globalToLocalX(mouseX));
      y1 = toGrid(globalToLocalY(mouseY));
      px1 = localToGlobalX(x1);
      py1 = localToGlobalY(y1);
      button1.x = px1-3;
      button1.y = py1-3;
    } else
    if (button2.pressed) {
      x2 = toGrid(globalToLocalX(mouseX));
      y2 = toGrid(globalToLocalY(mouseY));
      px2 = localToGlobalX(x2);
      py2 = localToGlobalY(y2);
      button2.x = px2-3;
      button2.y = py2-3;
    }
  }
  
  void press() {
    if(button1.over()) {
      button1.press();
    }
    if(button2.over()) {
      button2.press();
    }
  }
  
  void release() {
    button1.release();
    button2.release();
  }
  
  void select() {
    selected = true;
    button1.visible = true;
    button2.visible = true;
  }
  
  void deselect() {
    selected = false;
    button1.visible = false;
    button2.visible = false;
  }
  
  int minX() {
    return min(x1, x2);
  }
  int minY() {
    return min(y1, y2);
  }
  int maxX() {
    return max(x1, x2);
  }
  int maxY() {
    return max(y1, y2);
  }
  
  boolean inBounds(int ix1, int iy1, int ix2, int iy2) {
    if (inRegion(x1, y1, ix1, iy1, ix2-ix1, iy2-iy1) && inRegion(x2, y2, ix1, iy1, ix2-ix1, iy2-iy1)) {
      return true;
    }
    return false;
  }
  
  void display() {
    update();
    stroke(colorMap(speed, maxSpeed));
    line(px1, py1, px2, py1);
    line(px2, py1, px2, py2);
    line(px2, py2, px1, py2);
    line(px1, py2, px1, py1);
    button1.display();
    button2.display();
  }
  
  void makeCommands() {
  }
  
  String toString() {
    return "RECT "+speed+" "+x1+" "+y1+" "+x2+" "+y2;
  }
}

class Selection {
  int x, y;
  int w, h;
  int px, py;
  int pw, ph;
  ArrayList<DrawingObj> objs;
  Clickable dragButton;
  
  Selection() {
    objs = new ArrayList<DrawingObj>();
    dragButton = new Clickable(0, 0, 8, 8, true);
    dragButton.basecolor = color(0, 255, 0);
    dragButton.pressedcolor = dragButton.highlightcolor = color(0, 200, 0);
    dragButton.visible = false;
  }
  
  void insert(DrawingObj obj) {
    obj.select();
    objs.add(obj);
    updateMinMax();
  }
  
  void delete() {
    for (int i=0; i<objs.size(); i++) {
      drawingList.remove(objs.get(i));
    }
    erase();
  }
  
  void press() {
    if(dragButton.over()) {
      dragButton.press();
    }
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).press();
    }
  }
  
  void release() {
    dragButton.release();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).release();
    }
    updateMinMax();
  }
  
  
  void updateMinMax() {
    if (objs.size() > 0) {
      DrawingObj currObj = objs.get(0);
      int x1 = currObj.minX();
      int y1 = currObj.minY();
      int x2 = currObj.maxX();
      int y2 = currObj.maxY();
      
      for (int i=1; i<objs.size(); i++) {
        currObj = objs.get(i);
        x1 = min(x1, currObj.minX());
        y1 = min(y1, currObj.minY());
        x2 = max(x2, currObj.maxX());
        y2 = max(y2, currObj.maxY());
      }
      
      x = x1;
      y = y1;
      w = x2-x1;
      h = y2-y1;
      px = localToGlobalX(x);
      py = localToGlobalY(y);
      pw = localToGlobalX(x+w)-px;
      ph = localToGlobalY(y+h)-py;
      dragButton.x = px+pw/2-4;
      dragButton.y = py+ph/2-4;
      dragButton.visible = true;
    } else {
      dragButton.visible = false;
    }
  }
  
  void erase() {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).deselect();
    }
    objs.clear();
  }
  
  void display() {
    if (objs.size() > 0) {
      stroke(0, 255, 0);
      noFill();
      rect(px, py, pw, ph);
      dragButton.display();
    }
  }
}
