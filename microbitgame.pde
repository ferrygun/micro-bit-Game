import processing.serial.*;

Serial arduinoPort;

final int COLUMNS=12;
final int ROWS=6;
final int BALL_RADIUS=8;
final int BALL_DIAMETER=BALL_RADIUS*2;
final int MAX_VELOCITY=8;
final int MARGIN=10;
final int PADDLE_WIDTH=60;
final int PADDLE_HEIGHT=15;
final int BRICK_WIDTH=40;
final int BRICK_HEIGHT=20;
final int HEIGHT=300;
final int LINE_FEED=10;

int px, py;
int vx, vy;
int xpos = 150;
int[][] bricks= new int[COLUMNS][ROWS];

boolean buttonPressed=false;
boolean paused=true;
boolean done=true;
boolean win=false;

void setup(){
  size(500, 500);
  noCursor();
  textFont(loadFont("Verdana-Bold-36.vlw"));
  initGame();
  println(Serial.list());
  arduinoPort=new Serial(this, "COM4", 115200);
  arduinoPort.bufferUntil(10);
}

void initGame(){
  initBricks();
  initBall();
}

void initBricks(){
  for(int x=0; x<COLUMNS; x++)
  for(int y=0; y<ROWS; y++)
  bricks[x][y]=1;
}

void initBall(){
  px=width/2;
  py=height/2;
  vx=int(random(-MAX_VELOCITY, MAX_VELOCITY));
  vy=-2;
}

void draw(){
  background(0);
  stroke(255);
  strokeWeight(3);
  
  done=drawBricks();
  if(done){
    paused=true;
    win = true;
    printWinMessage();
  }
  if(paused)
    printPauseMessage();
  else
    updateGame();
  
  drawBall();
  drawPaddle();
}

boolean drawBricks(){
  boolean allEmpty=true;
  for(int x=0; x<COLUMNS; x++){
    for(int y=0; y<ROWS; y++){
      if(bricks[x][y]>0){
        allEmpty=false;
        fill(0, 0, 100+y*8);
        rect(
          MARGIN+x*BRICK_WIDTH,
          MARGIN+y*BRICK_HEIGHT,
          BRICK_WIDTH,
          BRICK_HEIGHT
        );
      }
    }
  }
  return allEmpty;
}

void drawBall(){
  strokeWeight(1);
  fill(128, 0, 0);
  ellipse(px, py, BALL_DIAMETER,  BALL_DIAMETER);
}

void drawPaddle(){
  int x=xpos - PADDLE_WIDTH/2;
  int y=height - 25;
  strokeWeight(1);
  fill(128);
  rect(x, y, 60, 15);
}

void printWinMessage(){
  fill(225);
  textSize(36);
  textAlign(CENTER);
  text("YOU WIN", width/2, height*2/3);
}

void printPauseMessage(){
  fill(128);
  textSize(16);
  textAlign(CENTER);
  text("Press button to continue", width/2, height*5/6);
}

void updateGame(){
  if(ballDropped()){
    initBall();
    paused=true;
  } else{
    checkBrickCollision();
    checkWallCollision();
    checkPaddleCollision();
    px+=vx;
    py+=vy;
  }
}

boolean ballDropped(){
  return py+vy> height - BALL_RADIUS;
}

boolean inXRange(final int row, final int v){
  return px + v > row*BRICK_WIDTH&&
         px+v < (row+1)*BRICK_WIDTH+BALL_DIAMETER;
}

boolean inYRange(final int col, final int v){
  return py+v> col*BRICK_HEIGHT&&
         py+v< (col+1)*BRICK_HEIGHT+BALL_DIAMETER;
}

void checkBrickCollision(){
  for(int x=0; x<COLUMNS; x++){
    for(int y=0; y<ROWS; y++){
      if(bricks[x][y]>0){
        if(inXRange(x, vx)&& inYRange(y, vy)){
          bricks[x][y]=0;
          if(inXRange(x, 0))
          vy=-vy;
          if(inYRange(y, 0))
          vx=-vx;
        }
      }
    }
  }
}

void checkWallCollision(){
  if(px+vx < BALL_RADIUS || px+vx > width - BALL_RADIUS)
  vx=-vx;
  
  if(py+vy < BALL_RADIUS || py+vy > height - BALL_RADIUS)
  vy=-vy;
}

void checkPaddleCollision(){
  final int cx=xpos;
  if(py+vy >=height - (PADDLE_HEIGHT + MARGIN + 6)&&
    px >= cx - PADDLE_WIDTH/2 &&
    px <= cx + PADDLE_WIDTH/2)
    {
      vy=-vy;
      vx=int(
        map(
          px - cx,
          -(PADDLE_WIDTH/2), PADDLE_WIDTH/2,
          -MAX_VELOCITY,
          MAX_VELOCITY
        )
      );
    }
}

void serialEvent(Serial port){
  final String inData=port.readStringUntil(LINE_FEED);
  
 
  if(inData!=null){
    println(inData);
    
     if(win) {
       win = false;
       done=false;
       initGame();
     }
     
     if (inData.charAt(0) == 'a') {
       paused = false;
       if (xpos >=31)
         xpos = xpos - 1;
     }
     
     if (inData.charAt(0) == 'b') {
       paused = false;
       if (xpos <=468 )
         xpos = xpos + 1;
     }
     
     if (inData.charAt(0) == 'c') {
       paused= true;
        if(done){
          done=false;
          initGame();
        }
     }
     
     
  }
}