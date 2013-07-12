class Tool {
  ArrayList<Interface> chooser;
  Clickable button;
  boolean beginPress = false;
  
  Tool() {
    chooser = new ArrayList<Interface>();
  }
  
  void activate() {
    button.press();
    if (currentTool != null) {
      currentTool.deactivate();
    }
    currentTool = this;
    chooserToolbar.setTools(chooser);
  }
  
  void deactivate() {
    button.release();  
  }
  
  void press() {
    if (button.over()) {
      activate();
    } else
    if (miniStage.mouseOver() == false) {
      if (currentTool == this && mainStage.mouseOver()) {
        beginPress = true;
        stagePress();
      }
    }
  }
  
  void drag() {
    if (beginPress) {
      if (currentTool == this) {
        stageDrag();
      }
    }
  }
  
  void release() {
    if (beginPress) {
      if (currentTool == this) {
        stageRelease();
      }
    }
    beginPress = false;
  }
  
  void keyPress() {
  }
  
  void stagePress() {
  }
  
  void stageDrag() {
  }
  
  void stageRelease() {
  }
}


class PointTool extends Tool {
  
  TextBox timeText;
  Slider timeSlider;
  TextBox xText;
  TextBox yText;
  TextButton createButton;
  
  PointTool () {
    super();
    button = new PointButton();
    
    timeText = new TextBox(0, 0, 120, 24, "Time (s): ", 0, new Create());
    timeSlider = new Slider(0, 0, 159, 24, maxTime, "Time", "%.1f", timeText);
    xText = new TextBox(0, 0, 100, 24, "x: ", 0, new Create());
    yText = new TextBox(0, 0, 100, 24, "y: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(timeSlider);
    chooser.add(timeText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(createButton);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new PointObj(timeText.val, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[0] = localX;
    currentDraw.yCoords[0] = localY;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[0] = localX;
    currentDraw.yCoords[0] = localY;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    timeText.type();
    xText.type();
    yText.type();
  }
  
  class PointButton extends Clickable {
    PointButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      fill(0);
      ellipse(x+w/2, y+h/2, 6, 6);
    }
  }
  
  class Create implements Action {
    void run() {
      drawingList.add(new PointObj(timeText.val, xText.val, yText.val));
    }
  }
}


class LineTool extends Tool {
  
  TextBox speedText;
  Slider speedSlider;
  TextBox x1Text;
  TextBox y1Text;
  TextBox x2Text;
  TextBox y2Text;
  TextButton createButton;
  
  LineTool () {
    super();
    button = new LineButton();
    
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new Create());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    x1Text = new TextBox(0, 0, 100, 24, "x1: ", 0, new Create());
    y1Text = new TextBox(0, 0, 100, 24, "y1: ", 0, new Create());
    x2Text = new TextBox(0, 0, 100, 24, "x2: ", 0, new Create());
    y2Text = new TextBox(0, 0, 100, 24, "y2: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(x1Text);
    chooser.add(y1Text);
    chooser.add(x2Text);
    chooser.add(y2Text);
    chooser.add(createButton);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new LineObj(speedText.val, localX, localY, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    speedText.type();
    x1Text.type();
    y1Text.type();
    x2Text.type();
    y2Text.type();
  }
  
  class LineButton extends Clickable {
    LineButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      line(x+3, y+h-3, x+21, y+3);
    }
  }
  
  class Create implements Action {
    void run() {
      drawingList.add(new LineObj(speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
    }
  }
}


class CurveTool extends Tool {
  
  TextBox speedText;
  Slider speedSlider;
  TextBox detailText;
  TextBox x1Text;
  TextBox y1Text;
  TextBox x2Text;
  TextBox y2Text;
  TextButton createButton;
  
  CurveTool () {
    super();
    button = new CurveButton();
    
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new Create());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    detailText = new TextBox(0, 0, 100, 24, "Detail: ", 0, new Create());
    x1Text = new TextBox(0, 0, 100, 24, "x1: ", 0, new Create());
    y1Text = new TextBox(0, 0, 100, 24, "y1: ", 0, new Create());
    x2Text = new TextBox(0, 0, 100, 24, "x2: ", 0, new Create());
    y2Text = new TextBox(0, 0, 100, 24, "y2: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(detailText);
    chooser.add(x1Text);
    chooser.add(y1Text);
    chooser.add(x2Text);
    chooser.add(y2Text);
    chooser.add(createButton);
    
    detailText.setVal(12);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new CurveObj(int(detailText.val), speedText.val, localX, localY, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.xCoords[2] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.33;
    currentDraw.yCoords[2] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.33;
    currentDraw.xCoords[3] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.66;
    currentDraw.yCoords[3] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.66;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.xCoords[2] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.33;
    currentDraw.yCoords[2] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.33;
    currentDraw.xCoords[3] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.66;
    currentDraw.yCoords[3] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.66;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    speedText.type();
    detailText.type();
    x1Text.type();
    y1Text.type();
    x2Text.type();
    y2Text.type();
  }
  
  class CurveButton extends Clickable {
    CurveButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      bezier(x+3, y+h-3, x+21, y+h-3, x+3, y+3, x+21, y+3);
    }
  }
  
  class Create implements Action {
    void run() {
      drawingList.add(new CurveObj(int(detailText.val), speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
    }
  }
}


class RectTool extends Tool {
  
  TextBox speedText;
  Slider speedSlider;
  TextBox xText;
  TextBox yText;
  TextBox wText;
  TextBox hText;
  TextButton createButton;
  
  RectTool () {
    super();
    button = new RectButton();
    
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new Create());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    xText = new TextBox(0, 0, 100, 24, "x: ", 0, new Create());
    yText = new TextBox(0, 0, 100, 24, "y: ", 0, new Create());
    wText = new TextBox(0, 0, 100, 24, "w: ", 0, new Create());
    hText = new TextBox(0, 0, 100, 24, "h: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(createButton);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new RectObj(speedText.val, localX, localY, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    speedText.type();
    xText.type();
    yText.type();
    wText.type();
    hText.type();
  }
  
  class RectButton extends Clickable { 
    RectButton () {
      super(0, 0, 24, 24, false);
    }

    void display () {
      super.display();
      rect(x+3, y+3, 18, 18);
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      drawingList.add(new RectObj(speedText.val, xText.val, yText.val, x2, y2));
    }
  }
}


class EllipseTool extends Tool {
  
  TextBox speedText;
  Slider speedSlider;
  TextBox detailText;
  TextBox xText;
  TextBox yText;
  TextBox wText;
  TextBox hText;
  TextButton createButton;
  
  EllipseTool () {
    super();
    button = new EllipseButton();
    
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new Create());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    detailText = new TextBox(0, 0, 100, 24, "Detail: ", 0, new Create());
    xText = new TextBox(0, 0, 100, 24, "x: ", 0, new Create());
    yText = new TextBox(0, 0, 100, 24, "y: ", 0, new Create());
    wText = new TextBox(0, 0, 100, 24, "w: ", 0, new Create());
    hText = new TextBox(0, 0, 100, 24, "h: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(detailText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(createButton);
    
    detailText.setVal(3);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new EllipseObj(int(detailText.val), speedText.val, localX, localY, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    speedText.type();
    detailText.type();
    xText.type();
    yText.type();
    wText.type();
    hText.type();
  }
  
  class EllipseButton extends Clickable {
    EllipseButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      ellipse(x+12, y+12, 18, 18);
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      drawingList.add(new EllipseObj(int(detailText.val), speedText.val, xText.val, yText.val, x2, y2));
    }
  }
}


class FillTool extends Tool {
  
  TextBox speedText;
  Slider speedSlider;
  TextButton hButton;
  TextButton vButton;
  TextBox spacingText;
  TextBox xText;
  TextBox yText;
  TextBox wText;
  TextBox hText;
  TextButton createButton;
  boolean horizontal = true;
  boolean vertical = false;
  
  FillTool () {
    super();
    button = new FillButton();
    
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new Create());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    hButton = new TextButton(0, 0, 0, 24, "H", new SetH());
    vButton = new TextButton(0, 0, 0, 24, "V", new SetV());
    spacingText = new TextBox(0, 0, 120, 24, "Spacing: ", 0, new Create());
    xText = new TextBox(0, 0, 100, 24, "x: ", 0, new Create());
    yText = new TextBox(0, 0, 100, 24, "y: ", 0, new Create());
    wText = new TextBox(0, 0, 100, 24, "w: ", 0, new Create());
    hText = new TextBox(0, 0, 100, 24, "h: ", 0, new Create());
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(hButton);
    chooser.add(vButton);
    chooser.add(spacingText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(createButton);
    
    hButton.basecolor = color(190);
    spacingText.setVal(10);
  }
  
  void stagePress() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw = new FillObj(speedText.val, horizontal, vertical, spacingText.val, localX, localY, localX, localY);
  }
  
  void stageDrag() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void stageRelease() {
    float localX = toGrid(mainStage.globalToLocalX(mouseX));
    float localY = toGrid(mainStage.globalToLocalY(mouseY));
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    speedText.type();
    spacingText.type();
    xText.type();
    yText.type();
    wText.type();
    hText.type();
  }
  
  class FillButton extends Clickable {
    FillButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      line(x+4, y+4, x+20, y+4);
      line(x+4, y+7, x+20, y+7);
      line(x+4, y+10, x+20, y+10);
      line(x+4, y+13, x+20, y+13);
      line(x+4, y+16, x+20, y+16);
      line(x+4, y+19, x+20, y+19);
    }
  }
  
  class SetH implements Action {
    void run() {
      if (horizontal == false) {
        horizontal = true;
        hButton.basecolor = color(190);
      } else {
        horizontal = false;
        hButton.basecolor = color(230);
      }
    }
  }
  
  class SetV implements Action {
    void run() {
      if (vertical == false) {
        fillTool.vertical = true;
        fillTool.vButton.basecolor = color(190);
      } else {
        fillTool.vertical = false;
        fillTool.vButton.basecolor = color(230);
      }
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      drawingList.add(new FillObj(speedText.val, horizontal, vertical, spacingText.val, xText.val, yText.val, x2, y2));
    }
  }
}


class ZoomInTool extends Tool {
  
  TextBox midXText;
  TextBox midYText;
  TextBox rangeXText;
  TextButton setButton;
  
  ZoomInTool () {
    super();
    button = new ZoomInButton();
    
    midYText = new TextBox(0, 0, 150, 24, "Mid x: ", 0, new Set());
    midXText = new TextBox(0, 0, 150, 24, "Mid y: ", 0, new Set());
    rangeXText = new TextBox(0, 0, 150, 24, "Range x: ", 0, new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(midYText);
    chooser.add(midXText);
    chooser.add(rangeXText);
    chooser.add(setButton);
    
    setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
  }
  
  void stagePress() {
    float localX = mainStage.globalToLocalX(mouseX);
    float localY = mainStage.globalToLocalY(mouseY);
    mainStage.setZoom(localX, localY, 0.5);
    setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
  }
  
  void keyPress() {
    midXText.type();
    midYText.type();
    rangeXText.type();
  }
  
  void setVals(float mx, float my, float rx) {
    midXText.setVal(mx);
    midYText.setVal(my);
    rangeXText.setVal(rx);
  }
  
  class ZoomInButton extends Clickable {
    ZoomInButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      ellipse(x+10, y+10, 12, 12);
      line(x+15, y+15, x+20, y+20);
      line(x+6, y+10, x+14, y+10);
      line(x+10, y+6, x+10, y+14);
    }
  }
  
  class Set implements Action {
    void run() {
      mainStage.setPos(midXText.val, midYText.val, rangeXText.val);
    }
  }
}


class ZoomOutTool extends Tool {
  
  TextBox midXText;
  TextBox midYText;
  TextBox rangeXText;
  TextButton setButton;
  
  ZoomOutTool () {
    super();
    button = new ZoomOutButton();
    
    midYText = new TextBox(0, 0, 150, 24, "Mid x: ", 0, new Set());
    midXText = new TextBox(0, 0, 150, 24, "Mid y: ", 0, new Set());
    rangeXText = new TextBox(0, 0, 150, 24, "Range x: ", 0, new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(midYText);
    chooser.add(midXText);
    chooser.add(rangeXText);
    chooser.add(setButton);
    
    setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
  }
  
  void stagePress() {
    float localX = mainStage.globalToLocalX(mouseX);
    float localY = mainStage.globalToLocalY(mouseY);
    mainStage.setZoom(localX, localY, 2);
    setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
  }
  
  void keyPress() {
    midXText.type();
    midYText.type();
    rangeXText.type();
  }
  
  void setVals(float mx, float my, float rx) {
    midXText.setVal(mx);
    midYText.setVal(my);
    rangeXText.setVal(rx);
  }
  
  class ZoomOutButton extends Clickable {
    ZoomOutButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      ellipse(x+10, y+10, 12, 12);
      line(x+15, y+15, x+20, y+20);
      line(x+6, y+10, x+14, y+10);
    }
  }
  
  class Set implements Action {
    void run() {
      mainStage.setPos(midXText.val, midYText.val, rangeXText.val);
    }
  }
}


class EditTool extends Tool {
  
  TextBox xText;
  TextBox yText;
  TextBox wText;
  TextBox hText;
  TextBox speedText;
  TextBox timeText;
  TextButton setButton;
  TextButton groupButton;
  TextButton ungroupButton;
  TextButton copyButton;
  TextButton pasteButton;
  TextButton deleteButton;
  boolean selecting;
  float beginSelectX;
  float beginSelectY;
  
  EditTool () {
    super();
    button = new EditButton();
    
    xText = new TextBox(0, 0, 100, 24, "x: ", 0, new Set());
    yText = new TextBox(0, 0, 100, 24, "y: ", 0, new Set());
    wText = new TextBox(0, 0, 100, 24, "w: ", 0, new Set());
    hText = new TextBox(0, 0, 100, 24, "h: ", 0, new Set());
    speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0, new SetSpeed());
    timeText = new TextBox(0, 0, 120, 24, "Time (s): ", 0, new SetTime());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    groupButton = new TextButton(0, 0, 0, 24, "GROUP", new Group());
    ungroupButton = new TextButton(0, 0, 0, 24, "UNGROUP", new Ungroup());
    copyButton = new TextButton(0, 0, 0, 24, "COPY", new Copy());
    pasteButton = new TextButton(0, 0, 0, 24, "PASTE", new Paste());
    deleteButton = new TextButton(0, 0, 0, 24, "DELETE", new Delete());
    
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(speedText);
    chooser.add(timeText);
    chooser.add(setButton);
    chooser.add(groupButton);
    chooser.add(ungroupButton);
    chooser.add(copyButton);
    chooser.add(pasteButton);
    chooser.add(deleteButton);
  }
  
  void deactivate() {
    super.deactivate();
    objSelection.deselect();
  }
  
  void stagePress() {
    objSelection.press();
    for (int i=0; i<objSelection.objs.size(); i++) {
      objSelection.objs.get(i).press();
    }
    if (dragging == false) {
      beginSelectX = mainStage.globalToLocalX(mouseX);
      beginSelectY = mainStage.globalToLocalY(mouseY);
      selecting = true;
    }
  }
  
  void stageRelease() {
    objSelection.release();
    if (selecting) {
      if (!(keyPressed && keyCode == SHIFT)) {
        objSelection.deselect();
      }
      ArrayList<DrawingObj> tempObjs = new ArrayList<DrawingObj>();
      for (int i=0; i<drawingList.size(); i++) {
        DrawingObj currObj = drawingList.get(i);
        if (currObj.inBounds(beginSelectX, beginSelectY, mainStage.globalToLocalX(mouseX), mainStage.globalToLocalY(mouseY))) {
          if (currObj.selected == false) {
            tempObjs.add(currObj);
          }
        }
      }
      if (tempObjs.size() > 0) {
        objSelection.insert(tempObjs);
      }
      selecting = false;
    }
  }
  
  void keyPress() {
    xText.type();
    yText.type();
    wText.type();
    hText.type();
    speedText.type();
    timeText.type();
    if (!(xText.selected || yText.selected || wText.selected || hText.selected || speedText.selected || timeText.selected)) {
      if (keyCode == BACKSPACE) {
        objSelection.delete();
      }
    }
  }
  
  void setVals(float x, float y, float w, float h) {
    xText.setVal(x);
    yText.setVal(y);
    wText.setVal(w);
    hText.setVal(h);
  }
  
  void display() {
    if (selecting) {
      stroke(0, 255, 0);
      noFill();
      int lx = mainStage.localToGlobalX(beginSelectX);
      int ly = mainStage.localToGlobalY(beginSelectY);
      rect(lx, ly, mouseX-lx, mouseY-ly);
    }
  }
  
  class EditButton extends Clickable {
    EditButton () {
      super(0, 0, 24, 24, false);
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
  
  class Set implements Action {
    void run() {
      float x2 = xText.val + wText.val;
      float y2 = yText.val + hText.val;
      objSelection.setPos(new float[]{xText.val, x2}, new float[]{yText.val, y2});
    }
  }
  
  class SetTime implements Action {
    void run() {
      float time = timeText.val;
      objSelection.setTime(time);
    }
  }
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class Group implements Action {
    void run() {
      objSelection.group();
    }
  }
  
  class Ungroup implements Action {
    void run() {
      objSelection.ungroup();
    }
  }
  
  class Copy implements Action {
    void run() {
      objSelection.copy();
    }
  }
  
  class Paste implements Action {
    void run() {
      objSelection.paste();
    }
  }
  
  class Delete implements Action {
    void run() {
      objSelection.delete();
    }
  }
}


class SettingsTool extends Tool {
  
  TextBox gridText;
  TextButton setButton;
  
  SettingsTool () {
    super();
    button = new TextButton(0, 0, 0, 24, "SETTINGS", null);
    
    gridText = new TextBox(0, 0, 150, 24, "Grid Size: ", 0, new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(gridText);
    chooser.add(setButton);
    
    gridText.setVal(gridSize);
  }
  
  void keyPress() {
    gridText.type();
  }
  
  class Set implements Action {
    void run() {
      gridSize = gridText.val;
    }
  }
}