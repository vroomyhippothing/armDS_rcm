class Slider {
  color background;
  color stick;
  float xPos;
  float yPos;
  float s;
  float w;
  float low;
  float high;
  int pointerID;
  String ga;
  int pKey;
  int mKey;
  int tilt;
  boolean horizontal;
  boolean reverse;
  float inc;
  Slider(float _xPos, float _yPos, float _size, float _width, float _low, float _high, color _background, color _stick, String _ga, int _pKey, int _mKey, float _inc, int _tilt, boolean _horizontal, boolean _reverse) {
    xPos=_xPos;
    yPos=_yPos;
    s=_size;
    w=_width;
    background=_background;
    stick=_stick;
    low=_low;
    high=_high;
    ga=_ga;
    pKey=_pKey;
    mKey=_mKey;
    tilt=_tilt;
    inc=_inc;
    horizontal=_horizontal;
    reverse=_reverse;
    pointerID=mousescreen.registerZone(xPos, yPos, boolAB(horizontal, s+w, w), boolAB(horizontal, w, s+w));
  }
  float run(float v) {
    pushStyle();
    v=map(v, low, high, -1, 1);
    if (reverse) {
      v=-v;
    }
    noStroke();
    fill(background);
    rect(xPos, yPos, boolAB(horizontal, s+w, w), boolAB(horizontal, w, s+w));
    v=gamepadVal(ga, v);
    v+=inc*keyboardCtrl.slider(0, pKey, mKey);
    if (horizontal)v=mousescreen.readPos(pointerID, new PVector(v, 0)).x;
    else v=mousescreen.readPos(pointerID, new PVector(0, v)).y;
    v=map(v, -1, 1, -1-w/s, 1+w/s);
    v=constrain(v, -1, 1);
    fill(stick);
    rect(xPos+boolAB(horizontal, s/2*v, 0), yPos-boolAB(horizontal, 0, s/2*v), w, w);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(w*.25);
    text(nfp(map(v, -1, 1, low, high), 1, 3), xPos+boolAB(horizontal, s/2*v, 0), yPos-boolAB(horizontal, 0, s/2*v), w, w/2);
    if (reverse) {
      v=-v;
    }
    v=map(v, -1, 1, low, high);
    popStyle();
    return v;
  }
}
float boolAB(boolean v, float a, float b) {
  if (v)return a;
  return b;
}
