window.GhostLand.Enemies = (function(GhostLand){
  var difficulty = 1
    , game
    , enemiesGroup
    , enemiesDebrisGroup
    , isActive = false

  function init(_game) {
    game = _game
    enemiesGroup = []
    enemiesDebrisGroup = game.add.physicsGroup(Phaser.Physics.P2JS)
  }

  function setDifficulty(newDifficulty) {
    difficulty = Math.max(1, newDifficulty)
  }

  function start() {
    setDifficulty(1)
    isActive = true
  }

  function stop() {
    if (isActive) {
      isActive = false
      // Stop enemies

      for (var i = 0; i < enemiesGroup.length; i++) {
        enemiesGroup[i].destroy()
      }

      enemiesGroup = []
    }
  }

  function tick() {
    var maxGhosts = Math.round(difficulty * 2)
      , availableGhosts = maxGhosts - enemiesGroup.length
      , i
      , ghost
      , coords
      , speed = 1000 / difficulty

    if (isActive && availableGhosts > 0) {
      for (i = 0; i < availableGhosts; i++) {
        // Span ghosts randomly
        if (Math.random() > 1 - difficulty * 0.2) {
          coords = getRandomCoordinates()
          ghost = game.add.sprite(coords.x, coords.y, 'sprite-ghost')
          enemiesGroup.push(ghost)
          ghost.animations.add('move');
          ghost.animations.play('move', 10, true)
          ghost.glAngle = 0
          ghost.glStep = Math.max(0.01, Math.random() / 20)
          ghost.glVectorX = (coords.x - 360) / speed
          ghost.glVectorY = (coords.y - 500) / speed
        }
      }
    }

    if (isActive) {
      for (i = 0; i < enemiesGroup.length; i++) {
        ghost = enemiesGroup[i]
        ghost.glAngle += ghost.glStep
        ghost.x += -Math.abs(Math.sin(ghost.glAngle)) * ghost.glVectorX
        ghost.y += -Math.abs(Math.cos(ghost.glAngle)) * ghost.glVectorY
      }
    }
  }

  function getRandomCoordinates() {
    var x = Math.random() * 600 + 100
    var y = Math.random() * 200 + 50
    return {x: x, y: y}
  }

  function hitCount(x, y) {
    var i , ghost, count = 0, error = 30

    for (i = enemiesGroup.length - 1; i >= 0 ; i--) {
      ghost = enemiesGroup[i]
      if (x + error > ghost.x && x - error < ghost.x + 74 && y + error > ghost.y && y - error < ghost.y + 53) {
        ghost.destroy()
        enemiesGroup.splice(i, 1)
        count++
      }
    }

    return count
  }

  function isHouseHit() {
    if (!isActive) return false;

    for (var i = 0; i < enemiesGroup.length; i++) {
      ghost = enemiesGroup[i]
      if (360 - 74 < ghost.x && 360 + 74 > ghost.x && 500 - 53 < ghost.y && 500 + 53 > ghost.y) {
        ghost.destroy()
        enemiesGroup.splice(i, 1)
        return true
      }
    }

    return false;
  }

  return {
    init: init
  , difficulty: setDifficulty
  , start: start
  , stop: stop
  , tick: tick
  , hitCount: hitCount
  , isHouseHit: isHouseHit
  }
})(window.GhostLand)
