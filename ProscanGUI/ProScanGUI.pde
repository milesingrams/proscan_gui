import processing.serial.*;
import processing.net.*;
import java.util.*;

// Thorlabs shutter
final int tcpPort = 5020;       
Server tcpServer;
boolean shutter;

// Proscan stage
Serial serialConn;  // The serial serialConn object
boolean firstContact = false;
float precision = 0.5;
float baseMoveSpeed = 5000;
float scopeX = 0;
float scopeY = 0;
ArrayList<Command> commandList;

// Window info
Stage mainStage;
Stage miniStage;
float miniStageRangeX = 25400;
final int width = 1280;
final int height = 960;
final int leftMargin = 20;
final int rightMargin = 20;
final int topMargin = 77;
final int bottomMargin = 50;
int backGroundColor = #66a3d2;
float gridSize = 1;
Selection objSelection;
DrawingObj currentDraw = null;
BackgroundImage backgroundImage = null;
ArrayList<DrawingObj> drawingList;

// Interface
final float maxSpeed = 10000;
final float maxTime = 100;
int fontSize = 12;
PFont font = createFont("Ariel", 12);
Tool currentTool;
TextBox selectedText = null;
boolean dragging = false;
boolean paused = false;
boolean beginPress = false;

// Toolbars
ArrayList<Tool> drawingTools;
Toolbar drawingToolbar;
Toolbar chooserToolbar;
Toolbar fileToolbar;
Toolbar controlToolbar;

// Tool Buttons

MoveTool moveTool;
PointTool pointTool;
LineTool lineTool;
CurveTool curveTool;
RectTool rectTool;
EllipseTool ellipseTool;
FillTool fillTool;
ScanImageTool scanImageTool;
BGImageTool bgImageTool;
ZoomInTool zoomInTool;
ZoomOutTool zoomOutTool;
EditTool editTool;
SettingsTool settingsTool;

// Other Buttons
TextButton saveButton;
TextButton loadButton;
TextButton posButton;
TextButton zeroButton;
TextButton stopButton;
TextButton pauseButton;
TextButton runButton;

// initialization
void setup() {
  // Stage init;
  size(width, height);
  mainStage = new Stage(leftMargin, topMargin, width-leftMargin-rightMargin, height-topMargin-bottomMargin, 1000);
  miniStage = new Stage(mainStage.x+mainStage.w-200, mainStage.y+mainStage.h-200, 200, 200, miniStageRangeX);
  miniStage.lowX = 0;
  miniStage.lowY = 0;
  size(leftMargin+mainStage.w+rightMargin, topMargin+mainStage.h+bottomMargin);
  textFont(font);
  
  // Initialize drawing and command lists
  drawingList = new ArrayList<DrawingObj>();
  commandList = new ArrayList<Command>();
  
  // Initialize Toolbars
  drawingToolbar = new Toolbar(leftMargin, 12);
  chooserToolbar = new Toolbar(leftMargin, 41);
  fileToolbar = new Toolbar(leftMargin+mainStage.w-110, 12);
  controlToolbar = new Toolbar(leftMargin, topMargin+mainStage.h+10);
  
  saveButton = new TextButton(0, 0, 0, 24, "SAVE", new SaveAction());
  loadButton = new TextButton(0, 0, 0, 24, "LOAD", new LoadAction());
  posButton = new TextButton(0, 0, 0, 24, "POS", new PosAction());
  zeroButton = new TextButton(0, 0, 0, 24, "ZERO", new ZeroAction());
  stopButton = new TextButton(0, 0, 0, 24, "STOP", new StopAction());
  pauseButton = new TextButton(0, 0, 0, 24, "PAUSE", new PauseAction());
  runButton = new TextButton(0, 0, 0, 24, "RUN", new RunAction());
  
  moveTool = new MoveTool();
  pointTool = new PointTool();
  lineTool = new LineTool();
  curveTool = new CurveTool();
  rectTool = new RectTool();
  ellipseTool = new EllipseTool();
  fillTool = new FillTool();
  scanImageTool = new ScanImageTool();
  bgImageTool = new BGImageTool();
  zoomInTool = new ZoomInTool();
  zoomOutTool = new ZoomOutTool();
  editTool = new EditTool();
  settingsTool = new SettingsTool();
  
  drawingTools = new ArrayList<Tool>();
  drawingTools.add(moveTool);
  drawingTools.add(pointTool);
  drawingTools.add(lineTool);
  drawingTools.add(curveTool);
  drawingTools.add(rectTool);
  drawingTools.add(ellipseTool);
  drawingTools.add(fillTool);
  drawingTools.add(scanImageTool);
  drawingTools.add(bgImageTool);
  drawingTools.add(zoomInTool);
  drawingTools.add(zoomOutTool);
  drawingTools.add(editTool);
  drawingTools.add(settingsTool);
  
  ArrayList<Interface> drawingButtons = new ArrayList<Interface>();
  for (int i=0; i<drawingTools.size(); i++) {
    drawingButtons.add(drawingTools.get(i).button);
  }
  drawingToolbar.setTools(drawingButtons);
  
  ArrayList<Interface> fileTools = new ArrayList<Interface>();
  fileTools.add(loadButton);
  fileTools.add(saveButton);
  fileToolbar.setTools(fileTools);
  
  ArrayList<Interface> controlTools = new ArrayList<Interface>();
  controlTools.add(posButton);
  controlTools.add(zeroButton);
  controlTools.add(stopButton);
  controlTools.add(pauseButton);
  controlTools.add(runButton);
  controlToolbar.setTools(controlTools);
  
  pointTool.activate();
  
  // Make Selection
  objSelection = new Selection();
  /*
  // connect to solenoid
  tcpServer = new Server(this, tcpPort);
  println(Serial.list());
  
  // Using the first available serialConn (might be different on your computer)
  serialConn = new Serial(this, Serial.list()[0], 9600);
  // Request values right off the bat
  while (firstContact == false) {
    serialConn.write("PS\r");
    delay(1000);
  }
  
  setShutter(false);
  addCommand(new TextCommand("BLSH", "0"));
  
  */
}

// draws screen (is looped automatically)
void draw() {
  // Set the background
  background(backGroundColor);
  
  // Draw stage
  mainStage.display();
  
  if (backgroundImage != null) {
    backgroundImage.display(mainStage, false);
  }
  
  // Origin Dot
  stroke(0);
  fill(0);
  ellipse(mainStage.localToGlobalX(0), mainStage.localToGlobalY(0), 3, 3);
  
  // Range Bar
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(mainStage.x+30, mainStage.y+mainStage.h-30, mainStage.x+mainStage.w/10, mainStage.y+mainStage.h-30);
  text(str(mainStage.rangeX/10)+" um", mainStage.x+30, mainStage.y+mainStage.h-28+fontSize);
  strokeWeight(1);
    
  // display drawing objects
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display(mainStage, false);
  }
  objSelection.display(mainStage, false);
  
  // show whats currently being drawn
  if (currentDraw != null) {
    currentDraw.display(mainStage, false);
  }
  editTool.display();
  
  // Show Scope Position
  int posX = mainStage.localToGlobalX(scopeX);
  int posY = mainStage.localToGlobalY(scopeY);
  stroke(0);
  line(posX-7, posY, posX+7, posY);
  line(posX, posY-7, posX, posY+7);
  noStroke();
  fill(0, 0, 255);
  ellipse(posX, posY, 8, 8);
  fill(0, 255, 0);
  ellipse(posX, posY, 4, 4);
  
  
  // Draw background to cover drawing objects beyond stage
  fill(backGroundColor);
  rect(0, 0, leftMargin-1, height);
  rect(0, 0, width, topMargin-1);
  rect(width, height, -rightMargin+1, -height);
  rect(width, height, -width, -bottomMargin+1);
  
  
  // Display ministage
  miniStage.display();
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display(miniStage, true);
  }
  stroke(200);
  noFill();
  int lx = miniStage.localToGlobalX(mainStage.lowX);
  int ly = miniStage.localToGlobalY(mainStage.lowY);
  int hx = miniStage.localToGlobalX(mainStage.lowX+mainStage.rangeX);
  int hy = miniStage.localToGlobalY(mainStage.lowY+mainStage.rangeY);
  rect(lx, ly, hx-lx, hy-ly);
  
  // Show Ministage Scope Position
  posX = miniStage.localToGlobalX(scopeX);
  posY = miniStage.localToGlobalY(scopeY);
  noStroke();
  fill(0, 255, 0);
  ellipse(posX, posY, 2, 2);
    
  // draw toolbars
  drawingToolbar.display();
  chooserToolbar.display();
  fileToolbar.display();
  controlToolbar.display();
  
  // set cursor
  fill(0);
  if (miniStage.mouseOver()) {
    cursor(CROSS);
    text("x:"+String.format("%.1f", miniStage.localMouseX()), mouseX + 15, mouseY - 2);
    text("y:"+String.format("%.1f", miniStage.localMouseY()), mouseX + 15, mouseY + fontSize);
  } else
  if (mainStage.mouseOver()) {
    cursor(CROSS);
    text("x:"+String.format("%.1f", mainStage.localMouseX()), mouseX + 15, mouseY - 2);
    text("y:"+String.format("%.1f", mainStage.localMouseY()), mouseX + 15, mouseY + fontSize);
  } else {
    cursor(ARROW);
  }
}

void keyPressed() {
  if (selectedText == null) {
    if (keyCode == BACKSPACE) {
      if (objSelection.selected) {
        objSelection.delete();
      }
    }
  } else {
    selectedText.type();
  }
  currentTool.keyPress();
}

void mousePressed() {
  if (mouseButton == LEFT) {  
    // Set Tools/Buttons
    for (int i=0; i<chooserToolbar.tools.size(); i++) {
      chooserToolbar.tools.get(i).press();
    }
    
    for (int i=0; i<fileToolbar.tools.size(); i++) {
      fileToolbar.tools.get(i).press();
    }
    
    for (int i=0; i<controlToolbar.tools.size(); i++) {
      controlToolbar.tools.get(i).press();
    }
    
    for (int i=0; i<drawingTools.size(); i++) {
      Tool tool = drawingTools.get(i);
      if (tool.button.over()) {
        tool.activate();
        beginPress = false;
      }
    }
    
    if (miniStage.mouseOver()) {
      mainStage.setPos(miniStage.globalToLocalX(mouseX), miniStage.globalToLocalY(mouseY));
      zoomInTool.setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
      zoomOutTool.setVals(mainStage.lowX+mainStage.rangeX/2, mainStage.lowY+mainStage.rangeY/2, mainStage.rangeX);
    } else
    if (mainStage.mouseOver()) {
      beginPress = true;
      currentTool.press();
    }
  }
  if (mouseButton == RIGHT) {
    if (mainStage.mouseOver()) {
      float dx = mainStage.globalToLocalX(mouseX);
      float dy = mainStage.globalToLocalY(mouseY);
      addCommand(new SpeedCommand(baseMoveSpeed));
      addCommand(new MoveCommand(dx, dy, false));
    }
  }
}

void mouseDragged() {
  if (beginPress) {
    currentTool.drag();
  }
}


// performed when mouse is released
void mouseReleased() {
  objSelection.release();
  for (int i=0; i<chooserToolbar.tools.size(); i++) {
    chooserToolbar.tools.get(i).release();
  }
  
  for (int i=0; i<fileToolbar.tools.size(); i++) {
    fileToolbar.tools.get(i).release();
  }
  
  for (int i=0; i<controlToolbar.tools.size(); i++) {
    controlToolbar.tools.get(i).release();
  }
  if (beginPress) {
    currentTool.release();
  }
  beginPress = false;
}


// Called whenever there is something available to read
void serialEvent(Serial srialConn) {
  // Dathe Serial serialConn isread in serialEvent() using the readStringUntil() function with * as the end character.
  String input = serialConn.readStringUntil('\r');
  
  if (firstContact == false) {
    if (input != null) {
      firstContact = true;
    }
  } else {
    if (input != null) {
      if (commandList.size() > 0) {
        Command currCommand = commandList.get(0);
        currCommand.recieve(input);
      }
    }
  }  
}

// adds a serial command
void addCommand(Command command) {
  commandList.add(command);
  if (commandList.size() == 1) {
    runNext();
  }
}

// runs next serial command
void runNext() {
  if (commandList.size() >= 1) {
    if (paused == false) {
      Command currCommand = commandList.get(0);
      currCommand.send();
    }
  } else {
    addCommand(new PosCommand());
  }
}

// begins command sequence to send to proscan
void runSequence(ArrayList<DrawingObj> sequence) {
  for (int i=0; i<sequence.size(); i++) {
    sequence.get(i).makeCommands();
  }
}
