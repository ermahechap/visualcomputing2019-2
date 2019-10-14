/**
 * Optical illusion taken from https://blog.csdn.net/dev_csdn/article/details/78469354
 */
import java.util.ArrayList;
import java.util.List;

class Rectangle {
  private float x;
  private float y;
  private float h;
  private float w;
  private float cornerR = 0.0;
  private int fillRGB = 0;
  
  @Override
  public String toString() {
    return "(" + x + "," + y + ") size = (" + w + "," + h + ")";
  }

  public void setX (float x) { this.x = x; }
  public float getX () { return x; }

  public void setY (float y) { this.y = y; }
  public float getY () { return y; }

  public float getCornerRadius() { return cornerR; }
  public void setCornerRadius(float r) { this.cornerR = r; }

  public int getFillColor() { return fillRGB; }
  public void setFillColor(int c) { this.fillRGB = c; } 

  public void draw() {
    noStroke();
    fill(fillRGB);
    rect(x, y, w, h, cornerR, cornerR, cornerR, cornerR);
  }
  
  public Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;
  }
};

float height, width;
final int fps = 60;

interface Animation {
  void draw();
  void update();
  boolean finished();
}

class MovingRectangle implements Animation {
  private Rectangle rect;
  private float duration;
  private float dx;
  private float dy;
  private int steps = 0;
  private boolean finished = false;

  public void setDuration(float durationSecs) { this.duration = durationSecs; }
  public void setDisplacementX(float dx) { this.dx = dx; }
  public void setDisplacementY(float dy) { this.dy = dy; }

  @Override
  public boolean finished() { return finished; }

  @Override
  public void draw() {
    rect.draw();
  }
  
  @Override
  public void update() {
    if ( !finished ) {
      steps++;
      rect.setX( rect.getX() + dx / duration / fps );
      rect.setY( rect.getY() + dy / duration / fps );
      if ( steps >= fps * duration ) {
        finished = true;
      }
    }
  }

  MovingRectangle(Rectangle rect) {
    this.rect = rect;
  }
}

final int BACKGROUND_COLOR = color(247, 98, 99);
final int DARK_BLUE = color(0, 0, 104);
final int MAGIC_COLOR = color(122, 0, 254);

List<Animation> animations;

void setupAnimations() {
  final float minX = 0.125 * width;
  final float maxX = width - minX;
  final float minY = 0.125 * height;
  final float maxY = height - minY;
  final float rectHeight = (maxY - minY) / 17;

  animations = new ArrayList<Animation>();
  for (int i = 0; i < 17; i += 2) {
    final float y = minY + i * rectHeight;
    Rectangle rect = new Rectangle(minX, y, maxX - minX, rectHeight);
    rect.setCornerRadius(rectHeight / 2);
    rect.setFillColor(DARK_BLUE);
    
    MovingRectangle movingRect = new MovingRectangle(rect);
    movingRect.setDuration(2);
    movingRect.setDisplacementX((maxX + 1) * (i % 4 == 0 ? 1 : -1 ));
    movingRect.setDisplacementY(0);
    animations.add(movingRect);
  }

  final float rectWidth = 0.15 * width;
  for (int i = 0; i < 17; i += 2) {
    final float y = minY + i * rectHeight;
    Rectangle rect = new Rectangle(0.25 * width, y, rectWidth, rectHeight);
    rect.setFillColor(MAGIC_COLOR);

    MovingRectangle movingRect = new MovingRectangle(rect);
    movingRect.setDuration(2);
    movingRect.setDisplacementX(0.175 * width);
    movingRect.setDisplacementY(0);
    animations.add(movingRect);
  }
  
  for ( int i = 1; i < 17; i += 2) {
    final float y = minY + i * rectHeight;
    Rectangle rect = new Rectangle(0.60 * width, y, rectWidth, rectHeight);
    rect.setFillColor(MAGIC_COLOR);

    MovingRectangle movingRect = new MovingRectangle(rect);
    movingRect.setDuration(2);
    movingRect.setDisplacementX(-0.175 * width);
    movingRect.setDisplacementY(0);
    animations.add(movingRect);
  }
}

void setup() {
  width = 640;
  height = 480;
  size(640, 480);
  frameRate(fps);
  setupAnimations();
}

boolean runAnimation = false;
boolean restart = false;
void mouseClicked() {
  if (runAnimation) {
    restart = true;
    runAnimation = false;
  }
  else {
    restart = false;
    runAnimation = true;
  }
}

void draw() {
  background(BACKGROUND_COLOR);

  if (restart) {
    setupAnimations();
    restart = false;
  }

  for (Animation animation : animations) {
    animation.draw();
  }
  
  if (runAnimation) {
    for (Animation animation : animations) {  
      animation.update();
    }
  }
}
