Wave = Class()

function Wave:init(config, factory)
  self.config = config
  self.factory = factory
  self.spawned = false
  self.completed = false
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
  if allDead then
    self.completed = true
  end
end

function Wave:draw()
  self.factory:draw()
end