Menu = Class()

function Menu:init()
  self.background = Sprite:new("assets/background.png")
  self.frame = Sprite:new("assets/menu-frame.png")
  self.ship = Sprite:new("assets/player.png")
  self.shipPanel = Sprite:new("assets/menu-ship-frame.png")
  self.baseModule = SpriteSheet:new("assets/base-modules.png", 15, 15)

  -- 1 = MAP, 2 = SHIP
  self.tab = 1
end

function Menu:update(dt)
  if G.Controls:isActionPressed("nextTab") then
    if self.tab < 2 then
      self.tab = self.tab + 1
    end
  end

  if G.Controls:isActionPressed("prevTab") then
    if self.tab > 1 then
      self.tab = self.tab - 1
    end
  end
end

function Menu:draw()
  self.background:draw()
  self.frame:draw()

  local activeColor = {1, 1, 1, 1}
  local inactiveColor = {0.5, 0.5, 0.5, 1}

  if self.tab == 1 then
    love.graphics.setColor(activeColor)
    love.graphics.print("MAP", 6, 3)
    love.graphics.setColor(inactiveColor)
    love.graphics.print("SHIP", 25, 3)
  else
    love.graphics.setColor(inactiveColor)
    love.graphics.print("MAP", 6, 3)
    love.graphics.setColor(activeColor)
    love.graphics.print("SHIP", 25, 3)
  end

  love.graphics.setColor(1, 1, 1, 1) -- сброс цвета
  love.graphics.print("<Q   E>", 120, 3)

  -- можно тут же отрисовывать контент вкладок
  if self.tab == 1 then
    love.graphics.print("MISSION", 40, 40)
  elseif self.tab == 2 then
    -- love.graphics.print("SHIP", 40, 40)
    self.shipPanel:draw(2, 10)
    -- self.ship:draw(128, 74)

    for i = 1, 6 do
      for j = 1, 3 do
        local gap = 2
        local size = 15
        local x = (i - 1) * (size + gap)
        local y = (j - 1) * (size + gap)
        self.baseModule:draw(x + 6, y + 48)
      end
    end

    love.graphics.print("LVL-1 XP-0 | 5", 4, 104)
    love.graphics.print("", 4, 111)
  end
end

function Menu:keypressed(key)
  if key == "left" then
    self.tab = 1
  elseif key == "right" then
    self.tab = 2
  elseif key == "return" or key == "space" then
    if self.tab == 1 then
      local waves = {
        {
          positions = {
            { x = 30, y = 35 },
            { x = 80, y = 50 },
            { x = 130, y = 35 },
          }
        },
        {
          positions = {
            { x = 30, y = 35 },
            { x = 130, y = 35 },
          }
        },
        {
          positions = {
            { x = 80, y = 50 },
          }
        },
      }
      G.State:switch(Game, waves)
    elseif self.tab == 2 then
      print("TODO: Ship upgrades menu")
    end
  end
end
