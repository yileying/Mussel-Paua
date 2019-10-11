import processing.serial.*;       //for serial
import java.awt.Robot;            //for robot 
import java.awt.event.KeyEvent;   //for keyboard
import java.io.IOException;       //for keyboard
import processing.sound.*;

Serial myPort;
Robot robot;
PImage pauaImg;
PImage musselImg;
PImage basketImg;
SoundFile musselS;
SoundFile pauaS;
//PImage[] musselImgs = new PImage[55]; //array for mussel images
//PImage[] pauaImgs = new PImage[55]; //array for paua images
int pauaRatio=5; //divide size by
int musselRatio=5; //divide size by
int serialN=2;

int inByte = 0; //number received from serial
int oldByte = 0; //previous reading
int dropByte=0;//drop byde
int tHold = 333; //threshold
int musselCounter = 0; //up counts
int pauaCounter = 0; //long enough down counts

int minDuration = 3000; //number of milliseconds to count for paua
int debounceDur = 200; //number of milliseconds for debounce
int startm = 0; //time in  milliseconds when the treshold is exceeded
int m = 0; // current time in  milliseconds
int droptm=0;//time in  milliseconds when crossing the treshold downwards 
float pauaRealTime = 0; //storing current paua duration
float pauaLastTime=0;//storing last paua duration
float duration = 0; //duration of the spike
float totalDuration = 0;

boolean triggerOnUP=false; //crossed the threshold on rising
boolean triggerOnDOWN=false; //crossed the threshold on falling1
int xPos = 0; //for drawing the graph
float yPos = 0; //for drawing mapped y
float ytHold=0; //for drawing mapped tHold
float pauaY=0;
float musselY=0;

boolean robotEnabled=false;
boolean soundEnabled=true;
boolean useMouse=false; //emulate input value by using mouse Y

void setup () {
  //load settings from file
  String[] settings_lines = loadStrings("settings.txt");
  debounceDur = int(split(settings_lines[0], "=")[1]);
  minDuration =  int(split(settings_lines[1], "=")[1]);
  tHold = int(split(settings_lines[2], "=")[1]);
  useMouse =  boolean(split(settings_lines[3], "=")[1]);
  robotEnabled = boolean(split(settings_lines[4], "=")[1]);
  serialN = int(split(settings_lines[5], "=")[1]);  
  soundEnabled = boolean(split(settings_lines[6], "=")[1]);  

  println (debounceDur+"-"+minDuration+"-"+tHold+"-"+useMouse+"-"+robotEnabled); 
  //imageMode(CENTER); 
  pauaImg = loadImage("img/paua.jpg");
  musselImg = loadImage("img/mussel.jpg");
  basketImg = loadImage("img/basket.png");
  musselS = new SoundFile(this, "mussel.wav");
  pauaS = new SoundFile(this, "paua.wav");
  /* for ( int i = 0; i< musselImgs.length; i++ )
   {
   musselImgs[i] = loadImage("img/mussel.jpg");
   }
   */
  surface.setAlwaysOnTop(true); //make window alway on top
  surface.setResizable(true); //size doesn't work, so make the graph window resizeble

  String[] args = {"TwoFrameTest"};
  Mussel_Paua sa = new Mussel_Paua(); //create second window
  PApplet.runSketch(args, sa);

  myPort = new Serial(this, Serial.list()[serialN], 9600);  //initialise serial port
  myPort.bufferUntil('\n');
  background(0); //clear screen
  try {
    //Launch NotePad
    //Runtime.getRuntime().exec("notepad");
    //Get a Robot
    robot = new Robot();
  } 
  catch (Exception e) {
    //Uh-oh...
    e.printStackTrace();
    exit();
  }
  //robot.delay(5000);
}

void draw () {
  m = millis();

  if (useMouse) {
    inByte = mouseY*4;
  } //this if is useless if we are not using mouse to simulate the signal
  //println(mouseY);

  //this part is drawing and showing the data on the small window
  yPos = map(inByte, 0, 1024, 0, height);
  ytHold=map(tHold, 0, 1024, 0, height);
  textSize(32); 
  fill(0);    // black rectangle = background for information
  noStroke();
  rect(0, 0, width, 40); //erase the text
  fill(255);  // Text
  // text ("[" + oldByte+"/"+ dropByte+"/" + inByte + "]dur[" + pauaRealTime/1000 +"/" + duration/1000 + "/" + totalDuration/1000 + "]#" + musselCounter, 0, 30);
  text ("[" + inByte + "]dur[" + pauaRealTime/1000 + "/" + "]#" + musselCounter, 0, 30);
  // text ("drag mouse-draw shape; q-quit; esc-drop line; Backspace-undo; d-del; r-CODE", 10, 30);
  stroke(127, 34, 255);
  line(xPos, height, xPos, height - yPos); //drawing the voltage
  line(0, height -ytHold, width, height -ytHold); //threshold line
  //point (xPos,inByte);
  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
    background(0);
  } else {
    // increment the horizontal position:
    xPos++;
  }



  //catch the threshold
  if (inByte>tHold) {

    if (dropByte<=tHold) {
      startm=m;
      musselY=0;
      musselCounter++;
      if (soundEnabled) {
        musselS.play();//play the mussel sound
      }
    }//close if oldByte<=tHold

    pauaRealTime=m-startm;

    if (pauaRealTime>=minDuration&&pauaLastTime<minDuration) {
      pauaY=0;

      pauaCounter++;
      if (soundEnabled) {
        pauaS.play();//play the paua sound
      }
    }
    dropByte=inByte;
    pauaLastTime=pauaRealTime;
  } else { // if inByte<=tHold

    if (oldByte>tHold) {
      droptm=m;
    }

    if (m-droptm>debounceDur) {
      duration=m-startm;
      totalDuration=totalDuration+duration;
      dropByte=inByte;
    }
  } //else close
  oldByte=inByte;
}


//==================================game window=========================================//
public class Mussel_Paua extends PApplet {

  public void settings() {
    size(700, 400);
  }
  public void draw() {
    background(255);
    fill(0);
    //gavityM=gavityM+1;
    //gavityP=gavityP+1;

    pauaY=pauaY*1.07+4;
    musselY=musselY*1.1+5;
    //tint(255, 127);
    image(pauaImg, 400, pauaY, pauaImg.width/7, pauaImg.height/7);
    //image(pauaImg, 0, 0, pauaImg.width, pauaImg.height);
    //translate(width/2, height/2);
    //rotate(pauaY/100);
    image(musselImg, 40, musselY, musselImg.width/8, musselImg.height/8);
    image(basketImg, 0, 180, basketImg.width/3, basketImg.height/3);
    image(basketImg, 350, 180, basketImg.width/3, basketImg.height/3);
    //println(mouseY);
    textSize(40); 
    fill(255);  // Text
    text (musselCounter, 50, 390);
    //fill(0);
    text (pauaCounter, 400, 390);
  }
}


//=====================reading signals from serial========
void serialEvent (Serial myPort) {
  //read from serial
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //format string
  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // convert to an int and map to the screen height:
    inByte = int(inString);
    //println(inByte);
  }
}