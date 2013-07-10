class Stage {
  int x, y;
  int w, h;
  float rangeX, rangeY;
  float lowX, lowY;
  float gridSize = 1;
  
  Stage (int ix, int iy, int iw, int ih, float irx) {
    x = ix;
    y = iy;
    w = iw;
    h = ih;
    rangeX = irx;
    rangeY = (float(h)/w)*rangeX;
    lowX = -rangeX/2;
    lowY = -rangeY/2;
  }
  
  int localToGlobalX(float ix) {
    return int(map(ix, lowX, lowX+rangeX, x, x+w));
  }
  
  int localToGlobalY(float iy) {
    return int(map(iy, lowY, lowY+rangeY, y, y+h));
  }
  
  float globalToLocalX(int ix) {
    return map(ix, x, x+w, lowX, lowX+rangeX);
  }
  
  float globalToLocalY(int iy) {
    return map(iy, y, y+h, lowY, lowY+rangeY);
  }
  
  float toGrid(float ix) {
    return round(ix/gridSize)*gridSize;
  }
  
  float localMouseX() {
    return globalToLocalX(mouseX);
  }
  
  float localMouseY() {
    return globalToLocalY(mouseY);
  }
  
  boolean mouseOver() {
    if (inRegion(mouseX, mouseY, x, y, x+w, y+h)) {
      return true;
    } else {
      return false;
    }
  }
  
  void setZoom(float ix, float iy, float zoom) {
    setPos(ix-rangeX*zoom/2, iy-rangeY*zoom/2, rangeX*zoom);
  }
  
  void setPos(float ilx, float ily, float irx) {
    lowX = ilx;
    lowY = ily;
    if (irx > 0) {
      rangeX = irx;
      rangeY = (float(h)/w)*rangeX;
    }
    updatePos();
  }
  
  void updatePos() {
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.get(i).updatePos();
    }
    objSelection.updatePos();
    lowXText.setVal(lowX);
    lowYText.setVal(lowY);
    rangeXText.setVal(rangeX);
  }
  
  void display() {
    stroke(0);
    fill(255);
    rect(x, y, w, h);
    
    // Gridlines
    if (rangeX/gridSize < 100) {
      stroke(220);
      for (float i=ceil(lowX/gridSize)*gridSize; i<lowX+rangeX; i+=gridSize) {
        int lineX = localToGlobalX(i);
        line(lineX, y, lineX, y+h);
      }
      for (float i=ceil(lowY/gridSize)*gridSize; i<lowY+rangeY; i+=gridSize) {
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
    text(str(rangeX)+" um", x+30, y+h-28+fontSize);
    strokeWeight(1);
    
    // Cursor
    if (mouseOver()) {
      fill(0);
      text("x:"+String.format("%.1f", localMouseX()), mouseX + 15, mouseY - 2);
      text("y:"+String.format("%.1f", localMouseY()), mouseX + 15, mouseY + fontSize);
    }
  }
}
