window.GhostLand.Game = (function(GhostLand){
  var Settings = GhostLand.Settings
    , game
    , background

  function init() {
    game = new Phaser.Game(Settings.width, Settings.height, Phaser.CANVAS, 'ghost-land', {
      preload: preload
    , create: create
    , update: update
    , render: render
    });
  }

  function preload() {
    game.load.image('bg-day', 'assets/bg-day.png');
    game.load.image('bg-night', 'assets/bg-day.png');
  }

  function create() {
    background = game.add.tileSprite(0, 0, game.width, game.height, 'bg-day')

    game.input.mouse.mouseDownCallback = function(ev) {
      hit(ev.clientX, ev.clientY)
    }
  }

  function update() {

  }

  function render() {

  }

  function hit(x, y) {

  }

  return {
    init: init
  , hit: hit
  , width: Settings.width
  , height: Settings.height
  }
})(window.GhostLand)
