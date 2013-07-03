// HELPER METHODS
// conversion functions
int localToGlobalX(int ix) {
  return int(map(ix, lowX, lowX+rangeX, margin, margin+stageWidth));
}

int localToGlobalY(int iy) {
  return int(map(iy, lowY, lowY+rangeY, margin, margin+stageHeight));
}

int globalToLocalX(int ix) {
  return round(map(ix, margin, margin+stageWidth, lowX, lowX+rangeX));
}

int globalToLocalY(int iy) {
  return round(map(iy, margin, margin+stageHeight, lowY, lowY+rangeY));
}

// is mouse over an area?

boolean inRegion(int x, int y, int bx, int by, int bw, int bh) {
  int bx2 = bx+bw;
  int by2 = by+bh;
  if (x >= bx && x <= bx2 || x >= bx && x <= bx2) {
    if (y >= by && y <= by2 || y >= by && y <= by2) {
      return true;
    }
  }
  return false;
}

color colorMap (int x, int maxX) {
  int val16bit = int((float(x)/maxX)*255);
  return color(val16bit, 0, 255-val16bit);
}

int toGrid(int x) {
  return round(float(x)/gridSize)*gridSize;
}

void makeToolbar(int x, int y, int spacing, Interface[] interfaces) {
  for (int i=0; i<interfaces.length; i++) {
    Interface current = interfaces[i];
    current.x = x;
    current.y = y;
    current.updatePos();
    x += current.w + spacing;
  }
}

void hold (long time){
  long t0,t1;
  t0 = System.currentTimeMillis();
  do {
    t1=System.currentTimeMillis();
  }
  while (t1-t0 < time);
}
