window.GhostLand.Kinect = (function(GhostLand){
  var Settings = GhostLand.Settings
    , O = GhostLand.Observer
    , connection = {}
    ;

  var connect = function(){
    if (connection.readyState === undefined || connection.readyState > 1) {
      connection = new WebSocket('ws://'+Settings.socket.hostname+':'+Settings.socket.port+'/'+Settings.socket.path);

      connection.onopen = function () {
        O.trigger('kinect-opened', true)
      };

      connection.onmessage = function (event) {
        O.trigger('kinect-message', JSON.parse(event.data))
      };

      connection.onclose = function (event) {
        O.trigger('kinect-closed', true)
      };
    }
  }

  return {
    connect: connect
  , isConnected: function(){
      return connection.readyState !== undefined && connection.readyState == 1
    }
  }
})(window.GhostLand);
