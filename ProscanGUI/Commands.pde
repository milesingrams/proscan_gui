import java.util.Timer;
import java.util.TimerTask;


interface Command {
  void run();
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
  
  void run() {
    serialConn.write(toString()+"\r");
  }
}

class ShutterCommand implements Command {
  boolean mode = false;
  long time;
  Timer timer;

  class nextTask extends TimerTask {
    public void run() {
      commandList.remove(0);
      runNext();
      timer.cancel();
    }
  }
  
  ShutterCommand (boolean im, long itime) {
    mode = im;
    time = itime;
  }
  
  void run() {
    setShutter(mode);
    if (time > 0) {
      timer = new Timer();
      timer.schedule(new nextTask(), time);
    } else {
      commandList.remove(0);
      runNext();
    }
  }
  
  String toString() {
    return "Shutter"+","+str(mode)+","+str(time);
  }
}

class MoveCommand extends TextCommand {
  float destX;
  float destY;
  boolean shutter;
  
  MoveCommand(float ix, float iy, boolean ishut) {
    super("G", int(ix*10)+","+int(iy*10));
    destX = ix;
    destY = iy;
    shutter = ishut;
  }
}
