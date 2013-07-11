void setShutter(boolean mode) {
  shutter = mode;
  if (mode) {
    tcpServer.write("1");
  } else {
    tcpServer.write("0");
  }
}

void saveData() {
  fileChooser.showSaveDialog(this);
  int returnVal = fileChooser.showSaveDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fileChooser.getSelectedFile();
    String[] strings = new String[drawingList.size()];
    for (int i=0; i<drawingList.size(); i++) {
      DrawingObj currObj = drawingList.get(i);
      strings[i] = currObj.toString();
    }
    saveStrings(file.getPath(), strings);
  }
}

void loadData() {
  int returnVal = fileChooser.showOpenDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) { 
    File file = fileChooser.getSelectedFile();
    drawingList.clear();
    objSelection.deselect();
    drawingList = parseStrings(loadStrings(file.getPath()));
  }
}

ArrayList<DrawingObj> parseStrings(String[] strings) {
  ArrayList<GroupObj> groups = new ArrayList<GroupObj>();
  groups.add(new GroupObj());
  
  for (int i=0; i<strings.length; i++) {
    String[] vals = splitTokens(strings[i], " ");
    if (vals[0].equals("GROUP")) {
      groups.add(new GroupObj());
    } else
    if (vals[0].equals("ENDGROUP")) {
        GroupObj lastGroup = groups.remove(groups.size()-1);
        groups.get(groups.size()-1).insert(lastGroup);
    } else {
        groups.get(groups.size()-1).insert(parseVals(vals));
    }
  }
  
  return (ArrayList<DrawingObj>)groups.get(0).objs.clone();
}

DrawingObj parseVals(String[] vals) {
  if (vals[0].equals("POINT")) {
    int time = parseInt(vals[1].trim());
    float x = parseFloat(vals[2].trim());
    float y = parseFloat(vals[3].trim());
    return new PointObj(time, x, y);
  } else
  if (vals[0].equals("LINE")) {
    int speed = parseInt(vals[1].trim());
    float x1 = parseFloat(vals[2].trim());
    float y1 = parseFloat(vals[3].trim());
    float x2 = parseFloat(vals[4].trim());
    float y2 = parseFloat(vals[5].trim());
    return new LineObj(speed, x1, y1, x2, y2);
  } else 
  if (vals[0].equals("CURVE")) {
    int speed = parseInt(vals[1].trim());
    float x1 = parseFloat(vals[2].trim());
    float y1 = parseFloat(vals[3].trim());
    float x2 = parseFloat(vals[4].trim());
    float y2 = parseFloat(vals[5].trim());
    float cx1 = parseFloat(vals[6].trim());
    float cy1 = parseFloat(vals[7].trim());
    float cx2 = parseFloat(vals[8].trim());
    float cy2 = parseFloat(vals[9].trim());
    return new CurveObj(speed, x1, y1, x2, y2, cx1, cy1, cx2, cy2);
  } else
  if (vals[0].equals("RECT")) {
    int speed = parseInt(vals[1].trim());
    float x1 = parseFloat(vals[2].trim());
    float y1 = parseFloat(vals[3].trim());
    float x2 = parseFloat(vals[4].trim());
    float y2 = parseFloat(vals[5].trim());
    return new RectObj(speed, x1, y1, x2, y2);
  } else
  if (vals[0].equals("ELLIPSE")) {
    int speed = parseInt(vals[1].trim());
    float x1 = parseFloat(vals[2].trim());
    float y1 = parseFloat(vals[3].trim());
    float x2 = parseFloat(vals[4].trim());
    float y2 = parseFloat(vals[5].trim());
    return new EllipseObj(speed, x1, y1, x2, y2);
  } else {
    return new DrawingObj(new float[]{}, new float[]{});
  }
}

boolean inRegion(float x, float y, float bx1, float by1, float bx2, float by2) {
  if (x >= bx1 && x <= bx2 || x >= bx1 && x <= bx2) {
    if (y >= by1 && y <= by2 || y >= by1 && y <= by2) {
      return true;
    }
  }
  return false;
}

// Gives an intermediate between red and blue
color redblueColor (float x, float maxX) {
  return lerpColor(color(0, 0, 255), color(255, 0, 0), x/maxX);
}
