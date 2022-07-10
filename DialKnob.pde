class DialKnob {
  int xPos;
  int yPos;
  int size;
  int min;
  int max;
  color c;
  int mouseID;
  int lowerEdge;
  int upperEdge;
  int maxAngle;
  DialKnob(int _xPos, int _yPos, int _size, int _min, int _max, int _maxAngle, color _color, int _lowerEdge, int _upperEdge) {
    xPos=_xPos;
    yPos=_yPos;
    size=_size;
    min=_min;
    max=_max;
    maxAngle=_maxAngle;
    c=_color;
    mouseID=mousescreen.registerZone(xPos, yPos, size, size);
    lowerEdge=_lowerEdge;
    upperEdge=_upperEdge;
  }

  float run(float inVal) {
    PVector mousePos=mousescreen.readPos(mouseID, new PVector(0, 0), true);
    if (mousescreen.readPressed(mouseID)&&mouseButton==LEFT) {
      if (mousePos.x!=0||mousePos.y!=0) {
        inVal=constrain(map(90+degrees(atan2(mousePos.x, mousePos.y)), 0, maxAngle, min, max), min, max);
      }
    }
    if (abs(mousePos.x)<1&&abs(mousePos.y)<1) {
      inVal-=mouseWheel/10.0;
    }
    inVal=constrain(inVal, min, maxAngle);
    pushStyle();
    pushMatrix();
    translate(xPos, yPos);
    rotate(PI); //align to nicer frame of reference
    noStroke();
    fill(c); //color wedges to background
    arc(0, 0, size, size, PI/max*maxAngle/180.0*(inVal+lowerEdge), PI/max*maxAngle/180.0*(inVal+upperEdge));
    popMatrix();
    popStyle();
    return inVal;
  }
}
