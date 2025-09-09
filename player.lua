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
  self.recoilTimer = Timer:new()
  self.recoilForce = 0.33
  self.recoilDuration = 0.02
  self.recoilVx = 0
  self.recoilVy = 0
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

  self.recoilTimer:update(dt)
  if not self.recoilTimer:isFinished() then
    self.x = self.x + self.recoilVx
    self.y = self.y + self.recoilVy

    local decayFactor = dt / self.recoilDuration
    self.recoilVx = self.recoilVx * (1 - decayFactor)
    self.recoilVy = self.recoilVy * (1 - decayFactor)
  else
    self.recoilVx, self.recoilVy = 0, 0
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy


end

function Player:shooting(dt)
  if G.Controls:isActionPressed("fire") then
    if self.weapon:tryFire() then
      local bullet = Bullet:new(self.x, self.y - 6, -90)
      table.insert(self.bullets, bullet)

      local angle = math.rad(-90)
      self.recoilVx = self.recoilVx - math.cos(angle) * self.recoilForce
      self.recoilVy = self.recoilVy - math.sin(angle) * self.recoilForce
      self.recoilTimer:reset(self.recoilDuration)
    end
  end
end

function Player:update(dt)
  self:movement(dt)
  self:shooting(dt)
  self.weapon:update(dt)

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