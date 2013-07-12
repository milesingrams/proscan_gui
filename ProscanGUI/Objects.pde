class DrawingObj {
  int numCoords;
  float[] xCoords;
  float[] yCoords;
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
        xCoords[i] = toGrid(mainStage.localMouseX());
        yCoords[i] = toGrid(mainStage.localMouseY());
        updatePos();
      }
    }
    if (dragButton.pressed) {
      midX = toGrid(mainStage.localMouseX());
      midY = toGrid(mainStage.localMouseY());
      for (int i=0; i<numCoords; i++) {
        xCoords[i] = midX + relativeCoordsX[i];
        yCoords[i] = midY + relativeCoordsY[i];
      }
      updatePos();
    }
  }
  
  void updatePos() {
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i].x = mainStage.localToGlobalX(xCoords[i])-buttonSize/2;
      vertexButtons[i].y = mainStage.localToGlobalY(yCoords[i])-buttonSize/2;
    }
    midX = midX();
    midY = midY();
    dragButton.x = mainStage.localToGlobalX(midX())-buttonSize/2;
    dragButton.y = mainStage.localToGlobalY(midY())-buttonSize/2;
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
  
  void display(Stage iStage, boolean simple){}
  void makeCommands(){}
}

class PointObj extends DrawingObj {
  float time;
 
  PointObj(float it, float ix, float iy) {
    super(new float[]{ix}, new float[]{iy});
    time = it;
  }
 
  void display(Stage iStage, boolean simple) {
    update();
    int px = iStage.localToGlobalX(xCoords[0]);
    int py = iStage.localToGlobalY(yCoords[0]);
    fill(redblueColor(time, maxTime));
    if (simple) {
      noStroke();
      ellipse(px, py, 2, 2);
    } else {
      stroke(0);
      ellipse(px, py, 10, 10);
      displayButtons();
    }
  }
  
  void makeCommands() {
    addCommand(new SpeedCommand(baseMoveSpeed));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], false));
    addCommand(new ShutterCommand(true, time));
  }
  
  String toString() {
    return "POINT "+time+" "+xCoords[0]+" "+yCoords[0];
  }
}

class LineObj extends DrawingObj {
  float speed;
 
  LineObj(float is, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = is;
  }
 
  void display(Stage iStage, boolean simple) {
    update();
    int px1 = iStage.localToGlobalX(xCoords[0]);
    int py1 = iStage.localToGlobalY(yCoords[0]);
    int px2 = iStage.localToGlobalX(xCoords[1]);
    int py2 = iStage.localToGlobalY(yCoords[1]);
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    line(px1, py1, px2, py2);
    if (!simple) {
      displayButtons();
    }
  }
  
  void makeCommands() {
    addCommand(new SpeedCommand(baseMoveSpeed));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], false));
    addCommand(new SpeedCommand(speed));
    addCommand(new MoveCommand(xCoords[1], yCoords[1], true));
  }
  
  String toString() {
    return "LINE "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class CurveObj extends DrawingObj {
  float speed;
  float detail = 12;
  
  CurveObj(int iDet, float is, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2, ix1+(ix2-ix1)*0.33, ix1+(ix2-ix1)*0.66}, new float[]{iy1, iy2, iy1+(iy2-iy1)*0.33, iy1+(iy2-iy1)*0.66});
    speed = is;
    detail = iDet;
  }
  
  CurveObj(int iDet, float is, float ix1, float iy1, float ix2, float iy2, float cx1, float cy1, float cx2, float cy2) {
    super(new float[]{ix1, ix2, cx1, cx2}, new float[]{iy1, iy2, cy1, cy2});
    speed = is;
    detail = iDet;
  }
 
  void display(Stage iStage, boolean simple) {
    update();
    int px1 = iStage.localToGlobalX(xCoords[0]);
    int py1 = iStage.localToGlobalY(yCoords[0]);
    int px2 = iStage.localToGlobalX(xCoords[1]);
    int py2 = iStage.localToGlobalY(yCoords[1]);
    int cx1 = iStage.localToGlobalX(xCoords[2]);
    int cy1 = iStage.localToGlobalY(yCoords[2]);
    int cx2 = iStage.localToGlobalX(xCoords[3]);
    int cy2 = iStage.localToGlobalY(yCoords[3]);
    
    if (simple) {
      noFill();
      stroke(redblueColor(speed, maxSpeed));
      bezier(px1, py1, cx1, cy1, cx2, cy2, px2, py2);
    } else {
      noFill();
      stroke(220);
      line(px1, py1, cx1, cy1);
      line(px2, py2, cx2, cy2);
      stroke(redblueColor(speed, maxSpeed));
      beginShape();
      for (int i=0; i<=detail; i++) {
        float px = bezierPoint(px1, cx1, cx2, px2, i/detail);
        float py = bezierPoint(py1, cy1, cy2, py2, i/detail); 
        vertex(px, py);
      }
      endShape();
      displayButtons();
    }
  }
  
  void makeCommands() {
    addCommand(new SpeedCommand(baseMoveSpeed));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], false));
    addCommand(new SpeedCommand(speed));
    for (int i=1; i<=detail; i++) {
      float dx = bezierPoint(xCoords[0], xCoords[2], xCoords[3], xCoords[1], i/detail);
      float dy = bezierPoint(yCoords[0], yCoords[2], yCoords[3], yCoords[1], i/detail); 
      addCommand(new MoveCommand(dx, dy, true));
    }
  }
  
  String toString() {
    return "CURVE "+speed+" "+detail+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1]+" "+xCoords[2]+" "+yCoords[2]+" "+xCoords[3]+" "+yCoords[3];
  }
}

class RectObj extends DrawingObj {
  float speed; // single bar width
 
  RectObj(float is, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = is;
  }
  
  void display(Stage iStage, boolean simple) {
    update();
    int px1 = iStage.localToGlobalX(xCoords[0]);
    int py1 = iStage.localToGlobalY(yCoords[0]);
    int px2 = iStage.localToGlobalX(xCoords[1]);
    int py2 = iStage.localToGlobalY(yCoords[1]);
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    rect(px1, py1, px2-px1, py2-py1);
    if (!simple) {
      displayButtons();
    }
  }
  
  void makeCommands() {
    addCommand(new SpeedCommand(baseMoveSpeed));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], false));
    addCommand(new SpeedCommand(speed));
    addCommand(new MoveCommand(xCoords[1], yCoords[0], true));
    addCommand(new MoveCommand(xCoords[1], yCoords[1], true));
    addCommand(new MoveCommand(xCoords[0], yCoords[1], true));
    addCommand(new MoveCommand(xCoords[0], yCoords[0], true));
  }
  
  String toString() {
    return "RECT "+speed+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class EllipseObj extends DrawingObj {
  float speed;
  float detail = 5;
 
  EllipseObj(int iDet, float is, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    speed = is;
    detail = iDet;
  }
  
  void display(Stage iStage, boolean simple) {
    update();
    int px1 = iStage.localToGlobalX(xCoords[0]);
    int py1 = iStage.localToGlobalY(yCoords[0]);
    int px2 = iStage.localToGlobalX(xCoords[1]);
    int py2 = iStage.localToGlobalY(yCoords[1]);
    int mx = int(iStage.localToGlobalX(midX()));
    int my = int(iStage.localToGlobalY(midY()));
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    if (simple) {
      ellipse(mx, my, px2-px1, py2-py1);
    } else {
      int xDist = int(float(px2-px1)/2*0.552);
      int yDist = int(float(py2-py1)/2*0.552);
      
      beginShape();
      for (int i=0; i<=detail; i++) {
        float px = bezierPoint(px1, px1, mx-xDist, mx, i/detail);
        float py = bezierPoint(my, my-yDist, py1, py1, i/detail);
        vertex(px, py);
      }
      for (int i=0; i<=detail; i++) {
        float px = bezierPoint(mx, mx+xDist, px2, px2, i/detail);
        float py = bezierPoint(py1, py1, my-yDist, my, i/detail);
        vertex(px, py);
      }
      for (int i=0; i<=detail; i++) {
        float px = bezierPoint(px2, px2, mx+xDist, mx, i/detail);
        float py = bezierPoint(my, my+yDist, py2, py2, i/detail);
        vertex(px, py);
      }
      for (int i=0; i<=detail; i++) {
        float px = bezierPoint(mx, mx-xDist, px1, px1, i/detail);
        float py = bezierPoint(py2, py2, my+yDist, my, i/detail);
        vertex(px, py);
      }
      endShape();
      displayButtons();
    }
  }
  
  void makeCommands() {
    float px1 = xCoords[0];
    float py1 = yCoords[0];
    float px2 = xCoords[1];
    float py2 = yCoords[1];
    float mx = midX();
    float my = midY();
    float xDist = (px2-px1)/2*0.552;
    float yDist = (py2-py1)/2*0.552;
    addCommand(new SpeedCommand(baseMoveSpeed));
    addCommand(new MoveCommand(px1, my, false));
    addCommand(new SpeedCommand(speed));
    for (int i=1; i<=detail; i++) {
      float dx = bezierPoint(px1, px1, mx-xDist, mx, i/detail);
      float dy = bezierPoint(my, my-yDist, py1, py1, i/detail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=detail; i++) {
      float dx = bezierPoint(mx, mx+xDist, px2, px2, i/detail);
      float dy = bezierPoint(py1, py1, my-yDist, my, i/detail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=detail; i++) {
      float dx = bezierPoint(px2, px2, mx+xDist, mx, i/detail);
      float dy = bezierPoint(my, my+yDist, py2, py2, i/detail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=detail; i++) {
      float dx = bezierPoint(mx, mx-xDist, px1, px1, i/detail);
      float dy = bezierPoint(py2, py2, my+yDist, my, i/detail);
      addCommand(new MoveCommand(dx, dy, true));
    }
  }
  
  String toString() {
    return "ELLIPSE "+speed+" "+detail+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class FillObj extends DrawingObj {
  float speed;
  boolean horizontal;
  boolean vertical;
  float spacing;
 
  FillObj(float is, boolean iHor, boolean iVer, float isp, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    horizontal = iHor;
    vertical = iVer;
    spacing = isp;
    speed = is;
  }
  
  void display(Stage iStage, boolean simple) {
    update();
    float lx = minX();
    float ly = minY();
    float hx = maxX();
    float hy = maxY();
    int px1 = iStage.localToGlobalX(lx);
    int py1 = iStage.localToGlobalY(ly);
    int px2 = iStage.localToGlobalX(hx);
    int py2 = iStage.localToGlobalY(hy);
    stroke(redblueColor(speed, maxSpeed));
    if (simple) {
      fill(redblueColor(speed, maxSpeed));
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
    } else {
      noFill();
      if (horizontal) {
        for (float i=ly; i<=hy; i+=spacing) {
          int py = iStage.localToGlobalY(i);
          line(px1, py, px2, py);
        }
      }
      if (vertical) {
        for (float i=lx; i<=hx; i+=spacing) {
          int px = iStage.localToGlobalX(i);
          line(px, py1, px, py2);
        }
      }
      stroke(220);
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
      displayButtons();
    }
  }
  
  void makeCommands() {

  }
  
  String toString() {
    return "FILL "+" "+speed+" "+horizontal+" "+vertical+" "+spacing+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class GroupObj extends DrawingObj {
  float w, h;
  ArrayList<DrawingObj> objs;
  ArrayList<float[]> relativeX;
  ArrayList<float[]> relativeY;
  
  GroupObj(Stage iStage) {
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
  
  void display(Stage iStage, boolean simple) {
    update();
    if (simple) {
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).display(iStage, true);
      }
    } else {
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).display(iStage, false);
      }
      int px1 = iStage.localToGlobalX(xCoords[0]);
      int py1 = iStage.localToGlobalY(yCoords[0]);
      int px2 = iStage.localToGlobalX(xCoords[1]);
      int py2 = iStage.localToGlobalY(yCoords[1]);
      noFill();
      stroke(220);
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
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
  
  void setTime(float time) {
    for (int i=0; i<objs.size(); i++) {
      DrawingObj currObj = objs.get(i);
      if (currObj instanceof PointObj) {
        PointObj pointObj = (PointObj)currObj;
        pointObj.time = time;
      } else
      if (currObj instanceof GroupObj) {
        GroupObj groupObj = (GroupObj)currObj;
        groupObj.setTime(time);
      }
    }
  }
  
  void setSpeed(float speed) {
    for (int i=0; i<objs.size(); i++) {
      DrawingObj currObj = objs.get(i);
      if (currObj instanceof LineObj) {
        LineObj lineObj = (LineObj)currObj;
        lineObj.speed = speed;
      } else
      if (currObj instanceof CurveObj) {
        CurveObj curveObj = (CurveObj)currObj;
        curveObj.speed = speed;
      } else
      if (currObj instanceof RectObj) {
        RectObj rectObj = (RectObj)currObj;
        rectObj.speed = speed;
      } else
      if (currObj instanceof EllipseObj) {
        EllipseObj ellipseObj = (EllipseObj)currObj;
        ellipseObj.speed = speed;
      } else
      if (currObj instanceof FillObj) {
        FillObj fillObj = (FillObj)currObj;
        fillObj.speed = speed;
      } else
      if (currObj instanceof GroupObj) {
        GroupObj groupObj = (GroupObj)currObj;
        groupObj.setSpeed(speed);
      }
    }
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
    super(mainStage);
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
    editTool.setVals(xCoords[0], yCoords[0], xCoords[1]-xCoords[0], yCoords[1]-yCoords[0]);
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
  
  void display(Stage iStage, boolean simple) {
    update();
    if (selected) {
      int px1 = iStage.localToGlobalX(xCoords[0]);
      int py1 = iStage.localToGlobalY(yCoords[0]);
      int px2 = iStage.localToGlobalX(xCoords[1]);
      int py2 = iStage.localToGlobalY(yCoords[1]);
      noFill();
      stroke(0, 255, 0);
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
      if (!simple) {
        displayButtons();
      }
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

