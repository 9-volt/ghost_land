;(function(GhostLand){
  var O = GhostLand.Observer
    , Kinect = GhostLand.Kinect
    ;

  O.add('kinect-opened', function(){
    console.log('kinect opened')
  })

  O.add('kinect-message', function(message){
    console.log('kinect message', message)
  })

  O.add('kinect-closed', function(){
    console.log('kinect closed')
  })

  Kinect.connect()
  var kinectTryToConnect = setInterval(function(){
    if(!Kinect.isConnected())
      Kinect.connect()
  }, 10000)
})(window.GhostLand)
