import processing.serial.*;

Serial serial;
int inputX = 0;
int inputY = 0;
int inputZ = 0;
int inputState;

int sw;
int sh;
int tw;
int th;
int mw;
int mh;

float bx;
float by;
float rx;
float ry;
float ex;
float ey;
int boxSize = 25;
boolean overBox = false;
boolean locked = false;

float posX;
float posY;

int screen = 0;
int ts = 0;

void setup() {
  size(990, 720);
  println(Serial.list());
  serial = new Serial(this, Serial.list()[0], 9600);
  sw = width/3;
  sh = height/3;
  tw = 240/3;
  th = 320/3;

  bx = width/2;
  by = height/2;
  rx = random(0,width-1);
  ry = random(0,height-1);
  textSize(50);
}

void draw() {
  background(255);
  rectMode(CORNER);
  for (int i=0; i<3; i++) {
    for (int j=0; j<3; j++) {
      fill(255);
      rect(i*sw, j*sh, sw, sh);
    }
  }

  if (inputState == 0) {
    screen = 0;
  }

  if (inputState == 1) {
    for (int i=0; i<3; i++) {
      for (int j=0; j<3; j++) { 
        if (330-inputY*2>th*i && 330-inputY*2<th*(i+1) && inputX>tw*j && inputX<tw*(j+1)) {
          ts = millis();
          fill(200, 255, 255);
          rect(i*sw, j*sh, sw, sh);
          posX = bx - i*sw;
          posY = by - j*sh;
        } else {
          fill(255);
          rect(i*sw, j*sh, sw, sh);
        }
      }
    }
    screen = 1;
  }

  if (inputState == 2) {
    for (int i=0; i<3; i++) {
      for (int j=0; j<3; j++) { 
        if (330-inputY*2>th*i && 330-inputY*2<th*(i+1) && inputX>tw*j && inputX<tw*(j+1)) {
          fill(200, 200, 255);
          rect(i*sw, j*sh, sw, sh);
          bx = i*sw + posX;
          by = j*sh + posY;
          mw = i*sw;
          mh = j*sh;
        } else {
          fill(255);
          rect(i*sw, j*sh, sw, sh);
        }
      }
    }
    screen = 2;
  }

  if (inputState == 3) {
    ex = mw + (330 - inputY*2);
    ey = mh + inputX;

    if (bx-boxSize>rx && bx-boxSize<rx+50 && by-boxSize>ry-50 && by-boxSize<ry) {
      println(millis()-ts);
      ex = 400;
      ey = 500;
      fill(0, 0, 255);
      rx = random(0, width-50);
      ry = random(-25, height-25);
      screen = 3;
    }

    if (ex>bx-boxSize && ex<bx+boxSize && ey>by-boxSize && ey<by+boxSize) {
      overBox = true;
      if (!locked) { 
        fill(200);
        //mousePressされいない場合、線だけ白にする。
      }
    } else {
      fill(200);
      overBox = false;
    }

    if (overBox) { 
      locked = true; 
      //もしmouseがBOXの範囲内ならば

      fill(255, 200, 200);
      bx = ex; 
      by = ey;
    }

    //rect(bx, by, boxSize, boxSize);
    rectMode(RADIUS);
    fill(255, 100, 100);
    rect(rx+50, ry, 50, 50);
    fill(150);
    rect(bx, by, boxSize, boxSize);
    fill(255, 0, 0);
    ellipse(ex, ey, 10, 10);
  }

  serial.write(screen);
  if (inputState != 3) {
    rectMode(RADIUS);
    fill(255, 100, 100);
    rect(rx+50, ry, 50, 50);
    fill(150);
    rect(bx, by, boxSize, boxSize);
  }
}

void serialEvent(Serial port) {
  if (port.available() > 3) {
    inputState = port.read();
    inputX = port.read();
    inputY = port.read();
    inputZ = port.read();
  }
}

