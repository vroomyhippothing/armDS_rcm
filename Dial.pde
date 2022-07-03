class Dial {
  int xPos;
  int yPos;
  int size;
  String label;
  Dial(int _xPos, int _yPos, int _size, String _label) {
    xPos=_xPos;
    yPos=_yPos;
    size=_size;
    label=_label;
  }

  void run(float inVal) {
    pushStyle();
    pushMatrix();
    fill(255);
    strokeWeight(3);
    stroke(75);
    translate(xPos, yPos);
    ellipse(0, 0, size, size);

    pushMatrix();
    rotate(PI);    
    noStroke();
    fill(255, 255, 0);
    arc(0, 0, size, size, PI/120*0, PI/120*60);
    fill(0, 255, 0);
    arc(0, 0, size, size, PI/120*60, PI/120*120);
    fill(255, 40, 40);
    arc(0, 0, size, size, PI/120*120, PI/120*140);
    popMatrix();

    pushMatrix(); // rotate dial
    rotate(-PI/2);
    rotate(map(inVal, 0, 120, 0, PI)); //rotate dial
    pushMatrix(); //shifting triangle backwards
    translate(0, size*.2);
    noStroke();
    fill(0);
    triangle(-size*.025, 0, size*.025, 0, 0, -size*.65);
    popMatrix(); //shifting triangle backwards
    fill(0);
    ellipse(0, 0, size*.09, size*.09);
    fill(#A28802);
    ellipse(0, 0, size*.07, size*.07);
    popMatrix(); // rotate dial
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(size*0.1);
    text(str(inVal), 0, size*.4, size*.3, size*.15);
    text(label, 0, size*.25, size*.7, size*.15);
    textSize(size*.075);
    fill(0);
    for (int i=0; i<=140; i++) {
      if (i%20==0) {
        strokeWeight(4);
        stroke(0);
        line(cos(i*PI/120)*-size*0.4, sin(i*PI/120)*-size*0.4, cos(i*PI/120)*-size*0.35, sin(i*PI/120)*-size*0.35);
        text(str(i), cos(i*PI/120)*-size*0.26, sin(i*PI/120)*-size*0.26, size*.15, size*.2);
      }
      if (i%10==0) {
        strokeWeight(2);
        stroke(0);
        line(cos(i*PI/120)*-size*0.45, sin(i*PI/120)*-size*0.45, cos(i*PI/120)*-size*0.37, sin(i*PI/120)*-size*0.37);
      } else if (i%2==0) {
        strokeWeight(1);
        stroke(0);
        line(cos(i*PI/120)*-size*0.45, sin(i*PI/120)*-size*0.45, cos(i*PI/120)*-size*0.4, sin(i*PI/120)*-size*0.4);
      }
    }
    popMatrix();
    popStyle();
  }
}
