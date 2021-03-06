import SimpleOpenNI.*;
import blobscanner.*;
import muthesius.net.*;
import org.webbitserver.*;
import Jama.*;

class QuadRectTransform {
  public QuadRectTransform(PVector q1, PVector q2, PVector q3, PVector q4,
                   PVector r1, PVector r2, PVector r3, PVector r4) {

    Matrix A = new Matrix(new double[][]{
      { r1.x, r1.y, 1., 0., 0., 0., (-q1.x)*r1.x, (-q1.x)*r1.y },
      { 0., 0., 0., r1.x, r1.y, 1., (-q1.y)*r1.x, (-q1.y)*r1.y },
      { r2.x, r2.y, 1., 0., 0., 0., (-q2.x)*r2.x, (-q2.x)*r2.y },
      { 0., 0., 0., r2.x, r2.y, 1., (-q2.y)*r2.x, (-q2.y)*r2.y },
      { r3.x, r3.y, 1., 0., 0., 0., (-q3.x)*r3.x, (-q3.x)*r3.y },
      { 0., 0., 0., r3.x, r3.y, 1., (-q3.y)*r3.x, (-q3.y)*r3.y },
      { r4.x, r4.y, 1., 0., 0., 0., (-q4.x)*r4.x, (-q4.x)*r4.y },
      { 0., 0., 0., r4.x, r4.y, 1., (-q4.y)*r4.x, (-q4.y)*r4.y }
    });

    Matrix B = new Matrix(new double[][]{
      { q1.x },
      { q1.y },
      { q2.x },
      { q2.y },
      { q3.x },
      { q3.y },
      { q4.x },
      { q4.y }
    });

    Matrix s = A.solve(B);

    rect2quadMat = new Matrix(new double[][]{
      { s.get(0, 0), s.get(1, 0), s.get(2, 0) },
      { s.get(3, 0), s.get(4, 0), s.get(5, 0) },
      { s.get(6, 0), s.get(7, 0), 1. }
    });

    quad2rectMat = rect2quadMat.inverse();
  }

  /*
  Translates a (x, y) quadrilateral point into (X, Y) rectangle point
  */
  public PVector quad2rect(PVector v) {
    return transform(quad2rectMat, v);
  }

  /*
  Translates a (X, Y) rectangle point into (x, y) quadrilateral point
  */
  public PVector rect2quad(PVector v) {
    return transform(rect2quadMat, v);
  }

  private PVector transform(Matrix transformMat, PVector v) {
    Matrix columnVec = new Matrix(new double[][]{
      { v.x },
      { v.y },
      { 1. }
    });

    Matrix result = transformMat.times(columnVec);

    return new PVector(new Float(result.get(0, 0) / result.get(2, 0)),
                       new Float(result.get(1, 0) / result.get(2, 0)));
  }


  private Matrix rect2quadMat;
  private Matrix quad2rectMat;
}


// Context and drawing canvas
SimpleOpenNI  context;
PImage canvas = null;

// Corners
PVector[] corners = new PVector[4]; // top-left, top-right, bottom-right, bottom-left
QuadRectTransform qrTransformer;
boolean cornersSet = false;
int cornersSetCount = 0;
java.awt.Polygon cornersPolygon = new java.awt.Polygon();

// Blobs detecting
Detector bd;
PImage blobsImage;
int[] blobsArray;
int cornerXMin, cornerXMax, cornerYMin, cornerYMax, cornerXSize, cornerYSize;
int playgroundArea;

// Centroids
int nextCentroidId = 0, lastCentroidsCount = 20;
PVector[] lastCentroids = new PVector[lastCentroidsCount];
PVector lastCentroidHit = new PVector(0, 0);
int emptyFramesCount = 0;
boolean centroidFound = true;

// Depth variation
int canvasDepthMax = 0;
int canvasDepthMin = 999999;
int[] defaultDepthValues = new int[640 * 480];

// Socket
WebSocketP5 socket;

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

  // Socket
  socket = new WebSocketP5(this,8080);
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

  qrTransformer = new QuadRectTransform(corners[0], corners[1], corners[2], corners[3],
                                        new PVector(0, 0), new PVector(0, 1),
                                        new PVector(1, 1), new PVector(1, 0));

  // Enlarge corners
//  cornerXMin -= (int) (cornerXSize * 0.1);
//  cornerXMax += (int) (cornerXSize * 0.1);
//  cornerXSize = cornerXMax - cornerXMin;
//  cornerYMin -= (int) (cornerYSize * 0.1);
//  cornerYMax += (int) (cornerYSize * 0.1);
//  cornerYSize = cornerYMax - cornerYMin;

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
  int i, x, y, depth, colorChanell, validBlobsCount;
  boolean hasValidCentroid = false;

  background(255, 255, 255);

  canvas.loadPixels();
  blobsImage.loadPixels();

  for (y = 0; y < 480; y++) {
    for (x = 0; x < 640; x++) {
      i = x + y * 640;
      depth = depthValues[i];

      if (x < cornerXMax && x > cornerXMin && y < cornerYMax && y > cornerYMin) {
        if (Math.abs(depth - defaultDepthValues[i]) < 100) {
          blobsImage.pixels[i] = color(0, 0, 0);
        } else {
          colorChanell = (int) (255 * depth / canvasDepthMax);
          blobsImage.pixels[i] = color(255, 255, 255);
        }
      }

      // Display only variations bigger than 100 units
      if (Math.abs(depth - defaultDepthValues[i]) < 100) {

        if (cornersPolygon.contains(x, y)) {
          canvas.pixels[i] = color(255, 255, 128);
        } else {
          canvas.pixels[i] = color(255, 255, 255);
        }
      } else {
        canvas.pixels[i] = color(0,0,100);
      }


    }
  }

  bd.findBlobs(blobsImage.pixels, blobsImage.width, blobsImage.height);

  canvas.updatePixels();
//  image(canvas, 0, 0);

  blobsImage.updatePixels();
//  image(blobsImage, 0, 0);
  image(context.rgbImage(), 0, 0);
  drawRectangleToCanvas();

  bd.loadBlobsFeatures(); // mandatory
  bd.weightBlobs(false);
  bd.findCentroids();
  bd.drawContours(color(255, 0, 0), 2);

  validBlobsCount = 0;
  for(i = 0; i < bd.getBlobsNumber(); i++) {
    x = (int) bd.getCentroidX(i);
    y = (int) bd.getCentroidY(i);
    depth = depthValues[x + y * 640];
    if (bd.getBlobWeight(i) < playgroundArea / 25 && bd.getBlobWeight(i) > 20 && depth > 0) {
      validBlobsCount++;
    }
  }

  // Only if there is one valid blob
  if (validBlobsCount == 1) {
    for(i = 0; i < bd.getBlobsNumber(); i++) {
      x = (int) bd.getCentroidX(i);
      y = (int) bd.getCentroidY(i);
      depth = depthValues[x + y * 640];

      if (bd.getBlobWeight(i) < playgroundArea / 25 && bd.getBlobWeight(i) > 20 && depth > 0) {
        lastCentroids[nextCentroidId % lastCentroidsCount].x = x;
        lastCentroids[nextCentroidId % lastCentroidsCount].y = y;
        lastCentroids[nextCentroidId % lastCentroidsCount].z = depthValues[x + y * 640]; // Depth
//        print(x, " ", y, " ", depthValues[x + y * 640], "\n");
        nextCentroidId++;
        hasValidCentroid = true;
        checkCentroids();
      }
    }
  }


  if (!hasValidCentroid) {
    emptyFrame();
  }
//


  stroke(142, 255, 154);
  strokeWeight(5);
  for(i = 0; i < lastCentroidsCount; i++) {
    if (lastCentroids[i].z > 0) {
      stroke(142, 255, (int) (255 * lastCentroids[i].z / canvasDepthMax));
    //    print((int) (255 * lastCentroids[i].z / canvasDepthMax), " ", lastCentroids[i].z, "\n");
    //    print(nextCentroidId % lastCentroidsCount);
      point(lastCentroids[i].x, lastCentroids[i].y);
    }
  }

  stroke(255, 0, 0);
  strokeWeight(8);
  point(lastCentroidHit.x, lastCentroidHit.y);
}

void checkCentroids() {
  // If new centroid was just added
  if (nextCentroidId == 1) {
    centroidFound = false;
    emptyFramesCount = 0;

    // Reset previous centroids
    for (int i = 1; i < lastCentroidsCount; i++) {
      lastCentroids[i].x = 0;
      lastCentroids[i].y = 0;
      lastCentroids[i].z = 0;
    }
  }

  // If 3 centroids colected and centroid stil not found
  if (nextCentroidId > 3 && !centroidFound) {
    for (int i = 1; i < nextCentroidId && i < lastCentroidsCount; i++) {
      if (lastCentroids[i - 1].z > 0 && lastCentroids[i - 1].z > lastCentroids[i].z) {
        computeCentroid();
        break;
      }
    }
  }

  // Check if we should compute hit now
}

void emptyFrame() {
  emptyFramesCount++;
  if (emptyFramesCount >= 7 && nextCentroidId > 0 && !centroidFound) {
    computeCentroid();
  }

  if (emptyFramesCount >= 7 && centroidFound) {
    nextCentroidId = 0;
  }
}

// TODO make working even if onyl decreasing points passed
// TODO compute hit by computing trajectory
void computeCentroid() {
  print("Computing centroid\n");
  float hitX, hitY;

  if (nextCentroidId > 2) {
    for (int i = 1; i < nextCentroidId && i < lastCentroidsCount; i++) {
      if (lastCentroids[i - 1].z < lastCentroids[i].z) {
        // Still increasing
      } else {
        // If near the wall
        if (lastCentroids[i - 1].z > canvasDepthMin * 0.9 || lastCentroids[i].z > canvasDepthMin * 0.9) {
          // Take the farest point as hit
          if (lastCentroids[i].z > lastCentroids[i - 1].z) {
            lastCentroidHit.x = lastCentroids[i].x;
            lastCentroidHit.y = lastCentroids[i].y;
          } else {
            lastCentroidHit.x = lastCentroids[i - 1].x;
            lastCentroidHit.y = lastCentroids[i - 1].y;
          }

          PVector hit = qrTransformer.quad2rect(lastCentroidHit);

          print("{\"action\": \"hit\", \"x\": " + hit.x + ", \"y\": " + hit.y + "}");
          socket.broadcast("{\"action\": \"hit\", \"x\": " + hit.x + ", \"y\": " + hit.y + "}");
        // Too far from wall
        } else {
          print("Something detected, but too far from wall\n");
          print("i ", i, "Prev ", lastCentroids[i - 1].z, " Next ", lastCentroids[i].z, "\n");
          for (int j = 0; j < nextCentroidId && j < lastCentroidsCount; j++) {
            print("i: ", j, " x:", lastCentroids[j].x, " y:", lastCentroids[j].y, " z:", lastCentroids[j].z, "\n");
          }
        }
        break; // Leave loop
      }
    }
  }

  centroidFound = true;
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

// Websocket functions
void stop(){
  socket.stop();
}

void websocketOnMessage(WebSocketConnection con, String msg){
  println(msg);
}

void websocketOnOpen(WebSocketConnection con){
  println("A client joined");
}

void websocketOnClosed(WebSocketConnection con){
  println("A client left");
}


