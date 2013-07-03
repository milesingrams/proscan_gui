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
int currX = 0;
int currY = 0;
ArrayList<Command> commandList = new ArrayList<Command>();

// window info
int stageWidth = 1000;
int stageHeight = 800;
int margin = 50;
int lowX = -500;
int lowY = -400;
int rangeX = 1000;
int rangeY = int((float(stageHeight)/stageWidth)*rangeX);
int gridSize = 10;
ArrayList<DrawingObj> drawingList = new ArrayList<DrawingObj>();
Selection objSelection = new Selection();

// Interface
int lastX;
int lastY;
int maxSpeed = 100;
int currSpeed = maxSpeed;
int maxTime = 1000;
int currTime = maxTime;
int fontSize = 12;
PFont font = createFont("Ariel", 12);
boolean startDraw = true;
String currentTool = "Line";
boolean dragging = false;
boolean selecting = false;

Interface[] topToolbar;
Interface[] bottomToolbar;
Interface[] drawingTools;

// Tool Buttons
PointButton pointButton;
LineButton lineButton;
CurveButton curveButton;
RectButton rectButton;
EllipseButton ellipseButton;
ZoomInButton zoomInButton;
ZoomOutButton zoomOutButton;
TextButton editButton;

// Slider
Slider slider;

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
  
  // Initialize Toolbar
  // Slider
  slider = new Slider(0, 12, 324, 24, maxSpeed, "Speed", 3, " um/s");
  
  // Tool Buttons  
  pointButton = new PointButton(0, 0, 24, 24);
  lineButton = new LineButton(0, 0, 24, 24);
  curveButton = new CurveButton(0, 0, 24, 24);
  rectButton = new RectButton(0, 0, 24, 24);
  ellipseButton = new EllipseButton(0, 0, 24, 24);
  zoomInButton = new ZoomInButton(0, 0, 24, 24);
  zoomOutButton = new ZoomOutButton(0, 0, 24, 24);
  editButton = new TextButton(0, 0, 45, 24, "EDIT");
  
  // Other Buttons
  saveButton = new TextButton(0, 0, 50, 24, "SAVE");
  loadButton = new TextButton(0, 0, 50, 24, "LOAD");
  posButton = new TextButton(0, 0, 50, 24, "POS");
  zeroButton = new TextButton(0, 0, 50, 24, "ZERO");
  stopButton = new TextButton(0, 0, 50, 24, "STOP");
  runSequenceButton = new TextButton(0, 0, 110, 24, "RUN SEQUENCE");
  
  drawingTools = new Interface[]{
                                pointButton, lineButton, curveButton, rectButton,
                                ellipseButton, zoomInButton, zoomOutButton, editButton
  };
  topToolbar = new Interface[]{
                                slider, pointButton, lineButton, curveButton,
                                rectButton, ellipseButton, zoomInButton,zoomOutButton,
                                editButton, loadButton, saveButton
  };
  bottomToolbar = new Interface[]{
                                posButton, zeroButton, stopButton, runSequenceButton
  };

  makeToolbar(margin, 12, 5, topToolbar);
  makeToolbar(margin, margin+stageHeight+10, 5, bottomToolbar);
  
  // File Chooser Init
  fileChooser = new JFileChooser();
  
  fileChooser.setCurrentDirectory(new File(sketchPath("")+"Saves/"));
  size(stageWidth+margin*2, stageHeight+margin*2);
  textFont(font);
  
  // In case you want to see the list of available serialConns
  //println(Serial.list());
  
  // connect to solenoid
  tcpServer = new Server(this, tcpPort);
  
  /*
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
            int newCurrX = parseInt(vals[0].trim());
            int newCurrY = parseInt(vals[1].trim());
            
            int distX = abs(currMoveCommand.destX-newCurrX);
            int distY = abs(currMoveCommand.destY-newCurrY);
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
            currX = newCurrX;
            currY = newCurrY;
          }
        } else 
        if (currCommand instanceof TextCommand) {
          TextCommand currTextCommand = (TextCommand)currCommand;
          if (currTextCommand.command.equals("PS")) {
            currX = parseInt(vals[0].trim());
            currY = parseInt(vals[1].trim());
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

void setShutter(boolean mode) {
  shutter = mode;
  if (mode) {
    tcpServer.write("1");
  } else {
    tcpServer.write("0");
  }
}

// draws screen (is looped automatically)
void draw() {
  int localMouseX = globalToLocalX(mouseX);
  int localMouseY = globalToLocalY(mouseY);
  
  // Set the background
  background(#66a3d2);
  
  // drawing area
  stroke(0);
  fill(255);
  rect(margin, margin, stageWidth, stageHeight);
  
  // gridlines
  if (rangeX/gridSize < 100) {
    stroke(220);
    for (int i=ceil(float(lowX)/gridSize)*gridSize; i<lowX+rangeX; i+=gridSize) {
      int lineX = localToGlobalX(i);
      line(lineX, margin, lineX, margin+stageHeight);
    }
    for (int i=ceil(float(lowY)/gridSize)*gridSize; i<lowY+rangeY; i+=gridSize) {
      int lineY = localToGlobalY(i);
      line(margin, lineY, margin+stageWidth, lineY);
    }
  }
  
  // Range Bar
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(margin+30, margin+stageHeight-30, margin+stageWidth/10, margin+stageHeight-30);
  text(str(rangeX/100)+" um", margin+30, margin+stageHeight-28+fontSize);
  strokeWeight(1);
  
  // origin dot
  noStroke();
  fill(0, 255, 0);
  ellipse(localToGlobalX(0), localToGlobalY(0), 4, 4);
  
  // display drawing objects
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).display();
  }
  objSelection.display();
  
  // show whats currently being drawn
  if (inRegion(mouseX, mouseY, margin, margin, stageWidth, stageHeight) == true) {
    cursor(CROSS);
    fill(0);
    text("x:"+str(float(localMouseX)/10), mouseX + 15, mouseY - 2);
    text("y:"+str(float(localMouseY)/10), mouseX + 15, mouseY + fontSize);
    
    if (currentTool.equals("Line")) {
      if (startDraw == false) {
        stroke(0);
        int posX = localToGlobalX(lastX);
        int posY = localToGlobalY(lastY);
        line(posX, posY, mouseX, mouseY);
      }
    } else
    if (currentTool.equals("Rect")) {
      if (startDraw == false) {
        stroke(0);
        noFill();
        int posX = localToGlobalX(lastX);
        int posY = localToGlobalY(lastY);
        rect(posX, posY, mouseX-posX, mouseY-posY);
      }
    }
    if (currentTool.equals("Edit")) {
      for (int i=0; i<drawingList.size(); i++) {
        drawingList.get(i).update();
      }
      if (selecting == true) {
        stroke(0, 255, 0);
        noFill();
        int posX = localToGlobalX(lastX);
        int posY = localToGlobalY(lastY);
        rect(posX, posY, mouseX-posX, mouseY-posY);
      }
    }
  } else {
    cursor(ARROW);
  }
  
  // show current pos
  int posX = localToGlobalX(currX);
  int posY = localToGlobalY(currY);
  stroke(0);
  line(posX-7, posY, posX+7, posY);
  line(posX, posY-7, posX, posY+7);
  noStroke();
  fill(0, 0, 255);
  ellipse(posX, posY, 8, 8);
  fill(0, 255, 0);
  ellipse(posX, posY, 4, 4);
  
  // draw toolbars
  for (int i=0; i<topToolbar.length; i++) {
    topToolbar[i].display();
  }
  for (int i=0; i<bottomToolbar.length; i++) {
    bottomToolbar[i].display();
  }
}

void keyPressed() {
  if (keyCode == BACKSPACE) {
    objSelection.delete();
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    slider.press();
    if (currentTool.equals("Edit")) {
      objSelection.press();
      if (dragging == false) {
        if (inRegion(mouseX, mouseY, margin, margin, stageWidth, stageHeight) == true) {
          lastX = globalToLocalX(mouseX);
          lastY = globalToLocalY(mouseY);
          selecting = true;
        }
      }
    }
  } else
  if (mouseButton == RIGHT) {
    objSelection.erase();
  }
}

// performed when mouse is released
void mouseReleased() {
  if (mouseButton == LEFT) {
    if (dragging) {
      // stops drag events
      slider.release();
      objSelection.release();
    } else {
      // UPDATE TOOLBAR
      if (pointButton.over()) {
        setTool(pointButton, "Point");
        setSlider("Time");
      }
      if (lineButton.over()) {
        setTool(lineButton, "Line");
        setSlider("Speed");
      }
      if (curveButton.over()) {
        setTool(curveButton, "Curve");
        setSlider("Speed");
      }
      if (rectButton.over()) {
        setTool(rectButton, "Rect");
        setSlider("Speed");
      }
      if (ellipseButton.over()) {
        setTool(ellipseButton, "Ellipse");
        setSlider("Speed");
      }
      if (zoomInButton.over()) {
        setTool(zoomInButton, "ZoomIn");
      }
      if (zoomOutButton.over()) {
        setTool(zoomOutButton, "ZoomOut");
      }
      if (editButton.over()) {
        setTool(editButton, "Edit");
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
      // PERFORM ACTIONS
      if (inRegion(mouseX, mouseY, margin, margin, stageWidth, stageHeight) == true) {
        int localX = toGrid(globalToLocalX(mouseX));
        int localY = toGrid(globalToLocalY(mouseY));
        if (currentTool.equals("Point")) {
          // adds point
          drawingList.add(new PointObj(slider.val, localX, localY));
        } else
        if (currentTool.equals("Line")) {
          // adds line
          if (startDraw == true) {
            startDraw = false;
            lastX = localX;
            lastY = localY;
          } else {
            drawingList.add(new LineObj(slider.val, lastX, lastY, localX, localY));
            lastX = localX;
            lastY = localY;
          }
        } else
        if (currentTool.equals("Rect")) {
          // adds rect
          if (startDraw == true) {
            startDraw = false;
            lastX = localX;
            lastY = localY;
          } else {
            startDraw = true;
            drawingList.add(new RectObj(slider.val, lastX, lastY, localX, localY));
          }
        } else
        if (currentTool.equals("ZoomIn")) {
          // zooms in
          lowX = localX-int(rangeX*0.25);
          lowY = localY-int(rangeY*0.25);
          rangeX *= 0.5;
          rangeY = int((float(stageHeight)/stageWidth)*rangeX);
        } else
        if (currentTool.equals("ZoomOut")) {
          // zooms out
          lowX = localX-int(rangeX);
          lowY = localY-int(rangeY);
          rangeX *= 2;
          rangeY = int((float(stageHeight)/stageWidth)*rangeX);
        } else
        if (currentTool.equals("Edit")) {
          if (selecting) {
            selecting = false;
            for (int i=0; i<drawingList.size(); i++) {
              DrawingObj currObj = drawingList.get(i);
              if (currObj.inBounds(lastX, lastY, globalToLocalX(mouseX), globalToLocalY(mouseY))) {
                if (currObj.selected == false) {
                  objSelection.insert(currObj);
                }
              }
            }
          }
        }
      }
    }
  } else
  if (mouseButton == RIGHT) {
    if (currentTool.equals("Line")) {
      startDraw = true;
    }
  }
}

// begins command sequence to send to proscan
void runSequence() {
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).makeCommands();
  }
}

void saveData() {
  int returnVal = fileChooser.showSaveDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) { 
    File file = fileChooser.getSelectedFile();
    String[] strings = new String[drawingList.size()];
    for (int i=0; i<drawingList.size(); i++) {
      DrawingObj currObj = drawingList.get(i);
      strings[i] = currObj.toString();
    }
    print (file.getPath());
    saveStrings(file.getPath(), strings);
  }
}

void loadData() {
  int returnVal = fileChooser.showOpenDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) { 
    File file = fileChooser.getSelectedFile();
    drawingList.clear();
    String[] strings = loadStrings(file.getPath());
    for (int i=0; i<strings.length; i++) {
      String[] vals = splitTokens(strings[i], " ");
      if (vals[0].equals("LINE")) {
        int speed = parseInt(vals[1].trim());
        int x1 = parseInt(vals[2].trim());
        int y1 = parseInt(vals[3].trim());
        int x2 = parseInt(vals[4].trim());
        int y2 = parseInt(vals[5].trim());
        drawingList.add(new LineObj(speed, x1, y1, x2, y2));
      }
      if (vals[0].equals("RECT")) {
        int speed = parseInt(vals[1].trim());
        int x1 = parseInt(vals[2].trim());
        int y1 = parseInt(vals[3].trim());
        int x2 = parseInt(vals[4].trim());
        int y2 = parseInt(vals[5].trim());
        drawingList.add(new RectObj(speed, x1, y1, x2, y2));
      }
      if (vals[0].equals("POINT")) {
        int time = parseInt(vals[1].trim());
        int x = parseInt(vals[2].trim());
        int y = parseInt(vals[3].trim());
        drawingList.add(new PointObj(time, x, y));
      }
    }
  }
}

void setTool(Clickable tool, String toolName) {
  for (int i=0; i<drawingTools.length; i++) {
    Clickable currButton = (Clickable)drawingTools[i];
    currButton.pressed = false;
  }
  tool.pressed = true;
  startDraw = true;
  currentTool = toolName;
}

void setSlider(String mode) {
  if (mode.equals("Speed")) {
    currTime = slider.val;
    slider.setVals(currSpeed, maxSpeed);
    slider.text = "Speed";
    slider.unit = " um/s";
  }
  if (mode.equals("Time")) {
    currSpeed = slider.val;
    slider.setVals(currTime, maxTime);
    slider.text = "Time";
    slider.unit = " cs";
  }
}

