import java.util.Timer;
import java.util.TimerTask;

interface Command {
  void send();
  void recieve(String input);
}

class TextCommand implements Command {
  String args;
  String command;
  
  TextCommand(String c, String a) {
    command = c;
    args = a;
  }
  
  String toString() {
    return command+","+args;
  }
  
  void send() {
    serialConn.write(toString()+"\r");
  }
  
  void recieve(String input) {
    runningCommand = false;
    commandList.remove(0);
    runNext();
  }
}

class ShutterCommand implements Command {
  boolean isOpen = false;
  float time;
  Timer timer;

  class nextTask extends TimerTask {
    public void run() {
      setShutter(false);
      commandList.remove(0);
      runNext();
      timer.cancel();
    }
  }
  
  ShutterCommand (boolean iOpen, float iTime) {
    isOpen = iOpen;
    time = iTime;
  }
  
  void send() {
    setShutter(isOpen);
    if (time > 0) {
      timer = new Timer();
      timer.schedule(new nextTask(), int(time*1000));
    } else {
      commandList.remove(0);
      runNext();
    }
  }
  
  void recieve(String input) {
  }
  
  String toString() {
    return "SET SHUTTER "+str(isOpen)+" for "+str(time)+"s";
  }
}

class PosCommand implements Command {
  void send() {
    serialConn.write("PS\r");
  }
  
  void recieve(String input) {
    String[] vals = splitTokens(input, ", ");
    scopeX = float(parseInt(vals[0].trim()))/10;
    scopeY = float(parseInt(vals[1].trim()))/10;
    runningCommand = false;
    commandList.remove(0);
    runNext();
  }
  
  String toString() {
    return "GET POS";
  }
}

class SpeedCommand implements Command {
  float speed;
  
  SpeedCommand(float iSpeed) {
    speed = iSpeed;
  }
  
  void send() {
    serialConn.write("SMS,"+str(int(speed*10))+",i"+"\r");
  }
  
  void recieve(String input) {
    runningCommand = false;
    commandList.remove(0);
    runNext();
  }
  
  String toString() {
    return "SET SPEED: "+str(speed)+"um/s";
  }
}

class MoveCommand implements Command {
  float destX;
  float destY;
  boolean shut;
  boolean recieved = false;
  
  MoveCommand(float ix, float iy, boolean iShut) {
    destX = ix;
    destY = iy;
    shut = iShut;
  }
  
  void send() {
    serialConn.write("G,"+str(int(destX*10))+","+str(int(destY*10))+"\r");
  }
  
  void recieve(String input) {
    String[] vals = splitTokens(input, ", ");
    if (recieved == false) {
      recieved = true;
      serialConn.write("PS\r");
      setShutter(shut);
    } else {
      scopeX = float(parseInt(vals[0].trim()))/10;
      scopeY = float(parseInt(vals[1].trim()))/10;
      float distX = abs(destX-scopeX);
      float distY = abs(destY-scopeY);
      float dist = sqrt(pow(distX, 2)+pow(distY, 2));
      
      if (dist <= precision) {
        runningCommand = false;
        if (shutter == true) {
          setShutter(false);
        }
        commandList.remove(0);
        runNext();
      } else {
        serialConn.write("PS\r");
      }
    }
  }
  
  String toString() {
    return "MOVE: x:"+str(destX)+"um y:"+str(destY)+"um with Shutter: "+str(shut);
  }
}

