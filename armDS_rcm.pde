/////////////////////////add interface elements here
EnableSwitch enableSwitch;
Selector testSelector;
//////////////////////
float batVolt=0.0;
boolean enabled=false;
int testValue=0;
////////////////////////add variables here

void setup() {
  size(1900, 1000);
  shapeMode(CENTER);
  rectMode(CENTER);
  background(0);
  mousescreen=new Mousescreen();
  keyboardCtrl=new KeyboardCtrl();
  udp = new UDP(this);
  udp.listen(true);  
  try {
    String[] settings=loadStrings("data/wifiSettings.txt");
    wifiIP=settings[0];
    wifiPort=int(settings[1]);
  }
  catch(Exception e) {
  }
  setupGamepad("Controller (XBOX 360 For Windows)");

  //setup UI here
  enableSwitch=new EnableSwitch(width*.15, height/15, width/4, height/9);
  testSelector=new Selector(width/2, 400, 100, 500, false, new color[]{color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)}, new color[]{color(255), color(255), color(255)}, new String[]{"a", "b", "c"}, 'n', 'p', "Button 1", "Button 2");
}
void draw() {
  background(0);
  if (keyPressed&&key==' ') {
    enabled=false;
  }
  enabled=enableSwitch.run(enabled);
  testValue=testSelector.run(testValue);
  /////////////////////////////////////add UI here

  String[] msg={"main voltage", "ping"};
  String[] data={str(batVolt), str(wifiPing)};
  dispTelem(msg, data, width*7/8, height/2, width/4-1, height, 14);

  sendWifiData(true);
  mousePress=false;
}
void WifiDataToRecv() {
  batVolt=recvFl();
  ////////////////////////////////////add data to read here
}
void WifiDataToSend() {
  sendBl(enabled);
  ///////////////////////////////////add data to send here
}
