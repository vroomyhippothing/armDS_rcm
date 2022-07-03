void dispTelem(String[] msg, String[] val, int x, int y, int w, int h, int ts) {
  pushStyle();
  textSize(ts);
  stroke(0);
  strokeWeight(1);
  fill(255);
  rect(x, y, w, h-1);
  fill(0);
  for (int i=0; i<msg.length; i++) {
    text(msg[i] + " = "+ val[i], x+0.2*ts, y-h/2+1.25*ts+1.25*i*ts, w*.94, ts*1.5);
  }
  popStyle();
}
