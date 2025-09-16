Sprite = Class()

function Sprite:init(asset, originX, originY)
  self.originX = originX or 0
  self.originY = originY or self.originX
  self.image = love.graphics.newImage(asset)
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Sprite:draw(x, y)
  local offsetX = self.originX * self.width
  local offsetY = self.originY * self.height

  love.graphics.draw(
    self.image,
    x or 0,
    y or 0,
    0,
    1, 1,
    offsetX,
    offsetY
  )
end

function Sprite:getBounds(x, y)
  local offsetX = self.originX * self.width
  local offsetY = self.originY * self.height

  local left = x - offsetX
  local top = y - offsetY
  local right = self.width
  local bottom = self.height

  return left, top, right, bottom
end