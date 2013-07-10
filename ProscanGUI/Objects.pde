class DrawingObj {
  int numCoords;
  float[] xCoords;
  float[] yCoords;
  int[] pxCoords;
  int[] pyCoords;
  float midX;
  float midY;
  float[] relativeCoordsX;
  float[] relativeCoordsY;
  Clickable[] vertexButtons;
  Clickable dragButton;
  int buttonSize = 6;
  boolean selected;
  
  DrawingObj (float[] ixCoords, float[] iyCoords) {
    numCoords = ixCoords.length;
    xCoords = ixCoords;
    yCoords = iyCoords;
    pxCoords = new int[numCoords];
    pyCoords = new int[numCoords];
    relativeCoordsX = new float[numCoords];
    relativeCoordsY = new float[numCoords];
    selected = false;
    
    vertexButtons = new Clickable[numCoords];
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i] = new Clickable(0, 0, buttonSize, buttonSize, true);
      vertexButtons[i].visible = false;
      vertexButtons[i].shapeType = 1;
    }
    dragButton = new Clickable(0, 0, buttonSize, buttonSize, true);
    dragButton.visible = false;
    updatePos();
  }
  
  void update() {
    for (int i=0; i<numCoords; i++) {
      if (vertexButtons[i].pressed) {
        xCoords[i] = stage.toGrid(stage.localMouseX());
        yCoords[i] = stage.toGrid(stage.localMouseY());
        updatePos();
      }
    }
    if (dragButton.pressed) {
      midX = stage.toGrid(stage.localMouseX());
      midY = stage.toGrid(stage.localMouseY());
      for (int i=0; i<numCoords; i++) {
        xCoords[i] = midX + relativeCoordsX[i];
        yCoords[i] = midY + relativeCoordsY[i];
      }
      updatePos();
    }
  }
  
  void updatePos() {
    for (int i=0; i<numCoords; i++) {
      pxCoords[i] = stage.localToGlobalX(xCoords[i]);
      pyCoords[i] = stage.localToGlobalY(yCoords[i]);
      vertexButtons[i].x = pxCoords[i]-buttonSize/2;
      vertexButtons[i].y = pyCoords[i]-buttonSize/2;
    }
    midX = midX();
    midY = midY();
    dragButton.x = stage.localToGlobalX(midX())-buttonSize/2;
    dragButton.y = stage.localToGlobalY(midY())-buttonSize/2;
  }
  
  void setRelativeCoords() {
    for (int i=0; i<numCoords; i++) {
      relativeCoordsX[i] = xCoords[i]-midX();
      relativeCoordsY[i] = yCoords[i]-midY();
    }
  }
  
  void setPos(float[] ixCoords, float[] iyCoords) {
    xCoords = ixCoords;
    yCoords = iyCoords;
    updatePos();
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
  
  float minX() {
    return min(xCoords);
  }
  float minY() {
    return min(yCoords);
  }
  float maxX() {
    return max(xCoords);
  }
  float maxY() {
    return max(yCoords);
  }
  float midX() {
    return (minX()+maxX())/2;
  }
  float midY() {
    return (minY()+maxY())/2;
  }
  
  boolean inBounds(float ix1, float iy1, float ix2, float iy2) {
    if (inRegion(midX(), midY(), ix1, iy1, ix2, iy2)) {
      int vertexCount = 0;
      for (int i=0; i<numCoords; i++) {
        if (inRegion(int(xCoords[i]), int(yCoords[i]), int(ix1), int(iy1), int(ix2), int(iy2))) {
          vertexCount++;
        }
      }
      if (vertexCount >= numCoords/2) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
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

class PointObj extends DrawingObj {
  float time; // single bar width
 
  PointObj(float it, float ix, float iy) {
    super(new float[]{ix}, new float[]{iy});
    time = it;
  }
 
  void display() {
    update();
    stroke(0);
    fill(redblueColor(time, maxTime));
    ellipse(pxCoords[0], pyCoords[0], 10, 10);
    displayButtons();
  }
  
  void makeCommands() {

  }
  
  String toString() {
    return "POINT "+time+" "+xCoords[0]+" "+yCoords[0];
  }
}

class LineObj extends DrawingObj {
  float speed; // single bar width
 
  LineObj(float s, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = s;
  }
 
  void display() {
    update();
    noFill();
    stroke(redblueColor(speed, maxSpeed));
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

class CurveObj extends DrawingObj {
  float speed; // single bar width
  float detail = 10;
  
  CurveObj(float s, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2, ix1, ix2}, new float[]{iy1, iy2, iy1, iy2});
    speed = s;
    
  }
  
  CurveObj(float s, float ix1, float iy1, float ix2, float iy2, float cx1, float cy1, float cx2, float cy2) {
    super(new float[]{ix1, ix2, cx1, cx2}, new float[]{iy1, iy2, cy1, cy2});
    speed = s;
  }
 
  void display() {
    update();
    noFill();
    stroke(220);
    line(pxCoords[0], pyCoords[0], pxCoords[2], pyCoords[2]);
    line(pxCoords[1], pyCoords[1], pxCoords[3], pyCoords[3]);
    stroke(redblueColor(speed, maxSpeed));
    beginShape();
    for (int i=0; i<=detail; i++) {
      float px = bezierPoint(pxCoords[0], pxCoords[2], pxCoords[3], pxCoords[1], i/detail);
      float py = bezierPoint(pyCoords[0], pyCoords[2], pyCoords[3], pyCoords[1], i/detail); 
      vertex(px, py);
    }
    endShape();
    displayButtons();
  }
  
  void makeCommands() {
    
  }
  
  String toString() {
    return "CURVE "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1]+" "+xCoords[2]+" "+yCoords[2]+" "+xCoords[3]+" "+yCoords[3];
  }
}

class RectObj extends DrawingObj {
  float speed; // single bar width
 
  RectObj(float s, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = s;
  }
  
  void display() {
    update();
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    rect(pxCoords[0], pyCoords[0], pxCoords[1]-pxCoords[0], pyCoords[1]-pyCoords[0]);
    displayButtons();
  }
  
  void makeCommands() {
  }
  
  String toString() {
    return "RECT "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class EllipseObj extends DrawingObj {
  float speed; // single bar width
  float detail = 5;
 
  EllipseObj(float s, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = s;
  }
  
  void display() {
    update();
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    int lx = pxCoords[0];
    int hx = pxCoords[1];
    int ly = pyCoords[0];
    int hy = pyCoords[1];
    int mx = int(float(lx+hx)/2);
    int my = int(float(ly+hy)/2);
    int xDist = int(float(hx-lx)/2*0.552);
    int yDist = int(float(hy-ly)/2*0.552);

    beginShape();
    for (int i=0; i<=detail; i++) {
      float px = bezierPoint(lx, lx, mx-xDist, mx, i/detail);
      float py = bezierPoint(my, my-yDist, ly, ly, i/detail);
      vertex(px, py);
    }
    for (int i=0; i<=detail; i++) {
      float px = bezierPoint(mx, mx+xDist, hx, hx, i/detail);
      float py = bezierPoint(ly, ly, my-yDist, my, i/detail);
      vertex(px, py);
    }
    for (int i=0; i<=detail; i++) {
      float px = bezierPoint(hx, hx, mx+xDist, mx, i/detail);
      float py = bezierPoint(my, my+yDist, hy, hy, i/detail);
      vertex(px, py);
    }
    for (int i=0; i<=detail; i++) {
      float px = bezierPoint(mx, mx-xDist, lx, lx, i/detail);
      float py = bezierPoint(hy, hy, my+yDist, my, i/detail);
      vertex(px, py);
    }
    endShape();
    displayButtons();
  }
  
  void makeCommands() {
  }
  
  String toString() {
    return "ELLIPSE "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class GroupObj extends DrawingObj {
  float w, h;
  ArrayList<DrawingObj> objs;
  ArrayList<float[]> relativeX;
  ArrayList<float[]> relativeY;
  
  GroupObj() {
    super(new float[]{0, 0}, new float[]{0, 0});
    objs = new ArrayList<DrawingObj>();
    init();
  }
  
  GroupObj(ArrayList<DrawingObj> iObjs) {
    super(new float[]{0, 0}, new float[]{0, 0});
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
          tempRelX[j] = (currObj.xCoords[j]-xCoords[0])/w;
        } else {
          tempRelX[j] = 0;
        }
        if (h > 0) {
          tempRelY[j] = (currObj.yCoords[j]-yCoords[0])/h;
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
          currObj.xCoords[j] = xCoords[0] + tempRelX[j]*w;
          currObj.yCoords[j] = yCoords[0] + tempRelY[j]*h;
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
    noFill();
    stroke(220);
    rect(pxCoords[0]-1, pyCoords[0]-1, pxCoords[1]-pxCoords[0]+2, pyCoords[1]-pyCoords[0]+2);
    displayButtons();
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
    String toPrint = "GROUP\n";
    for (int i=0; i<objs.size(); i++) {
      toPrint += objs.get(i).toString()+"\n";
    }
    toPrint += "ENDGROUP";
    return toPrint;
  }
}

class Selection extends GroupObj {
  String clipboard = "";
  
  Selection() {
    super();
    buttonSize = 8;
    dragButton.basecolor = color(0, 255, 0);
    dragButton.pressedcolor = dragButton.highlightcolor = color(0, 200, 0);
    dragButton.w = dragButton.h = buttonSize;
    for (int i=0; i<2; i++) {
      vertexButtons[i].basecolor = color(0, 255, 0);
      vertexButtons[i].pressedcolor = vertexButtons[i].highlightcolor = color(0, 200, 0);
      vertexButtons[i].w = vertexButtons[i].h = buttonSize;
    }
  }
  
  void updatePos() {
    super.updatePos();
    x1Text.setVal(xCoords[0]);
    y1Text.setVal(yCoords[0]);
    x2Text.setVal(xCoords[1]);
    y2Text.setVal(yCoords[1]);
  }
  
  void release() {
    super.release();
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
  
  void insert(ArrayList<DrawingObj>  iObjs) {
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
  
  void copy() {
    clipboard = toString();
  }
  
  void paste() {
    if (clipboard.length() > 0) {
      String[] strings = clipboard.split("\n");
      ArrayList<DrawingObj> pasted = parseStrings(strings);
      deselect();
      insert(pasted);
      drawingList.addAll(pasted);
    }
  }
  
  void display() {
    update();
    if (selected) {
      noFill();
      stroke(0, 255, 0);
      rect(pxCoords[0]-1, pyCoords[0]-1, pxCoords[1]-pxCoords[0]+2, pyCoords[1]-pyCoords[0]+2);
      displayButtons();
    }
  }
  
  String toString() {
    String toPrint = "";
    for (int i=0; i<objs.size(); i++) {
      toPrint += objs.get(i).toString()+"\n";
    }
    return toPrint;
  }
}
