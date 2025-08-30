Enemy = Class()

function Enemy:init(targetX, targetY)
  local screenLeft = -32
  local screenRight = WIDTH + 32
  local spawnTop = -32
  local screenCenterX = WIDTH / 2

  if targetX < screenCenterX then
    self.x = math.random(screenLeft, 0)
    self.y = math.random(spawnTop, 0)
  else
    self.x = math.random(WIDTH, screenRight)
    self.y = math.random(spawnTop, 0)
  end

  self.targetX = targetX
  self.targetY = targetY

  self.vx = 0
  self.vy = 0
  self.maxSpeed = 0.5
  self.acceleration = 1.0
  self.deceleration = 0.25

  self.sprite = Sprite:new("assets/enemy.png", 0.5)
end

function Enemy:draw()
  self.sprite:draw(self.x, self.y)
end

function Enemy:update(dt)
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
