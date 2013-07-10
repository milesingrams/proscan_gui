class SaveButton extends TextButton {
  SaveButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "SAVE");
  }
  
  void press() {
    if (over()) {
      saveData();
    }
  }
}

class LoadButton extends TextButton {
  LoadButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "LOAD");
  }
  
  void press() {
    if (over()) {
      loadData();
    }
  }
}

class PosButton extends TextButton {
  PosButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "POS");
  }
  
  void press() {
    if (over()) {
      addCommand(new TextCommand("PS", ""));
    }
  }
}

class ZeroButton extends TextButton {
  ZeroButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "ZERO");
  }
  
  void press() {
    if (over()) {
      addCommand(new TextCommand("Z", ""));
    }
  }
}

class StopButton extends TextButton {
  StopButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "STOP");
  }
  
  void press() {
    if (over()) {
      commandList.clear();
      addCommand(new TextCommand("K", ""));
    }
  }
}

class RunButton extends TextButton {
  RunButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "RUN");
  }
  
  void press() {
    if (over()) {
      runSequence();
    }
  }
}

class GroupButton extends TextButton {
  GroupButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "GROUP");
  }
  
  void press() {
    if (over()) {
      objSelection.group();
    }
  }
}

class UngroupButton extends TextButton {
  UngroupButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "UNGROUP");
  }
  
  void press() {
    if (over()) {
      objSelection.ungroup();
    }
  }
}

class CopyButton extends TextButton {
  CopyButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "COPY");
  }
  
  void press() {
    if (over()) {
      objSelection.copy();
    }
  }
}

class PasteButton extends TextButton {
  PasteButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "PASTE");
  }
  
  void press() {
    if (over()) {
      objSelection.paste();
    }
  }
}

class CreateButton extends TextButton {
  CreateButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "CREATE");
  }
  
  void press() {
    if (over()) {
      if (currentTool.equals("POINT")) {
        drawingList.add(new PointObj(timeText.val, x1Text.val, y1Text.val));
      } else
      if (currentTool.equals("LINE")) {
        drawingList.add(new LineObj(speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
      } else
      if (currentTool.equals("CURVE")) {
        float cx1 = x1Text.val+(x2Text.val-x1Text.val)*0.33;
        float cy1 = y1Text.val+(y2Text.val-y1Text.val)*0.33;
        float cx2 = x1Text.val+(x2Text.val-x1Text.val)*0.66;
        float cy2 = y1Text.val+(y2Text.val-y1Text.val)*0.66;
        drawingList.add(new CurveObj(timeText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val, cx1, cy1, cx2, cy2));
      } else
      if (currentTool.equals("RECT")) {
        drawingList.add(new RectObj(speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
      }
      if (currentTool.equals("ELLIPSE")) {
        drawingList.add(new EllipseObj(speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
      }
    }
  }
}

class SetButton extends TextButton {
  SetButton (int ix, int iy, int iw, int ih) {
    super(ix, iy, iw, ih, "SET");
  }
  
  void press() {
    if (over()) {
      if (currentTool.equals("ZOOMIN")) {
        stage.setPos(lowXText.val, lowYText.val, rangeXText.val);
      } else
      if (currentTool.equals("ZOOMOUT")) {
        stage.setPos(lowXText.val, lowYText.val, rangeXText.val);
      } else
      if (currentTool.equals("EDIT")) {
        objSelection.setPos(new float[]{x1Text.val, x2Text.val}, new float[]{y1Text.val, y2Text.val});
      }
    }
  }
}

class Tool extends Clickable {
  Toolbar toolbar;
  ArrayList<Interface> tools;
  int tx, ty;
  String name;
  
  Tool(int ix, int iy, String iName, Toolbar iToolbar) {
    super(ix, iy, 24, 24, false);
    name = iName;
    toolbar = iToolbar;
    tools = new ArrayList<Interface>();
  }
  
  void choose() {
    for (int i=0; i<drawingToolbar.tools.size(); i++) {
      Tool currTool = (Tool)drawingToolbar.tools.get(i);
      currTool.release();
    }
    pressed = true;
    currentTool = name;
    toolbar.setTools(tools);
    objSelection.deselect();
  }
  
  void press() {
    if (over()) {
      choose();
    }
  }
}

class PointButton extends Tool {
  
  PointButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "POINT", iToolbar);
  }
  
  void display () {
    super.display();
    fill(0);
    ellipse(x+w/2, y+h/2, 6, 6);
  }
}

class LineButton extends Tool {
  
  LineButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "LINE", iToolbar);
  }
  
  void display () {
    super.display();
    line(x+3, y+h-3, x+21, y+3);
  }
}

class CurveButton extends Tool {
  
  CurveButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "CURVE", iToolbar);
  }
  
  void display () {
    super.display();
    bezier(x+3, y+h-3, x+21, y+h-3, x+3, y+3, x+21, y+3);
  }
}

class RectButton extends Tool {
  
  RectButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "RECT", iToolbar);
  }
  
  void display () {
    super.display();
    rect(x+3, y+3, 18, 18);
  }
}

class EllipseButton extends Tool {
  
  EllipseButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "ELLIPSE", iToolbar);
  }
  
  void display () {
    super.display();
    ellipse(x+12, y+12, 18, 18);
  }
}

class ZoomInButton extends Tool {
  
  ZoomInButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "ZOOMIN", iToolbar);
  }
  
  void press() {
    super.press();
    if (over()) {
      lowXText.setVal(stage.lowX);
      lowYText.setVal(stage.lowY);
      rangeXText.setVal(stage.rangeX);
    }
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
    line(x+10, y+6, x+10, y+14);
  }
}

class ZoomOutButton extends Tool {
  
  ZoomOutButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "ZOOMOUT", iToolbar);
  }
  
  void press() {
    super.press();
    if (over()) {
      lowXText.setVal(stage.lowX);
      lowYText.setVal(stage.lowY);
      rangeXText.setVal(stage.rangeX);
    }
  }
  
  void display () {
    super.display();
    ellipse(x+10, y+10, 12, 12);
    line(x+15, y+15, x+20, y+20);
    line(x+6, y+10, x+14, y+10);
  }
}

class EditButton extends Tool {
  
  EditButton (int ix, int iy, Toolbar iToolbar) {
    super(ix, iy, "EDIT", iToolbar);
  }
  
  void display () {
    super.display();
    fill(255);
    beginShape();
    vertex(x+4, y+4);
    vertex(x+19, y+9);
    vertex(x+15, y+13);
    vertex(x+21, y+19);
    vertex(x+19, y+21);
    vertex(x+13, y+15);
    vertex(x+9, y+19);
    endShape(CLOSE);
  }
}
