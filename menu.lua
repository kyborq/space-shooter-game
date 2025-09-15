Menu = Class()

function Menu:init()
  self.shipCursor = Cursor:new()
  
  self.background = Sprite:new("assets/background.png")
  self.frame = Sprite:new("assets/menu-frame.png")
  self.ship = Sprite:new("assets/player.png")
  self.shipPanel = Sprite:new("assets/menu-ship-frame.png")
  self.baseModule = SpriteSheet:new("assets/base-modules.png", 15, 15)

  -- 1 = MAP, 2 = SHIP
  self.tab = 1

  self.columns = {"firepower","speed","energy","defense","xp","gameplay"}

  self.grid = {}
  for i, colName in ipairs(self.columns) do
    self.grid[i] = {}
    print(colName)
    for j, mod in ipairs(Modules[colName]) do
      self.grid[i][j] = mod
    end
  end

  -- equipped grid
  self.equipped = {}
  for i = 1, 6 do
    self.equipped[i] = nil
  end

  -- menu ship upgrade tab cursor
  self.cursorCol = 1
  self.cursorRow = 1
  self.cursorOnEquipped = false
end

function Menu:updateCursorPosition()
  local gap, size = 2, 15

  if self.cursorOnEquipped then
    local x = (self.cursorCol - 1) * (size + gap) + 6
    local y = 14
    self.shipCursor:setPosition(x - 0.5, y - 0.5)
  else
    local x = (self.cursorCol - 1) * (size + gap) + 6
    local y = (self.cursorRow - 1) * (size + gap) + 48
    self.shipCursor:setPosition(x - 0.5, y - 0.5)
  end
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

  if self.tab == 2 then
    if G.Controls:isActionJustPressed("right") then
      self.cursorCol = math.min(self.cursorCol + 1, #self.columns)
      self:updateCursorPosition()
    end

    if G.Controls:isActionJustPressed("left") then
      self.cursorCol = math.max(self.cursorCol - 1, 1)
      self:updateCursorPosition()
    end

    if G.Controls:isActionJustPressed("up") then
      if not self.cursorOnEquipped then
        if self.cursorRow > 1 then
          self.cursorRow = self.cursorRow - 1
        else
          self.cursorOnEquipped = true
        end
      end
      self:updateCursorPosition()
    end

    if G.Controls:isActionJustPressed("down") then
      if self.cursorOnEquipped then
        self.cursorOnEquipped = false
        self.cursorRow = 1
      else
        self.cursorRow = math.min(self.cursorRow + 1, #self.grid[self.cursorCol])
      end
      self:updateCursorPosition()
    end

    if G.Controls:isActionJustPressed("select") then
      if not self.cursorOnEquipped then
        local module = self.grid[self.cursorCol][self.cursorRow]
        if module and module.unlocked then
          self.equipped[self.cursorCol] = module
        end
      else
        self.equipped[self.cursorCol] = nil
      end
    end
  end

  self.shipCursor:update(dt)
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

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("<Q   E>", 120, 3)

  if self.tab == 1 then
    love.graphics.print("MISSION", 40, 40)
  elseif self.tab == 2 then
    self.shipPanel:draw(2, 10)

    -- draw equipped row grid
    for i = 1, 6 do
      local gap, size = 2, 15
      local x = (i - 1) * (size + gap)
      local y = 14
      local module = self.equipped[i]
      if module then
        local color = {1,1,1,1}
        if i == 1 then color = {1,0.2,0.2,1}
        elseif i == 2 then color = {0.3,0.5,1,1}
        elseif i == 3 then color = {0.2,1,0.4,1}
        elseif i == 4 then color = {1,1,0.3,1}
        elseif i == 5 then color = {0.7,0.3,1,1} end
        love.graphics.setColor(color)
        self.baseModule:draw(x+6, y, module.type + 1)
      end
    end
    
    -- draw modules grid
    for i = 1, 6 do
      for j = 1, 3 do
        local gap, size = 2, 15
        local x = (i - 1) * (size + gap)
        local y = (j - 1) * (size + gap)

        local module = self.grid[i][j]
        if module then
          if module.unlocked then
            local color = {1,1,1,1}
            if i == 1 then color = {1,0.2,0.2,1}
            elseif i == 2 then color = {0.3,0.5,1,1}
            elseif i == 3 then color = {0.2,1,0.4,1}
            elseif i == 4 then color = {1,1,0.3,1}
            elseif i == 5 then color = {0.7,0.3,1,1} end
            love.graphics.setColor(color)
          else
            love.graphics.setColor(0.3,0.3,0.3,0.6)
          end
          self.baseModule:draw(x+6, y+48, module.type + 1)
        end
      end
    end
    love.graphics.setColor(1,1,1,1)

    local selectedModule
    if self.cursorOnEquipped then
      selectedModule = self.equipped[self.cursorCol]
    else
      selectedModule = self.grid[self.cursorCol][self.cursorRow]
    end

    if selectedModule and selectedModule.unlocked then
      love.graphics.print(selectedModule.name, 4, 104)
      local unlockedText = selectedModule.desc
      love.graphics.print(unlockedText, 4, 111)
    end

    self.shipCursor:draw()
  end
end

function Menu:keypressed(key)
  -- if key == "left" then
  --   self.tab = 1
  -- elseif key == "right" then
  --   self.tab = 2
  -- elseif key == "return" or key == "space" then
  --     local waves = {
  --       {
  --         positions = {
  --           { x = 30, y = 35 },
  --           { x = 80, y = 50 },
  --           { x = 130, y = 35 },
  --         }
  --       },
  --       {
  --         positions = {
  --           { x = 30, y = 35 },
  --           { x = 130, y = 35 },
  --         }
  --       },
  --       {
  --         positions = {
  --           { x = 80, y = 50 },
  --         }
  --       },
  --     }
  --     G.State:switch(Game:new(waves))
  -- end
end
