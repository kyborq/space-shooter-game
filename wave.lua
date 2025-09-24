Wave = Class()

function Wave:init(config, factory)
  self.config = config
  self.factory = factory
  self.spawned = false
  self.completed = false
  self.delay = config.delay or 2.0
  self.behavior = config.behavior or "straight"
  self.isBoss = config.isBoss or false
  self.enemyCount = config.enemyCount or #config.positions
  self.enemySpeed = config.enemySpeed or 0.5
  self.enemyHealth = config.enemyHealth or 3
  self.spawnDelay = config.spawnDelay or 0.5
  self.spawnedCount = 0
  self.lastSpawnTime = 0
end

function Wave:update(dt)
  -- Постепенное появление врагов с задержкой
  if not self.spawned then
    self.lastSpawnTime = love.timer.getTime()
    self.spawned = true
  end

  -- Спавним врагов по одному с задержкой
  if self.spawnedCount < self.enemyCount then
    local currentTime = love.timer.getTime()
    if currentTime - self.lastSpawnTime >= self.spawnDelay then
      local position = self.config.positions[self.spawnedCount + 1]
      if position then
        local enemy = self.factory:createSingle(position.x, position.y, {
          speed = self.enemySpeed,
          health = self.enemyHealth,
          behavior = self.behavior,
          isBoss = self.isBoss
        })
        self.spawnedCount = self.spawnedCount + 1
        self.lastSpawnTime = currentTime
      end
    end
  end

  self.factory:update(dt)

  -- check if all enemies are dead
  local allDead = true
  for _, enemy in pairs(self.factory.objects) do
    if not enemy.dead then
      allDead = false
      break
    end
  end
  if allDead and not self.completed and self.spawnedCount >= self.enemyCount then
    self.completed = true
    self.completedAt = love.timer.getTime()
  end
end

function Wave:isReadyForNext()
  if not self.completed then return false end
  local elapsed = love.timer.getTime() - (self.completedAt or 0)
  return elapsed >= self.delay
end

function Wave:draw()
  self.factory:draw()
end