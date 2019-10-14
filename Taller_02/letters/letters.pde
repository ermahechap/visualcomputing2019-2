/**
 * Optical illusion taken from https://blog.csdn.net/dev_csdn/article/details/78469354
 */
 
final int LINE_COLOR = color(62, 226, 245);
final int STEPS = 4;
final int FPS = 60;
int step = 0;

void setup() {
  width = 640;
  height = 480;
  size(640, 480);
}

void drawI() {
  final float heightI = height * 0.6;
  final float widthI = width * 0.05;
  final float x = width * 0.2;
  final float y = height * 0.2;
  noStroke();
  frameRate(FPS);
  fill(255);
  rect(x, y, widthI, heightI);
}

void drawO() {
  final float outerRadius = height * 0.62;
  final float innerRadius = outerRadius - width * 0.1;
  final float x = 0.6 * width;
  final float y = 0.5 * height;
  noStroke();
  fill(255);
  circle(x, y, outerRadius);

  fill(0);
  circle(x, y, innerRadius);
}

float lineWidth = 0;
void drawLines() {
  final float lineHeight = height * 0.015;
  
  noStroke();

  final float outerRadius = height * 0.62;
  final float x = 0.6 * width;
  final float y = 0.5 * height;
  final float ANG = 15 * PI / 180.0;
  
  lineWidth += width / 2 / FPS;
  noStroke();

  if ( lineWidth >= width ) {
    fill(255, 0, 0);
    arc(x, y, outerRadius, outerRadius, PI+HALF_PI - ANG, PI+HALF_PI + ANG, CHORD);
    arc(x, y, outerRadius, outerRadius, HALF_PI - ANG, HALF_PI + ANG, CHORD);
    lineWidth = width;
  }

  fill(LINE_COLOR);
  rect(0, 0.2 * height, lineWidth, lineHeight);
  rect(0, 0.5 * height - 0.5 * lineHeight, lineWidth, lineHeight);
  rect(0, 0.8 * height - lineHeight, lineWidth, lineHeight);
}

void mouseClicked() {
  step++;
  step %= STEPS;
  if (step == 0) {
    lineWidth = 0;
  }
}
 
void draw() {
  background(0);
  if (step >= 1) drawI();
  if (step >= 2) drawO();
  if (step >= 3) drawLines();
}
