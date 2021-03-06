Mousescreen mousescreen;
boolean mousePress=false;
float mouseWheel=0;
class Mousescreen {
  ArrayList<MouseZone> zones;
  Mousescreen() {
    zones=new ArrayList<MouseZone>();
  }
  int registerZone(float x, float y, float w, float h) {
    int id=zones.size();
    zones.add(new MouseZone(id, x, y, w, h));
    return id;
  }
  void deregisterZone(int id) {
    zones.remove(id);
  }
  boolean readPressed(int id) {
    MouseZone zone=zones.get(id);
    if (!mousePressed) {
      zone.touched=false;
    }
    if (abs(mouseX-zone.x)<zone.w/2&&abs(mouseY-zone.y)<zone.h/2&&mousePress) {
      zone.touched=true;
    }
    zones.set(id, zone);
    return zone.touched;
  }
  PVector readPos(int id, PVector v) {
    return readPos(id, v, false);
  }

  PVector readPos(int id, PVector v, boolean always) {
    MouseZone zone=zones.get(id);
    if (abs(mouseX-zone.x)<zone.w/2&&abs(mouseY-zone.y)<zone.h/2&&mousePress) {
      zone.touched=true;
    }
    if (!mousePressed) {
      zone.touched=false;
    }
    if (zone.touched||always) {
      v.set(((mouseX-zone.x)/zone.w*2), (((-mouseY+zone.y)/zone.h*2)));
    }
    zones.set(id, zone);
    return v;
  }
}

class MouseZone {
  boolean touched;
  int id;
  float x;
  float y;
  float w;
  float h;
  MouseZone(int _id, float _x, float _y, float _w, float _h) {
    touched=false;
    id=_id;
    x=_x;
    y=_y;
    w=_w;
    h=_h;
  }
}

void mousePressed() {
  mousePress=true;
}
