class DialKnob {
  int xPos;
  int yPos;
  int size;
  int min;
  int max;
  color c;
  int mouseID;
  DialKnob(int _xPos, int _yPos, int _size, int _min, int _max, color _color) {
    xPos=_xPos;
    yPos=_yPos;
    size=_size;
    min=_min;
    max=_max;
    c=_color;
    mouseID=mousescreen.registerZone(xPos, yPos, size, size);
  }

  float run(float inVal) {
    PVector mousePos=mousescreen.readPos(mouseID, new PVector(0, 0), true);
    if (mousescreen.readPressed(mouseID)) {
      if (mousePos.x!=0||mousePos.y!=0) {
        inVal=constrain(map(90+degrees(atan2(mousePos.x, mousePos.y)), 0, 180, min, max), min, max);
      }
    }
    if (abs(mousePos.x)<1&&abs(mousePos.y)<1) {
      inVal-=mouseWheel/5.0;
    }
    inVal=constrain(inVal, min, max);
    pushStyle();
    pushMatrix();
    translate(xPos, yPos);
    rotate(PI); //align to nicer frame of reference
    noStroke();
    fill(c); //color wedges to background
    arc(0, 0, size, size, PI/max*(inVal-1), PI/max*(inVal+1));
    popMatrix();
    popStyle();
    return inVal;
  }
}
