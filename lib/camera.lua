Camera = Class()

function Camera:init(width, height)
  self.width = width
  self.height = height
end

function Camera:push()
  love.graphics.push()

  local scale, offsetX, offsetY = self:getScaleAndOffset()

  love.graphics.translate(offsetX, offsetY)
  love.graphics.scale(scale, scale)
  love.graphics.setScissor(offsetX, offsetY, self.width * scale, self.height * scale)
end

function Camera:pop()
  love.graphics.setScissor()
  love.graphics.pop()
end

function Camera:getScaleAndOffset()
  local actualWidth, actualHeight = love.graphics.getDimensions()
  local scaleX, scaleY = actualWidth / self.width, actualHeight / self.height
  local scale = math.min(scaleX, scaleY)
  local offsetX = (actualWidth - self.width * scale) / 2
  local offsetY = (actualHeight - self.height * scale) / 2
  return scale, offsetX, offsetY
end

function Camera:getScale()
  local actualWidth, actualHeight = love.graphics.getDimensions()
  local scaleX, scaleY = actualWidth / self.width, actualHeight / self.height
  local scale = math.min(scaleX, scaleY)
  return scale
end

function Camera:getDimensions()
  return self.width, self.height
end

function Camera:getCursor()
  local scale, offsetX, offsetY = self:getScaleAndOffset()
  local mouseX, mouseY = love.mouse.getPosition()
  local virtualX = (mouseX - offsetX) / scale
  local virtualY = (mouseY - offsetY) / scale
  return virtualX, virtualY
end