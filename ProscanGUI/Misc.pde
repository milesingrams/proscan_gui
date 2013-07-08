// HELPER METHODS
// conversion functions

// is mouse over an area?
boolean inRegion(int x, int y, int bx1, int by1, int bx2, int by2) {
  if (x >= bx1 && x <= bx2 || x >= bx1 && x <= bx2) {
    if (y >= by1 && y <= by2 || y >= by1 && y <= by2) {
      return true;
    }
  }
  return false;
}

color colorMap (int x, int maxX) {
  int val16bit = int((float(x)/maxX)*255);
  return color(val16bit, 0, 255-val16bit);
}

void hold (long time){
  long t0,t1;
  t0 = System.currentTimeMillis();
  do {
    t1=System.currentTimeMillis();
  }
  while (t1-t0 < time);
}

