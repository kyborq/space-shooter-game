Cursor = Class()

function Cursor:init()
  self.x = 0
  self.y = 0

  self.targetX = 0
  self.targetY = 0

  self.sprite = Sprite:new("assets/cursor.png", 0.5)
end

function Cursor:setPosition(x, y)
  self.targetX = x
  self.targetY = y
end

function Cursor:update(dt)
  local speed = 10  -- увеличь, чтобы курсор двигался быстрее
  local t = math.min(dt * speed, 1)  -- чтобы t не превышало 1
  self.x = Utils.lerp(self.x, self.targetX, t)
  self.y = Utils.lerp(self.y, self.targetY, t)
end

function Cursor:draw()
  self.sprite:draw(self.x, self.y)
end
