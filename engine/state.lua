State = Class()

function State:init()
  self.current = nil
end

function State:switch(newState)
  self.current = newState
end

function State:update(dt)
  if self.current and self.current.update then
    self.current:update(dt)
  end
end

function State:draw()
  if self.current and self.current.draw then
    self.current:draw()
  end
end

function State:keypressed(key)
  if self.current and self.current.keypressed then
    self.current:keypressed(key)
  end
end
