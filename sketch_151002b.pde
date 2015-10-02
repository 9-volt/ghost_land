import SimpleOpenNI.*;

SimpleOpenNI  context;
boolean flag = true;
int[] lastDepthValues = new int[640 * 480];
PImage canvas = null;
int maxDepth = 0;
int minDepth = -1;
PVector[] corners = new PVector[4];
boolean cornersSet = false;
int cornersSetCount = 0;

void setup()
{
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  context.enableDepth();
  
  // enable camera image generation
  context.enableRGB();
 
  size(context.depthWidth(), context.depthHeight()); 
  
  print("Size", context.depthWidth(), context.depthHeight(), "\n");
  
  background(color(0,0,0));
  canvas = createImage(640, 480, RGB);
  context.setDepthToColor(true);
}

void mouseClicked() {
  switch (cornersSetCount) {
    case 0:
      corners[0] = new PVector(mouseX, mouseY);
      break;
    case 1:
      corners[1] = new PVector(mouseX, mouseY);
      break;
    case 2:
      corners[2] = new PVector(mouseX, mouseY);
      break;
    case 3:
      corners[3] = new PVector(mouseX, mouseY);
      cornersSet = true;
      break; 
    default:
      print(inPolyCheck(new PVector(mouseX, mouseY), corners), "\n"); // check if clicked inside of canvas
      break;
  }
  cornersSetCount++;
  print(mouseX, mouseY, "\n"); 
}

void draw()
{
  // update the cam
  context.update();
  
  if (cornersSet) {
    
    drawDepth();  
  } else {
    image(context.rgbImage(), 0, 0);
  }
  return;
}

void drawDepth() {
//  image(context.depthImage(),0,0);
  int[] depthValues = context.depthMap();
  int i, x, y, depth;
  
  canvas.loadPixels();
  
  for (y = 0; y < 480; y++) {
    for (x = 0; x < 640; x++) {
      i = x + y * 640; 
      depth = depthValues[i];
      
      if (depth > maxDepth) {
        maxDepth = depth;
      }
      
      // Display only variations bigger than 100 units
      if (Math.abs(depthValues[i] - lastDepthValues[i]) < 100) {
        canvas.pixels[i] = color(255, 255, 255);
      } else {
        // Print once in 100 times
        if (Math.random() < 0.01) {
//          print(i, Math.abs(depthValues[i] - lastDepthValues[i]), " max: ", maxDepth, "\n");
        }
        canvas.pixels[i] = color(0,0,100);
      }
      
      lastDepthValues[i] = depthValues[i];
      
    }
  }
  
  canvas.updatePixels();
  image(canvas, 0, 0);
  drawRectangleToCanvas();
}

// Draw a rectangle around canvas
void drawRectangleToCanvas() {
  PVector topLeft = corners[0],
    topRight = corners[1],
    bottomRight = corners[2],
    bottomLeft = corners[3];
     
  stroke(204, 102, 0); // red
  
  line(topLeft.x, topLeft.y, topRight.x, topRight.y);
  line(bottomRight.x, bottomRight.y, topRight.x, topRight.y);
  line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y);
  line(bottomRight.x, bottomRight.y, bottomLeft.x, bottomLeft.y);
}

// Checks is a point is inside a poly
// http://www.openprocessing.org/sketch/65627
int inPolyCheck(PVector v, PVector [] p) {
  float a = 0;
  for (int i =0; i<p.length-1; ++i) {
    PVector v1 = p[i].get();
    PVector v2 = p[i+1].get();
    a += vAtan2cent180(v, v1, v2);
  }
  PVector v1 = p[p.length-1].get();
  PVector v2 = p[0].get();
  a += vAtan2cent180(v, v1, v2);
//  if (a < 0.001) println(degrees(a));
 
  if (abs(abs(a) - TWO_PI) < 0.01) return 1;
  else return 0;
}

float vAtan2cent180(PVector cent, PVector v2, PVector v1) {
  PVector vA = v1.get();
  PVector vB = v2.get();
  vA.sub(cent);
  vB.sub(cent);
  vB.mult(-1);
  float ang = atan2(vB.x, vB.y) - atan2(vA.x, vA.y);
  if (ang < 0) ang = TWO_PI + ang;
  ang-=PI;
  return ang;
}

