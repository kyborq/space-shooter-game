Player = Class()

function Player:init()
  -- player params
  self.speed = 0
  self.maxSpeed = 0.8
  self.acceleration = 1.25
  self.deceleration = 0.5

  -- object params
  self.x = 80
  self.y = 90

  -- internal
  self.vx = 0
  self.vy = 0
  self.dx = 0
  self.dy = 0

  -- misc
  self.sprite = Sprite:new("assets/player.png", 0.5)
  self.bullets = {}

  -- modules
  self.weapon = Weapon:new(1.05)

  -- recoil
  self.recoilVx = 0
  self.recoilVy = 0
  self.recoilForce = 60        -- сила отдачи (чем выше — тем сильнее толчок)
  self.recoilStiffness = 25    -- упругость пружины
  self.recoilDamping = 8

  -- stats
  self.xp = 0
  self.health = 100
  self.maxHealth = 100

  self.equippedModules = {}
  
  -- Модули влияют на характеристики
  self:updateModuleStats()
end

function Player:add_XP(amount)
  self.xp = self.xp + amount
end

-- Получить текущий опыт
function Player:getXP()
  return self.xp
end

-- Проверить, достаточно ли опыта для системы
function Player:canAccessSystem(requiredXP)
  return self.xp >= requiredXP
end

-- Получить уровень игрока (каждые 100 XP = 1 уровень)
function Player:getLevel()
  return math.floor(self.xp / 100) + 1
end

-- Получить прогресс до следующего уровня
function Player:getLevelProgress()
  local currentLevelXP = (self:getLevel() - 1) * 100
  local nextLevelXP = self:getLevel() * 100
  local progress = (self.xp - currentLevelXP) / (nextLevelXP - currentLevelXP)
  return math.min(progress, 1)
end

function Player:draw()
  for _, bullet in pairs(self.bullets) do
    bullet:draw()
  end
  self.sprite:draw(self.x, self.y)
end

function Player:movement(dt)
  self.directionX = 0
  self.directionY = 0

  if G.Controls:isActionPressed("up") then self.directionY = -1 end
  if G.Controls:isActionPressed("down") then self.directionY = 1 end
  if G.Controls:isActionPressed("left") then self.directionX = -1 end
  if G.Controls:isActionPressed("right") then self.directionX = 1 end

  if self.directionX ~= 0 or self.directionY ~= 0 then
    local len = math.sqrt(self.directionX^2 + self.directionY^2)
    local normX = self.directionX / len
    local normY = self.directionY / len

    self.vx = self.vx + normX * self.acceleration * dt
    self.vy = self.vy + normY * self.acceleration * dt

    local speed = math.sqrt(self.vx^2 + self.vy^2)
    if speed > self.maxSpeed then
      self.vx = self.vx / speed * self.maxSpeed
      self.vy = self.vy / speed * self.maxSpeed
    end
  else
    local speed = math.sqrt(self.vx^2 + self.vy^2)
    if speed > 0 then
      local decelAmount = self.deceleration * dt
      speed = math.max(speed - decelAmount, 0)
      self.vx = self.vx / (speed + decelAmount) * speed
      self.vy = self.vy / (speed + decelAmount) * speed
    end
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  -- recoil
  self.x = self.x + self.recoilVx * dt
  self.y = self.y + self.recoilVy * dt

  local ax = -self.recoilVx * self.recoilStiffness
  local ay = -self.recoilVy * self.recoilStiffness

  ax = ax - self.recoilVx * self.recoilDamping
  ay = ay - self.recoilVy * self.recoilDamping

  self.recoilVx = self.recoilVx + ax * dt
  self.recoilVy = self.recoilVy + ay * dt
end

function Player:shooting(dt)
  if G.Controls:isActionPressed("fire") then
    if self.weapon:tryFire() then
      -- Обычная стрельба
      local bullet = Bullet:new(self.x, self.y - 6, -90)
      table.insert(self.bullets, bullet)

      -- Проверяем модули стрельбы
      for _, module in ipairs(self.equippedModules) do
        if module and module.name == "DOUBLESHOT" then
          -- Двойной выстрел
          local bullet2 = Bullet:new(self.x + 4, self.y - 6, -90)
          table.insert(self.bullets, bullet2)
        elseif module and module.name == "BURST" then
          -- Залп из 3 пуль
          local bullet2 = Bullet:new(self.x - 2, self.y - 6, -90)
          local bullet3 = Bullet:new(self.x + 2, self.y - 6, -90)
          table.insert(self.bullets, bullet2)
          table.insert(self.bullets, bullet3)
        end
      end

      local angle = math.rad(-90)
      self.recoilVx = self.recoilVx - math.cos(angle) * self.recoilForce
      self.recoilVy = self.recoilVy - math.sin(angle) * self.recoilForce
    end
  end
end


-- Получение урона
function Player:takeDamage(damage)
  self.health = self.health - damage
  if self.health <= 0 then
    self.health = 0
    -- TODO: Обработка смерти игрока
    print("Player died!")
  end
end

-- Лечение
function Player:heal(amount)
  self.health = math.min(self.health + amount, self.maxHealth)
end

-- Получение здоровья
function Player:getHealth()
  return self.health
end

-- Получение максимального здоровья
function Player:getMaxHealth()
  return self.maxHealth
end

-- Проверка, жив ли игрок
function Player:isAlive()
  return self.health > 0
end

-- Установка экипированных модулей
function Player:setEquippedModules(modules)
  self.equippedModules = modules or {}
  self:updateModuleStats()
end

-- Обновление характеристик на основе модулей
function Player:updateModuleStats()
  -- Сбрасываем базовые характеристики
  self.maxSpeed = 0.8
  self.acceleration = 1.25
  self.deceleration = 0.5
  self.maxHealth = 100
  self.weapon.fireRate = 1.05
  
  -- Применяем эффекты модулей
  for _, module in ipairs(self.equippedModules) do
    if module then
      self:applyModuleEffect(module)
    end
  end
  
  -- Восстанавливаем здоровье до максимума при изменении модулей
  if self.health > self.maxHealth then
    self.health = self.maxHealth
  end
end

-- Применение эффекта модуля
function Player:applyModuleEffect(module)
  if not module then return end
  
  if module.name == "SPEEDSTER" then
    self.maxSpeed = self.maxSpeed * 1.5
  elseif module.name == "ACCELERATOR" then
    self.acceleration = self.acceleration * 1.8
  elseif module.name == "DASH" then
    self.maxSpeed = self.maxSpeed * 1.3
    self.acceleration = self.acceleration * 1.5
  elseif module.name == "RELOAD" then
    self.weapon.fireRate = self.weapon.fireRate * 1.5
  elseif module.name == "BURST" then
    self.weapon.fireRate = self.weapon.fireRate * 1.2
  elseif module.name == "INFINITE AMMO" then
    self.weapon.fireRate = self.weapon.fireRate * 2.0
  elseif module.name == "SHIELD" then
    self.maxHealth = self.maxHealth + 50
  elseif module.name == "MIRROR SHIELD" then
    self.maxHealth = self.maxHealth + 30
  elseif module.name == "REGENERATE" then
    self.maxHealth = self.maxHealth + 25
  elseif module.name == "TORTOISER" then
    self.maxSpeed = self.maxSpeed * 0.7
    self.acceleration = self.acceleration * 0.8
  end
end

-- Получение урона с учетом модулей
function Player:takeDamage(damage)
  local actualDamage = damage
  
  -- Проверяем модули защиты
  for _, module in ipairs(self.equippedModules) do
    if module and module.name == "SHIELD" then
      actualDamage = actualDamage * 0.7 -- снижаем урон на 30%
    elseif module and module.name == "MIRROR SHIELD" then
      actualDamage = actualDamage * 0.8 -- снижаем урон на 20%
    end
  end
  
  self.health = self.health - actualDamage
  if self.health <= 0 then
    self.health = 0
    print("Player died!")
  end
end

-- Обновление с учетом модулей
function Player:update(dt)
  self:movement(dt)
  self:shooting(dt)
  self.weapon:update(dt)

  -- Регенерация здоровья
  for _, module in ipairs(self.equippedModules) do
    if module and module.name == "REGENERATE" and self.health < self.maxHealth then
      self.health = math.min(self.health + dt * 5, self.maxHealth) -- 5 HP в секунду
    end
  end

  for i, bullet in pairs(self.bullets) do
    bullet:update(dt)

    if bullet:isOut({x = 0, y = 0, width = WIDTH, height = HEIGHT}) then
      table.remove(self.bullets, i)
    end
  end
end

function Player:checkCollision()
  local x, y, w, h = self.sprite:getBounds(self.x, self.y)
  return false
end