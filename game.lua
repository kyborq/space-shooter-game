Game = Class()

function Game:init(waves)
  self.background = Sprite:new("assets/background.png")
  self.frame = Sprite:new("assets/frame.png")

  self.player = Player:new()

  -- init waves
  self.waves = {}
  if waves then
    local enemies = Factory:new(Enemy)
    for _, waveConfig in pairs(waves) do
      local wave = Wave:new(waveConfig, enemies)
      table.insert(self.waves, wave)
    end
  end

  self.currentWave = 1

  G.Signals:connect("enemy_killed", function(enemy)
    self.player:add_XP(1)
  end)
end

function Game:update(dt)
  self.player:update(dt)

  local currentWave = self.waves[self.currentWave]
  if currentWave then
    currentWave:update(dt)
    if currentWave:isReadyForNext() then
      self.currentWave = self.currentWave + 1
      currentWave.factory.objects = {}
    end
  end

  -- handling bullets collision with enemies
  local factory = currentWave and currentWave.factory
  if factory then
    for i = #self.player.bullets, 1, -1 do
      local bullet = self.player.bullets[i]
      for _, enemy in ipairs(factory.objects) do
        if bullet:collidesWithEnemy(enemy) then
          local angle = Utils.degtorad(bullet.direction)
          local dx = math.cos(angle)
          local dy = math.sin(angle)
          enemy:hit(dx, dy, 2.0)
          table.remove(self.player.bullets, i)
          break
        end
      end
    end
  end
end

function Game:draw()
  self.background:draw()

  local currentWave = self.waves[self.currentWave]
  if currentWave then
    currentWave:draw()
  end

  self.player:draw()
  self.frame:draw()

  love.graphics.print(string.format("%dXP", self.player.xp), 3, 11)
end
