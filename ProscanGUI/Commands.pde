interface MicroscopeStage {
  void connect();
  void disconnect();
  void parseInput(String input);
}

class ProscanIII implements MicroscopeStage {
  boolean connected = false;
  String serialName = "COM3";
  
  void connect() {
    while (connected == false) {
      stageSerial.write("PS\r");
      delay(1000);
      connected = true;
    }
  }
  
  void disconnect() {
    connected = false;
  }
  
  void parseInput(String input) {
    if (connected == false) {
      if (input != null) {
        connected = true;
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
}

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
    stageSerial.write(toString()+"\r");
  }
  
  void recieve(String input) {
    commandList.remove(0);
    runNext();
  }
}

class ShutterCommand implements Command {
  boolean isOpen = false;
  float time;
  Timer timer;

  class Finish extends TimerTask {
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
      timer.schedule(new Finish(), int(time*1000));
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
    stageSerial.write("PS\r");
  }
  
  void recieve(String input) {
    String[] vals = splitTokens(input, ", ");
    scopeX = float(parseInt(vals[0].trim()))/10;
    scopeY = float(parseInt(vals[1].trim()))/10;
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
    stageSerial.write("SMS,"+str(int(speed*100))+",i"+"\r");
  }
  
  void recieve(String input) {
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
  float aveDeltaScope = 0;
  float precision = 0.5;
  float sensitivity = 0.07;
  
  MoveCommand(float ix, float iy, boolean iShut) {
    destX = ix;
    destY = iy;
    shut = iShut;
  }
  
  void send() {
    stageSerial.write("G,"+str(int(destX*10))+","+str(int(destY*10))+"\r");
  }
  
  void recieve(String input) {
    String[] vals = splitTokens(input, ", ");
    
    if (recieved == false) {
      recieved = true;
      stageSerial.write("PS\r");
    } else {
      
      float newScopeX = float(parseInt(vals[0].trim()))/10;
      float newScopeY = float(parseInt(vals[1].trim()))/10;
      float deltaScope = sqrt(pow((scopeX-newScopeX), 2)+pow((scopeY-newScopeY), 2));
      aveDeltaScope = (aveDeltaScope+deltaScope)/2;
      scopeX = newScopeX;
      scopeY = newScopeY;
      
      float destDist = sqrt(pow((destX-scopeX), 2)+pow((destY-scopeY), 2));
      
      if (destDist > precision) {
        if (shut && !shutter && aveDeltaScope > sensitivity) {
          setShutter(true);
        }
      } else {
        if (aveDeltaScope < sensitivity) {
          if (shut && shutter) {
            setShutter(false);
          }
          commandList.remove(0);
          runNext();
          return;
        }
      }
      stageSerial.write("PS\r");
    }
  }
  
  String toString() {
    return "MOVE: x:"+str(destX)+"um y:"+str(destY)+"um with Shutter: "+str(shut);
  }
}

