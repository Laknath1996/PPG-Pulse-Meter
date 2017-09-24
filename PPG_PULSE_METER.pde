//************************* PHOTOPLETHYSMOGRAPHIC PULSE METER ****************************

//This project was designed and implemented by Ashwin de Silva and Sachini Hewage for ExMO'17//

//This proccessing code implements a visual interface to display the real time photoplethysmogram obtained from the hardware component.

import processing.serial.*;

Serial port;  // Create object from Serial class
int val;  
int Signal;// Data received from the serial port
int[] values;
//float zoom;
int BPM; //store the BPM values coming from the serial communication
int pulseTime; //store the PulseTime values coming from the serial communication

//Data Winow Dimensions
int pulseWindowWidth = 980;
int pulseWindowHeight = 480;

int BPMWindowWidth = 300;

int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM

float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW

Scrollbar scaleBar;

int[] rate;      

void setup() 
{
  size(1280, 750);

  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, Serial.list()[2], 115200);
  values = new int[pulseWindowWidth];
  zoom = 1.0f;
  smooth();
  
  RawY = new int[pulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[pulseWindowWidth];   // initialize scaled pulse waveform array
  
  scaleBar = new Scrollbar (1040, 440, 180, 12, 0.5, 1.0); 
  
   for (int i=0; i<RawY.length; i++){
    RawY[i] = height/4; // initialize the pulse window data line to V/2
 }
 
   rate = new int [BPMWindowWidth];
   
   for (int i=0; i<rate.length; i++){
    rate[i] = 750;      // Place BPM graph line at bottom of BPM Window
   }
}

int getY(int val) {
  //return (int)((pulseWindowHeight - val / 1023.0f * (pulseWindowHeight - 1)));
 return (int)((pulseWindowHeight - val / 1023.0f * (pulseWindowHeight - 1)));
}

int getValue() {
  int value = -1;
  while (port.available() >= 3) {
    if (port.read() == 0xff) {
      value = (port.read() << 8) | (port.read());
    }
  }
  return value;
}

void pushValue(int value) {
  for (int i=0; i<pulseWindowWidth-1; i++)
    values[i] = values[i+1];
  values[pulseWindowWidth-1] = value;
}

void drawLines() {
  stroke(85,232,63);
  
  int displayWidth = (int) (pulseWindowWidth );
  
  int k = values.length - displayWidth;
  
  int x0 = 0;
  int y0 = getY(values[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (pulseWindowWidth-1) / (displayWidth-1));
    int y1 = getY(values[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}

void drawGrid() {
  stroke(18,103,2);
 // line(0, pulseWindowHeight/2, pulseWindowWidth, pulseWindowHeight/2);
  //line(0, pulseWindowHeight/4, pulseWindowWidth, pulseWindowHeight/4);
  //line(0, pulseWindowHeight/2, pulseWindowWidth, pulseWindowHeight/2);
  
  for (int i = 1; i <= 8; i ++){
    line(0, i*pulseWindowHeight/8, pulseWindowWidth,i* pulseWindowHeight/8);
  }
  
  for (int i = 1; i <= 8; i ++){
    line(0, i*pulseWindowHeight/8, pulseWindowWidth,i* pulseWindowHeight/8);
  }
  
  for (int i = 1; i <= 16; i ++){
    line(i*pulseWindowWidth/16, 0,i* pulseWindowWidth/16, pulseWindowHeight);
  }
  
}

void keyReleased() {
  switch (key) {
    case 'a':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case 's':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}

void draw()
{
  background(0);
  drawDataWindows();
  drawGrid();
  val = getValue();
  if (val != -1) {
    pushValue(val);
  }
  //drawLines();
  drawPulseWaveform();
  PFont mono1;
  mono1 = loadFont("Avenir-BlackOblique-48.vlw");
  PFont mono2;
  mono2 = loadFont("SansSerif-48.vlw");
  fill(255,255,255);
  textFont(mono2);
  textSize(26);
  //text("PHOTOPLETHYSMOGRAMIC PULSE METER", 240,450);
  textSize(18);
  fill(0,63,245);
  text("INSTANTANEOUS PULSE RATE",1000,50);
  textSize(80);
  textFont(mono1);
  fill(255,255,255);
  text(BPM,1090,120);
  textFont(mono2);
  textSize(18);
  text("beats per min.",1060,160);
  fill(0,63,245);
  text("TIME BETWEEN TWO BEATS",1015,230);
  textSize(80);
  textFont(mono1);
  fill(255,255,255);
  text(pulseTime,1090,300);
  textFont(mono2);
  fill(255,255,255);
  textSize(18);
  text("milliseconds",1060,330);
  fill(0,63,245);
  text("Enhance PPG",1080,400);
  fill(0);
  stroke(0);
  rect(0,481,1280,265);
  fill(255,255,255);
  textSize(50);
  textFont(mono2);
  text("PHOTOPLETHYSMOGRAPHIC", 190,600);
  text("PULSE METER",340, 660);
  fill(255,255,255);
  rect(980,480,300,270);
  drawBPMWaveform();
  textSize(10);
  for (int i = 0; i < 200; i= i + 10){
    text(i,960,750-i*1.25);
  }
  textSize(18);
  fill(0);
  text("BPM vs Time",1080,498);
  
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
  

  
  
  //text("INTER PULSE INTERVAL : " + pulseTime + "ms",600,70);
}

void drawDataWindows(){
    // DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES
    fill(255,255,255); 
    stroke(0);// color for the window background
    rect(0,400,980,80);
    fill(122,116,116);
    rect(980,0,300,480);
    fill(0);
    rect(990,10,280,460);
    fill(0);
    rect(0,0,980,480);
}