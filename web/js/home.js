window.GhostLand.Home = (function(GhostLand){
  var game
    , home = null
    , homeX = 400 - 40
    , homeY = 525 - 55

  function init(_game) {
    game = _game
  }

  function show() {
    home = game.add.sprite(homeX, homeY, 'sprite-home')
  }

  function hide() {
    home && home.destroy()
    home = null
  }

  function setLife(life) {
    home.frame = Math.min(3, Math.max(0, 3 - life))
  }

  function hit() {
    home && game.add.tween(home)
      .to({x: homeX + 10}, 100, Phaser.Easing.Bounce.InOut, true, 0, 0, true);
  }

  return {
    init: init
  , show: show
  , hide: hide
  , setLife: setLife
  , hit: hit
  }
})(window.GhostLand)
