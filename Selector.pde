class Selector {
  float xPos;
  float yPos;
  float sizeX;
  float sizeY;
  boolean horizontal;
  color[] unSelected;
  color[] selected;
  String[] labels;
  int keyboardKeyNext;
  int keyboardKeyPrev;
  String gamepadNext;
  String gamepadPrev;

  int[] mouseID;
  int value;
  int lastValue;
  boolean justPressed=false;
  boolean wasIncrementing=false;
  Selector(float _xPos, float _yPos, float _sizeX, float _sizeY, boolean _horizontal, color[] _unSelected, color[] _selected, String[] _labels, int _keyboardKeyNext, int _keyboardKeyPrev, String _gamepadNext, String _gamepadPrev) {
    xPos=_xPos;
    yPos=_yPos;
    sizeX=_sizeX;
    sizeY=_sizeY;
    horizontal=_horizontal;
    unSelected=_unSelected;
    selected=_selected;
    labels=_labels;
    keyboardKeyPrev=_keyboardKeyPrev;
    keyboardKeyNext=_keyboardKeyNext;
    gamepadPrev=_gamepadPrev;
    gamepadNext=_gamepadNext;

    mouseID=new int[labels.length];
    for (int i=0; i<labels.length; i++) {
      if (horizontal) {
        mouseID[i]=mousescreen.registerZone(xPos+i*sizeX/labels.length, yPos, sizeX/labels.length, sizeY);
      } else { //vertical
        mouseID[i]=mousescreen.registerZone(xPos, yPos+i*sizeY/labels.length, sizeX, sizeY/labels.length);
      }
    }
    if (selected.length!=labels.length) {
      println("ERROR: color[] selected and String[] labels must be the same length!");
      exit();
    }
    if (unSelected.length!=labels.length) {
      println("ERROR: color[] unSelected and String[] labels must be the same length!");
      exit();
    }
  }

  int run(int inVal) {
    justPressed=false;
    lastValue=value;
    value=constrain(inVal, 0, labels.length-1);
    if (keyboardCtrl.isPressed(keyboardKeyNext)||gamepadButton(gamepadNext, false)) {
      if (!wasIncrementing) {
        wasIncrementing=true;
        value++;
        if (value>=labels.length) {
          value=0;
        }
        justPressed=true;
      }
    } else if (keyboardCtrl.isPressed(keyboardKeyPrev)||gamepadButton(gamepadPrev, false)) {
      if (!wasIncrementing) {
        wasIncrementing=true;
        value--;
        if (value<0) {
          value=labels.length-1;
        }
        justPressed=true;
      }
    } else {
      wasIncrementing=false;
    }

    for (int i=0; i<mouseID.length; i++) {
      if (mousescreen.readPressed(mouseID[i])) {
        justPressed=true;
        value=i;
        break;
      }
    }


    for (int i=0; i<labels.length; i++) {
      int xTemp;
      int yTemp;
      int sizeXTemp;
      int sizeYTemp;
      if (horizontal) {
        xTemp=int(xPos+i*sizeX/labels.length);
        yTemp=int(yPos);
        sizeXTemp=int(sizeX/labels.length);
        sizeYTemp=int(sizeY);
      } else {
        xTemp=int(xPos);
        yTemp=int(yPos+i*sizeY/labels.length);
        sizeXTemp=int(sizeX);
        sizeYTemp=int(sizeY/labels.length);
      }
      pushStyle();
      noStroke();
      if (value==i) {
        fill(selected[i]);
      } else {
        fill(unSelected[i]);
      }
      rect(xTemp, yTemp, sizeXTemp, sizeYTemp);
      if (value!=i) {
        fill(selected[i]);
      } else {
        fill(unSelected[i]);
      }
      textSize(sizeYTemp/2);
      textAlign(CENTER, CENTER);
      text(labels[i], xTemp, yTemp, sizeXTemp, sizeYTemp);
      popStyle();
    }

    return value;
  }
  int getVal() {
    return value;
  }
  boolean justChanged() {
    return value!=lastValue;
  }
  boolean justPressed() {
    return justPressed;
  }
}
