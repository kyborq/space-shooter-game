Menu = Class()

function Menu:init()
  self.shipCursor = Cursor:new()
  
  self.background = Sprite:new("assets/background.png")
  self.frame = Sprite:new("assets/menu-frame.png")
  self.ship = Sprite:new("assets/player.png")
  self.shipPanel = Sprite:new("assets/menu-ship-frame.png")
  self.baseModule = SpriteSheet:new("assets/base-modules.png", 15, 15)
  self.selectedHighlight = Sprite:new("assets/selected-highlight.png")
  self.systemSprite = Sprite:new("assets/system.png", 0.5)
  
  -- Генерируем 10 игровых систем (уровней) для карты
  self.gameSystems = System.generateSystems(10, 160, 120, 20, 20)
  self.systemConnections = System.generateClusteredConnections(self.gameSystems, 1, 35)
  
  -- Позиция корабля (индекс текущей системы)
  self.shipPosition = 1 -- начинаем с первой системы
  self.selectedSystem = nil -- выбранная система для прыжка
  
  -- Курсор для карты (аналогично курсору корабля)
  self.mapCursor = Cursor:new()
  self.selectedSystemIndex = 1 -- индекс выбранной системы
  
  -- Инициализируем доступность систем
  self:updateSystemAccessibility()
  
  -- Строим граф соединений
  self:buildSystemGraph()
  
  -- Инициализируем выбранную систему
  self:updateMapCursorPosition()
  self.selectedSystem = self.gameSystems[self.selectedSystemIndex]

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

  self:updateCursorPosition()
end

-- Построение графа соединений между системами
function Menu:buildSystemGraph()
  -- Очищаем все соединения
  for _, system in ipairs(self.gameSystems) do
    system.connections = {}
  end
  
  -- Добавляем соединения на основе systemConnections
  for _, conn in ipairs(self.systemConnections) do
    local systemA = self.gameSystems[conn.start]
    local systemB = self.gameSystems[conn.endd]
    
    if systemA and systemB then
      systemA:addConnection(conn.endd)
      systemB:addConnection(conn.start)
    end
  end
end

-- Обновление позиции курсора карты
function Menu:updateMapCursorPosition()
  if self.gameSystems[self.selectedSystemIndex] then
    local system = self.gameSystems[self.selectedSystemIndex]
    self.mapCursor:setPosition(system.x - 11, system.y - 11)
  end
end

-- Обновление доступности систем на основе опыта игрока
function Menu:updateSystemAccessibility()
  local playerXP = G.Player and G.Player.xp or 0
  
  for _, system in ipairs(self.gameSystems) do
    system:checkAccessibility(playerXP)
  end
  
  -- Первая система всегда доступна
  if #self.gameSystems > 0 then
    self.gameSystems[1].isAccessible = true
  end
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
  -- Обновляем доступность систем
  self:updateSystemAccessibility()
  
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
  self.mapCursor:update(dt)
  
  -- Обработка взаимодействия с системами на вкладке MAP
  if self.tab == 1 then
    -- Навигация по графу соединений в конкретных направлениях
    if G.Controls:isActionJustPressed("right") then
      self:navigateInDirection(1, 0) -- вправо
    end

    if G.Controls:isActionJustPressed("left") then
      self:navigateInDirection(-1, 0) -- влево
    end

    if G.Controls:isActionJustPressed("down") then
      self:navigateInDirection(0, 1) -- вниз
    end

    if G.Controls:isActionJustPressed("up") then
      self:navigateInDirection(0, -1) -- вверх
    end
    
    if G.Controls:isActionJustPressed("select") then
      self:handleSystemSelection()
    end
  end
end


-- Навигация в конкретном направлении
function Menu:navigateInDirection(dirX, dirY)
  local currentSystem = self.gameSystems[self.selectedSystemIndex]
  if not currentSystem or #currentSystem.connections == 0 then return end
  
  local bestIndex = nil
  local bestDistance = math.huge
  
  for _, connectedIndex in ipairs(currentSystem.connections) do
    local connectedSystem = self.gameSystems[connectedIndex]
    if connectedSystem then
      local dx = connectedSystem.x - currentSystem.x
      local dy = connectedSystem.y - currentSystem.y
      
      -- Проверяем, что система в нужном направлении
      local inDirection = false
      
      if dirX > 0 then -- вправо
        inDirection = dx > 0
      elseif dirX < 0 then -- влево
        inDirection = dx < 0
      elseif dirY > 0 then -- вниз
        inDirection = dy > 0
      elseif dirY < 0 then -- вверх
        inDirection = dy < 0
      end
      
      if inDirection then
        -- Вычисляем расстояние для выбора ближайшей
        local distance = math.sqrt(dx*dx + dy*dy)
        if distance < bestDistance then
          bestDistance = distance
          bestIndex = connectedIndex
        end
      end
    end
  end
  
  if bestIndex then
    self.selectedSystemIndex = bestIndex
    self.selectedSystem = self.gameSystems[self.selectedSystemIndex]
    self:updateMapCursorPosition()
  end
end

-- Обработка выбора системы
function Menu:handleSystemSelection()
  -- Здесь можно добавить логику выбора системы
  -- Например, переход к игре с выбранной системой
  if self.selectedSystem and self.selectedSystem.isAccessible then
    print("Starting mission in system: " .. self.selectedSystem.name)
    -- TODO: Переход к игре с настройками выбранной системы
  end
end

-- Выбор системы по координатам (для будущего использования с мышью)
function Menu:selectSystemAt(x, y)
  for i, system in ipairs(self.gameSystems) do
    local distance = math.sqrt((x - system.x)^2 + (y - system.y)^2)
    if distance < 10 then -- радиус выбора
      self.selectedSystem = system
      return system
    end
  end
  return nil
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
    
    -- Показываем название выбранной системы
    if self.selectedSystem then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(self.selectedSystem.name, 50, 3)
    end
  else
    love.graphics.setColor(inactiveColor)
    love.graphics.print("MAP", 6, 3)
    love.graphics.setColor(activeColor)
    love.graphics.print("SHIP", 25, 3)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("<Q   E>", 120, 3)

  if self.tab == 1 then
    -- Рисуем соединения между системами
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    for _, conn in ipairs(self.systemConnections) do
      local a = self.gameSystems[conn.start]
      local b = self.gameSystems[conn.endd]
      love.graphics.line(a.x, a.y, b.x, b.y)
    end
    
    -- Рисуем системы в их оригинальных позициях
    love.graphics.setColor(1, 1, 1, 1)
    for i, system in ipairs(self.gameSystems) do
      -- Рисуем систему как спрайт
      self.systemSprite:draw(system.x - 3, system.y - 3)
      
      -- Рисуем номер системы
      love.graphics.print(tostring(i), system.x + 6, system.y - 8)
    end
    
    -- Рисуем курсор карты
    self.mapCursor:draw()
    
    -- Рисуем информацию об игроке
    if G.Player then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("Level: " .. G.Player:getLevel(), 5, 100)
      love.graphics.print("XP: " .. G.Player:getXP(), 5, 108)
    end
    
    -- Рисуем информацию о выбранной системе
    if self.selectedSystem then
      local info = self.selectedSystem:getInfo()
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("System " .. self.selectedSystemIndex .. "/" .. #self.gameSystems, 5, 116)
      love.graphics.print("Name: " .. info.name, 5, 124)
      love.graphics.print("Connections: " .. #self.selectedSystem.connections, 5, 132)
      
      -- Показываем доступные направления
      if #self.selectedSystem.connections > 0 then
        local connectedNames = {}
        for _, connIndex in ipairs(self.selectedSystem.connections) do
          table.insert(connectedNames, self.gameSystems[connIndex].name)
        end
        love.graphics.print("Connected to: " .. table.concat(connectedNames, ", "), 5, 140)
      else
        love.graphics.print("No connections", 5, 140)
      end
      
      love.graphics.print("Waves: " .. info.waveCount, 5, 148)
      love.graphics.print("Boss: " .. (info.hasBoss and "Yes" or "No"), 5, 156)
      love.graphics.print("Required XP: " .. info.requiredXP, 5, 164)
      love.graphics.print("Status: " .. (info.isCompleted and "Completed" or (info.isAccessible and "Accessible" or "Locked")), 5, 172)
    else
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("No system selected", 5, 116)
    end

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
          love.graphics.setColor(1, 1, 1, 1)
          if self.equipped[i] == module then
            self.selectedHighlight:draw(x + 7, y + 49)
          end
          
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
