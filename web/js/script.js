;(function(GhostLand){
  var O = GhostLand.Observer
    , Kinect = GhostLand.Kinect
    , Game = GhostLand.Game
    , $alert = document.getElementById('alert')
    ;

  Game.init()

  O.add('kinect-opened', function(){
    console.log('kinect opened')
    $alert.style.display = 'none'
  })

  O.add('kinect-message', function(message){
    console.log('kinect message', message)
    if (message && message.action && message.action == 'hit') {
      Game.hit(Math.round(Game.width * message.x), Math.round(Game.height * message.y));
    }
  })

  O.add('kinect-closed', function(){
    console.log('kinect closed')
    $alert.style.display = 'block'
    // Hide alert after 3 seconds
    setTimeout(function() {
      $alert.style.display = 'none'
    }, 3000)
  })

  Kinect.connect()
  var kinectTryToConnect = setInterval(function(){
    if(!Kinect.isConnected())
      Kinect.connect()
  }, 10000)
})(window.GhostLand)
