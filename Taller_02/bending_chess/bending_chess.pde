int d[] = {0,0,1,0,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,0,0};
boolean hidden = false;
void setup(){
  size(420,420);
}

void draw(){
  background(202);
  drawGrid();
  if(!hidden)drawCrosses();
}

void mousePressed(){
  hidden = true;
}
void mouseReleased(){
  hidden = false;
}
void drawGrid(){
  noStroke();
  fill(182);
  int step = width/6;
  int r=0;
  for(int y = 0;y<height;y+=step/2){
    int x = (r%2==0)?0:step/2;
    for(; x<width; x+=step){
      rect(x,y,step/2,step/2);
    }
    r++;
  }
}

void drawCrosses(){
  strokeWeight(3.5);
  int step = width/12;
  int change = 0;
  
  for(int y = 0 ; y < 12; y++){
    for(int x = 0 ; x < 12; x++){
      if(x==0 || y==0)continue;
      stroke((d[x+y] == 1)?243:168);
      int xx = x*step, yy=y*step;
      line(xx-5,yy,xx+5,yy);
      line(xx,yy-5,xx,yy+5);
    }
  }
}
