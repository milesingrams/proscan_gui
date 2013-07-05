class DrawingObj {
  int numCoords;
  int[] xCoords;
  int[] yCoords;
  int[] pxCoords;
  int[] pyCoords;
  int midX;
  int midY;
  int[] relativeCoordsX;
  int[] relativeCoordsY;
  Clickable[] vertexButtons;
  Clickable dragButton;
  int buttonSize = 6;
  boolean selected;
  
  DrawingObj (int[] ixCoords, int[] iyCoords) {
    numCoords = ixCoords.length;
    xCoords = ixCoords;
    yCoords = iyCoords;
    pxCoords = new int[numCoords];
    pyCoords = new int[numCoords];
    relativeCoordsX = new int[numCoords];
    relativeCoordsY = new int[numCoords];
    selected = false;
    
    vertexButtons = new Clickable[numCoords];
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i] = new Clickable(0, 0, buttonSize, buttonSize, true);
      vertexButtons[i].visible = false;
    }
    dragButton = new Clickable(0, 0, buttonSize, buttonSize, true);
    dragButton.visible = false;
    
    updatePos();
  }
  
  void update() {
    for (int i=0; i<numCoords; i++) {
      if (vertexButtons[i].pressed) {
        xCoords[i] = toGrid(globalToLocalX(mouseX));
        yCoords[i] = toGrid(globalToLocalY(mouseY));
        updatePos();
      }
    }
    if (dragButton.pressed) {
      midX = globalToLocalX(mouseX);
      midY = globalToLocalY(mouseY);
      for (int i=0; i<numCoords; i++) {
        xCoords[i] = toGrid(midX + relativeCoordsX[i]);
        yCoords[i] = toGrid(midY + relativeCoordsY[i]);
      }
      updatePos();
    }
  }
  
  void updatePos() {
    for (int i=0; i<numCoords; i++) {
      pxCoords[i] = localToGlobalX(xCoords[i]);
      pyCoords[i] = localToGlobalY(yCoords[i]);
      vertexButtons[i].x = pxCoords[i]-buttonSize/2;
      vertexButtons[i].y = pyCoords[i]-buttonSize/2;
    }
    midX = midX();
    midY = midY();
    dragButton.x = localToGlobalX(midX())-buttonSize/2;
    dragButton.y = localToGlobalY(midY())-buttonSize/2;
  }
  
  void setRelativeCoords() {
    for (int i=0; i<numCoords; i++) {
      relativeCoordsX[i] = xCoords[i]-midX();
      relativeCoordsY[i] = yCoords[i]-midY();
    }
  }
  
  void press() {
    if (dragButton.over()) {
      dragButton.press();
      setRelativeCoords();
    }
    for (int i=0; i<numCoords; i++) {
      if (vertexButtons[i].over()) {
        vertexButtons[i].press();
      }
    }
  }
  
  void release() {
    dragButton.release();
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i].release();
    }
  }
  
  void select() {
    selected = true;
    dragButton.visible = true;
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i].visible = true;
    }
  }
  
  void deselect() {
    selected = false;
    dragButton.visible = false;
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i].visible = false;
    }
  }
  
  void delete() {
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.remove(this);
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
  int midX() {
    return (minX()+maxX())/2;
  }
  int midY() {
    return (minY()+maxY())/2;
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
      vertexButtons[i].display();
    }
    dragButton.display();
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
    noFill();
    rect(pxCoords[0], pyCoords[0], pxCoords[1]-pxCoords[0], pyCoords[1]-pyCoords[0]);
    displayButtons();
  }
  
  void makeCommands() {
  }
  
  String toString() {
    return "RECT "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}
  

class GroupObj extends DrawingObj {
  int w, h;
  ArrayList<DrawingObj> objs;
  ArrayList<float[]> relativeX;
  ArrayList<float[]> relativeY;
  
  GroupObj() {
    super(new int[]{0, 0}, new int[]{0, 0});
    objs = new ArrayList<DrawingObj>();
    init();
  }
  
  GroupObj(ArrayList<DrawingObj> iObjs) {
    super(new int[]{0, 0}, new int[]{0, 0});
    objs = iObjs;
    init();
  }
  
  void init() {
    relativeX = new ArrayList<float[]>();
    relativeY = new ArrayList<float[]>();
    getBounds();
  }
  
  void insert(DrawingObj iObj) {
    objs.add(iObj);
    getBounds();
  }
  
  void insert(ArrayList<DrawingObj> iObjs) {
    objs.addAll(iObjs);
    getBounds();
  }
  
  void updatePos() {
    super.updatePos();
    w = xCoords[1]-xCoords[0];
    h = yCoords[1]-yCoords[0];
    endTransform();
  }
  
  void getBounds() {
    if (objs.size() > 0) {
      DrawingObj currObj = objs.get(0);
      xCoords[0] = xCoords[1] = currObj.minX();
      yCoords[0] = yCoords[1] = currObj.minY();
      
      for (int i=0; i<objs.size(); i++) {
        currObj = objs.get(i);
        xCoords[0] = min(xCoords[0], currObj.minX());
        yCoords[0] = min(yCoords[0], currObj.minY());
        xCoords[1] = max(xCoords[1], currObj.maxX());
        yCoords[1] = max(yCoords[1], currObj.maxY());
      }
      
      w = xCoords[1]-xCoords[0];
      h = yCoords[1]-yCoords[0];
      
      setRelativePos();
    } else {
      xCoords[0] = xCoords[1] = 0;
      yCoords[0] = yCoords[1] = 0;
      w = 0;
      h = 0;
    }
    updatePos();
  }
  
  void setRelativePos() {
    relativeX.clear();
    relativeY.clear();
        
    for (int i=0; i<objs.size(); i++) {
      DrawingObj currObj = objs.get(i);
      float[] tempRelX = new float[currObj.numCoords];
      float[] tempRelY = new float[currObj.numCoords];
      for (int j=0; j<currObj.numCoords; j++) {
        if (w > 0) {
          tempRelX[j] = float(currObj.xCoords[j]-xCoords[0])/w;
        } else {
          tempRelX[j] = 0;
        }
        if (h > 0) {
          tempRelY[j] = float(currObj.yCoords[j]-yCoords[0])/h;
        } else {
          tempRelY[j] = 0;
        }
      }
      relativeX.add(tempRelX);
      relativeY.add(tempRelY);
    }
  }
  
  void endTransform() {
    if (objs != null) {
      for (int i=0; i<objs.size(); i++) {
        DrawingObj currObj = objs.get(i);
        float[] tempRelX = relativeX.get(i);
        float[] tempRelY = relativeY.get(i);
        for (int j=0; j<currObj.numCoords; j++) {
          currObj.xCoords[j] = xCoords[0] + int(tempRelX[j]*w);
          currObj.yCoords[j] = yCoords[0] + int(tempRelY[j]*h);
        }
        currObj.updatePos();
      }
    }
  }
  
  void display() {
    update();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).display();
    }
    if (selected) {
      stroke(0, 200, 0);
      noFill();
      rect(pxCoords[0], pyCoords[0], w, h);
      displayButtons();
    }
  }
  
  void makeCommands() {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).makeCommands();
    }
  }
  
  void ungroup() {
    drawingList.addAll(this.objs);
    objSelection.insert(this.objs);
    delete();
  }
  
  String toString() {
    String toPrint = "GROUP";
    for (int i=0; i<objs.size(); i++) {
      toPrint += "\n"+objs.get(i).toString();
    }
    toPrint += "\nENDGROUP";
    return toPrint;
  }
}

class Selection extends GroupObj {
  
  Selection() {
    super();
    dragButton.basecolor = color(0, 255, 0);
    dragButton.pressedcolor = dragButton.highlightcolor = color(0, 200, 0);
    for (int i=0; i<2; i++) {
      vertexButtons[i].basecolor = color(0, 255, 0);
      vertexButtons[i].pressedcolor = vertexButtons[i].highlightcolor = color(0, 200, 0);
    }
  }
  
  void press() {
    super.press();
    for (int i=0; i<objs.size(); i++) {
        objs.get(i).press();
    }
  }
  
  void release() {
    super.release();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).release();
    }
    getBounds();
  }
  
  void select() {
    super.select();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).select();
    }
  }
  
  void deselect() {
    super.deselect();
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).deselect();
    }
    objs.clear();
  }
  
  void insert(DrawingObj iObj) {
    super.insert(iObj);
    select();
  }
  
  void insert(ArrayList<DrawingObj> iObjs) {
    super.insert(iObjs);
    select();
  }
  
  void delete() {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).delete();
    }
    deselect();
  }
  
  void group() {
    if (selected) {
      GroupObj newGroup = new GroupObj((ArrayList<DrawingObj>)objs.clone());
      drawingList.add(newGroup);
      delete();
      insert(newGroup);
    }
  }
  
  void ungroup() {
    if (selected) {
      int objsSize = objs.size();
      for (int i=0; i<objsSize; i++) {
        if (objs.get(i) instanceof GroupObj) {
          GroupObj currObj = (GroupObj)objs.get(i);
          currObj.ungroup();
        }
      }
    }
  }
  
  void display() {
    update();
    if (selected) {
      stroke(0, 255, 0);
      noFill();
      rect(pxCoords[0], pyCoords[0], w, h);
      displayButtons();
    }
  }
}
