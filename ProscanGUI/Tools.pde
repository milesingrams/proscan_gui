class Tool {
  ArrayList<Interface> chooser;
  Clickable button;
  
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
  
  void press() {}
  
  void drag() {}
  
  void release() {}
  
  void keyPress(){}
  
}

class MoveTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  TextButton shutButton;
  NumberBox xText;
  NumberBox yText;
  TextButton moveButton;
  
  MoveTool () {
    super();
    button = new MoveButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    shutButton = new TextButton(0, 0, 0, 24, "SHUTTER XXX", new SetShut());
    xText = new NumberBox(0, 0, 100, 24, "x: ", new Move());
    yText = new NumberBox(0, 0, 100, 24, "y: ", new Move());
    moveButton = new TextButton(0, 0, 0, 24, "MOVE", new Move());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(shutButton);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(moveButton);
    
    if (shutter == false) {
        shutButton.text = "SHUTTER ON";
        shutButton.basecolor = color(190);
      } else {
        shutButton.text = "SHUTTER OFF";
        shutButton.basecolor = color(230);
      }
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
  }
  
  class MoveButton extends Clickable {
    MoveButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      noFill();
      stroke(0);
      line(x+4, y+4, x+20, y+20);
      line(x+4, y+20, x+20, y+4);
      line(x+4, y+4, x+8, y+4);
      line(x+4, y+4, x+4, y+8);
      line(x+20, y+4, x+16, y+4);
      line(x+20, y+4, x+20, y+8);
      line(x+20, y+20, x+16, y+20);
      line(x+20, y+20, x+20, y+16);
      line(x+4, y+20, x+8, y+20);
      line(x+4, y+20, x+4, y+16);
      
    }
  }
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class SetShut implements Action {
    void run() {
      if (shutter == false) {
        setShutter(true);
        shutButton.text = "SHUTTER ON";
        shutButton.basecolor = color(190);
      } else {
        setShutter(false);
        shutButton.text = "SHUTTER OFF";
        shutButton.basecolor = color(230);
      }
    }
  }
  
  class Move implements Action {
    void run() {
      float dx = xText.val;
      float dy = yText.val;
      addCommand(new SpeedCommand(speedText.val));
      addCommand(new MoveCommand(dx, dy, shutter));
    }
  }
}

class PointTool extends Tool {
  
  NumberBox timeText;
  Slider timeSlider;
  TextButton shutButton;
  NumberBox xText;
  NumberBox yText;
  TextButton createButton;
  boolean shut = true;
  
  PointTool () {
    super();
    button = new PointButton();
    
    timeText = new NumberBox(0, 0, 120, 24, "Time (s): ", new SetTime());
    timeSlider = new Slider(0, 0, 159, 24, maxTime, "Time", "%.1f", timeText);
    shutButton = new TextButton(0, 0, 0, 24, "SHUTTER ON", new SetShut());
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(timeSlider);
    chooser.add(timeText);
    chooser.add(shutButton);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(createButton);
    
    shutButton.basecolor = color(190);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new PointObj(timeText.val, shut, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[0] = localX;
    currentDraw.yCoords[0] = localY;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[0] = localX;
    currentDraw.yCoords[0] = localY;
    setLastState();
    drawingList.add(currentDraw);
    currentDraw = null;
  }
  
  void keyPress() {
    timeSlider.setVal(timeText.val);
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
  
  class SetShut implements Action {
    void run() {
      if (shut == false) {
        shut = true;
        shutButton.text = "SHUTTER ON";
        shutButton.basecolor = color(190);
      } else {
        shut = false;
        shutButton.text = "SHUTTER OFF";
        shutButton.basecolor = color(230);
      }
    }
  }
  
  class SetTime implements Action {
    void run() {
      float time = timeText.val;
      objSelection.setTime(time);
    }
  }
  
  class Create implements Action {
    void run() {
      setLastState();
      drawingList.add(new PointObj(timeText.val, shut, xText.val, yText.val));
    }
  }
}


class LineTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  NumberBox x1Text;
  NumberBox y1Text;
  NumberBox x2Text;
  NumberBox y2Text;
  TextButton createButton;
  
  LineTool () {
    super();
    button = new LineButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    x1Text = new NumberBox(0, 0, 100, 24, "x1: ", null);
    y1Text = new NumberBox(0, 0, 100, 24, "y1: ", null);
    x2Text = new NumberBox(0, 0, 100, 24, "x2: ", null);
    y2Text = new NumberBox(0, 0, 100, 24, "y2: ", null);
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(x1Text);
    chooser.add(y1Text);
    chooser.add(x2Text);
    chooser.add(y2Text);
    chooser.add(createButton);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new LineObj(speedText.val, localX, localY, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    if (!(currentDraw.xCoords[0] == currentDraw.xCoords[1] && currentDraw.yCoords[0] == currentDraw.yCoords[1])) {
      setLastState();
      drawingList.add(currentDraw);
    }
    currentDraw = null;
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
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
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class Create implements Action {
    void run() {
      setLastState();
      drawingList.add(new LineObj(speedText.val, x1Text.val, y1Text.val, x2Text.val, y2Text.val));
    }
  }
}


class CurveTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  NumberBox detailText;
  NumberBox x1Text;
  NumberBox y1Text;
  NumberBox x2Text;
  NumberBox y2Text;
  TextButton createButton;
  
  CurveTool () {
    super();
    button = new CurveButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    detailText = new NumberBox(0, 0, 100, 24, "Detail: ", new SetDetail());
    x1Text = new NumberBox(0, 0, 100, 24, "x1: ", null);
    y1Text = new NumberBox(0, 0, 100, 24, "y1: ", null);
    x2Text = new NumberBox(0, 0, 100, 24, "x2: ", null);
    y2Text = new NumberBox(0, 0, 100, 24, "y2: ", null);
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
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new CurveObj(speedText.val, int(detailText.val), localX, localY, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.xCoords[2] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.33;
    currentDraw.yCoords[2] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.33;
    currentDraw.xCoords[3] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.66;
    currentDraw.yCoords[3] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.66;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.xCoords[2] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.33;
    currentDraw.yCoords[2] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.33;
    currentDraw.xCoords[3] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.66;
    currentDraw.yCoords[3] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.66;
    if (!(currentDraw.xCoords[0] == currentDraw.xCoords[1] && currentDraw.yCoords[0] == currentDraw.yCoords[1])) {
      setLastState();
      drawingList.add(currentDraw);
    }
    currentDraw = null;
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
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
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class SetDetail implements Action {
    void run() {
      int detail = int(detailText.val);
      objSelection.setDetail(detail);
    }
  }
  
  class Create implements Action {
    void run() {
      setLastState();
      drawingList.add(new CurveObj(speedText.val, int(detailText.val), x1Text.val, y1Text.val, x2Text.val, y2Text.val));
    }
  }
}


class RectTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
  TextButton createButton;
  
  RectTool () {
    super();
    button = new RectButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    wText = new NumberBox(0, 0, 100, 24, "w: ", null);
    hText = new NumberBox(0, 0, 100, 24, "h: ", null);
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(createButton);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new RectObj(speedText.val, localX, localY, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    if (!(currentDraw.xCoords[0] == currentDraw.xCoords[1] && currentDraw.yCoords[0] == currentDraw.yCoords[1])) {
      setLastState();
      drawingList.add(currentDraw);
    }
    currentDraw = null;
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
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
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      setLastState();
      drawingList.add(new RectObj(speedText.val, xText.val, yText.val, x2, y2));
    }
  }
}


class EllipseTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  NumberBox detailText;
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
  TextButton createButton;
  
  EllipseTool () {
    super();
    button = new EllipseButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    detailText = new NumberBox(0, 0, 100, 24, "Detail: ", new SetDetail());
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    wText = new NumberBox(0, 0, 100, 24, "w: ", null);
    hText = new NumberBox(0, 0, 100, 24, "h: ", null);
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(detailText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(createButton);
    
    detailText.setVal(12);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new EllipseObj(speedText.val, int(detailText.val), localX, localY, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    if (!(currentDraw.xCoords[0] == currentDraw.xCoords[1] && currentDraw.yCoords[0] == currentDraw.yCoords[1])) {
      setLastState();
      drawingList.add(currentDraw);
    }
    currentDraw = null;
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
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
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class SetDetail implements Action {
    void run() {
      int detail = int(detailText.val);
      objSelection.setDetail(detail);
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      setLastState();
      drawingList.add(new EllipseObj(speedText.val, int(detailText.val), xText.val, yText.val, x2, y2));
    }
  }
}


class FillTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  TextButton hButton;
  TextButton vButton;
  NumberBox spacingText;
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
  TextButton createButton;
  boolean horizontal = true;
  boolean vertical = false;
  
  FillTool () {
    super();
    button = new FillButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    hButton = new TextButton(0, 0, 0, 24, "H", new SetH());
    vButton = new TextButton(0, 0, 0, 24, "V", new SetV());
    spacingText = new NumberBox(0, 0, 120, 24, "Spacing: ", new SetSpacing());
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    wText = new NumberBox(0, 0, 100, 24, "w: ", null);
    hText = new NumberBox(0, 0, 100, 24, "h: ", null);
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
  
  void press() {
   if (objSelection.selected) {
      objSelection.deselect();
    }
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw = new FillObj(speedText.val, horizontal, vertical, spacingText.val, localX, localY, localX, localY);
  }
  
  void drag() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    currentDraw.updatePos();
  }
  
  void release() {
    float localX = toGrid(mainWindow.localMouseX());
    float localY = toGrid(mainWindow.localMouseY());
    currentDraw.xCoords[1] = localX;
    currentDraw.yCoords[1] = localY;
    if (!(currentDraw.xCoords[0] == currentDraw.xCoords[1] && currentDraw.yCoords[0] == currentDraw.yCoords[1])) {
      setLastState();
      drawingList.add(currentDraw);
    }
    currentDraw = null;
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
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
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
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
        vertical = true;
        vButton.basecolor = color(190);
      } else {
        vertical = false;
        vButton.basecolor = color(230);
      }
    }
  }
  
  class SetSpacing implements Action {
    void run() {
      float spacing = spacingText.val;
      objSelection.setSpacing(spacing);
    }
  }
  
  class Create implements Action {
    void run() {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      setLastState();
      drawingList.add(new FillObj(speedText.val, horizontal, vertical, spacingText.val, xText.val, yText.val, x2, y2));
    }
  }
}

class LetterTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  NumberBox xText;
  NumberBox yText;
  NumberBox hText;
  TextBox textText;
  TextButton createButton;
  
  LetterTool () {
    super();
    button = new LetterButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    hText = new NumberBox(0, 0, 100, 24, "h: ", null);
    textText = new TextBox(0, 0, 200, 24, "Text: ", null);
    createButton = new TextButton(0, 0, 0, 24, "CREATE", new Create());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(hText);
    chooser.add(textText);
    chooser.add(createButton);
    
    hText.setVal(22);
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
  }
  
  class LetterButton extends Clickable {
    LetterButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
      fill(0);
      text("abc", x+2, y+17);
    }
  }
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
    }
  }
  
  class Create implements Action {
    void run() {
      setLastState();
      float th = hText.val;
      float tx = xText.val;
      float ty = yText.val;
      float spaceW = th/2;
      for (int i=0; i<textText.text.length(); i++) {
        char character = textText.text.charAt(i);
        if (character == ' ') {
          tx += spaceW;
        } else {
          String[] strings = loadStrings(sketchPath("")+"/Macros/Typography/"+character+".txt");
          GroupObj letterObj = (GroupObj)parseStrings(strings).get(0);
          float scaleRatio = letterObj.w/letterObj.h;
          float letterW = th*scaleRatio;
          letterObj.setPos(new float[]{0, letterW}, new float[]{0, th});
          letterObj.translate(tx, ty);
          tx += letterObj.w + spaceW/2;
          drawingList.add(letterObj);
        }
      }
    }
  }
}

public class ScanImageTool extends Tool {
  
  NumberBox speedText;
  Slider speedSlider;
  TextButton hButton;
  TextButton vButton;
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
  TextButton loadScanButton;
  boolean horizontal = true;
  boolean vertical = false;
  
  ScanImageTool () {
    super();
    button = new ScanImageButton();
    
    speedText = new NumberBox(0, 0, 160, 24, "Speed (um/s): ", new SetSpeed());
    speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
    hButton = new TextButton(0, 0, 0, 24, "H", new SetH());
    vButton = new TextButton(0, 0, 0, 24, "V", new SetV());
    xText = new NumberBox(0, 0, 100, 24, "x: ", null);
    yText = new NumberBox(0, 0, 100, 24, "y: ", null);
    wText = new NumberBox(0, 0, 100, 24, "w: ", null);
    hText = new NumberBox(0, 0, 100, 24, "h: ", null);
    loadScanButton = new TextButton(0, 0, 0, 24, "LOAD SCAN", new LoadScan());
    
    chooser.add(speedSlider);
    chooser.add(speedText);
    chooser.add(hButton);
    chooser.add(vButton);
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(loadScanButton);
    
    hButton.basecolor = color(190);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
  }
  
  void keyPress() {
    speedSlider.setVal(speedText.val);
  }
  
  class ScanImageButton extends Clickable { 
    ScanImageButton () {
      super(0, 0, 24, 24, false);
    }

    void display () {
      super.display();
      rect(x+3, y+3, 18, 18);
      line(x+3, y+8, x+8, y+3);
      line(x+21, y+8, x+16, y+3);
      line(x+21, y+16, x+16, y+21);
      line(x+3, y+16, x+8, y+21);
      line(x+8, y+8, x+16, y+8);
      line(x+8, y+10, x+16, y+10);
      line(x+8, y+12, x+16, y+12);
      line(x+8, y+14, x+16, y+14);
      line(x+8, y+16, x+16, y+16);
    }
  }
  
  public void loadScan(File file) {
    if (file != null) {
      float speed = speedText.val;
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      setLastState();
      drawingList.add(new ScanImage(speed, file.getPath(), horizontal, vertical, xText.val, yText.val, x2, y2));
    }
  }
  
  class SetSpeed implements Action {
    void run() {
      float speed = speedText.val;
      objSelection.setSpeed(speed);
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
        vertical = true;
        vButton.basecolor = color(190);
      } else {
        vertical = false;
        vButton.basecolor = color(230);
      }
    }
  }
  
  class LoadScan implements Action {
    void run() {
      selectInput("Load Image", "loadScan", null, ScanImageTool.this);
    }
  }
}


public class BGImageTool extends Tool {
  
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
  TextButton setButton;
  TextButton loadBGButton;
  TextButton deleteBGButton;
  boolean selecting;
  
  BGImageTool () {
    super();
    button = new BGImageButton();
    
    xText = new NumberBox(0, 0, 100, 24, "x: ", new Set());
    yText = new NumberBox(0, 0, 100, 24, "y: ", new Set());
    wText = new NumberBox(0, 0, 100, 24, "w: ", new Set());
    hText = new NumberBox(0, 0, 100, 24, "h: ", new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    loadBGButton = new TextButton(0, 0, 0, 24, "LOAD BG", new LoadBG());
    deleteBGButton = new TextButton(0, 0, 0, 24, "DELETE BG", new DeleteBG());
    
    chooser.add(xText);
    chooser.add(yText);
    chooser.add(wText);
    chooser.add(hText);
    chooser.add(setButton);
    chooser.add(loadBGButton);
    chooser.add(deleteBGButton);
  }
  
  void activate() {
    super.activate();
    if (backgroundImage != null) {
      backgroundImage.select();
      backgroundImage.updatePos();
    }
  }
  
  void deactivate() {
    super.deactivate();
    if (backgroundImage != null) {
      backgroundImage.deselect();
    }
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
    if (backgroundImage == null) {
      selecting = true;
      float x1 = toGrid(mainWindow.localMouseX());
      float y1 = toGrid(mainWindow.localMouseY());
      xText.setVal(x1);
      yText.setVal(y1);
    } else {
      backgroundImage.press();
    }
  }
  
  void drag() {
    if (selecting) {
      float x2 = toGrid(mainWindow.localMouseX());
      float y2 = toGrid(mainWindow.localMouseY());
      wText.setVal(x2-xText.val);
      hText.setVal(y2-yText.val);
    }
  }
  
  void release() {
    if (backgroundImage == null) {
      selecting = false;
      float x2 = toGrid(mainWindow.localMouseX());
      float y2 = toGrid(mainWindow.localMouseY());
      wText.setVal(x2-xText.val);
      hText.setVal(y2-yText.val);
      selectInput("Load Image", "loadBG", null, BGImageTool.this);
    } else {
      backgroundImage.release();
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
      stroke(200);
      noFill();
      int px1 = mainWindow.localToGlobalX(xText.val);
      int py1 = mainWindow.localToGlobalY(yText.val);
      int px2 = mainWindow.localToGlobalX(xText.val+wText.val);
      int py2 = mainWindow.localToGlobalY(yText.val+hText.val);
      rect(px1, py1, px2-px1, py2-py1);
    }
  }
  
  class BGImageButton extends Clickable { 
    BGImageButton () {
      super(0, 0, 24, 24, false);
    }

    void display () {
      super.display();
      rect(x+3, y+3, 18, 18);
      line(x+3, y+8, x+8, y+3);
      line(x+21, y+8, x+16, y+3);
      line(x+21, y+16, x+16, y+21);
      line(x+3, y+16, x+8, y+21);
      fill(0);
      text("B", x+9, y+17);
    }
  }
  
  public void loadBG(File file) {
    if (file != null) {
      float x2 = xText.val+wText.val;
      float y2 = yText.val+hText.val;
      backgroundImage = new BackgroundImage(file.getPath(), xText.val, yText.val, x2, y2);
      backgroundImage.select();
    }
  }
  
  class Set implements Action {
    void run() {
      if (backgroundImage != null) {
        float x2 = xText.val+wText.val;
        float y2 = yText.val+hText.val;
        backgroundImage.setPos(new float[]{xText.val, x2}, new float[]{yText.val, y2});
      }
    }
  }
  
  class LoadBG implements Action {
    void run() {
      selectInput("Load Image", "loadBG", null, BGImageTool.this);
    }
  }
  
  class DeleteBG implements Action {
    void run() {
      backgroundImage = null;
    }
  }
}


class ZoomInTool extends Tool {
  
  NumberBox midXText;
  NumberBox midYText;
  NumberBox rangeXText;
  TextButton setButton;
  
  ZoomInTool () {
    super();
    button = new ZoomInButton();
    
    midYText = new NumberBox(0, 0, 150, 24, "Mid x: ", new Set());
    midXText = new NumberBox(0, 0, 150, 24, "Mid y: ", new Set());
    rangeXText = new NumberBox(0, 0, 150, 24, "Range x: ", new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(midYText);
    chooser.add(midXText);
    chooser.add(rangeXText);
    chooser.add(setButton);
    
    setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
  }
  
  void press() {
    float localX = mainWindow.localMouseX();
    float localY = mainWindow.localMouseY();
    mainWindow.setZoom(localX, localY, 0.5);
    setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
    if (objSelection.selected) {
      objSelection.updatePos();
    }
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
      mainWindow.setPos(midXText.val, midYText.val);
      mainWindow.setRangeX(rangeXText.val);
    }
  }
}


class ZoomOutTool extends Tool {
  
  NumberBox midXText;
  NumberBox midYText;
  NumberBox rangeXText;
  TextButton setButton;
  
  ZoomOutTool () {
    super();
    button = new ZoomOutButton();
    
    midYText = new NumberBox(0, 0, 150, 24, "Mid x: ", new Set());
    midXText = new NumberBox(0, 0, 150, 24, "Mid y: ", new Set());
    rangeXText = new NumberBox(0, 0, 150, 24, "Range x: ", new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(midYText);
    chooser.add(midXText);
    chooser.add(rangeXText);
    chooser.add(setButton);
    
    setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
  }
  
  void press() {
    float localX = mainWindow.localMouseX();
    float localY = mainWindow.localMouseY();
    mainWindow.setZoom(localX, localY, 2);
    setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
    if (objSelection.selected) {
      objSelection.updatePos();
    }
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
      mainWindow.setPos(midXText.val, midYText.val);
      mainWindow.setRangeX(rangeXText.val);
    }
  }
}




class EditTool extends Tool {
  
  NumberBox xText;
  NumberBox yText;
  NumberBox wText;
  NumberBox hText;
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
    
    xText = new NumberBox(0, 0, 100, 24, "x: ", new Set());
    yText = new NumberBox(0, 0, 100, 24, "y: ", new Set());
    wText = new NumberBox(0, 0, 100, 24, "w: ", new Set());
    hText = new NumberBox(0, 0, 100, 24, "h: ", new Set());
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
    chooser.add(setButton);
    chooser.add(groupButton);
    chooser.add(ungroupButton);
    chooser.add(copyButton);
    chooser.add(pasteButton);
    chooser.add(deleteButton);
  }
  
  void press() {
    objSelection.press();
    if (dragging) {
      setLastState();
    } else {
      if (!(keyPressed && keyCode == SHIFT)) {
        objSelection.deselect();
      }
      beginSelectX = mainWindow.localMouseX();
      beginSelectY = mainWindow.localMouseY();
      selecting = true;
    }
  }
  
  void release() {
    if (selecting) {
      for (int i=0; i<drawingList.size(); i++) {
        DrawingObj currObj = drawingList.get(i);
        if (currObj.inBounds(beginSelectX, beginSelectY, mainWindow.localMouseX(), mainWindow.localMouseY())) {
          if (currObj.selected) {
            objSelection.remove(currObj);
          } else {
            objSelection.insert(currObj);
          }
        }
      }
      selecting = false;
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
      int lx = mainWindow.localToGlobalX(beginSelectX);
      int ly = mainWindow.localToGlobalY(beginSelectY);
      rect(lx, ly, mouseX-lx, mouseY-ly);
    }
  }
  
  class EditButton extends Clickable {
    EditButton () {
      super(0, 0, 24, 24, false);
    }
    
    void display () {
      super.display();
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
  
  NumberBox gridText;
  NumberBox baseMSText;
  NumberBox miniRangeXText;
  TextButton setButton;
  
  SettingsTool () {
    super();
    button = new TextButton(0, 0, 0, 24, "SETTINGS", null);
    
    gridText = new NumberBox(0, 0, 150, 24, "Grid Size: ", new Set());
    baseMSText = new NumberBox(0, 0, 150, 24, "Base Speed: ", new Set());
    miniRangeXText = new NumberBox(0, 0, 200, 24, "Minimap Range x: ", new Set());
    setButton = new TextButton(0, 0, 0, 24, "SET", new Set());
    
    chooser.add(gridText);
    chooser.add(baseMSText);
    chooser.add(miniRangeXText);
    chooser.add(setButton);
    
    gridText.setVal(gridSize);
    baseMSText.setVal(baseMoveSpeed);
    miniRangeXText.setVal(miniWindow.rangeX);
  }
  
  void press() {
    if (objSelection.selected) {
      objSelection.deselect();
    }
  }
  
  class Set implements Action {
    void run() {
      gridSize = gridText.val;
      baseMoveSpeed = baseMSText.val;
      miniWindow.setRangeX(miniRangeXText.val);
    }
  }
}
