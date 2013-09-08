class DrawingWindow {
  int x, y;
  int w, h;
  float rangeX, rangeY;
  float lowX, lowY;
  
  DrawingWindow (int ix, int iy, int iw, int ih, float irx) {
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
  
  int localToGlobalW(float iw) {
    return int(iw/rangeX*w);
  }
  
  int localToGlobalH(float ih) {
    return int(ih/rangeY*h);
  }
  
  float globalToLocalX(int ix) {
    return map(ix, x, x+w, lowX, lowX+rangeX);
  }
  
  float globalToLocalY(int iy) {
    return map(iy, y, y+h, lowY, lowY+rangeY);
  }
  
  float globalToLocalW(int iw) {
    return float(iw)/width*rangeX;
  }
  
  float globalToLocalH(int ih) {
    return float(ih)/height*rangeY;
  }
  
  float localMouseX() {
    return globalToLocalX(mouseX);
  }
  
  float localMouseY() {
    return globalToLocalY(mouseY);
  }
  
  float midX() {
    return lowX+rangeX/2;
  }
  
  float midY() {
    return lowY+rangeY/2;
  }
  
  boolean mouseOver() {
    if (inRegion(mouseX, mouseY, x, y, x+w, y+h)) {
      return true;
    } else {
      return false;
    }
  }
  
  void setZoom(float ix, float iy, float zoom) {
    setRangeX(rangeX*zoom);
    setPos(ix, iy);
  }
  
  void setPos(float imx, float imy) {
    lowX = imx-rangeX/2;
    lowY = imy-rangeY/2;
  }
  
  void setRangeX(float irx) {
    if (irx > 0) {
      rangeX = irx;
      rangeY = (float(h)/w)*rangeX;
    }
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
  }
}

