int cellW=30, cellH=26, horiLineSz=1, vertiLineSz=2, numRows=9;

void setup() {  
  size(400, 254);
  stroke(255);  
  background(136, 136, 136);
}

void draw() {
   for(int i = 0; i < numRows; i++){
     int yPos = i*(cellH+vertiLineSz)+vertiLineSz;
     int numCells = ceil(width/cellW);     
     for(int j = -10; j < numCells+10; j++){
       if(j % 2 == 0){
         fill(0);
       }else fill(255);
       noStroke();
       int pos = i % 4;
       if(pos == 3)pos = 1;
       rect(j * (cellW + horiLineSz) - pos * mouseX / 15, yPos,  cellW, cellH);
     }
   }
}