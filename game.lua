Game = Class()

function Game:init(waves)
  self.background = Sprite:new("assets/background.png")
  self.frame = Sprite:new("assets/frame.png")

  -- Используем существующего игрока с модулями
  self.player = G.Player

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
  
  -- Проверяем, завершены ли все волны
  if self.currentWave > #self.waves then
    self:completeMission()
  end
  
  -- Проверяем смерть игрока
  self:handlePlayerDeath()

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
    
    -- handling enemy bullets collision with player
    for _, enemy in ipairs(factory.objects) do
      for i = #enemy.bullets, 1, -1 do
        local bullet = enemy.bullets[i]
        if self:checkBulletPlayerCollision(bullet, self.player) then
          -- Игрок получает урон
          self.player:takeDamage(bullet.damage)
          table.remove(enemy.bullets, i)
        end
      end
    end
  end
end

-- Проверка столкновения пули врага с игроком
function Game:checkBulletPlayerCollision(bullet, player)
  local dx = bullet.x - player.x
  local dy = bullet.y - player.y
  local distance = math.sqrt(dx*dx + dy*dy)
  return distance < 6 -- радиус столкновения (уменьшен для более точной коллизии)
end

-- Завершение миссии
function Game:completeMission()
  print("Mission completed!")
  -- Даем игроку опыт за завершение миссии
  local xpReward = #self.waves * 10 -- 10 XP за каждую волну
  G.Player:add_XP(xpReward)
  
  -- Возвращаемся в меню
  G.State:switch(Menu:new())
end

-- Обработка смерти игрока
function Game:handlePlayerDeath()
  if not self.player:isAlive() then
    print("Game Over!")
    -- Возвращаемся в меню
    G.State:switch(Menu:new())
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
  love.graphics.print(string.format("HP: %d/%d", self.player:getHealth(), self.player:getMaxHealth()), 3, 19)
  
  -- Показываем информацию о текущей волне
  if currentWave then
    love.graphics.print(string.format("Wave: %d/%d", self.currentWave, #self.waves), 3, 3)
  end
  
  -- Показываем активные модули
  local yOffset = 27
  for i, module in ipairs(self.player.equippedModules) do
    if module then
      love.graphics.print(module.name, 3, yOffset)
      yOffset = yOffset + 8
    end
  end
end
