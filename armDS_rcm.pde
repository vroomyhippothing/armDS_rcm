/*
 libraries needed:
 * UDP
 * GameControlPlus 
 
 */
int wifiPort=25210;
String wifiIP="192.168.4.1";
static final int wifiRetryPingTime=200;
final int workingPressureConstant=60; //setting of regulator
final float compressorDutyCycleLimit=9; // rating of compressor (%)
final float compressorDutyCycleBounds=4; // how far from dutyCycleLimit does the duty cycle get while running at the maximum duty cycle?
final int compressorSetpointHysteresis=15; // difference between when the compressor turns on and when it turns off
final float pressureSwitchVal=115;//what's the lowest pressure where the pressure switch might shut off the compressor and prevent the software from having full control
final String gamepadName ="Controller (XBOX 360 For Windows)";
/////////////////////////add interface elements and variables here
EnableSwitch enableSwitch;
boolean enabled=false;

Selector compressorModeSelector;
public static class CompressorMode {
  static byte Off=2;
  static byte Normal=1;
  static byte Override=0;
}
byte compressorMode=CompressorMode.Normal;
boolean compressing=false;

Dial storedPressureDial;
float storedPressure=0;

Dial workingPressureDial;
float workingPressure=0;

Dial clawPressureDial;
float clawPressure=0;

Button clawVentButton;
boolean clawVent=false;

Slider clawPressurizeSlider;
float clawPressurize=0;

Button clawDumpButton;

Button clawAutoButton;
boolean clawAuto=true;

DialKnob clawPressureDialKnob;
float clawAutoPressure=30;

DialKnob storedPressureSetpointDialKnob;
float storedPressureSetpoint=110;

Dial compressorDutyDial;
float compressorDuty=0;

Button clawGrabButton;
boolean clawGrabAuto=false;

float timeCompressorOn=0;  // calculated in driverstation
float timeCompressorOff=0; // calculated in driverstation

boolean isCompressorOverDutyCycle=false;
float clawPressurizeValveState=0;
boolean clawVentValveState=false;

float mainVoltage=0.0;

void setup() {
  size(1900, 1000);
  shapeMode(CENTER);
  rectMode(CENTER);
  background(200);
  frameRate(60);
  mousescreen=new Mousescreen();
  keyboardCtrl=new KeyboardCtrl();
  udp = new UDP(this);
  udp.setBuffer(255);
  udp.listen(true);  
  setupGamepad(gamepadName);

  //setup UI here
  enableSwitch=new EnableSwitch(width/14, height/28, width/7, height/14);
  compressorModeSelector=new Selector(int(width*.7), int(height*.92), width/10-3, height/10, false, "compressor", color(255, 0)
    , new color[]{color(55), color(55), color(65, 40, 40)}
    , new color[]{color(255, 190, 0), color(200, 255, 200), color(0, 210, 0)}
    , new String[]{"override (o)", "normal (l)", "off (.)"}, 0, 0, null, null);

  ArrayList<DialColorConfig> storedDialBackground=new ArrayList<DialColorConfig>();
  storedDialBackground.add(new DialColorConfig(0, workingPressureConstant, color(255, 255, 0)));
  storedDialBackground.add(new DialColorConfig(workingPressureConstant, 120, color(0, 255, 0)));
  storedDialBackground.add(new DialColorConfig(120, 140, color(255, 80, 40)));
  storedPressureDial=new Dial(int(width*.695), int(height*.68), width/10-3, "stored psi", 0, 120, 140, 2, 10, 20, storedDialBackground);

  storedPressureSetpointDialKnob=new DialKnob(storedPressureDial.xPos, storedPressureDial.yPos, storedPressureDial.size, storedPressureDial.min, storedPressureDial.realMax, int(storedPressureDial.realMax*180.0/storedPressureDial.max), color(200, 25, 255, 150), -compressorSetpointHysteresis, 0);


  ArrayList<DialColorConfig> compressorDutyBackground=new ArrayList<DialColorConfig>();
  compressorDutyBackground.add(new DialColorConfig(0, int(compressorDutyCycleLimit)-4, color(0, 255, 0)));
  compressorDutyBackground.add(new DialColorConfig(int(compressorDutyCycleLimit-compressorDutyCycleBounds), int(compressorDutyCycleLimit+compressorDutyCycleBounds), color(255, 255, 0)));
  compressorDutyBackground.add(new DialColorConfig(int(compressorDutyCycleLimit)+4, 100, color(255, 155, 155)));
  compressorDutyDial=new Dial(int(width*.722), int(height*.818), width/19, "duty %", 0, 50, 50, 1, 10, 10, compressorDutyBackground);



  ArrayList<DialColorConfig> workingDialBackground=new ArrayList<DialColorConfig>();
  workingDialBackground.add(new DialColorConfig(workingPressureConstant-10, workingPressureConstant, color(0, 255, 0)));
  workingDialBackground.add(new DialColorConfig(workingPressureConstant, workingPressureConstant+10, color(255, 40, 40)));
  workingPressureDial=new Dial(int(width*.695), int(height*.49), width/10-3, "working psi", 0, workingPressureConstant, workingPressureConstant+10, 1, 10, 10, workingDialBackground);
  clawPressureDial=new Dial(int(width*.695), int(width/20+height*.01), width/10-3, "claw psi", 0, workingPressureConstant, workingPressureConstant+10, 1, 10, 10, null);

  clawPressureDialKnob=new DialKnob(clawPressureDial.xPos, clawPressureDial.yPos, clawPressureDial.size, clawPressureDial.min, clawPressureDial.realMax, int(clawPressureDial.realMax*180.0/clawPressureDial.max), color(255, 0, 255, 150), -1, 1);

  clawPressurizeSlider=new Slider(width*.68, height*.2975, height*.12, width*.03, 0, 1, color(0, 60, 0), color(255), null, 0, 0, .03, 0, false, false);
  clawVentButton=new Button(width*.73, height*.22, height*.05, color(100, 0, 0), color(200, 0, 0), "Button 5", 'v', true, false, "vent (v)");
  clawDumpButton=new Button(width*.737, height*.395, height*.04, color(150, 0, 0), color(255, 0, 0), null, ';', false, false, "DUMP    ( ; )");
  clawAutoButton=new Button(width*.72, height*.3, height*.05, color(50, 50, 200), color(200, 0, 200), null, 'p', false, false, "auto (p)");
  clawGrabButton=new Button(width*.68, height*.312, height*.075, color(25, 100, 25), color(255, 70, 255), null, 'i', false, false, "grab (i)");
}
void draw() {
  background(200);

  if ((keyboardCtrl.isPressed('[')&&keyboardCtrl.isPressed('['))||gamepadButton("Button 7", false)) { //enable
    enabled=true;
  }
  if (keyboardCtrl.isPressed(' ')||keyboardCtrl.isPressed(ENTER)||gamepadButton("Button 6", false)) { //disable
    enabled=false;
  }
  enabled=enableSwitch.run(enabled);

  //compressor mode selector keyboard control
  if (keyPressed) {
    if (key=='o')
      compressorMode=CompressorMode.Override;
    if (key=='l')
      compressorMode=CompressorMode.Normal;
    if (key=='.')
      compressorMode=CompressorMode.Off;
  }
  //"compressor on" light and compressor mode selector
  if (compressing) {
    compressorModeSelector.titleColor=color(255, 255, 225);
  } else {
    compressorModeSelector.titleColor=color(255, 0);
  }
  pushStyle();
  noStroke();
  String tempCompressorMessage="";
  if (isCompressorOverDutyCycle==false) {
    fill(25, 200, 25);
    tempCompressorMessage="compressor NORMAL";
  } else if (!compressing) {
    fill(225, 255, 0);    
    tempCompressorMessage="compressor COOLING";
  } else { // overriden
    fill(255, 130, 85);
    tempCompressorMessage="compressor OVERLOAD";
  }
  rect(int(width*.672), int(height*.805), width*.04, height*.05, width*.01, width*.01, width*.01, width*.01);
  textAlign(CENTER, CENTER);
  textSize(12);
  fill(0);
  text(tempCompressorMessage, int(width*.672), int(height*.805), width*.04, height*.05);
  popStyle();
  compressorMode=byte(compressorModeSelector.run(compressorMode));

  compressorDutyDial.run(compressorDuty*100);
  workingPressureDial.run(workingPressure);
  clawPressureDial.run(clawPressure);
  storedPressureDial.run(storedPressure);
  storedPressureSetpoint=storedPressureSetpointDialKnob.run(storedPressureSetpoint);
  pushStyle(); //display knob setpoint value as text
  textSize(20);
  if (storedPressureSetpoint>=pressureSwitchVal) {
    fill(255, 0, 0);
  } else {
    fill(180, 0, 200);
  }
  textAlign(CENTER, CENTER);
  text(nf(storedPressureSetpoint, 1, 1), width*.69, height*.70);
  popStyle();

  //claw control UI logic
  if (clawDumpButton.run()) { // the dump button is on the driverstation side, it is identical to:
    clawAuto=false; //setting the claw to manual
    //and opening both valves
    clawPressurize=1;
    clawVent=true;
    if (clawDumpButton.justPressed()) {
      compressorMode=CompressorMode.Off; //and turning the compressor off.
    }
    clawGrabAuto=false; //in regular manual mode, this variable is reset so when auto grab is selected the claw starts open.
  } else { //not dumping pressure
    clawAutoButton.setVal(clawAuto);
    clawAuto=clawAutoButton.run();
    if (clawAuto) { //automatic pressure control
      clawAutoPressure=clawPressureDialKnob.run(clawAutoPressure);
      pushStyle(); //display claw auto pressure setpoint as text on the knob
      textSize(20);
      fill(180, 0, 180);
      textAlign(CENTER, CENTER);
      text(nf(clawAutoPressure, 1, 1), width*.695, height*.13);
      popStyle();

      clawGrabButton.setVal(clawGrabAuto); //set button to the state of the variable in case the variable has been changed

      if (gamepadVal("Z Axis", 0)<-.5) {
        clawGrabButton.setVal(true);
      }
      if (gamepadButton(clawVentButton.gpButton, false)) {
        clawGrabButton.setVal(false);
      }

      clawGrabAuto=clawGrabButton.run();
    } else { //manual pressure control
      clawGrabAuto=false;
      clawPressurize=constrain(-gamepadVal("Z Axis", 0), 0, 1);
      clawPressurize=clawPressurizeSlider.run(clawPressurize);
      clawVent=clawVentButton.run();
    }
  }

  //calculate compressor on and off times
  if (keyPressed&&key=='r') {
    timeCompressorOn=0;
    timeCompressorOff=0;
  }
  if (compressing) {
    timeCompressorOn+=1.0/frameRate;
  } else {
    timeCompressorOff+=1.0/frameRate;
  }

  //left
  String[] msgc1={"time compress on", "time compress off", "compressor duty t"};
  String[] datac1={nf(timeCompressorOn, 1, 1), nf(timeCompressorOff, 1, 1), nf(100.0*timeCompressorOn/(timeCompressorOff+timeCompressorOn), 2, 2)};
  dispTelem(msgc1, datac1, width*13/16, height/4, width/8-1, height/2, 14, color(230, 240, 240));

  //right
  String[] msgc2={"enabled", "compressorMode", "storedPressSetpoint", "clawAuto", "clawGrabAuto", "clawAutoPressure", "clawPressurize", "clawVent"};
  String[] datac2={str(enabled), str(compressorMode), nf(storedPressureSetpoint, 1, 3), str(clawAuto), str(clawGrabAuto), nf(clawAutoPressure, 1, 2), nf(clawPressurize, 1, 3), str(clawVent)};
  dispTelem(msgc2, datac2, width*15/16, height/4, width/8-1, height/2, 14, color(230, 240, 240));


  //left
  String[] msgt1={};
  String[] datat1={};
  dispTelem(msgt1, datat1, width*13/16, 3*height/4, width/8-1, height/2, 14, (millis()-wifiReceivedMillis>wifiRetryPingTime)?color(255, 200, 200):color(255, 255, 255));

  //right
  String[] msgt2={"ping", "main voltage", "stored pressure", "working pressure", "claw pressure", "compressing", "clawPressValveState", "clawVentValveState", "compressorDuty", "compressorOverDuty"};
  String[] datat2={nf(wifiPing, 1, 0), nf(mainVoltage, 1, 3), nf(storedPressure, 1, 3), nf(workingPressure, 1, 3), nf(clawPressure, 1, 3), str(compressing), nf(clawPressurizeValveState, 1, 3), str(clawVentValveState), nf(compressorDuty, 1, 5), str(isCompressorOverDutyCycle)};
  dispTelem(msgt2, datat2, width*15/16, 3*height/4, width/8-1, height/2, 14, (millis()-wifiReceivedMillis>wifiRetryPingTime)?color(255, 200, 200):color(255, 255, 255));


  sendWifiData(true);
  mousePress=false;
  mouseWheel=0;
}
void WifiDataToRecv() {
  mainVoltage=recvFl();
  storedPressure=recvFl();
  workingPressure=recvFl();
  clawPressure=recvFl();
  compressing=recvBl();
  compressorDuty=recvFl();
  clawPressurizeValveState=recvFl();
  clawVentValveState=recvBl();
  isCompressorOverDutyCycle=recvBl();
}
void WifiDataToSend() {
  sendBl(enabled);
  sendBy(compressorMode);
  sendFl(storedPressureSetpoint);
  sendBl(clawAuto);
  sendBl(clawGrabAuto);
  sendFl(clawAutoPressure);
  sendFl(clawPressurize);
  sendBl(clawVent);
}

void mouseWheel(MouseEvent event) {
  mouseWheel = event.getCount();
}
