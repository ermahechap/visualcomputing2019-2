int endX1, endY1, delta1x, delta1y;
int endX2, endY2, delta2x, delta2y;
int lineWidth;

void setup() {
  size(640, 480);
  stroke(255);
  endX1 = 220;
  endY1 = 240;
  endX2 = 210;
  endY2 = 210;
  lineWidth = 70;
  delta1x = -1;
  delta1y = 1;
  delta2x = 1;
  delta2y = 1;
}

void draw() {
  background(51);
  strokeWeight(4);      
  
  line(endX1, endY1, endX1+lineWidth, endY1+lineWidth);  
  line(endX1+120, endY1-120, endX1+190, endY1-50);  
  endX1 += delta1x;
  endY1 += delta1y;
  if(endX1 == 190){    
    delta1x = 1;
    delta1y = -1;
  }else if(endX1 == 220){
    delta1x = -1;
    delta1y = 1;
  }
  
  line(endX2, endY2, endX2+lineWidth, endY2-lineWidth);
  line(endX2+120, endY2+120, endX2+190, endY2+50);
  endX2 += delta2x;
  endY2 += delta2y;
  if(endX2 == 190){
    delta2x = 1;
    delta2y = 1;
  }else if(endX2 == 220){
    delta2x = -1;
    delta2y = -1;
  } 
  
  if(mousePressed == true){    
    translate(175, 177);    
    rotate(radians(45));   
    rect(0, 0, 75, 75);    
    rect(177, 0, 75, 75);
    rect(0, -177, 75, 75);
    rect(175, -175, 75, 75);
  }
}