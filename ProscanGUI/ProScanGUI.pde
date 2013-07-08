import processing.serial.*;
import processing.net.*;
import javax.swing.*;

// thorlabs shutter
int tcpPort = 5020;       
Server tcpServer;
boolean shutter;

// proscan stage
Serial serialConn;  // The serial serialConn object
boolean firstContact = false;
boolean runningCommand = false;
boolean checkingPos = false;
int precision = 2;
int baseMoveSpeed = 60;
int scopeX = 0;
int scopeY = 0;
ArrayList<Command> commandList = new ArrayList<Command>();

// window info
Stage stage;
int leftMargin = 20;
int rightMargin = 20;
int topMargin = 77;
int bottomMargin = 50;
ArrayList<DrawingObj> drawingList = new ArrayList<DrawingObj>();
Selection objSelection;
DrawingObj currentDraw = null;

// Interface
int lastX;
int lastY;
int maxSpeed = 100;
int maxTime = 10000;
int fontSize = 12;
PFont font = createFont("Ariel", 12);
String currentTool;
boolean dragging = false;
boolean selecting = false;

Toolbar topToolbar;
Toolbar chooserToolbar;
Toolbar bottomToolbar;
Tool[] drawingTools;

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
TextButton groupButton;
TextButton ungroupButton;
TextButton createButton;

// Other Buttons
TextButton saveButton;
TextButton loadButton;
TextButton posButton;
TextButton zeroButton;
TextButton stopButton;
TextButton runSequenceButton;

// File Chooser Init
JFileChooser fileChooser;


// initialization
void setup() {
  // Stage init;
  stage = new Stage(leftMargin, topMargin, 1000, 800, 1000);
  
  // Selection init;
  objSelection = new Selection();
  
  // Initialize Toolbar
  // Chooser
  chooserToolbar = new Toolbar(leftMargin, 41);
  timeSlider = new Slider(0, 0, 320, 24, maxTime, "Time", " ms");
  speedSlider = new Slider(0, 0, 320, 24, maxSpeed, "Speed", " um/s");
  groupButton = new TextButton(0, 0, 0, 24, "GROUP");
  ungroupButton = new TextButton(0, 0, 0, 24, "UNGROUP");
  createButton = new TextButton(0, 0, 0, 24, "CREATE");
  
  // Tool Buttons  
  pointButton = new PointButton(0, 0, chooserToolbar);
    pointButton.tools.add(timeSlider);
    pointButton.tools.add(createButton);
    
  lineButton = new LineButton(0, 0, chooserToolbar);
    lineButton.tools.add(speedSlider);
    lineButton.tools.add(createButton);
    
  curveButton = new CurveButton(0, 0, chooserToolbar);
    curveButton.tools.add(speedSlider);
    curveButton.tools.add(createButton);
    
  rectButton = new RectButton(0, 0, chooserToolbar);
    rectButton.tools.add(speedSlider);
    rectButton.tools.add(createButton);
    
  ellipseButton = new EllipseButton(0, 0, chooserToolbar);
    ellipseButton.tools.add(speedSlider);
    ellipseButton.tools.add(createButton);
    
  zoomInButton = new ZoomInButton(0, 0, chooserToolbar);
  
  zoomOutButton = new ZoomOutButton(0, 0, chooserToolbar);
  
  editButton = new EditButton(0, 0, chooserToolbar);
    editButton.tools.add(groupButton);
    editButton.tools.add(ungroupButton);
  
  
  
  // Other Buttons
  saveButton = new TextButton(0, 0, 0, 24, "SAVE");
  loadButton = new TextButton(0, 0, 0, 24, "LOAD");
  posButton = new TextButton(0, 0, 0, 24, "POS");
  zeroButton = new TextButton(0, 0, 0, 24, "ZERO");
  stopButton = new TextButton(0, 0, 0, 24, "STOP");
  runSequenceButton = new TextButton(0, 0, 0, 24, "RUN SEQUENCE");
  
  
  // Tools
  drawingTools = new Tool[]{
                                pointButton, lineButton, curveButton, rectButton,
                                ellipseButton, zoomInButton, zoomOutButton, editButton
  };
  
  // Start On Point Tool
  pointButton.press();
  
  
  // Toolbars
  topToolbar = new Toolbar(leftMargin, 12);
  ArrayList<Interface> topTools = new ArrayList<Interface>();
  topTools.add(pointButton);
  topTools.add(lineButton);
  topTools.add(curveButton);
  topTools.add(rectButton);
  topTools.add(ellipseButton);
  topTools.add(zoomInButton);
  topTools.add(zoomOutButton);
  topTools.add(editButton);
  topTools.add(loadButton);
  topTools.add(saveButton);
  topToolbar.setTools(topTools);
  
  bottomToolbar = new Toolbar(leftMargin, topMargin+stage.h+10);
  ArrayList<Interface> bottomTools = new ArrayList<Interface>();
  bottomTools.add(posButton);
  bottomTools.add(zeroButton);
  bottomTools.add(stopButton);
  bottomTools.add(runSequenceButton);
  bottomToolbar.setTools(bottomTools);
  
  // File Chooser Init
  fileChooser = new JFileChooser();
  
  fileChooser.setCurrentDirectory(new File(sketchPath("")+"Saves/"));
  size(leftMargin+stage.w+rightMargin, topMargin+stage.h+bottomMargin);
  textFont(font);
  
  // In case you want to see the list of available serialConns
  //println(Serial.list());
  
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
      currentDraw.updatePos();
      currentDraw.display();
    }

    if (currentTool.equals("Edit")) {
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
  topToolbar.display();
  chooserToolbar.display();
  bottomToolbar.display();
}

void keyPressed() {
  if (keyCode == BACKSPACE) {
    objSelection.delete();
  }
}

void mousePressed() {
  timeSlider.press();
  speedSlider.press();
  
  if (mouseButton == LEFT) {  
    // Set Tools/Buttons
    for (int i=0; i<drawingTools.length; i++) {
      Tool currTool = drawingTools[i];
      if (currTool.over()) {
        currTool.press();
      }
    }
    if (groupButton.over()) {
      objSelection.group();
    }
    if (ungroupButton.over()) {
      objSelection.ungroup();
    }
    if (posButton.over()) {
      addCommand(new TextCommand("PS", ""));
    }
    if (zeroButton.over()) {
      addCommand(new TextCommand("Z", ""));
    }
    if (stopButton.over()) {
      commandList.clear();
      addCommand(new TextCommand("K", ""));
    }
    if (runSequenceButton.over()) {
      runSequence();
    }
    if (saveButton.over()) {
      saveData();
    }
    if (loadButton.over()) {
      loadData();
    }
    
    // Perform Actions
    if (stage.mouseOver()) {
      int localX = stage.toGrid(stage.globalToLocalX(mouseX));
      int localY = stage.toGrid(stage.globalToLocalY(mouseY));
      if (currentTool.equals("Point")) {
        // adds point
        drawingList.add(new PointObj(timeSlider.val, localX, localY));
      } else
      if (currentTool.equals("Line")) {
        currentDraw = new LineObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("Rect")) {
        currentDraw = new RectObj(speedSlider.val, localX, localY, 0, 0);
      } else
      if (currentTool.equals("ZoomIn")) {
        stage.setZoom(localX, localY, 0.5);
      } else
      if (currentTool.equals("ZoomOut")) {
        stage.setZoom(localX, localY, 2);
      } else
      if (currentTool.equals("Edit")) {
        for (int i=0; i<drawingList.size(); i++) {
          drawingList.get(i).press();
        }
        objSelection.press();
        if (dragging == false) {
          if (stage.mouseOver()) {
            lastX = stage.globalToLocalX(mouseX);
            lastY = stage.globalToLocalY(mouseY);
            selecting = true;
          }
        }
      }
    }
    
  } else
  if (mouseButton == RIGHT) {
    objSelection.deselect();
  }
}

// performed when mouse is released
void mouseReleased() {
  timeSlider.release();
  speedSlider.release();
  
  if (mouseButton == LEFT) {
    for (int i=0; i<drawingList.size(); i++) {
      drawingList.get(i).release();
    }
    objSelection.release();
    
    if (stage.mouseOver()) {
      if (currentDraw != null) {
        drawingList.add(currentDraw);
        currentDraw = null;
      }
      if (currentTool.equals("Edit")) {
        if (selecting) {
          selecting = false;
          ArrayList<DrawingObj> tempObjs = new ArrayList<DrawingObj>();
          for (int i=0; i<drawingList.size(); i++) {
            DrawingObj currObj = drawingList.get(i);
            if (currObj.inBounds(lastX, lastY, stage.globalToLocalX(mouseX), stage.globalToLocalY(mouseY))) {
              if (currObj.selected == false) {
                tempObjs.add(currObj);
              }
            }
          }
          objSelection.insert(tempObjs);
        }
      }
    }
  } else
  if (mouseButton == RIGHT) {
  }
}

// Called whenever there is something available to read
void serialEvent(Serial serialConn) {
  // Data from the Serial serialConn is read in serialEvent() using the readStringUntil() function with * as the end character.
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
            int newScopeX = parseInt(vals[0].trim());
            int newScopeY = parseInt(vals[1].trim());
            
            int distX = abs(currMoveCommand.destX-newScopeX);
            int distY = abs(currMoveCommand.destY-newScopeY);
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
            scopeX = parseInt(vals[0].trim());
            scopeY = parseInt(vals[1].trim());
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
