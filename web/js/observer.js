window.GhostLand.Observer = (function(){
  // Private var
  var observers = []

  return {
    add: function(topic, observer) {
      observers[topic] || (observers[topic] = [])

      observers[topic].push(observer)
    }
  , remove: function(topic, observer) {
      if (!observers[topic])
        return;

      var index = observers[topic].indexOf(observer)

      if (~index) {
        observers[topic].splice(index, 1)
      }
    }
  , trigger: function(topic, message) {
      if (!observers[topic])
        return;

      for (var i = observers[topic].length - 1; i >= 0; i--) {
        observers[topic][i](message)
      };
    }
  }
})(window.GhostLand);
