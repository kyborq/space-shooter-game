Wave = Class()

function Wave:init(config, factory)
  self.config = config
  self.factory = factory
  self.spawned = false
  self.completed = false
  self.delay = config.delay or 2.0
end

function Wave:update(dt)
  if not self.spawned then
    self.factory:create(self.config.positions)
    self.spawned = true
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
  if allDead and not self.completed then
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