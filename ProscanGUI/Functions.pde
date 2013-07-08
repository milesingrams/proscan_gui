void saveData() {
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
  if (vals[0].equals("LINE")) {
    int speed = parseInt(vals[1].trim());
    int x1 = parseInt(vals[2].trim());
    int y1 = parseInt(vals[3].trim());
    int x2 = parseInt(vals[4].trim());
    int y2 = parseInt(vals[5].trim());
    return new LineObj(speed, x1, y1, x2, y2);
  } else 
  if (vals[0].equals("RECT")) {
    int speed = parseInt(vals[1].trim());
    int x1 = parseInt(vals[2].trim());
    int y1 = parseInt(vals[3].trim());
    int x2 = parseInt(vals[4].trim());
    int y2 = parseInt(vals[5].trim());
    return new RectObj(speed, x1, y1, x2, y2);
  } else
  if (vals[0].equals("POINT")) {
    int time = parseInt(vals[1].trim());
    int x = parseInt(vals[2].trim());
    int y = parseInt(vals[3].trim());
    return new PointObj(time, x, y);
  } else {
    return new DrawingObj(new int[]{}, new int[]{});
  }
}

void setTool(Clickable tool, String toolName) {
  for (int i=0; i<drawingTools.length; i++) {
    Clickable currButton = (Clickable)drawingTools[i];
    currButton.pressed = false;
  }
  for (int i=0; i<drawingList.size(); i++) {
    drawingList.get(i).endEdit();
  }
  tool.pressed = true;
  currentTool = toolName;
}
