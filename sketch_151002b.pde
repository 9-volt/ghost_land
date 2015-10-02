import SimpleOpenNI.*;
import blobscanner.*;

// Context and drawing canvas
SimpleOpenNI  context;
PImage canvas = null;

// Corners
PVector[] corners = new PVector[4]; // top-left, top-right, bottom-right, bottom-left
boolean cornersSet = false;
int cornersSetCount = 0;
java.awt.Polygon cornersPolygon = new java.awt.Polygon();

// Blobs detecting
Detector bd;
PImage blobsImage;
int[] blobsArray;
int cornerXMin, cornerXMax, cornerYMin, cornerYMax, cornerXSize, cornerYSize;
int playgroundArea;

int lastCentroidId = 0, lastCentroidsCount = 10;
PVector[] lastCentroids = new PVector[lastCentroidsCount];


// Depth variation
int[] lastDepthValues = new int[640 * 480];

int maxDepth = 0;
int canvasDepthMax = 0;
int canvasDepthMin = 999999;
int[] defaultDepthValues = new int[640 * 480];

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
      onAllCornersSet();
      break; 
    default:
      break;
  }
  cornersSetCount++;
  print(mouseX, mouseY, "\n"); 
}

void onAllCornersSet() {
  cornersSet = true;
  cornersPolygon.addPoint((int) corners[0].x, (int) corners[0].y); // top-left
  cornersPolygon.addPoint((int) corners[1].x, (int) corners[1].y); // top-right
  cornersPolygon.addPoint((int) corners[2].x, (int) corners[2].y); // bottom-right
  cornersPolygon.addPoint((int) corners[3].x, (int) corners[3].y); // bottom-left
  cornerXMin = (int) Math.min(corners[0].x, corners[3].x);
  cornerXMax = (int) Math.max(corners[1].x, corners[2].x);
  cornerYMin = (int) Math.min(corners[0].y, corners[1].y);
  cornerYMax = (int) Math.max(corners[2].y, corners[3].y);
  cornerXSize = cornerXMax - cornerXMin;
  cornerYSize = cornerYMax - cornerYMin;
//  bd = new Detector(this, 0, 0, cornerXSize, cornerYSize, 255);
  bd = new Detector(this, 255);
  blobsImage = createImage(640, 480, RGB);
    
  playgroundArea = cornerXSize * cornerYSize;
  print("Canvas size ", cornerXSize, "x", cornerYSize, "\n");
  
  int i;
  for (i = 0; i < lastCentroidsCount; i++) {
    lastCentroids[i] = new PVector(0, 0);
  }
    
  int x, y;
  int[] depthValues = context.depthMap();
  for (y = cornerYMin; y < cornerYMax; y++) {
    for (x = cornerXMin; x < cornerXMax; x++) {
      i = x + y * 640;
      canvasDepthMax = Math.max(canvasDepthMax, depthValues[i]);
      canvasDepthMin = Math.min(canvasDepthMin, depthValues[i]);
    } 
  }
  
  for (y = cornerYMin; y < cornerYMax; y++) {
    for (x = cornerXMin; x < cornerXMax; x++) {
      i = x + y * 640;
      defaultDepthValues[i] = Math.min(canvasDepthMax, Math.max(canvasDepthMin, depthValues[i]));
    } 
  }
  
  print("Min ", canvasDepthMin, " Max ", canvasDepthMax, "\n");
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
  int i, x, y, depth, colorChanell;
  
  background(255, 255, 255);
  
  canvas.loadPixels();
  blobsImage.loadPixels();
  
  for (y = 0; y < 480; y++) {
    for (x = 0; x < 640; x++) {
      i = x + y * 640; 
      depth = depthValues[i];
      
      if (depth > maxDepth) {
        maxDepth = depth;
      }
      
      if (x < cornerXMax && x > cornerXMin && y < cornerYMax && y > cornerYMin) {
        if (Math.abs(depthValues[i] - defaultDepthValues[i]) < 100) {
          blobsImage.pixels[i] = color(255, 255, 255);  
        } else {
          colorChanell = (int) (255 * depth / maxDepth);
          blobsImage.pixels[i] = color(0, colorChanell, 0); 
        }
      }
      
      // Display only variations bigger than 100 units
      if (Math.abs(depthValues[i] - lastDepthValues[i]) < 100) {
        
        if (cornersPolygon.contains(x, y)) {
          canvas.pixels[i] = color(255, 255, 128);
        } else {
          canvas.pixels[i] = color(255, 255, 255);
        }
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
  
  bd.findBlobs(blobsImage.pixels, blobsImage.width, blobsImage.height);
  

  
  canvas.updatePixels();
//  blobsImage.updatePixels();
//  image(canvas, 0, 0);
//  image(blobsImage, 0, 0);
//  drawRectangleToCanvas();
  
  bd.loadBlobsFeatures(); // mandatory
  bd.weightBlobs(false);
  bd.findCentroids();
//  bd.drawContours(color(255, 0, 0), 2);
//  
  for(i = 0; i < bd.getBlobsNumber(); i++) {
    if (bd.getBlobWeight(i) < playgroundArea / 10 && bd.getBlobsNumber() < 3) {
      lastCentroidId++;
      lastCentroids[lastCentroidId % lastCentroidsCount].x = bd.getCentroidX(i);
      lastCentroids[lastCentroidId % lastCentroidsCount].y = bd.getCentroidY(i); 
//      print(i, ": ", bd.getEdgeSize(i), " - ", bd.getBlobWeight(i), "\n"); 
//      point(bd.getCentroidX(i), bd.getCentroidY(i));
    }
  }
//  
  blobsImage.updatePixels();
  image(blobsImage, 0, 0);
  drawRectangleToCanvas();
  
  stroke(0, 0, 255);
  strokeWeight(5);
  for(i = 0; i < lastCentroidsCount; i++) {
//    print(lastCentroidId % lastCentroidsCount);
    point(lastCentroids[i].x, lastCentroids[i].y);
  }
}

// Draw a rectangle around canvas
void drawRectangleToCanvas() {
  PVector topLeft = corners[0],
    topRight = corners[1],
    bottomRight = corners[2],
    bottomLeft = corners[3];
       
  strokeWeight(1);
  stroke(204, 102, 0); // red
  
  line(topLeft.x, topLeft.y, topRight.x, topRight.y);
  line(bottomRight.x, bottomRight.y, topRight.x, topRight.y);
  line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y);
  line(bottomRight.x, bottomRight.y, bottomLeft.x, bottomLeft.y);
  
  stroke(135, 183, 255); // light blue
  
  line(cornerXMin, cornerYMin, cornerXMax, cornerYMin);
  line(cornerXMax, cornerYMin, cornerXMax, cornerYMax);
  line(cornerXMax, cornerYMax, cornerXMin, cornerYMax);
  line(cornerXMin, cornerYMax, cornerXMin, cornerYMin);
}


