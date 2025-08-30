Enemy = Class()

function Enemy:init(x, y)
  self.x = x
  self.y = y

  -- misc
  self.sprite = Sprite:new("assets/enemy.png", 0.5)
end

function Enemy:draw()
  self.sprite:draw(self.x, self.y)
end

function Enemy:update(dt)
end