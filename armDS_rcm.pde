/*

 
 libraries needed:
 "UDP" 
 "GameControlPlus"
 
 */
String gamepadName ="Controller (XBOX 360 For Windows)";
/////////////////////////add interface elements and variables here
EnableSwitch enableSwitch;
boolean enabled=false;
Selector compressorModeSelector;
int compressorMode=1;

Dial storedPressureDial;
float storedPressure=0;

float batVolt=0.0;

void setup() {
  size(1900, 1000);
  shapeMode(CENTER);
  rectMode(CENTER);
  background(200);
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
  setupGamepad(gamepadName);

  //setup UI here
  enableSwitch=new EnableSwitch(width/14, height/28, width/7, height/14);
  compressorModeSelector=new Selector(int(width*.7), int(height*.86), width/10-3, height/6, false, "compressor"
    , new color[]{color(55), color(55), color(65, 40, 40)}
    , new color[]{color(255, 190, 0), color(200, 255, 200), color(0, 210, 0)}
    , new String[]{"override", "normal", "off"}, 0, 0, "", "");

  storedPressureDial=new Dial(width/2, height/2, width/8);
}
void draw() {
  background(200);
  if (keyPressed&&key==' ') {
    enabled=false;
  }
  enabled=enableSwitch.run(enabled);
  compressorMode=compressorModeSelector.run(compressorMode);
  storedPressureDial.run(map(mouseX, 0, width, -0, 160));
  /////////////////////////////////////add UI here

  String[] msg={"ping", "main voltage"};
  String[] data={str(wifiPing), str(batVolt)};
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
