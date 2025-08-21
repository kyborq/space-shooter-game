Bullet = Class()

function Bullet:init(x, y, direction, speed)
  self.x = x or 0
  self.y = y or 0
  self.speed = speed or 80
  self.direction = direction or 0

  self.radius = 4

  self.image = Sprite:new("assets/bullet.png", 0.5, 0.0)
end

function Bullet:update(dt)
  local direction = Utils.degtorad(self.direction)
  local dx = math.cos(direction) * self.speed * dt
  local dy = math.sin(direction) * self.speed * dt

  self.x = self.x + dx
  self.y = self.y + dy
end

function Bullet:draw()
  self.image:draw(self.x, self.y)
end

function Bullet:isOut(bounds)
  local left = self.x - self.image.width
  local right = self.x + self.image.width
  local top = self.y - self.image.height
  local bottom = self.y + self.image.height

  return right < bounds.x or left > bounds.x + bounds.width or
         bottom < bounds.y or top > bounds.y + bounds.height
end