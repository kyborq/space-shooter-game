Factory = Class()

function Factory:init(object, positions)
  self.object = object

  -- misc
  self.objects = {}

  if positions then
    self:create(positions)
  end
end

function Factory:create(positions)
  for _, position in pairs(positions) do
    local instance = self.object:new(position.x, position.y)
    table.insert(self.objects, instance)
  end
end

function Factory:createSingle(x, y, params)
  local instance = self.object:new(x, y, params)
  table.insert(self.objects, instance)
  return instance
end

function Factory:update(dt)
  for _, object in pairs(self.objects) do
    object:update(dt)
  end
end

function Factory:draw()
  for _, object in pairs(self.objects) do
    object:draw()
  end
end