class Dial {
  int xPos;
  int yPos;
  int size;
  Dial(int _xPos, int _yPos, int _size) {
    xPos=_xPos;
    yPos=_yPos;
    size=_size;
  }

  void run(float inVal) {
    pushStyle();
    pushMatrix();
    fill(255);
    strokeWeight(3);
    stroke(75);
    translate(xPos, yPos);
    ellipse(0, 0, size, size);
    noStroke();
    fill(0);
    pushMatrix(); // rotate dial
    rotate(-PI/2);
    rotate(map(inVal, 0, 120, 0, PI));
    pushMatrix(); //shifting triangle backwards
    translate(0, size*.2);
    triangle(-size*.02, 0, size*.02, 0, 0, -size*.65);
    popMatrix(); //shifting triangle backwards
    fill(0);
    ellipse(0, 0, size*.09, size*.09);
    fill(#A28802);
    ellipse(0, 0, size*.07, size*.07);
    popMatrix(); // rotate dial
    fill(0);
    text(" "+((abs(int(inVal))>=100)?(inVal>0?" ":"")+str(int(inVal)):nfs(inVal, 0, (abs(inVal)>=10?1:2))), 0, size*.4, size*.4, size*.3);
    popMatrix();
    popStyle();
  }
}
