class DialColorConfig {
  DialColorConfig(int _min, int _max, color _c) {
    min=_min;
    max=_max;
    c=_c;
  }
  public int min;
  public int max;
  public color c;
}
class Dial {
  int xPos;
  int yPos;
  int size;
  String label;
  int min;
  int max;
  int realMax;
  int fineMarkings;
  int heavyMarkings;
  int labeledHeavyMarkings;
  ArrayList<DialColorConfig> background;
  Dial(int _xPos, int _yPos, int _size, String _label, int _min, int _max, int _realMax, int _fineMarkings, int _heavyMarkings, int _labeledHeavyMarkings, ArrayList<DialColorConfig> _background) {
    xPos=_xPos;
    yPos=_yPos;
    size=_size;
    label=_label;
    min=_min;
    max=_max;
    realMax=_realMax;
    fineMarkings=_fineMarkings;
    heavyMarkings=_heavyMarkings;
    labeledHeavyMarkings=_labeledHeavyMarkings;
    background=_background;
  }

  void run(float inVal) {
    pushStyle();
    pushMatrix();
    fill(255);
    strokeWeight(3);
    stroke(75);
    translate(xPos, yPos);
    ellipse(0, 0, size, size); //dial circle

    if (background!=null) {
      pushMatrix();
      rotate(PI); //align to nicer frame of reference
      noStroke();
      for (DialColorConfig b : background) {
        fill(b.c); //color wedges to background
        arc(0, 0, size-3, size-3, PI/max*b.min, PI/max*b.max);
      }
      popMatrix();
    }

    pushMatrix(); // rotate dial
    rotate(-PI/2);
    rotate(map(inVal, min, max, 0, PI)); //rotate dial
    pushMatrix(); //shifting triangle backwards
    translate(0, size*.2);
    noStroke();
    fill(0);
    triangle(-size*.025, 0, size*.025, 0, 0, -size*.65);
    popMatrix(); //shifting triangle backwards
    fill(0); //little circle where the dial attaches
    ellipse(0, 0, size*.09, size*.09);
    fill(#999999);
    ellipse(0, 0, size*.065, size*.065);
    popMatrix(); // rotate dial
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(size*0.1);
    text(nfs(inVal, 1, 2), 0, size*.4, size*.4, size*.15);
    text(label, 0, size*.25, size*.7, size*.15);
    textSize(size*.075);
    fill(0);
    for (int i=min; i<=realMax; i++) {
      if (i%labeledHeavyMarkings==0) {
        strokeWeight(4);
        stroke(0);
        line(cos(i*PI/max)*-size*0.4, sin(i*PI/max)*-size*0.4, cos(i*PI/max)*-size*0.35, sin(i*PI/max)*-size*0.35);
        text(str(i), cos(i*PI/max)*-size*0.26, sin(i*PI/max)*-size*0.26, size*.15, size*.2);
      }
      if (i%heavyMarkings==0) {
        strokeWeight(2);
        stroke(0);
        line(cos(i*PI/max)*-size*0.45, sin(i*PI/max)*-size*0.45, cos(i*PI/max)*-size*0.37, sin(i*PI/max)*-size*0.37);
      } else if (i%fineMarkings==0) {
        strokeWeight(1);
        stroke(0);
        line(cos(i*PI/max)*-size*0.45, sin(i*PI/max)*-size*0.45, cos(i*PI/max)*-size*0.4, sin(i*PI/max)*-size*0.4);
      }
    }
    popMatrix();
    popStyle();
  }
}
