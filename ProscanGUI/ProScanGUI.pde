import processing.serial.*;
import processing.net.*;
import javax.swing.*;

// Thorlabs shutter
final int tcpPort = 5020;       
Server tcpServer;
boolean shutter;

// Proscan stage
Serial serialConn;  // The serial serialConn object
boolean firstContact = false;
boolean runningCommand = false;
boolean checkingPos = false;
final int precision = 2;
final int baseMoveSpeed = 60;
float scopeX = 0;
float scopeY = 0;
ArrayList<Command> commandList;

// Window info
Stage stage;
final int leftMargin = 20;
final int rightMargin = 20;
final int topMargin = 77;
final int bottomMargin = 50;
DrawingObj currentDraw = null;
Selection objSelection;
ArrayList<DrawingObj> drawingList;

// Interface
float lastX;
float lastY;
final float maxSpeed = 1000;
final float maxTime = 10;
int fontSize = 12;
PFont font = createFont("Ariel", 12);
String currentTool;
boolean dragging = false;
boolean selecting = false;

// Toolbars
Toolbar drawingToolbar;
Toolbar chooserToolbar;
Toolbar fileToolbar;
Toolbar controlToolbar;

// Tool Buttons
PointButton pointButton;
LineButton lineButton;
CurveButton curveButton;
RectButton rectButton;
EllipseButton ellipseButton;
ZoomInButton zoomInButton;
ZoomOutButton zoomOutButton;
EditButton editButton;

// Chooser Interfaces
Slider timeSlider;
Slider speedSlider;
TextBox timeText;
TextBox speedText;
TextBox x1Text;
TextBox y1Text;
TextBox x2Text;
TextBox y2Text;
TextBox lowXText;
TextBox lowYText;
TextBox rangeXText;

GroupButton groupButton;
UngroupButton ungroupButton;
CopyButton copyButton;
PasteButton pasteButton;
CreateButton createButton;
SetButton setButton;

// Other Buttons
SaveButton saveButton;
LoadButton loadButton;
PosButton posButton;
ZeroButton zeroButton;
StopButton stopButton;
RunButton runButton;

// File Chooser Init
JFileChooser fileChooser;


// initialization
void setup() {
  // Stage init;
  stage = new Stage(leftMargin, topMargin, 1000, 800, 100);
  size(leftMargin+stage.w+rightMargin, topMargin+stage.h+bottomMargin);
  textFont(font);
  
  // Selection init;
  drawingList = new ArrayList<DrawingObj>();
  commandList = new ArrayList<Command>();
  
  // Initialize Toolbars
  // Function Buttons
  saveButton = new SaveButton(0, 0, 0, 24);
  loadButton = new LoadButton(0, 0, 0, 24);
  posButton = new PosButton(0, 0, 0, 24);
  zeroButton = new ZeroButton(0, 0, 0, 24);
  stopButton = new StopButton(0, 0, 0, 24);
  runButton = new RunButton(0, 0, 0, 24);
  
  // Chooser Interfaces
  chooserToolbar = new Toolbar(leftMargin, 41);
  timeText = new TextBox(0, 0, 120, 24, "Time (s): ", 0);
  speedText = new TextBox(0, 0, 160, 24, "Speed (um/s): ", 0);
  timeSlider = new Slider(0, 0, 159, 24, maxTime, "Time", "%.1f", timeText);
  speedSlider = new Slider(0, 0, 166, 24, maxSpeed, "Speed", "%.0f", speedText);
  x1Text = new TextBox(0, 0, 100, 24, "x1: ", 0);
  y1Text = new TextBox(0, 0, 100, 24, "y1: ", 0);
  x2Text = new TextBox(0, 0, 100, 24, "x2: ", 0);
  y2Text = new TextBox(0, 0, 100, 24, "y2: ", 0);
  lowXText = new TextBox(0, 0, 140, 24, "Low x: ", 0);
  lowYText = new TextBox(0, 0, 140, 24, "Low y: ", 0);
  rangeXText = new TextBox(0, 0, 140, 24, "Range x: ", 0);
  createButton = new CreateButton(0, 0, 0, 24);
  setButton = new SetButton(0, 0, 0, 24);
  groupButton = new GroupButton(0, 0, 0, 24);
  ungroupButton = new UngroupButton(0, 0, 0, 24);
  copyButton = new CopyButton(0, 0, 0, 24);
  pasteButton = new PasteButton(0, 0, 0, 24);
  
  // Tools
  pointButton = new PointButton(0, 0, chooserToolbar);
    pointButton.tools.add(timeSlider);
    pointButton.tools.add(timeText);
    pointButton.tools.add(x1Text);
    pointButton.tools.add(y1Text);
    pointButton.tools.add(createButton);
    
  lineButton = new LineButton(0, 0, chooserToolbar);
    lineButton.tools.add(speedSlider);
    lineButton.tools.add(speedText);
    lineButton.tools.add(x1Text);
    lineButton.tools.add(y1Text);
    lineButton.tools.add(x2Text);
    lineButton.tools.add(y2Text);
    lineButton.tools.add(createButton);
    
  curveButton = new CurveButton(0, 0, chooserToolbar);
    curveButton.tools.add(speedSlider);
    curveButton.tools.add(speedText);
    curveButton.tools.add(x1Text);
    curveButton.tools.add(y1Text);
    curveButton.tools.add(x2Text);
    curveButton.tools.add(y2Text);
    curveButton.tools.add(createButton);
    
  rectButton = new RectButton(0, 0, chooserToolbar);
    rectButton.tools.add(speedSlider);
    rectButton.tools.add(speedText);
    rectButton.tools.add(x1Text);
    rectButton.tools.add(y1Text);
    rectButton.tools.add(x2Text);
    rectButton.tools.add(y2Text);
    rectButton.tools.add(createButton);
    
  ellipseButton = new EllipseButton(0, 0, chooserToolbar);
    ellipseButton.tools.add(speedSlider);
    ellipseButton.tools.add(speedText);
    ellipseButton.tools.add(x1Text);
    ellipseButton.tools.add(y1Text);
    ellipseButton.tools.add(x2Text);
    ellipseButton.tools.add(y2Text);
    ellipseButton.tools.add(createButton);
    
  zoomInButton = new ZoomInButton(0, 0, chooserToolbar);
    zoomInButton.tools.add(lowXText);
    zoomInButton.tools.add(lowYText);
    zoomInButton.tools.add(rangeXText);
    zoomInButton.tools.add(setButton);
  
  zoomOutButton = new ZoomOutButton(0, 0, chooserToolbar);
    zoomOutButton.tools.add(lowXText);
    zoomOutButton.tools.add(lowYText);
    zoomOutButton.tools.add(rangeXText);
    zoomOutButton.tools.add(setButton);
  
  editButton = new EditButton(0, 0, chooserToolbar);
    editButton.tools.add(x1Text);
    editButton.tools.add(y1Text);
    editButton.tools.add(x2Text);
    editButton.tools.add(y2Text);
    editButton.tools.add(setButton);
    editButton.tools.add(groupButton);
    editButton.tools.add(ungroupButton);
    editButton.tools.add(copyButton);
    editButton.tools.add(pasteButton);
  
  // Toolbars
  drawingToolbar = new Toolbar(leftMargin, 12);
  ArrayList<Interface> drawingTools = new ArrayList<Interface>();
  drawingTools.add(pointButton);
  drawingTools.add(lineButton);
  drawingTools.add(curveButton);
  drawingTools.add(rectButton);
  drawingTools.add(ellipseButton);
  drawingTools.add(zoomInButton);
  drawingTools.add(zoomOutButton);
  drawingTools.add(editButton);
  drawingToolbar.setTools(drawingTools);
  
  fileToolbar = new Toolbar(leftMargin+stage.w-110, 12);
  ArrayList<Interface> fileTools = new ArrayList<Interface>();
  fileTools.add(loadButton);
  fileTools.add(saveButton);
  fileToolbar.setTools(fileTools);
  
  controlToolbar = new Toolbar(leftMargin, topMargin+stage.h+10);
  ArrayList<Interface> controlTools = new ArrayList<Interface>();
  controlTools.add(posButton);
  controlTools.add(zeroButton);
  controlTools.add(stopButton);
  controlTools.add(runButton);
  controlToolbar.setTools(controlTools);
  
  // Make Selection and Filechooser
  objSelection = new Selection();
  fileChooser = new JFileChooser();
  fileChooser.setCurrentDirectory(new File(sketchPath("")+"Saves/"));
  pointButton.choose();
  
  /*
  // connect to solenoid
  tcpServer = new Server(this, tcpPort);
  
  
  // Using the first available serialConn (might be different on your computer)
  serialConn = new Serial(this, Serial.list()[0], 9600);
  // Request values right off the bat
  while (firstContact == false) {
    serialConn.write("PS\r");
    delay(1000);
  }
  
  addCommand(new ShutterCommand(false, 0));
  addCommand(new TextCommand("K", ""));
  addCommand(new TextCommand("PS", ""));
  addCommand(new TextCommand("BLSH", "0"));
  
  */
}

// draws screen (is looped automatically)
void draw() {
  // Set the background
  background(#66a3d2);
  
  // Draw stage
  stage.display();
  
  // display drawing objects
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display();
  }
  objSelection.display();
  
  // show whats currently being drawn
  if (stage.mouseOver()) {
    cursor(CROSS);
    
    if (currentDraw != null) {
      currentDraw.xCoords[1] = stage.toGrid(stage.localMouseX());
      currentDraw.yCoords[1] = stage.toGrid(stage.localMouseY());
      if (currentTool.equals("CURVE")) {
        currentDraw.xCoords[2] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.33;
        currentDraw.yCoords[2] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.33;
        currentDraw.xCoords[3] = currentDraw.xCoords[0]+(currentDraw.xCoords[1]-currentDraw.xCoords[0])*0.66;
        currentDraw.yCoords[3] = currentDraw.yCoords[0]+(currentDraw.yCoords[1]-currentDraw.yCoords[0])*0.66;
      }
      currentDraw.updatePos();
      currentDraw.display();
    }

    if (currentTool.equals("EDIT")) {
      for (int i=0; i<drawingList.size(); i++) {
        drawingList.get(i).update();
      }
      if (selecting == true) {
        stroke(0, 255, 0);
        noFill();
        int posX = stage.localToGlobalX(lastX);
        int posY = stage.localToGlobalY(lastY);
        rect(posX, posY, mouseX-posX, mouseY-posY);
      }
    }
  } else {
    cursor(ARROW);
  }
  
  // Show Scope Position
  int posX = stage.localToGlobalX(scopeX);
  int posY = stage.localToGlobalY(scopeY);
  stroke(0);
  line(posX-7, posY, posX+7, posY);
  line(posX, posY-7, posX, posY+7);
  noStroke();
  fill(0, 0, 255);
  ellipse(posX, posY, 8, 8);
  fill(0, 255, 0);
  ellipse(posX, posY, 4, 4);
    
  // draw toolbars
  drawingToolbar.display();
  chooserToolbar.display();
  fileToolbar.display();
  controlToolbar.display();
}

void keyPressed() {
  if (keyCode == BACKSPACE) {
    objSelection.delete();
    x1Text.delete();
    y1Text.delete();
    x2Text.delete();
    y2Text.delete();
    timeText.delete();
    speedText.delete();
    lowXText.delete();
    lowYText.delete();
    rangeXText.delete();
  } else {
    char[] numeric = new char[]{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-'};
    for (int i=0; i<numeric.length; i++) {
      if (key == numeric[i]) {
        x1Text.type(key);
        y1Text.type(key);
        x2Text.type(key);
        y2Text.type(key);
        timeText.type(key);
        speedText.type(key);
        lowXText.type(key);
        lowYText.type(key);
        rangeXText.type(key);
        if (timeText.selected) {
          timeSlider.setVal(timeText.val);
        }
        if (speedText.selected) {
          speedSlider.setVal(speedText.val);
        }
      }
    }
  }
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
    
    for (int i=0; i<drawingToolbar.tools.size(); i++) {
      drawingToolbar.tools.get(i).press();
    }
    
    // BEGIN OBJECT DRAW
    if (stage.mouseOver()) {
      float localX = stage.toGrid(stage.globalToLocalX(mouseX));
      float localY = stage.toGrid(stage.globalToLocalY(mouseY));
      if (currentTool.equals("POINT")) {
        // adds point
        drawingList.add(new PointObj(timeSlider.val, localX, localY));
      } else
      if (currentTool.equals("LINE")) {
        currentDraw = new LineObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("CURVE")) {
        currentDraw = new CurveObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("RECT")) {
        currentDraw = new RectObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("ELLIPSE")) {
        currentDraw = new EllipseObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("ZOOMIN")) {
        stage.setZoom(localX, localY, 0.5);
      } else
      if (currentTool.equals("ZOOMOUT")) {
        stage.setZoom(localX, localY, 2);
      } else
      if (currentTool.equals("EDIT")) {
        objSelection.press();
        for (int i=0; i<drawingList.size(); i++) {
          drawingList.get(i).press();
        }
        if (dragging == false) {
          if (stage.mouseOver()) {
            lastX = stage.globalToLocalX(mouseX);
            lastY = stage.globalToLocalY(mouseY);
            selecting = true;
          }
        }
      }
    } 
  }
}

// performed when mouse is released
void mouseReleased() {
  if (mouseButton == LEFT) {
    timeSlider.release();
    speedSlider.release();
    
    // END OBJECT DRAW
    if (stage.mouseOver()) {
      if (currentDraw != null) {
        drawingList.add(currentDraw);
        currentDraw = null;
      }
      if (currentTool.equals("EDIT")) {
        for (int i=0; i<drawingList.size(); i++) {
          drawingList.get(i).release();
        }
        objSelection.release();
        if (selecting) {
          if (!(keyPressed && keyCode == SHIFT)) {
            objSelection.deselect();
          }
          ArrayList<DrawingObj> tempObjs = new ArrayList<DrawingObj>();
          for (int i=0; i<drawingList.size(); i++) {
            DrawingObj currObj = drawingList.get(i);
            if (currObj.inBounds(lastX, lastY, stage.globalToLocalX(mouseX), stage.globalToLocalY(mouseY))) {
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
    }
  }
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
      println(input);
      String[] vals = splitTokens(input, ", ");
      if (commandList.size() > 0) {
        Command currCommand = commandList.get(0);
        if (currCommand instanceof MoveCommand) {
          MoveCommand currMoveCommand = (MoveCommand)currCommand;
          if (checkingPos == false) {
            checkingPos = true;
            serialConn.write("PS\r");
          } else {
            float newScopeX = float(parseInt(vals[0].trim()))/10;
            float newScopeY = float(parseInt(vals[1].trim()))/10;
            
            float distX = abs(currMoveCommand.destX-newScopeX);
            float distY = abs(currMoveCommand.destY-newScopeY);
            float dist = sqrt(pow(distX, 2)+pow(distY, 2));
            
            if (currMoveCommand.shutter == true && shutter == false) {
              setShutter(true);
            }
            
            if (dist <= precision) {
              checkingPos = false;
              runningCommand = false;
              if (shutter == true) {
                setShutter(false);
              }
              commandList.remove(0);
              runNext();
            } else {
              serialConn.write("PS\r");
            }
            scopeX = newScopeX;
            scopeY = newScopeY;
          }
        } else 
        if (currCommand instanceof TextCommand) {
          TextCommand currTextCommand = (TextCommand)currCommand;
          if (currTextCommand.command.equals("PS")) {
            scopeX = float(parseInt(vals[0].trim()))/10;
            scopeY = float(parseInt(vals[1].trim()))/10;
          }
          runningCommand = false;
          commandList.remove(0);
          runNext();
        } else {
          runningCommand = false;
          commandList.remove(0);
          runNext();
        }
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
    Command currCommand = commandList.get(0);
    currCommand.run();
    println(currCommand);
  }
}

// begins command sequence to send to proscan
void runSequence() {
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).makeCommands();
  }
}

void setShutter(boolean mode) {
  shutter = mode;
  if (mode) {
    tcpServer.write("1");
  } else {
    tcpServer.write("0");
  }
}
