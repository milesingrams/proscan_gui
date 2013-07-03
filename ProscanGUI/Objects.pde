class DrawingObj {
  int numCoords;
  int[] xCoords;
  int[] yCoords;
  int[] pxCoords;
  int[] pyCoords;
  Clickable[] buttons;
  int buttonSize = 6;
  boolean selected;
  
  DrawingObj (int[] ixCoords, int[] iyCoords) {
    numCoords = ixCoords.length;
    xCoords = ixCoords;
    yCoords = iyCoords;
    pxCoords = new int[numCoords];
    pyCoords = new int[numCoords];
    buttons = new Clickable[numCoords];
    
    for (int i=0; i<numCoords; i++) {
      pxCoords[i] = localToGlobalX(xCoords[i]);
      pyCoords[i] = localToGlobalY(yCoords[i]);
      Clickable tempButton = new Clickable(pxCoords[i]-buttonSize/2, pyCoords[i]-buttonSize/2, buttonSize, buttonSize, true);
      buttons[i] = tempButton;
      tempButton.visible = false;
    }
    
    selected = false;
  }
  
  void update() {
    for (int i=0; i<numCoords; i++) {
      if (buttons[i].pressed) {
        xCoords[i] = toGrid(globalToLocalX(mouseX));
        yCoords[i] = toGrid(globalToLocalY(mouseY));
      }
      pxCoords[i] = localToGlobalX(xCoords[i]);
      pyCoords[i] = localToGlobalY(yCoords[i]);
      buttons[i].x = pxCoords[i]-buttonSize/2;
      buttons[i].y = pyCoords[i]-buttonSize/2;
    }
  }
  
  void press() {
    for (int i=0; i<numCoords; i++) {
      if (buttons[i].over()) {
        buttons[i].press();
      }
    }
  }
  
  void release() {
    for (int i=0; i<numCoords; i++) {
      buttons[i].release();
    }
  }
  
  void select() {
    selected = true;
    for (int i=0; i<numCoords; i++) {
      buttons[i].visible = true;
    }
  }
  
  void deselect() {
    selected = false;
    for (int i=0; i<numCoords; i++) {
      buttons[i].visible = false;
    }
  }
  
  int minX() {
    return min(xCoords);
  }
  int minY() {
    return min(yCoords);
  }
  int maxX() {
    return max(xCoords);
  }
  int maxY() {
    return max(yCoords);
  }
  
  boolean inBounds(int ix1, int iy1, int ix2, int iy2) {
    boolean allin = true;
    for (int i=0; i<numCoords; i++) {
      if (inRegion(xCoords[i], yCoords[i], ix1, iy1, ix2-ix1, iy2-iy1) == false) {
        allin = false;
      }
    }
    return allin;
  }
  
  void displayButtons() {
    for (int i=0; i<numCoords; i++) {
      buttons[i].display();
    }
  }
  
  void display(){}
  void makeCommands(){}
}

class LineObj extends DrawingObj {
  int speed; // single bar width
 
  LineObj(int s, int ix1, int iy1, int ix2, int iy2) {
    super(new int[]{ix1, ix2}, new int[]{iy1, iy2});
    speed = s;
  }
 
  void display() {
    update();
    stroke(colorMap(speed, maxSpeed));
    line(pxCoords[0], pyCoords[0], pxCoords[1], pyCoords[1]);
    displayButtons();
  }
  
  void makeCommands() {
    addCommand(new TextCommand("SMS", str(baseMoveSpeed)));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], false));
    addCommand(new TextCommand("SMS", str(speed)));
    addCommand(new MoveCommand(xCoords[1], yCoords[1], true));
  }
  
  String toString() {
    return "LINE "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class PointObj extends DrawingObj {
  int time; // single bar width
 
  PointObj(int it, int ix, int iy) {
    super(new int[]{ix}, new int[]{iy});
    time = it;
  }
 
  void display() {
    update();
    stroke(0);
    fill(colorMap(time, maxTime));
    ellipse(pxCoords[0], pyCoords[0], 10, 10);
    displayButtons();
  }
  
  void makeCommands() {

  }
  
  String toString() {
    return "POINT "+time+" "+xCoords[0]+" "+yCoords[0];
  }
}

class RectObj extends DrawingObj {
  int speed; // single bar width
 
  RectObj(int s, int ix1, int iy1, int ix2, int iy2) {
    super(new int[]{ix1, ix2}, new int[]{iy1, iy2});
    speed = s;
  }
  
  void display() {
    update();
    stroke(colorMap(speed, maxSpeed));
    line(pxCoords[0], pyCoords[0], pxCoords[1], pyCoords[0]);
    line(pxCoords[1], pyCoords[0], pxCoords[1], pyCoords[1]);
    line(pxCoords[1], pyCoords[1], pxCoords[0], pyCoords[1]);
    line(pxCoords[0], pyCoords[1], pxCoords[0], pyCoords[0]);
    displayButtons();
  }
  
  void makeCommands() {
  }
  
  String toString() {
    return "RECT "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class Selection {
  int x, y;
  int w, h;
  int px, py;
  int pw, ph;
  ArrayList<DrawingObj> objs;
  ArrayList<float[]> relativeCoordsX;
  ArrayList<float[]> relativeCoordsY;
  Clickable dragButton;
  Clickable scaleButton;
  int buttonSize = 8;
  
  Selection() {
    objs = new ArrayList<DrawingObj>();
    
    dragButton = new Clickable(0, 0, buttonSize, buttonSize, true);
    dragButton.basecolor = color(0, 255, 0);
    dragButton.pressedcolor = dragButton.highlightcolor = color(0, 200, 0);
    dragButton.visible = false;
    
    scaleButton = new Clickable(0, 0, buttonSize, buttonSize, true);
    scaleButton.basecolor = color(0, 255, 0);
    scaleButton.pressedcolor = scaleButton.highlightcolor = color(0, 200, 0);
    scaleButton.visible = false;
  }
  
  void insert(DrawingObj obj) {
    obj.select();
    objs.add(obj);
    updateVals();
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
    } else
    if(scaleButton.over()) {
      scaleButton.press();
    } else {
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).press();
      }
    }
  }
  
  void release() {
    dragButton.release();
    scaleButton.release();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).release();
    }
    updateVals();
  }
  
  void update() {
    if (dragButton.pressed) {
      x = toGrid(globalToLocalX(mouseX)-w/2);
      y = toGrid(globalToLocalY(mouseY)-h/2);
      setPos();
      endTransform();
    } else 
    if (scaleButton.pressed) {
      w = toGrid(globalToLocalX(mouseX)-x-buttonSize);
      h = toGrid(globalToLocalY(mouseY)-y-buttonSize);
      setPos();
      endTransform();
    }
  }
  
  void setPos() {
    px = localToGlobalX(x);
    py = localToGlobalY(y);
    pw = localToGlobalX(x+w)-px;
    ph = localToGlobalY(y+h)-py;
    dragButton.x = px+pw/2-buttonSize/2;
    dragButton.y = py+ph/2-buttonSize/2;
    scaleButton.x = px+pw+buttonSize;
    scaleButton.y = py+ph+buttonSize;
  }
  
  void endTransform() {
    for (int i=0; i<objs.size(); i++) {
      DrawingObj currObj = objs.get(i);
      float[] tempRelX = relativeCoordsX.get(i);
      float[] tempRelY = relativeCoordsY.get(i);
      for (int j=0; j<currObj.numCoords; j++) {
        currObj.xCoords[j] = toGrid(x + int(tempRelX[j]*w));
        currObj.yCoords[j] = toGrid(y + int(tempRelY[j]*h));
      }
    }
  }
  
  void updateVals() {
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
      setPos();
      dragButton.visible = true;
      scaleButton.visible = true;
      
      // set relative positions
      relativeCoordsX = new ArrayList<float[]>();
      relativeCoordsY = new ArrayList<float[]>();
      for (int i=0; i<objs.size(); i++) {
        currObj = objs.get(i);
        float[] tempRelX = new float[currObj.numCoords];
        float[] tempRelY = new float[currObj.numCoords];
        for (int j=0; j<currObj.numCoords; j++) {
          if (w > 0) {
            tempRelX[j] = float(currObj.xCoords[j]-x)/w;
          } else {
            tempRelX[j] = 0;
          }
          if (h > 0) {
            tempRelY[j] = float(currObj.yCoords[j]-y)/h;
          } else {
            tempRelY[j] = 0;
          }
        }
        relativeCoordsX.add(tempRelX);
        relativeCoordsY.add(tempRelY);
      }
    } else {
      dragButton.visible = false;
      scaleButton.visible = false;
    }
  }
  
  void erase() {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).deselect();
    }
    objs.clear();
  }
  
  void display() {
    update();
    if (objs.size() > 0) {
      stroke(0, 255, 0);
      noFill();
      rect(px, py, pw, ph);
      dragButton.display();
      scaleButton.display();
    }
  }
}
