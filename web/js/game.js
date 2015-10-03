window.GhostLand.Game = (function(GhostLand){
  var Settings = GhostLand.Settings
    , game
    , background
    , gameStates = {
        welcome: {
          bg: 'day'
        , time: Settings.isDebug ? 0.5 : 5
        , next: 'lets_play'
        , text: 'WELCOME TO GHOST LAND'
        }
      , lets_play: {
          bg: 'day'
        , time: Settings.isDebug ? 0.5 : 3
        , next: 'are_you_worthy'
        , text: 'LET’S PLAY A GAME'
        }
      , are_you_worthy: {
          bg: 'day'
        , time: Settings.isDebug ? 0.5 : 4
        , next: 'hit_the_sun'
        , text: 'FIRST, LET’S SEE IF YOU’RE A WORTHY PLAYER'
        }
      , hit_the_sun: {
          bg: 'day'
        , time: -1
        , next: 'lets_play_then'
        , text: 'SEE THE SUN? (DUHH)\n\nHIT IT 3 TIMES IN A ROW'
        }
      , lets_play_then: {
          bg: 'night'
        , time: Settings.isDebug ? 0.5 : 3
        , next: 'game'
        , text: 'OK, LET’S PLAY THEN\n\nKILL THE GHOSTS BEFORE THEY GET TO YOUR HOUSE'
        }
      , game: {
          bg: 'night'
        , time: -1
        , next: 'death'
        , text: ''
        }
      , death: {
          bg: 'day'
        , time: Settings.isDebug ? 0.5 : 30
        , next: 'lets_play'
        , text: 'HARD ONE, EH?\n\nWANNA TRY AGAIN?\nHIT THE SUN FOR “YES”'
        }
      }
    , textStyle = {font: "normal 24px sans-serif", align: "center", fill: "#fff", boundsAlignH: "center", boundsAlignV: "top" }
    , currentState = null
    , currentStateName = null
    , currentStateStartTime = null
    , currentStateHits = 0

  function init() {
    game = new Phaser.Game(Settings.width, Settings.height, Phaser.CANVAS, 'ghost-land', {
      preload: preload
    , create: create
    , update: update
    });
  }

  function preload() {
    game.load.image('bg-day', 'assets/bg-day.png');
    game.load.image('bg-night', 'assets/bg-night.png');
  }

  function create() {
    background = game.add.tileSprite(0, 0, game.width, game.height, 'bg-day')

    game.input.mouse.mouseDownCallback = function(ev) {
      hit(ev.clientX, ev.clientY)
    }

    // Init text
    text = game.add.text(0, 0, '', textStyle);
    text.setTextBounds(100, 200, 600, 400);

    checkForState()
  }

  function update() {
    checkForState()
  }

  function hit(x, y) {
    if (currentStateName == 'hit_the_sun' || currentStateName == 'death') {
      // Hit the sun
      if (x > 338 && x < 463 && y > 27 && y < 152) {
        currentStateHits++
      }
    }

    // If completed hit_the_sun
    if (currentStateName == 'hit_the_sun' && currentStateHits >= 3) {
      setState(currentState.next)
    // If completed death
    } else if (currentStateName == 'death' && currentStateHits >= 1) {
      setState(currentState.next)
    }
  }

  function checkForState() {
    var nextState = null

    if (currentStateName == null) {
      nextState = 'welcome'
    } else if (currentState.next && currentState.time >= 0 && currentState.time * 1000 < Date.now() - currentStateStartTime) {
      nextState = currentState.next
    }

    if (nextState && nextState != currentStateName) {
      setState(nextState)
    }
  }

  function setState(nextState) {
    currentStateName = nextState
    currentState = gameStates[currentStateName]
    currentStateStartTime = Date.now()
    currentStateHits = 0

    // Backgrounds needs an update
    if (background.key != 'bg-' + currentState.bg) {
      background.loadTexture('bg-' + currentState.bg)
    }

    if (currentState.text != null) {
      text.text = currentState.text;
    }
  }

  return {
    init: init
  , hit: hit
  , width: Settings.width
  , height: Settings.height
  }
})(window.GhostLand)
