/*

 
 libraries needed:
 "UDP"
 "GameControlPlus"
 
 */
int wifiPort=25210;
String wifiIP="192.168.4.1";

String gamepadName ="Controller (XBOX 360 For Windows)";
/////////////////////////add interface elements and variables here
EnableSwitch enableSwitch;
boolean enabled=false;
Selector compressorModeSelector;
int compressorMode=1;

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
boolean clawAuto=false;

DialKnob clawPressureDialKnob;
float clawAutoPressure=0;

Button clawGrabButton;
boolean clawGrabAuto=false;

float batVolt=0.0;

void setup() {
  size(1900, 1000);
  shapeMode(CENTER);
  rectMode(CENTER);
  background(200);
  frameRate(60);
  mousescreen=new Mousescreen();
  keyboardCtrl=new KeyboardCtrl();
  udp = new UDP(this);
  udp.listen(true);  
  setupGamepad(gamepadName);

  //setup UI here
  enableSwitch=new EnableSwitch(width/14, height/28, width/7, height/14);
  compressorModeSelector=new Selector(int(width*.7), int(height*.86), width/10-3, height/6, false, "compressor"
    , new color[]{color(55), color(55), color(65, 40, 40)}
    , new color[]{color(255, 190, 0), color(200, 255, 200), color(0, 210, 0)}
    , new String[]{"override (o)", "normal (l)", "off (.)"}, 0, 0, null, null);

  ArrayList<DialColorConfig> storedDialBackground=new ArrayList<DialColorConfig>();
  storedDialBackground.add(new DialColorConfig(0, 60, color(255, 255, 0)));
  storedDialBackground.add(new DialColorConfig(60, 120, color(0, 255, 0)));
  storedDialBackground.add(new DialColorConfig(120, 140, color(255, 40, 40)));
  storedPressureDial=new Dial(int(width*.695), int(height*.68), width/10-3, "stored psi", 0, 120, 140, 2, 10, 20, storedDialBackground);

  ArrayList<DialColorConfig> workingDialBackground=new ArrayList<DialColorConfig>();
  workingDialBackground.add(new DialColorConfig(50, 60, color(0, 255, 0)));
  workingDialBackground.add(new DialColorConfig(60, 70, color(255, 40, 40)));
  workingPressureDial=new Dial(int(width*.695), int(height*.49), width/10-3, "working psi", 0, 60, 70, 1, 10, 10, workingDialBackground);
  clawPressureDial=new Dial(int(width*.695), int(width/20+height*.01), width/10-3, "claw psi", 0, 60, 70, 1, 10, 10, null);

  clawPressureDialKnob=new DialKnob(clawPressureDial.xPos, clawPressureDial.yPos, clawPressureDial.size, clawPressureDial.min, clawPressureDial.max, color(255, 0, 255, 150));

  clawPressurizeSlider=new Slider(width*.685, height*.2975, height*.12, width*.03, 0, 1, color(0, 60, 0), color(255), null, 0, 0, .03, 0, false, false);
  clawVentButton=new Button(width*.72, height*.24, height*.06, color(100, 0, 0), color(200, 0, 0), "Button 5", 'v', true, false, "vent (v)");
  clawDumpButton=new Button(width*.72, height*.36, height*.05, color(150, 0, 0), color(255, 0, 0), null, ';', false, false, "DUMP    ( ; )");
  clawAutoButton=new Button(width*.72, height*.3, height*.05, color(50, 50, 200), color(200, 0, 200), null, 'p', false, false, "auto (p)");
  clawGrabButton=new Button(width*.68, height*.312, height*.075, color(25, 100, 25), color(255, 70, 255), null, 'i', false, false, "grab (i)");
  if (!focused) {
    println("HELLO");
    //    ((java.awt.Canvas) surface.getNative()).requestFocus();
  }
}
void draw() {
  background(200);

  if ((keyboardCtrl.isPressed('[')&&keyboardCtrl.isPressed('['))||gamepadButton("Button 7", false)) { //enable
    enabled=true;
  }
  if (keyboardCtrl.isPressed(' ')||keyboardCtrl.isPressed(ENTER)||gamepadButton("Button 6", false)) { //disable
    enabled=false;
    if (compressorMode==0) // if disabled, turn off compressor override
      compressorMode=1;
  }
  enabled=enableSwitch.run(enabled);

  if (keyPressed) { //compressor keyboard control
    if (key=='o')
      compressorMode=0;
    if (key=='l')
      compressorMode=1;
    if (key=='.')
      compressorMode=2;
  }
  compressorMode=compressorModeSelector.run(compressorMode);
  storedPressureDial.run(storedPressure);
  workingPressureDial.run(workingPressure);
  clawPressureDial.run(clawPressure);


  if (clawDumpButton.run()) {
    clawPressurize=1;
    clawVent=true;
    compressorMode=2;
    clawGrabAuto=false;
  } else { //not dumping pressure
    clawAutoButton.setVal(clawAuto);
    clawAuto=clawAutoButton.run();
    if (clawAuto) { //automatic pressure control
      clawAutoPressure=clawPressureDialKnob.run(clawAutoPressure);
      pushStyle(); //display knob setpoint
      textSize(20);
      fill(180, 0, 180);
      textAlign(CENTER, CENTER);
      text(nf(clawAutoPressure, 1, 1), width*.695, height*.13);
      popStyle();

      clawGrabButton.setVal(clawGrabAuto);

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

  //fake pneumatics simulation
  if (compressorMode!=2) {
    if ((enabled&&compressorMode==1&&storedPressure<120)||(storedPressure<120&&compressorMode==0)) {
      storedPressure+=(.1+(frameCount%4<=1?4:-4));
    }
  }

  float storedToWorkingFlow=(constrain(storedPressure, 0, 60)-workingPressure)*.09;

  float workingToClawFlow=((workingPressure-clawPressure)*.09)*((workingPressure-clawPressure>0)?clawPressurize*.1:.2);

  storedPressure-=storedToWorkingFlow;
  workingPressure+=storedToWorkingFlow;

  workingPressure-=workingToClawFlow;

  clawPressure+=5*(workingToClawFlow-(clawVent?clawPressure*0.01:0));

  //end fake pneumatics simulation



  String[] msgc1={"enabled", "compressorMode", "clawAuto", "clawGrabAuto", "clawAutoPressure", "clawPressurize", "clawVent"};
  String[] datac1={str(enabled), str(compressorMode), str(clawAuto), str(clawGrabAuto), nf(clawAutoPressure, 1, 2), nf(clawPressurize, 1, 3), str(clawVent)};
  dispTelem(msgc1, datac1, width*13/16, height/4, width/8-1, height/2, 14, color(230, 240, 240));

  String[] msgc2={};
  String[] datac2={};
  dispTelem(msgc2, datac2, width*15/16, height/4, width/8-1, height/2, 14, color(230, 240, 240));


  String[] msgt1={"ping", "main voltage", "stored pressure", "working pressure", "claw pressure"};
  String[] datat1={str(wifiPing), nf(batVolt, 1, 3), nf(storedPressure, 1, 3), nf(workingPressure, 1, 3), nf(clawPressure, 1, 3)};
  dispTelem(msgt1, datat1, width*13/16, 3*height/4, width/8-1, height/2, 14, (millis()-wifiReceivedMillis>wifiRetryPingTime)?color(255, 200, 200):color(255, 255, 255));

  String[] msgt2={};
  String[] datat2={};
  dispTelem(msgt2, datat2, width*15/16, 3*height/4, width/8-1, height/2, 14, (millis()-wifiReceivedMillis>wifiRetryPingTime)?color(255, 200, 200):color(255, 255, 255));

  sendWifiData(true);
  mousePress=false;
  mouseWheel=0;
}
void WifiDataToRecv() {
  batVolt=recvFl();
  ////////////////////////////////////add data to read here
}
void WifiDataToSend() {
  sendBl(enabled);
  ///////////////////////////////////add data to send here
}

void mouseWheel(MouseEvent event) {
  mouseWheel = event.getCount();
}
