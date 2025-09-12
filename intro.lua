Intro = Class()

function Intro:init()
  self.timer = 0
end

function Intro:update(dt)
  self.timer = self.timer + dt
  if self.timer > 2 then
    G.State:switch(Menu:new())
  end
end

function Intro:draw()
  love.graphics.print("MY GAME STUDIO", 50, 50)
end

function Intro:keypressed(key)
  G.State:switch(Menu:new())
end
