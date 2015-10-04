# Ghost Land

## About
Real life shooter game. The goal of the game is to shoot as many ghosts before they reach the house.

The game scene is projected on the wall, and a ball is used to shoot. The ball is tracked using a kinect. 
The collision point of the ball with the wall is the shot.

![Ghoster Land Gameplay](https://raw.githubusercontent.com/9-volt/ghost_land/master/screenshots/ghoster-land-gameplay.jpeg)

![Ghoster Land Overview](https://raw.githubusercontent.com/9-volt/ghost_land/master/screenshots/ghoster-land-overview.jpeg)

[Video here](https://youtu.be/Psrh_SsXb38).

## Aim
The aim of the game is to improve hand-eye coordination and provide a fun way to exercise.

## Technologies
The challange was to build an "alive" game using the benefits of modern technologies like: 
* projector/beamer
* Kinect
* [Processing](https://processing.org/)
* WebSockets
* [Phaser](http://phaser.io)

## Requirements
* Kinect (first generation)
* Processing 2.x
  * SimpleOpenNi
  * websocketP5
  * blobscanner
* Google Chrome 45
* Phaser 2.4.3

## How it works
1. Open the web page in browser and project it on the wall
* Run the processing sketch 
* In opened window click on the corners of projected image. Corners order is top-left, top-right, bottom-right, bottom-left
* A rectangle should appear. It means that depth image processing started
* Focus on browser (Phaser stops if it is not focused). If game music is playing then everything is ok.
* Throw the ball to the wall
* Have fun!

## Technical problems that still have to be solved
* Collision point is not perfect. Right now it is computed by taking the fartherst detected point. A better approach would be to compute ball trajectory and get the intersetion with the wall
* Projected points are not perfectly matched with game rectangle. You can see in video (borrom-right corner) that red circle (collision point detected by Kinect) and white circle (point in game) are shifted. A affine transformation should solve this problem much better. 

## Team 
* Art director - @cip
* Head of design - @cip
* CTO - @bumbu
* Quality Assurance - @leoșa
* Research Development Team - @bumbu
* Story Writing - @cip
* Composer - @cip
* Sound engineer - @cip
* Production assistant - @bumbu, @cip
* Installments - @bumbu
* Senior Graphical Designer - @cip
* Junior Graphical Designer - @bumbu
* Logistics manager - @bumbu
* PR - @cip
* Video Production - @cip
* Cameraman - @cip, @bumbu
* HR - @cip
* Technical Lead - @bumbu
* Readme Writer - @bumbu
* Readme Co-writer - @cip

## Partners
* Antioffice
* [big pixel](https://www.facebook.com/canyouseethebigpixel)
* [bumbu.me](http://bumbu.me)
* [FAF](http://faf.utm.md/)
* [Technical University of Moldova](http://www.utm.md/)
* [BEST](http://best-chisinau.org/)

## Papers not published during the work on this project
* Long term effects of throwing a ball to a wall
* Playing a bright game in a dark environment
* Short term effect of scary background music in a dark environment while playing a bright game
* Computing the trajectory of an object in space using Kinect
* Mapping points coordinates from trapezoidal shapes to rectangle shapes

## Time table 
48 hours of hard work.

## Funding
Nobody.

