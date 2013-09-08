import java.util.*;
import processing.serial.*;
import processing.net.*;
import java.text.SimpleDateFormat;

// Thorlabs shutter
final int tcpPort = 5020;       
Server tcpServer;
boolean shutter;

// Proscan stage
ProscanIII stage;
Serial stageSerial;
float baseMoveSpeed = 5000;
float scopeX = 0;
float scopeY = 0;
ArrayList<Command> commandList;

// Window info
DrawingWindow mainWindow;
DrawingWindow miniWindow;
Selection objSelection;
ProgressBox progressBox;
DrawingObj currentDraw = null;
BackgroundImage backgroundImage = null;
String lastState = "";
ArrayList<DrawingObj> drawingList;
final int width = 1280;
final int height = 960;
final int leftMargin = 20;
final int rightMargin = 20;
final int topMargin = 77;
final int bottomMargin = 50;
int backGroundColor = #66a3d2;
int fontSize = 12;
PFont font = createFont("Ariel", 12);
float gridSize = 10.0;

// Interface
final float maxSpeed = 10000;
final float maxTime = 100;
Tool currentTool;
TextBox selectedText = null;
boolean mapDrag = false;
boolean dragging = false;
boolean paused = false;
boolean beginPress = false;
boolean[] keys = new boolean[526];

// File I/O
String logPath;
PrintWriter logFile;
File sketchPathFile;
File saveFile;
File loadFile;
File lettersFile;
int sequenceNum = 0;

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
LetterTool letterTool;
ScanImageTool scanImageTool;
BGImageTool bgImageTool;
ZoomInTool zoomInTool;
ZoomOutTool zoomOutTool;
EditTool editTool;
LogTool logTool;
SettingsTool settingsTool;

// Other Buttons
TextButton newButton;
TextButton loadButton;
TextButton saveButton;
TextButton posButton;
TextButton zeroButton;
TextButton stopButton;
Toggle pauseButton;
TextButton runButton;

// Initialization
void setup() {
  // Window Init;
  size(width, height);
  mainWindow = new DrawingWindow(leftMargin, topMargin, width-leftMargin-rightMargin, height-topMargin-bottomMargin, 1000);
  miniWindow = new DrawingWindow(mainWindow.x+mainWindow.w-200, mainWindow.y+mainWindow.h-200, 200, 200, 25000);
  miniWindow.lowX = 0;
  miniWindow.lowY = 0;
  textFont(font);
  
  // Initialize drawing and command lists
  drawingList = new ArrayList<DrawingObj>();
  commandList = new ArrayList<Command>();
  
  // Initialize Toolbars
  drawingToolbar = new Toolbar(leftMargin, 12);
  chooserToolbar = new Toolbar(leftMargin, 41);
  fileToolbar = new Toolbar(leftMargin+mainWindow.w-160, 12);
  controlToolbar = new Toolbar(leftMargin, topMargin+mainWindow.h+10);
  
  newButton = new TextButton(0, 0, 0, 24, "NEW", new NewAction());
  loadButton = new TextButton(0, 0, 0, 24, "LOAD", new LoadAction());
  saveButton = new TextButton(0, 0, 0, 24, "SAVE", new SaveAction());
  posButton = new TextButton(0, 0, 0, 24, "POS", new PosAction());
  zeroButton = new TextButton(0, 0, 0, 24, "ZERO", new ZeroAction());
  stopButton = new TextButton(0, 0, 0, 24, "STOP", new StopAction());
  pauseButton = new Toggle(0, 0, 0, 24, "PAUSE", "PLAY", new PauseAction());
  runButton = new TextButton(0, 0, 0, 24, "RUN", new RunAction());
  
  moveTool = new MoveTool();
  pointTool = new PointTool();
  lineTool = new LineTool();
  curveTool = new CurveTool();
  rectTool = new RectTool();
  ellipseTool = new EllipseTool();
  fillTool = new FillTool();
  letterTool = new LetterTool();
  scanImageTool = new ScanImageTool();
  bgImageTool = new BGImageTool();
  zoomInTool = new ZoomInTool();
  zoomOutTool = new ZoomOutTool();
  editTool = new EditTool();
  logTool = new LogTool();
  settingsTool = new SettingsTool();
  
  drawingTools = new ArrayList<Tool>();
  drawingTools.add(moveTool);
  drawingTools.add(pointTool);
  drawingTools.add(lineTool);
  drawingTools.add(curveTool);
  drawingTools.add(rectTool);
  drawingTools.add(ellipseTool);
  drawingTools.add(fillTool);
  drawingTools.add(letterTool);
  drawingTools.add(scanImageTool);
  drawingTools.add(bgImageTool);
  drawingTools.add(zoomInTool);
  drawingTools.add(zoomOutTool);
  drawingTools.add(editTool);
  drawingTools.add(logTool);
  drawingTools.add(settingsTool);
  
  ArrayList<Interface> drawingButtons = new ArrayList<Interface>();
  for (int i=0; i<drawingTools.size(); i++) {
    drawingButtons.add(drawingTools.get(i).button);
  }
  drawingToolbar.setTools(drawingButtons);
  
  ArrayList<Interface> fileTools = new ArrayList<Interface>();
  fileTools.add(newButton);
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
  
  // Setup Objects
  objSelection = new Selection();
  progressBox = new ProgressBox(mainWindow.x+mainWindow.w-200, topMargin+mainWindow.h+10, 200, 24);
  
  // Setup Files
  Date date = new Date();
  String dateString = new SimpleDateFormat("MM:dd:yyyy/h.mm.ss a").format(date);
  logPath = sketchPath("")+"/Logs/"+dateString+"/";
  logFile = createWriter(logPath+"logfile.txt");
  
  sketchPathFile = new File(sketchPath(""));
  loadFile = sketchPathFile;
  saveFile = sketchPathFile;
  lettersFile = new File(sketchPath("")+"/Macros/Typography/");
  // Create Connection
  /*
  stage = new ProscanIII();
  for (int i=0; i<Serial.list().length; i++) {
    if (Serial.list()[i].equals(stage.serialName)) {
      stageSerial = new Serial(this, Serial.list()[i], 9600);
    }
  }
  stage.connect();
  */
  
  // connect to solenoid
  tcpServer = new Server(this, tcpPort);
  
  moveTool.activate();
  setShutter(false);
}

void stop() {
  logFile.flush();
  logFile.close();
} 

// draws screen (is looped automatically)
void draw() {

  // Set the background
  background(backGroundColor);
  
  // Draw Main Window
  mainWindow.display();
  
  if (backgroundImage != null) {
    backgroundImage.display(mainWindow, false);
  }
  
  // Origin Dot
  stroke(0);
  fill(0);
  ellipse(mainWindow.localToGlobalX(0), mainWindow.localToGlobalY(0), 3, 3);
  
  // Range Bar
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(mainWindow.x+30, mainWindow.y+mainWindow.h-30, mainWindow.x+mainWindow.w/10, mainWindow.y+mainWindow.h-30);
  text(str(mainWindow.rangeX/10)+" um", mainWindow.x+30, mainWindow.y+mainWindow.h-28+fontSize);
  strokeWeight(1);
    
  // display drawing objects
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display(mainWindow, false);
  }
  objSelection.display(mainWindow, false);
  
  // show whats currently being drawn
  if (currentDraw != null) {
    currentDraw.display(mainWindow, false);
  }
  editTool.display();
  bgImageTool.display();
  scanImageTool.display();
  
  // Show Scope Position
  int posX = mainWindow.localToGlobalX(scopeX);
  int posY = mainWindow.localToGlobalY(scopeY);
  stroke(0);
  line(posX-7, posY, posX+7, posY);
  line(posX, posY-7, posX, posY+7);
  noStroke();
  fill(0, 0, 255);
  ellipse(posX, posY, 8, 8);
  fill(0, 255, 0);
  ellipse(posX, posY, 4, 4);
  
  
  // Draw background to cover drawing objects beyond window
  fill(backGroundColor);
  rect(0, 0, leftMargin-1, height);
  rect(0, 0, width, topMargin-1);
  rect(width, height, -rightMargin+1, -height);
  rect(width, height, -width, -bottomMargin+1);
  
  
  // Display miniWindow
  
  miniWindow.display();
  if (backgroundImage != null) {
    backgroundImage.display(miniWindow, true);
  }
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display(miniWindow, true);
  }
  stroke(200);
  noFill();
  int lx = miniWindow.localToGlobalX(mainWindow.lowX);
  int ly = miniWindow.localToGlobalY(mainWindow.lowY);
  int hx = miniWindow.localToGlobalX(mainWindow.lowX+mainWindow.rangeX);
  int hy = miniWindow.localToGlobalY(mainWindow.lowY+mainWindow.rangeY);
  rect(lx, ly, hx-lx, hy-ly);
  
  // Show miniWindow Scope Position
  posX = miniWindow.localToGlobalX(scopeX);
  posY = miniWindow.localToGlobalY(scopeY);
  noStroke();
  fill(0, 255, 0);
  ellipse(posX, posY, 2, 2);
    
  // draw toolbars
  drawingToolbar.display();
  chooserToolbar.display();
  fileToolbar.display();
  controlToolbar.display();
  
  // draw timer
  progressBox.display();
  
  // set cursor
  fill(0);
  if (miniWindow.mouseOver()) {
    cursor(CROSS);
    text("x:"+String.format("%.1f", miniWindow.localMouseX()), mouseX + 15, mouseY - 2);
    text("y:"+String.format("%.1f", miniWindow.localMouseY()), mouseX + 15, mouseY + fontSize);
  } else
  if (mainWindow.mouseOver()) {
    cursor(CROSS);
    text("x:"+String.format("%.1f", mainWindow.localMouseX()), mouseX + 15, mouseY - 2);
    text("y:"+String.format("%.1f", mainWindow.localMouseY()), mouseX + 15, mouseY + fontSize);
  } else {
    cursor(ARROW);
  }
}

void keyPressed() {
  keys[keyCode] = true;
  if (selectedText == null) {
    if (keyCode == BACKSPACE) {
      if (objSelection.selected) {
        objSelection.delete();
      }
    } else
    if (keyCode == UP) {
      if (objSelection.selected) {
        objSelection.translate(0, -gridSize);
      }
    } else
    if (keyCode == DOWN) {
      if (objSelection.selected) {
        objSelection.translate(0, +gridSize);
      }
    } else
    if (keyCode == LEFT) {
      if (objSelection.selected) {
        objSelection.translate(-gridSize, 0);
      }
    } else
    if (keyCode == RIGHT) {
      if (objSelection.selected) {
        objSelection.translate(gridSize, 0);
      }
    }
  } else {
    selectedText.type();
  }
  currentTool.keyPress();
  
  if (checkKey(CONTROL)) {
    if (keyCode == int('S')) {
      if (saveFile == sketchPathFile) {
        selectOutput("Save File", "saveData", sketchPathFile);
      } else {
        saveData(saveFile);
      }
    } else
    if (keyCode == int('Z')) {
      restoreLastState();
    } else
    if (keyCode == int('C')) {
      objSelection.copy();
    } else
    if (keyCode == int('V')) {
      objSelection.paste();
    } else
    if (keyCode == int('A')) {
      objSelection.deselect();
      objSelection.insert(drawingList);
    } else
    if (keyCode == int('N')) {
      
    }
  }
  
  // stop escape behavior
  if (keyCode == ESC) {
    key = 0;
  }
}

void keyReleased() {
  keys[keyCode] = false;
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
    
    if (miniWindow.mouseOver()) {
      mainWindow.setPos(miniWindow.localMouseX(), miniWindow.localMouseY());
      zoomInTool.setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
      zoomOutTool.setVals(mainWindow.lowX+mainWindow.rangeX/2, mainWindow.lowY+mainWindow.rangeY/2, mainWindow.rangeX);
      if (backgroundImage != null) {
        backgroundImage.updatePos();
      }
      if (objSelection.selected) {
        objSelection.updatePos();
      }
    } else
    if (mainWindow.mouseOver()) {
      if (keyPressed && keyCode == SHIFT) {
        mapDrag = true;
      } else {
        beginPress = true;
        currentTool.press();
      }
    }
  }
  if (mouseButton == RIGHT) {
    if (mainWindow.mouseOver()) {
      float dx = mainWindow.localMouseX();
      float dy = mainWindow.localMouseY();
      addCommand(new SpeedCommand(baseMoveSpeed));
      addCommand(new MoveCommand(dx, dy, false));
    }
  }
}

void mouseDragged() {
  int mouseDiffX = mouseX-pmouseX;
  int mouseDiffY = mouseY-pmouseY;
  if (mapDrag) {
    mainWindow.lowX -= mainWindow.globalToLocalW(mouseDiffX);
    mainWindow.lowY -= mainWindow.globalToLocalH(mouseDiffY);
    if (backgroundImage != null) {
      backgroundImage.updatePos();
    }
    if (objSelection.selected) {
      objSelection.updatePos();
    }
  }
  if (beginPress) {
    currentTool.drag();
  }
}


// performed when mouse is released
void mouseReleased() {
  if (objSelection.selected) {
    objSelection.release();
  }
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
  mapDrag = false;
  beginPress = false;
}

//
void serialEvent(Serial serial) {
  String input = serial.readStringUntil('\r');
  if (serial == stageSerial) {
    stage.parseInput(input);
  }
}

void mouseWheel(MouseEvent event) {
  float amount = event.getAmount();
  float midX = mainWindow.lowX+mainWindow.rangeX/2;
  float midY = mainWindow.lowY+mainWindow.rangeY/2;
  if (amount > 0) {
    mainWindow.setZoom(midX, midY, 2);
  } else {
    mainWindow.setZoom(midX, midY, 0.5);
  }
  zoomInTool.setVals(midX, midY, mainWindow.rangeX);
  zoomOutTool.setVals(midX, midY, mainWindow.rangeX);
  if (backgroundImage != null) {
    backgroundImage.updatePos();
  }
  if (objSelection.selected) {
    objSelection.updatePos();
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
  progressBox.init();
  
  // autosave
  String filePath = logPath+"SEQUENCE"+str(sequenceNum);
  String[] strings = new String[sequence.size()];
  for (int i=0; i<sequence.size(); i++) {
    DrawingObj currObj = sequence.get(i);
    strings[i] = currObj.toString();
  }
  saveStrings(filePath, strings);
  printToLog("Ran SEQUENCE"+sequenceNum);
  sequenceNum++;
}
