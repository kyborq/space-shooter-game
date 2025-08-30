Factory = Class()

function Factory:init(object, positions)
  self.object = object
  self.positions = positions

  -- misc
  self.objects = {}

  for _, position in pairs(self.positions) do
    local instance = self.object:new(position.x, position.y)
    table.insert(self.objects, instance)
  end
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