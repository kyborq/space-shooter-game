Anchor = Class()

function Anchor:init(horizontal, vertical, width, height)
  self.horizontal = horizontal or "start" -- start middle end
  self.vertical = vertical or "start" -- start middle end

  self.x = 0
  self.y = 0
  self.width = width or love.graphics.getWidth()
  self.heigth = height or love.graphics.getHeight()
end

function Anchor:setSize(width, height)
  self.width = width or love.graphics.getWidth()
  self.heigth = height or love.graphics.getHeight()
end

function Anchor:update()
  if self.horizontal == "start" then
    self.x = 0
  elseif self.horizontal == "middle" then
    self.x = self.width / 2
  elseif self.horizontal == "end" then
    self.x = self.width
  end

  if self.vertical == "start" then
    self.y = 0
  elseif self.vertical == "middle" then
    self.y = self.heigth / 2
  elseif self.vertical == "end" then
    self.y = self.heigth
  end
end

function Anchor:getPosition(offsetX, offsetY)
  return self.x + offsetX, self.y + offsetY
end