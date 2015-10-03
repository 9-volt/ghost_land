window.GhostLand.Game = (function(GhostLand){
  var Settings = GhostLand.Settings
    , Enemies = GhostLand.Enemies
    , Home = GhostLand.Home
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
        , time: 30
        , next: 'lets_play'
        , text: 'HARD ONE, EH?\n\nWANNA TRY AGAIN?\nHIT THE SUN FOR “YES”'
        }
      }
    , text
    , textStyle = {font: "normal 24px sans-serif", align: "center", fill: "#fff", boundsAlignH: "center", boundsAlignV: "top" }
    , currentState = null
    , currentStateName = null
    , currentStateStartTime = null
    , currentStateHits = 0
    , currentLife = 3
    , score = 0
    , scoreText
    , audio = {
        death: null
      , gameplay: null
      , hit: null
      , intro: null
      , start: null
      }
    , sun

  function init() {
    game = new Phaser.Game(Settings.width, Settings.height, Phaser.AUTO, 'ghost-land', {
      preload: preload
    , create: create
    , update: update
    });
  }

  function preload() {
    game.load.image('bg-day', 'assets/bg-day.png');
    game.load.image('bg-night', 'assets/bg-night.png');
    game.load.spritesheet('sprite-ghost', 'assets/sprite-ghost.png', 74, 53, 6, 0, 1);
    game.load.spritesheet('sprite-home', 'assets/sprite-home.png', 79, 82, 4, 0, 1);
    game.load.spritesheet('sprite-sun', 'assets/sprite-sun.png', 124, 124, 1);
    game.load.audio('audio-death', 'assets/audio/death.mp3')
    game.load.audio('audio-gameplay', 'assets/audio/gameplay.mp3')
    game.load.audio('audio-hit', 'assets/audio/hit.mp3')
    game.load.audio('audio-intro', 'assets/audio/intro.mp3')
    game.load.audio('audio-start', 'assets/audio/start.mp3')
  }

  function create() {
    // Background
    background = game.add.tileSprite(0, 0, game.width, game.height, 'bg-day')

    // Phisics
    game.physics.startSystem(Phaser.Physics.P2JS)
    // game.physics.p2.defaultRestitution = 0.8
    game.physics.p2.gravity.y = 100

    // Input
    game.input.mouse.mouseDownCallback = function(ev) {
      hit(ev.clientX, ev.clientY)
    }

    // Text
    text = game.add.text(0, 0, '', textStyle);
    text.setTextBounds(100, 200, 600, 400);
    scoreText = game.add.text(0, 0, '', {font: 'normal 36px sans-serif', align: 'right', fill: '#fff', boundsAlignH: 'right'})
    scoreText.setTextBounds(600, 10, 180, 40);

    // State
    checkForState()

    // Enemies
    Enemies.init(game)
    Home.init(game)

    // Audio
    audio.death = game.add.audio('audio-death')
    audio.death.loop = false
    audio.gameplay = game.add.audio('audio-gameplay')
    audio.gameplay.loop = true
    audio.hit = game.add.audio('audio-hit')
    audio.hit.loop = false
    audio.intro = game.add.audio('audio-intro')
    audio.intro.loop = true
    audio.start = game.add.audio('audio-start')
    audio.start.loop = false
  }

  function update() {
    checkForState()
    Enemies.tick()

    if (currentStateName === 'game' && Enemies.isHouseHit()) {
      currentLife--;
      Home.setLife(currentLife)
      Home.hit()
      console.log('Life left', currentLife)

      if (currentLife == 0) {
        setState('death')
      }
    }
  }

  function hit(x, y) {
    if (currentStateName == 'hit_the_sun' || currentStateName == 'death') {
      // Hit the sun
      if (x > 338 && x < 463 && y > 27 && y < 152) {
        currentStateHits++
        sun && game.add.tween(sun)
          .to({x: 400 - 62 + 10}, 40, Phaser.Easing.Bounce.InOut, true, 0, 3, true);
      } else {
        currentStateHits = 0
      }
    }

    // If completed hit_the_sun
    if (currentStateName == 'hit_the_sun' && currentStateHits >= 3) {
      setState(currentState.next)
    // If completed death
    } else if (currentStateName == 'death' && currentStateHits >= 1) {
      // setState(currentState.next)
      setState('lets_play_then')
    } else if (currentStateName == 'game') {
      var hitCount = Enemies.hitCount(x, y)

      if (hitCount) {
        audio.hit && audio.hit.play()
        currentStateHits += hitCount
        Enemies.difficulty(Math.log(currentStateHits))
        scoreText.text = currentStateHits
      } else {
        console.log('Missed')
      }
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

    if (nextState === 'game') {
      Enemies.start()
      Home.show()
      scoreText.text = '0'
      audio.start && audio.start.play()
      audio.intro && audio.intro.isPlaying && audio.intro.stop()
      audio.gameplay && !audio.gameplay.isPlaying && audio.gameplay.play()
      sun && sun.destroy() && (sun = null)
    } else {
      Enemies.stop()
      Home.hide()
      scoreText.text = ''
      audio.gameplay && audio.gameplay.isPlaying && audio.gameplay.stop()
      audio.intro && !audio.intro.isPlaying && audio.intro.play()

      if (nextState === 'death') {
        audio.death && audio.death.play()
      }

      if (!sun) {
        sun = game.add.sprite(400 - 62, 24, 'sprite-sun')
      }
    }
  }

  return {
    init: init
  , hit: hit
  , width: Settings.width
  , height: Settings.height
  }
})(window.GhostLand)
