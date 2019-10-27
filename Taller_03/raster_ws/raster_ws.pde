import nub.primitives.*;
import nub.core.*;
import nub.processing.*;

float cross(Vector a, Vector b) {
  return Vector.cross(a, b, null).z();
}

float signedArea(Vector a, Vector b, Vector c) {
  return cross(Vector.subtract(b,a), Vector.subtract(c,a));
}

int sign(float f) {
  return f < 0 ? -1 : ( f > 0 ? 1 : 0 );
}

boolean pointInTriangle(Vector p, Vector a, Vector b, Vector c) {
  int s1 = sign(signedArea(p, a, b));
  int s2 = sign(signedArea(p, b, c));
  int s3 = sign(signedArea(p, c, a));
  return Math.max(s1, Math.max(s2, s3)) - Math.min(s1, Math.min(s2, s3)) <= 1;
}

void calcBaricentricCoords(Vector[] triangle, Vector p, float[] barCoef) {
  float triangleArea = signedArea(triangle[0], triangle[1], triangle[2]);
  for (int i = 0; i < 3; ++i) {
    barCoef[i] = signedArea(p, triangle[(i+1)%3], triangle[(i+2)%3]) / triangleArea;
  }
}

// 1. Nub objects
Scene scene;
Node node;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean shadeHint = false;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P2D;

// 4. Window dimension
int dim = 9;

// 5. Antialisaing depth
int antiAliasingDepth = 3;

// 6. Draw raster?
boolean raster = true;

void settings() {
  size(int(pow(2, dim)), int(pow(2, dim)), renderer);
}

void setup() {
  rectMode(CENTER);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fit(1);

  // not really needed here but create a spinning task
  // just to illustrate some nub timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the node instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask(scene) {
    @Override
    public void execute() {
      scene.eye().orbit(scene.is2D() ? new Vector(0, 0, 1) :
        yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100);
    }
  };

  node = new Node();
  node.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow(2, n));
  if (triangleHint)
    drawTriangleHint();
  push();
  scene.applyTransformation(node);
  triangleRaster();
  pop();
}

Vector[] triangle = new Vector[3];
float[] barCoordinates = new float[3];

Vector getPixelRGB(Vector pixelTopLeft, float size, int depth) {
  if (depth == antiAliasingDepth) {
    Vector pixelCenter = Vector.add( pixelTopLeft, new Vector(size/2, size/2, 0) );
    if (pointInTriangle(pixelCenter, triangle[0], triangle[1], triangle[2])) {
      calcBaricentricCoords(triangle, pixelCenter, barCoordinates);
      return new Vector(
        barCoordinates[0]*255,
        barCoordinates[1]*255,
        barCoordinates[2]*255
      );
    }
    return new Vector(0, 0, 0);
  }
  size /= 2;
  depth++;
  Vector r = getPixelRGB(pixelTopLeft, size, depth);
  r.add(getPixelRGB(Vector.add(pixelTopLeft, new Vector(size, 0)), size, depth));
  r.add(getPixelRGB(Vector.add(pixelTopLeft, new Vector(0, size)), size, depth));
  r.add(getPixelRGB(Vector.add(pixelTopLeft, new Vector(size, size)), size, depth));
  r.divide(4);
  return r;
  
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the node system which has a dimension of 2^n
void triangleRaster() {
  if (!raster) return;

  triangle[0] = node.location(v1);
  triangle[1] = node.location(v2);
  triangle[2] = node.location(v3);
  
  Vector p = new Vector();
  final int to = Math.round((1<<dim) / node.scaling() / 2);
  final int from = -to;
  push();
  noStroke();
  for (int x = from; x < to; ++x) {
    for (int y = from; y < to; ++y) {
      p.setX(x);
      p.setY(y);
      Vector c = getPixelRGB(p, 1, 0);
      if (c.x() == 0 && c.y() == 0 && c.z() == 0) continue;
      fill(c.x(), c.y(), c.z(), shadeHint ? 125 : 255 );
      square(x + 0.5, y + 0.5, 1);
    }
  }
  pop();
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  push();

  if(shadeHint)
    noStroke();
  else {
    strokeWeight(2);
    noFill();
  }
  beginShape(TRIANGLES);
  if(shadeHint)
    fill(255, 0, 0);
  else
    stroke(255, 0, 0);
  vertex(v1.x(), v1.y());
  if(shadeHint)
    fill(0, 255, 0);
  else
    stroke(0, 255, 0);
  vertex(v2.x(), v2.y());
  if(shadeHint)
    fill(0, 0, 255);
  else
    stroke(0, 0, 255);
  vertex(v3.x(), v3.y());
  endShape();

  strokeWeight(5);
  stroke(255, 0, 0);
  point(v1.x(), v1.y());
  stroke(0, 255, 0);
  point(v2.x(), v2.y());
  stroke(0, 0, 255);
  point(v3.x(), v3.y());

  pop();
}

void keyPressed() {
  if (key == '\n')
    raster = !raster;
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 's')
    shadeHint = !shadeHint;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    node.setScaling(width/pow(2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    node.setScaling(width/pow(2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run();
  if (key == 'y')
    yDirection = !yDirection;
}
