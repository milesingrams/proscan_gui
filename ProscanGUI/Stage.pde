class Stage {
  int x, y;
  int w, h;
  int rangeX, rangeY;
  int lowX, lowY;
  int gridSize = 10;
  
  Stage (int ix, int iy, int iw, int ih, int irx) {
    x = ix;
    y = iy;
    w = iw;
    h = ih;
    rangeX = irx;
    rangeY = int((float(h)/w)*rangeX);
    lowX = -rangeX/2;
    lowY = -rangeY/2;
  }
  
  int localToGlobalX(int ix) {
    return int(map(ix, lowX, lowX+rangeX, x, x+w));
  }
  
  int localToGlobalY(int iy) {
    return int(map(iy, lowY, lowY+rangeY, y, y+h));
  }
  
  int globalToLocalX(int ix) {
    return round(map(ix, x, x+w, lowX, lowX+rangeX));
  }
  
  int globalToLocalY(int iy) {
    return round(map(iy, y, y+h, lowY, lowY+rangeY));
  }
  
  int toGrid(int ix) {
    return round(float(ix)/gridSize)*gridSize;
  }
  
  int localMouseX() {
    return globalToLocalX(mouseX);
  }
  
  int localMouseY() {
    return globalToLocalY(mouseY);
  }
  
  boolean mouseOver() {
    if (inRegion(mouseX, mouseY, x, y, x+w, y+h)) {
      return true;
    } else {
      return false;
    }
  }
  
  void setZoom(int ix, int iy, float zoom) {
    setPos(int(ix-rangeX*zoom/2), int(iy-rangeY*zoom/2), int(rangeX*zoom));
  }
  
  void setPos(int ilx, int ily, int irx) {
    lowX = ilx;
    lowY = ily;
    rangeX = irx;
    rangeY = int((float(h)/w)*rangeX);
    updatePos();
  }
  
  void updatePos() {
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.get(i).updatePos();
    }
    objSelection.updatePos();
  }
  
  void display() {
    stroke(0);
    fill(255);
    rect(x, y, w, h);
    
    // Gridlines
    if (rangeX/gridSize < 100) {
      stroke(220);
      for (int i=ceil(float(lowX)/gridSize)*gridSize; i<lowX+rangeX; i+=gridSize) {
        int lineX = localToGlobalX(i);
        line(lineX, y, lineX, y+h);
      }
      for (int i=ceil(float(lowY)/gridSize)*gridSize; i<lowY+rangeY; i+=gridSize) {
        int lineY = localToGlobalY(i);
        line(x, lineY, x+w, lineY);
      }
    }
    
    // Origin Dot
    stroke(0);
    fill(0);
    ellipse(localToGlobalX(0), localToGlobalY(0), 5, 5);
    
    // Range Bar
    stroke(0);
    strokeWeight(2);
    fill(0);
    line(x+30, y+h-30, x+w/10, y+h-30);
    text(str(rangeX/100)+" um", x+30, y+h-28+fontSize);
    strokeWeight(1);
    
    // Cursor
    if (mouseOver()) {
      fill(0);
      text("x:"+str(float(localMouseX())/10), mouseX + 15, mouseY - 2);
      text("y:"+str(float(localMouseY())/10), mouseX + 15, mouseY + fontSize);
    }
  }
}
