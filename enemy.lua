Enemy = Class()

function Enemy:init(targetX, targetY)
  self.x = targetX
  self.y = targetY - 10

  self.targetX = targetX
  self.targetY = targetY

  self.vx = 0
  self.vy = 0
  self.maxSpeed = 0.5
  self.acceleration = 1.0
  self.deceleration = 0.25

  self.sprite = Sprite:new("assets/enemy.png", 0.5)

  self.health = 3
  self.dead = false
end

function Enemy:draw()
  if self.dead then
    return
  end

  self.sprite:draw(self.x, self.y)
end

function Enemy:update(dt)
  if self.dead then
    return
  end

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

  if self.health <= 0 then
    self.dead = true
  end
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
end
