Enemy = Class()

function Enemy:init(targetX, targetY, params)
  self.x = targetX
  self.y = targetY - 10

  self.targetX = targetX
  self.targetY = targetY

  self.vx = 0
  self.vy = 0
  self.maxSpeed = (params and params.speed) or 0.5
  self.acceleration = 1.0
  self.deceleration = 0.25

  self.sprite = Sprite:new("assets/enemy.png", 0.5)

  self.health = (params and params.health) or 3
  self.dead = false
  
  -- Поведение врага
  self.behavior = (params and params.behavior) or "straight"
  self.isBoss = (params and params.isBoss) or false
  
  -- Параметры для различных поведений
  self.behaviorTimer = 0
  self.zigzagDirection = 1
  self.circleRadius = 20
  self.circleAngle = 0
  self.circleCenterX = targetX
  self.circleCenterY = targetY + 30
  self.aggressiveTargetX = targetX
  self.aggressiveTargetY = targetY + 60
  
  -- Стрельба
  self.canShoot = true
  self.shootTimer = 0
  self.shootCooldown = 2.0 -- секунды между выстрелами
  self.bullets = {}
  
  -- Увеличиваем размер спрайта для босса
  if self.isBoss then
    self.sprite = Sprite:new("assets/enemy.png", 1.0)
    self.maxSpeed = self.maxSpeed * 0.7 -- босс медленнее
    self.shootCooldown = 1.0 -- босс стреляет чаще
  end
end

function Enemy:draw()
  if self.dead then
    return
  end

  self.sprite:draw(self.x, self.y)
  self:drawBullets()
end

function Enemy:update(dt)
  if self.dead then
    return
  end

  self.behaviorTimer = self.behaviorTimer + dt
  self.shootTimer = self.shootTimer + dt

  -- Обновляем поведение в зависимости от типа
  if self.behavior == "straight" then
    self:updateStraightBehavior(dt)
  elseif self.behavior == "zigzag" then
    self:updateZigzagBehavior(dt)
  elseif self.behavior == "circle" then
    self:updateCircleBehavior(dt)
  elseif self.behavior == "aggressive" then
    self:updateAggressiveBehavior(dt)
  elseif self.behavior == "boss" then
    self:updateBossBehavior(dt)
  end

  -- Обновляем пули
  self:updateBullets(dt)

  -- Стрельба
  if self.shootTimer >= self.shootCooldown then
    self:shoot()
    self.shootTimer = 0
  end

  if self.health <= 0 then
    self.dead = true
  end
end

-- Прямолинейное движение
function Enemy:updateStraightBehavior(dt)
  local dx = self.targetX - self.x
  local dy = self.targetY - self.y
  local dist = math.sqrt(dx^2 + dy^2)
  local Kp = 0.5

  self.vx = self.vx + dx * Kp * dt
  self.vy = self.vy + dy * Kp * dt

  local speed = math.sqrt(self.vx^2 + self.vy^2)
  if speed > self.maxSpeed then
    self.vx = self.vx / speed * self.maxSpeed
    self.vy = self.vy / speed * self.maxSpeed
  end

  if dist < 5 then
    self.vx = self.vx * 0.8
    self.vy = self.vy * 0.8
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy
end

-- Зигзагообразное движение
function Enemy:updateZigzagBehavior(dt)
  local baseTargetX = self.targetX + math.sin(self.behaviorTimer * 3) * 20
  local baseTargetY = self.targetY
  
  local dx = baseTargetX - self.x
  local dy = baseTargetY - self.y
  local Kp = 0.3

  self.vx = self.vx + dx * Kp * dt
  self.vy = self.vy + dy * Kp * dt

  local speed = math.sqrt(self.vx^2 + self.vy^2)
  if speed > self.maxSpeed then
    self.vx = self.vx / speed * self.maxSpeed
    self.vy = self.vy / speed * self.maxSpeed
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy
end

-- Круговое движение
function Enemy:updateCircleBehavior(dt)
  self.circleAngle = self.circleAngle + dt * 2
  
  local targetX = self.circleCenterX + math.cos(self.circleAngle) * self.circleRadius
  local targetY = self.circleCenterY + math.sin(self.circleAngle) * self.circleRadius
  
  local dx = targetX - self.x
  local dy = targetY - self.y
  local Kp = 0.8

  self.vx = self.vx + dx * Kp * dt
  self.vy = self.vy + dy * Kp * dt

  local speed = math.sqrt(self.vx^2 + self.vy^2)
  if speed > self.maxSpeed then
    self.vx = self.vx / speed * self.maxSpeed
    self.vy = self.vy / speed * self.maxSpeed
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy
end

-- Агрессивное поведение (движется к игроку)
function Enemy:updateAggressiveBehavior(dt)
  -- Ищем игрока
  local player = G.Player
  if player then
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx^2 + dy^2)
    
    if dist > 0 then
      dx = dx / dist
      dy = dy / dist
      
      self.vx = self.vx + dx * 0.8 * dt
      self.vy = self.vy + dy * 0.8 * dt
    end
  end

  local speed = math.sqrt(self.vx^2 + self.vy^2)
  if speed > self.maxSpeed * 1.2 then -- агрессивные враги быстрее
    self.vx = self.vx / speed * self.maxSpeed * 1.2
    self.vy = self.vy / speed * self.maxSpeed * 1.2
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy
end

-- Поведение босса
function Enemy:updateBossBehavior(dt)
  -- Босс движется медленно и предсказуемо
  local dx = self.targetX - self.x
  local dy = self.targetY - self.y
  local dist = math.sqrt(dx^2 + dy^2)
  local Kp = 0.2

  self.vx = self.vx + dx * Kp * dt
  self.vy = self.vy + dy * Kp * dt

  local speed = math.sqrt(self.vx^2 + self.vy^2)
  if speed > self.maxSpeed then
    self.vx = self.vx / speed * self.maxSpeed
    self.vy = self.vy / speed * self.maxSpeed
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy
end

-- Стрельба
function Enemy:shoot()
  if not self.canShoot then return end
  
  local bullet = {
    x = self.x + 3, -- центр врага
    y = self.y + 3,
    vx = 0,
    vy = 0.5, -- пули летят вниз
    speed = 1.0,
    damage = 1,
    life = 2.0 -- время жизни пули
  }
  
  -- Различные типы стрельбы в зависимости от поведения
  if self.behavior == "aggressive" then
    -- Агрессивные враги стреляют в игрока
    local player = G.Player
    if player then
      local dx = player.x - self.x
      local dy = player.y - self.y
      local dist = math.sqrt(dx^2 + dy^2)
      if dist > 0 then
        bullet.vx = (dx / dist) * bullet.speed
        bullet.vy = (dy / dist) * bullet.speed
      end
    end
  elseif self.behavior == "boss" then
    -- Босс стреляет веером
    for i = -2, 2 do
      local angle = i * 0.3
      local bossBullet = {
        x = self.x + 3,
        y = self.y + 3,
        vx = math.sin(angle) * bullet.speed,
        vy = math.cos(angle) * bullet.speed,
        speed = 1.0,
        damage = 2,
        life = 3.0
      }
      table.insert(self.bullets, bossBullet)
    end
    return -- для босса не добавляем обычную пулю
  end
  
  table.insert(self.bullets, bullet)
end

-- Обновление пуль врага
function Enemy:updateBullets(dt)
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    bullet.x = bullet.x + bullet.vx * dt * 60
    bullet.y = bullet.y + bullet.vy * dt * 60
    bullet.life = bullet.life - dt
    
    -- Удаляем пули, которые вышли за экран или истекло время жизни
    if bullet.y > 120 or bullet.y < -10 or bullet.x < -10 or bullet.x > 170 or bullet.life <= 0 then
      table.remove(self.bullets, i)
    end
  end
end

-- Рисование пуль врага
function Enemy:drawBullets()
  love.graphics.setColor(1, 0, 0, 1) -- красные пули врагов
  for _, bullet in ipairs(self.bullets) do
    love.graphics.rectangle("fill", bullet.x, bullet.y, 2, 2)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function Enemy:hit(dx, dy, force)
  self.health = self.health - 1

  local len = math.sqrt(dx*dx + dy*dy)
  if len > 0 then
    dx = dx / len
    dy = dy / len
  end

  local knockbackForce = force or 1.5
  self.vx = self.vx + dx * knockbackForce
  self.vy = self.vy + dy * knockbackForce

  if self.health <= 0 and not self.dead then
    self.dead = true
    G.Signals:emit("enemy_killed", self)
  end
end
