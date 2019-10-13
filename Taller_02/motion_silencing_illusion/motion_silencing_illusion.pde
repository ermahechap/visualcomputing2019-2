/*
Idea of silencing with size change taken from
http://visionlab.harvard.edu/silencing/
https://suchow.io/assets/docs/suchow2011silencing.pdf
*/

/*
---------------------------------------------------------
---------*************WARNING****************------------
---------------------------------------------------------

THIS IS INTERACTIVE:

R - regenerates the pattern
C - changes between modes
W/S - Increase/Decrease rotation speed
A/D - Increase/Decrease Twitching(or color change) speed

Click over the screen canvas changes direction of rotation.

IMPORTANT: IF THERE IS SOME PROBLEM WITH GENERATION OF PATTERNS RELATED WITH THE SEED,
CHANGE IT TO A STATIC VALUE

*/

import java.util.*;

// Global declaration
class Tp{
  float x, y, r, amt;
  boolean state;
  Tp(float x, float y, float amt, boolean state, boolean polar){
    // if polar x=r, y=theta
    this.x = (polar)? x*cos(y):x;
    this.y = (polar)? x*sin(y):y;
    this.amt = amt; // keeps the percentaje between r_min and r_max
    this.state = state; //tells us if the circle's radius is increasing
  }
  
  void twitch(float d_twitch){
    float st = (this.state)? d_twitch : -d_twitch;
    if(this.amt + st >1)this.state = false;
    else if(this.amt + st < 0)this.state = true;
    if(this.state)this.amt += d_twitch;
    else this.amt-=d_twitch;
  }
  
}

Vector<Tp> centres = new Vector();// x,y stores 
float d_twitch;
float r_min, r_max;
float theta_amt, d_theta;
Tp test;


boolean direction=true, back_forth=false; int state_direction = 0;
boolean mode = true;

void setup(){
  size(320, 320);
  frameRate(120);
  d_twitch = 0.001; //twitch speed
  d_theta = 0.001; //rotation speed
  r_min = 10; //min radius of circles
  r_max = 20;//max radius of circles
  theta_amt = 0; //initial rotation
  
  noStroke();
  //genCircles(0, 100, 150, 250, 4321);
  genCircles(0,80,140,(int)System.currentTimeMillis());
}
void draw(){
  background(200);
  translate(height/2, width/2);
  rotation();
  fill(color(127));
  circle(0,0,5);
  drawCircles();
  
}


//----------INTERACTIONS---------
void mouseClicked(){
  if(mouseX>=0 && mouseY>=0 && mouseX<=width && mouseY<=height){
    state_direction = (state_direction+1)%4;
    switch(state_direction){
      case 0:
       direction=true; back_forth=false;
        break;
      case 1:
        direction=false; back_forth=false;
        break;
      case 2:
        direction=false; back_forth=true;
        break;
      case 3:
        direction=true; back_forth=true;
        break;
      default:
        direction=true; back_forth=false;
        break;
    }
  }
}

void keyPressed() {
  int keyIndex = -1;
  if (key >= 'A' && key <= 'Z') {
    keyIndex = key - 'A';
  } else if (key >= 'a' && key <= 'z') {
    keyIndex = key - 'a';
  }
  if (keyIndex != -1) {
    if(keyIndex == 'w'-'a') d_theta = (d_theta+0.001 >= 0.01)?0.01: d_theta + 0.001;
    else if(keyIndex == 's'-'a') d_theta = (d_theta-0.001 <= 0)?0: d_theta - 0.001;
    else if(keyIndex == 'd'-'a') d_twitch = (d_twitch+0.001 >= 0.1)?0.1: d_twitch + 0.001;
    else if(keyIndex == 'a'-'a') d_twitch = (d_twitch-0.001 <= 0)?0: d_twitch - 0.001;
    else if(keyIndex == 'r'-'a') genCircles(0,80,140,(int)System.currentTimeMillis());
    else if(keyIndex == 'c'-'a'){
      if(mode){
        colorMode(HSB);
        r_min = r_max = 20;
        mode = false;
      }else{
        colorMode(RGB);
        r_min = 10;
        r_max = 20;
        mode = true;
      }
      genCircles(0,80,140,(int)System.currentTimeMillis());
    }
  }
}


//--------- IMPORTANT FUNCTIONS :v ------------
int counts_to_invert = 0;
boolean invert = false;
void rotation(){
  rotate(TAU*theta_amt);
  if(back_forth && direction)return;
  if (back_forth){
    if (invert)theta_amt = (theta_amt + d_theta)%1;
    else theta_amt = (theta_amt - d_theta)%1;
    
    if( counts_to_invert * d_theta >= PI / 24 ){invert = !invert; counts_to_invert = 0;}
    counts_to_invert++;
    return;
  }else{
    invert = false;
    counts_to_invert = 0;
  }
  
  if (direction){//clockwise
    theta_amt = (theta_amt+d_theta)%1;
  }else{//counter
    theta_amt = (theta_amt-d_theta)%1;
  }
}

/*
IMPORTANT: Because we are using translate, the point of reference of these values is 0,0

c - center of the canvas (center of R1 and R2). we take c as x and y
r - radius of the circles generated randomly.
R1 and R2 - radius of the circles with center on c. They must be constrained to R1<=R2.
n - number of circles to be drawn
seed - enables us to replicate a configuration.
*/
void genCircles(float c, float R1,float R2, int n, int seed){
  centres.clear();
  assert(R1 <= R2);
  randomSeed(seed);
  int tries = 5;
  do{
    float theta = random(0, TAU);
    float R = random(R1, R2);
    float x = c + R*cos(theta), y = c + R*sin(theta);
    float amt = random(1);
    boolean state = random(1)>=0.5;
    
    // Ask diego if there is a better way of doing this.
    boolean flag = true;
    for(Tp t: centres){
      float dist = ((t.x - x) * (t.x - x)) + ((t.y - y) * (t.y - y));
      float diam = r_max*r_max;
      if( diam >= dist ){
        flag = false;
      }
    }
    
    if(centres.size() == 0) flag = true;
    tries--;
    if(flag){
      n--;
      tries = 20;
      centres.add(new Tp(x,y,amt, state,false));
    }
  }while(n>0 && tries > 0);
}

//Variation of of the function above... I think this fills the ring better.
void genCircles(float c, float R1, float R2, int seed){
  centres.clear();
  assert(R1 <= R2);
  randomSeed(seed);
  int splits = 360, tries = 5;
  
  for(int s = 0; s<splits;s++){
    float d = (TAU*s)/splits;
    
    do{
      float R = random(R1, R2);
      float amt = random(1);
      boolean state = random(1)>=0.5;
      Tp tp = new Tp(R, d,amt, state, true);
      tp.x+=c; tp.y+=c;
      boolean flag = true;
      for(Tp t: centres){
        float dist = ((t.x - tp.x) * (t.x - tp.x)) + ((t.y - tp.y) * (t.y - tp.y));
        float diam = r_max*r_max;
        if( diam >= dist ){
          flag = false;
        }
      }
      if(centres.size() == 0) flag = true;
      tries--;
      if(flag){
        tries = 5;
        centres.add(tp);
      }
    }while(tries>0);
    
  }
  
}

void drawCircles(){
  fill(color(70));
  for(Tp t: centres){
    t.twitch(d_twitch);
    if(mode)circle(t.x, t.y, r_min + (r_max-r_min)*t.amt);
    else{
      fill(color(t.amt*360,200,200));
      circle(t.x, t.y, r_min + (r_max-r_min)*t.amt);
    }
  }
}
