class DrawingObj {
  int numCoords;
  float[] xCoords;
  float[] yCoords;
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
  }
  
  void update() {
    for (int i=0; i<numCoords; i++) {
      if (vertexButtons[i].pressed) {
        xCoords[i] = toGrid(mainWindow.localMouseX());
        yCoords[i] = toGrid(mainWindow.localMouseY());
        updatePos();
      }
    }
    if (dragButton.pressed) {
      float minX = toGrid(mainWindow.localMouseX()-(maxX()-minX())/2);
      float minY = toGrid(mainWindow.localMouseY()-(maxY()-minY())/2);
      for (int i=0; i<numCoords; i++) {
        xCoords[i] = minX + relativeCoordsX[i];
        yCoords[i] = minY + relativeCoordsY[i];
      }
      updatePos();
    }
  }
  
  void updatePos() {
    for (int i=0; i<numCoords; i++) {
      vertexButtons[i].x = mainWindow.localToGlobalX(xCoords[i])-buttonSize/2;
      vertexButtons[i].y = mainWindow.localToGlobalY(yCoords[i])-buttonSize/2;
    }
    dragButton.x = mainWindow.localToGlobalX(midX())-buttonSize/2;
    dragButton.y = mainWindow.localToGlobalY(midY())-buttonSize/2;
  }
  
  void setRelativeCoords() {
    for (int i=0; i<numCoords; i++) {
      relativeCoordsX[i] = xCoords[i]-minX();
      relativeCoordsY[i] = yCoords[i]-minY();
    }
  }
  
  void setPos(float[] ixCoords, float[] iyCoords) {
    xCoords = ixCoords;
    yCoords = iyCoords;
    updatePos();
  }
  
  void translate(float ix, float iy) {
    for (int i=0; i<numCoords; i++) {
      xCoords[i] += ix;
      yCoords[i] += iy;
    }
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
    setLastState();
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
  
  void setTime(float it){}
  void setSpeed(float is){}
  void setDetail(int iDet){}
  void setSpacing(float isp){}
  void display(DrawingWindow iWindow, boolean simple){}
  void makeCommands(){}
}

class PointObj extends DrawingObj {
  float time;
  boolean shut;
 
  PointObj(float it, boolean iShut, float ix, float iy) {
    super(new float[]{ix}, new float[]{iy});
    setTime(it);
    shut = iShut;
    updatePos();
  }
  
  void setTime(float it) {
    if (it > 0) {
      time = it;
    } else {
      time = 0;
    }
  }
 
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px = iWindow.localToGlobalX(xCoords[0]);
    int py = iWindow.localToGlobalY(yCoords[0]);
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
    addCommand(new ShutterCommand(shut, time));
  }
  
  String toString() {
    return "POINT "+time+" "+str(shut)+" "+xCoords[0]+" "+yCoords[0];
  }
}

class LineObj extends DrawingObj {
  float speed;
 
  LineObj(float is, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    setSpeed(is);
    updatePos();
  }
  
  void setSpeed(float is) {
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
 
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
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
  float detail = 0;
  float[] bezierX;
  float[] bezierY;
  
  CurveObj(float is, int iDet, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2, ix1+(ix2-ix1)*0.33, ix1+(ix2-ix1)*0.66}, new float[]{iy1, iy2, iy1+(iy2-iy1)*0.33, iy1+(iy2-iy1)*0.66});
    setSpeed(is);
    setDetail(iDet);
    updatePos();
  }
  
  CurveObj(float is, int iDet, float ix1, float iy1, float ix2, float iy2, float icx1, float icy1, float icx2, float icy2) {
    super(new float[]{ix1, ix2, icx1, icx2}, new float[]{iy1, iy2, icy1, icy2});
    setSpeed(is);
    setDetail(iDet);
    updatePos();
  }
  
  void setSpeed(float is) {
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
  
  void setDetail(int iDet) {
    if (iDet >= 1) {
      detail = iDet;
    } else {
      detail = 1;
    }
    bezierX = new float[int(detail+1)];
    bezierY = new float[int(detail+1)];
    updatePos();
  }
  
  void updatePos() {
    super.updatePos();
    for (int i=0; i<=int(detail); i++) {
      bezierX[i] = bezierPoint(xCoords[0], xCoords[2], xCoords[3], xCoords[1], i/detail);
      bezierY[i] = bezierPoint(yCoords[0], yCoords[2], yCoords[3], yCoords[1], i/detail); 
    }
  }
  
  float minX() {
    return min(bezierX);
  }
  
  float minY() {
    return min(bezierY);
  }
  
  float maxX() {
    return max(bezierX);
  }
  
  float maxY() {
    return max(bezierY);
  }
 
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
    int cx1 = iWindow.localToGlobalX(xCoords[2]);
    int cy1 = iWindow.localToGlobalY(yCoords[2]);
    int cx2 = iWindow.localToGlobalX(xCoords[3]);
    int cy2 = iWindow.localToGlobalY(yCoords[3]);
    
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
      for (int i=0; i<=int(detail); i++) {
        float px = iWindow.localToGlobalX(bezierX[i]);
        float py = iWindow.localToGlobalY(bezierY[i]);
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
    for (int i=1; i<=int(detail); i++) {
      addCommand(new MoveCommand(bezierX[i], bezierY[i], true));
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
    setSpeed(is);
    updatePos();
  }
  
  void setSpeed(float is) {
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
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
  int detail;
 
  EllipseObj(float is, int iDet, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    setSpeed(is);
    setDetail(iDet);
    updatePos();
  }
  
  void setSpeed(float is) {
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
  
  void setDetail(int iDet) {
    if (iDet >= 4) {
      detail = iDet;
    } else {
      detail = 4;
    }
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    float quarterDetail = round(float(detail)/4);
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
    int mx = int(iWindow.localToGlobalX(midX()));
    int my = int(iWindow.localToGlobalY(midY()));
    noFill();
    stroke(redblueColor(speed, maxSpeed));
    if (simple) {
      ellipse(mx, my, px2-px1, py2-py1);
    } else {
      int xDist = int(float(px2-px1)/2*0.552);
      int yDist = int(float(py2-py1)/2*0.552);
      
      beginShape();
      for (int i=0; i<=quarterDetail; i++) {
        float px = bezierPoint(px1, px1, mx-xDist, mx, i/quarterDetail);
        float py = bezierPoint(my, my-yDist, py1, py1, i/quarterDetail);
        vertex(px, py);
      }
      for (int i=0; i<=quarterDetail; i++) {
        float px = bezierPoint(mx, mx+xDist, px2, px2, i/quarterDetail);
        float py = bezierPoint(py1, py1, my-yDist, my, i/quarterDetail);
        vertex(px, py);
      }
      for (int i=0; i<=quarterDetail; i++) {
        float px = bezierPoint(px2, px2, mx+xDist, mx, i/quarterDetail);
        float py = bezierPoint(my, my+yDist, py2, py2, i/quarterDetail);
        vertex(px, py);
      }
      for (int i=0; i<=quarterDetail; i++) {
        float px = bezierPoint(mx, mx-xDist, px1, px1, i/quarterDetail);
        float py = bezierPoint(py2, py2, my+yDist, my, i/quarterDetail);
        vertex(px, py);
      }
      endShape();
      displayButtons();
    }
  }
  
  void makeCommands() {
    float quarterDetail = round(float(detail)/4);
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
    for (int i=1; i<=quarterDetail; i++) {
      float dx = bezierPoint(px1, px1, mx-xDist, mx, i/quarterDetail);
      float dy = bezierPoint(my, my-yDist, py1, py1, i/quarterDetail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=quarterDetail; i++) {
      float dx = bezierPoint(mx, mx+xDist, px2, px2, i/quarterDetail);
      float dy = bezierPoint(py1, py1, my-yDist, my, i/quarterDetail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=quarterDetail; i++) {
      float dx = bezierPoint(px2, px2, mx+xDist, mx, i/quarterDetail);
      float dy = bezierPoint(my, my+yDist, py2, py2, i/quarterDetail);
      addCommand(new MoveCommand(dx, dy, true));
    }
    for (int i=0; i<=quarterDetail; i++) {
      float dx = bezierPoint(mx, mx-xDist, px1, px1, i/quarterDetail);
      float dy = bezierPoint(py2, py2, my+yDist, my, i/quarterDetail);
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
    setSpeed(is);
    horizontal = iHor;
    vertical = iVer;
    setSpacing(isp);
    updatePos();
  }
  
  void setSpeed(float is) {
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
  
  void setSpacing(float isp) {
    if (isp > 0) {
      spacing = isp;
    } else {
      spacing = 0;
    }
  }
  
  void makeLines() {
    float lx = minX();
    float ly = minY();
    float hx = maxX();
    float hy = maxY();
    if (horizontal) {
      for (float i=ly; i<=hy; i+=spacing) {
        line(lx, i, hx, i);
      }
    }
    if (vertical) {
      for (float i=lx; i<=hx; i+=spacing) {
        line(i, ly, i, hy);
      }
    }
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    float lx = minX();
    float ly = minY();
    float hx = maxX();
    float hy = maxY();
    int px1 = iWindow.localToGlobalX(lx);
    int py1 = iWindow.localToGlobalY(ly);
    int px2 = iWindow.localToGlobalX(hx);
    int py2 = iWindow.localToGlobalY(hy);
    stroke(redblueColor(speed, maxSpeed));
    if (simple) {
      fill(redblueColor(speed, maxSpeed));
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
    } else {
      noFill();
      if (horizontal) {
        for (float i=ly; i<=hy; i+=spacing) {
          int py = iWindow.localToGlobalY(i);
          line(px1, py, px2, py);
        }
      }
      if (vertical) {
        for (float i=lx; i<=hx; i+=spacing) {
          int px = iWindow.localToGlobalX(i);
          line(px, py1, px, py2);
        }
      }
      stroke(220);
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
      displayButtons();
    }
  }
  
  void makeCommands() {
    float lx = minX();
    float ly = minY();
    float hx = maxX();
    float hy = maxY();
    if (horizontal) {
      for (float i=ly; i<=hy; i+=spacing) {
        addCommand(new SpeedCommand(baseMoveSpeed));
        addCommand(new MoveCommand(lx, i, false));
        addCommand(new SpeedCommand(speed));
        addCommand(new MoveCommand(hx, i, true));
      }
    }
    if (vertical) {
      for (float i=lx; i<=hx; i+=spacing) {
        addCommand(new SpeedCommand(baseMoveSpeed));
        addCommand(new MoveCommand(i, ly, false));
        addCommand(new SpeedCommand(speed));
        addCommand(new MoveCommand(i, hy, true));
      }
    }
  }
  
  String toString() {
    return "FILL "+speed+" "+horizontal+" "+vertical+" "+spacing+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class ScanImage extends GroupObj {
  float x1, y1;
  float x2, y2;
  float speed;
  String path;
  PImage img;
  boolean horizontal;
  boolean vertical;
  
  ScanImage(float is, String iPath, boolean iHor, boolean iVer, float ix1, float iy1, float ix2, float iy2) {
    super();
    setSpeed(is);
    path = iPath;
    img = loadImage(path);
    horizontal = iHor;
    vertical = iVer;
    x1 = ix1;
    y1 = iy1;
    x2 = ix2;
    y2 = iy2;
    makeLines();
    updatePos();
  }
  
  void setSpeed(float is) {
    super.setSpeed(is);
    if (is > 0) {
      speed = is;
    } else {
      speed = 0;
    }
  }
  
  boolean isBlack(int ip) {
    if (brightness(ip) < 255/2) {
      return true;
    } else {
      return false;
    }
  }
  
  void makeLines() {
    float w = x2-x1;
    float h = y2-y1;
    int imgH = img.height;
    int imgW = img.width;
    boolean makingLine = false;
    ArrayList<DrawingObj> tempLines = new ArrayList<DrawingObj>();
    LineObj currLine = null;
    img.loadPixels();
    
    if (horizontal) {
      for (int i=0; i<imgH; i++) {
        float y = y1+i*(h/imgH);
        for (int j=0; j<imgW; j++) {
          float x = x1+j*(w/imgW);
          int pixel = img.pixels[i*imgW+j];
          if (currLine != null) {
            if (isBlack(pixel) == false) {
              currLine.xCoords[1] = x;
              currLine.yCoords[1] = y;
              tempLines.add(currLine);
              currLine = null;
            }
          } else {
            if (isBlack(pixel) == true) {
              currLine = new LineObj(speed, x, y, 0, 0);
            }
          }
        }
        if (currLine != null) {
          currLine.xCoords[1] = w;
          currLine.yCoords[1] = y;
          tempLines.add(currLine);
          currLine = null;
        }
      }
    }
    if (vertical) {
      for (int i=0; i<imgW; i++) {
        float x = x1+i*(w/imgW);
        for (int j=0; j<imgH; j++) {
          float y = y1+j*(h/imgH);
          int pixel = img.pixels[j*imgW+i];
          if (currLine != null) {
            if (isBlack(pixel) == false) {
              currLine.xCoords[1] = x;
              currLine.yCoords[1] = y;
              tempLines.add(currLine);
              currLine = null;
            }
          } else {
            if (isBlack(pixel) == true) {
              currLine = new LineObj(speed, x, y, 0, 0);
            }
          }
        }
        if (currLine != null) {
          currLine.xCoords[1] = x;
          currLine.yCoords[1] = h;
          tempLines.add(currLine);
          currLine = null;
        }
      }
    }
    insert(tempLines);
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
    if (simple) {
      tint(255, 126);
      image(img, px1, py1, px2-px1, py2-py1);
    } else {
      tint(255, 126);
      image(img, px1, py1, px2-px1, py2-py1);
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).display(iWindow, false);
      }
      noFill();
      stroke(220);
      rect(px1-1, py1-1, px2-px1+2, py2-py1+2);
      displayButtons();
    }
  }
  
  String toString() {
    return "SCANIMAGE "+speed+" "+path+" "+horizontal+" "+vertical+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
  }
}

class BackgroundImage extends DrawingObj{
  String path;
  PImage img;
  
  BackgroundImage(String iPath, float ix1, float iy1, float ix2, float iy2) {
    super(new float[]{ix1, ix2}, new float[]{iy1, iy2});
    path = iPath;
    img = loadImage(path);
    updatePos();
  }
  
  void updatePos() {
    super.updatePos();
    bgImageTool.setVals(xCoords[0], yCoords[0], xCoords[1]-xCoords[0], yCoords[1]-yCoords[0]);
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    int px1 = iWindow.localToGlobalX(xCoords[0]);
    int py1 = iWindow.localToGlobalY(yCoords[0]);
    int px2 = iWindow.localToGlobalX(xCoords[1]);
    int py2 = iWindow.localToGlobalY(yCoords[1]);
    noFill();
    noStroke();
    tint(255, 126);
    image(img, px1, py1, px2-px1, py2-py1);
    if (!simple) {
      displayButtons();
    }
  }
  
  String toString() {
    return "BGIMAGE "+path+" "+xCoords[0]+" "+yCoords[0]+" "+xCoords[1]+" "+yCoords[1];
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
    relativeX = new ArrayList<float[]>();
    relativeY = new ArrayList<float[]>();
    getBounds();
    updatePos();
  }
  
  GroupObj(ArrayList<DrawingObj> iObjs) {
    super(new float[]{0, 0}, new float[]{0, 0});
    objs = iObjs;
    relativeX = new ArrayList<float[]>();
    relativeY = new ArrayList<float[]>();
    getBounds();
    updatePos();
  }
  
  void insert(DrawingObj iObj) {
    objs.add(iObj);
    getBounds();
  }
  
  void insert(ArrayList<DrawingObj> iObjs) {
    objs.addAll(iObjs);
    getBounds();
  }
  
  void remove(DrawingObj iObj) {
    objs.remove(iObj);
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
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    if (simple) {
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).display(iWindow, true);
      }
    } else {
      for (int i=0; i<objs.size(); i++) {
        objs.get(i).display(iWindow, false);
      }
      int px1 = iWindow.localToGlobalX(xCoords[0]);
      int py1 = iWindow.localToGlobalY(yCoords[0]);
      int px2 = iWindow.localToGlobalX(xCoords[1]);
      int py2 = iWindow.localToGlobalY(yCoords[1]);
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
    setLastState();
    drawingList.addAll(this.objs);
    objSelection.insert(this.objs);
    delete();
  }
  
  void setTime(float it) {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).setTime(it);
    }
  }
  
  void setSpeed(float is) {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).setSpeed(is);
    }
  }
  
  void setDetail(int iDet) {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).setDetail(iDet);
    }
  }
  
  void setSpacing(float isp) {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).setSpacing(isp);
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
    updatePos();
  }
  
  void updatePos() {
    super.updatePos();
    editTool.setVals(xCoords[0], yCoords[0], xCoords[1]-xCoords[0], yCoords[1]-yCoords[0]);
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
  
  void insert(ArrayList<DrawingObj>  iObjs) {
    super.insert(iObjs);
    select();
  }
  
  void remove(DrawingObj iObj) {
    iObj.deselect();
    super.remove(iObj);
    if (objs.size() == 0) {
      deselect();
    }
  }
  
  void delete() {
    for (int i=0; i<objs.size(); i++) {
      objs.get(i).delete();
    }
    deselect();
  }
  
  void group() {
    if (selected) {
      setLastState();
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
      setLastState();
      String[] strings = clipboard.split("\n");
      ArrayList<DrawingObj> pasted = parseStrings(strings);
      deselect();
      insert(pasted);
      drawingList.addAll(pasted);
    }
  }
  
  void display(DrawingWindow iWindow, boolean simple) {
    update();
    if (selected) {
      int px1 = iWindow.localToGlobalX(xCoords[0]);
      int py1 = iWindow.localToGlobalY(yCoords[0]);
      int px2 = iWindow.localToGlobalX(xCoords[1]);
      int py2 = iWindow.localToGlobalY(yCoords[1]);
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

