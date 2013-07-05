class Interface {
  int x, y;
  int w, h;
  
  Interface(int ix, int iy, int iw, int ih) {
    x = ix;
    y = iy;
    w = iw;
    h = ih;
  }
  
  void updatePos(){}
  void display(){}
}

class Clickable extends Interface {
  color basecolor = color(230);
  color highlightcolor = color(190);
  color pressedcolor = color(190);
  boolean pressed = false;
  boolean draggable = false;
  boolean visible = true;
  
  Clickable(int ix, int iy, int iw, int ih, boolean d) {
    super(ix, iy, iw, ih);
    draggable = d;
  }
    
  boolean over() {
    if(inRegion(mouseX, mouseY, x, y, x+w, y+h) ) {
      return true;
    } else {
      return false;
    }
  }
  
  void press() {
    if (visible) {
      if (draggable) {
        dragging = true;
      }
      pressed = true;
    }
  }
  
  void release() {
    if (visible) {
      if (draggable) {
        dragging = false;
      }
      pressed = false;
    }
  }

  void display() {
    if (visible) {
      color currentcolor;
      if(over()) {
        currentcolor = highlightcolor;
      } 
      else {
        if (pressed) {
          currentcolor = pressedcolor;
        } else {
          currentcolor = basecolor;
        }
      }
      stroke(0);
      fill(currentcolor);
      rect(x, y, w, h);
    }
  }
}

class Slider extends Interface{
  String text;
  String unit;
  int digits;
  int slideX, slideY;
  int slideLength;
  int boxx, boxy;
  int slidePos;
  int val;
  int maxVal;
  Clickable box;
  int boxSize = 10;
  
  Slider(int ix, int iy, int iw, int ih, int imv, String itext, int idigits, String iunit) {
    super(ix, iy, iw, ih);
    text = itext;
    unit = iunit;
    digits = idigits;
    
    int textWidth1 = int(textWidth(text));
    slideX = x + textWidth1 + 15;
    slideY = y + h/2;
    String temp = iunit;
    for (int i=0; i<digits; i++) {
      temp += "0";
    }
    int textWidth2 = int(textWidth(temp));
    
    slideLength = w-textWidth1-textWidth2-30;
    slidePos = slideLength;
    maxVal = imv;
    val = imv;
    box = new Clickable(slideX+slidePos-boxSize/2, slideY - boxSize/2, boxSize, boxSize, true);
  }
  
  void updatePos() {
    int textWidth1 = int(textWidth(text));
    slideX = x + textWidth1 + 15;
    slideY = y + h/2;
    String temp = unit;
    for (int i=0; i<digits; i++) {
      temp += "0";
    }
    int textWidth2 = int(textWidth(temp));
    
    slideLength = w-textWidth1-textWidth2-30;
    slidePos = slideLength;
  };
  
  void press() {
    if(box.over()) {
      box.press();
    }
  }
  
  void release() {
    box.release();
  }
  
  void setVals(int iv, int imv) {
    val = iv;
    maxVal = imv;
    slidePos = int(((float)val/maxVal)*slideLength);
  }
  
  void update() {
    if(box.pressed) {
      slidePos = lock(mouseX-slideX, 0, slideLength);
      val = int((float(slidePos)/slideLength)*maxVal);
    }
  }
  
  int lock(int val, int minv, int maxv) { 
    return  min(max(val, minv), maxv); 
  }
  
  void display() {
    update();
    stroke(0);
    fill(230);
    rect(x, y, w, h);
    fill(0);
    text(text, x+5, slideY+fontSize/2);
    line(slideX, slideY-1, slideX+slideLength, slideY-1);
    line(slideX, slideY+1, slideX+slideLength, slideY+1);
    stroke(colorMap(val, maxVal));
    line(slideX, slideY, slideX+slidePos, slideY);
    stroke(0);
    fill(0);
    text(str(val)+unit, slideX+slideLength + 10, slideY+fontSize/2);
    box.x = slideX+slidePos-box.w/2;
    box.y = slideY - box.w/2;
    box.display();
  }
}

class TextBox extends Clickable {
  String text;
  boolean selected;
  
  TextBox(int ix, int iy, int iw, int ih, String itext) {
    super(ix, iy, iw, ih, false);
    basecolor = color(255);
    pressedcolor = highlightcolor = color(230, 230, 255);
    text = itext;
  }
  
  void display() {
    super.display();
    fill(0);
    text(text, x+5, y+h/2+fontSize/2);
  }
}

class TextButton extends Clickable {
  String txt;
  
  TextButton (int ix, int iy, int iw, int ih, String s) {
    super(ix, iy, iw, ih, false);
    txt = s;
    if (w == 0) {
      w = int(textWidth(txt))+20;
    }
    
  }
  
  void display () {
    super.display();
    fill(0);
    text(txt, x+10, y+h/2+fontSize/2);
  }
}

class PointButton extends Clickable {
  
  PointButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    fill(0);
    ellipse(x+w/2, y+h/2, 6, 6);
  }
}

class LineButton extends Clickable {
  
  LineButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    line(x+3, y+h-3, x+21, y+3);
  }
}

class CurveButton extends Clickable {
  
  CurveButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    bezier(x+3, y+h-3, x+21, y+h-3, x+3, y+3, x+21, y+3);
  }
}

class RectButton extends Clickable {
  
  RectButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    rect(x+3, y+3, 18, 18);
  }
}

class EllipseButton extends Clickable {
  
  EllipseButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    ellipse(x+12, y+12, 18, 18);
  }
}

class ZoomInButton extends Clickable {
  
  ZoomInButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
    line(x+10, y+6, x+10, y+14);
  }
}

class ZoomOutButton extends Clickable {
  
  ZoomOutButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, false);
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
  }
}
