System = Class()

local function distance(a, b)
  return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

local function generateSystemName()
  local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local index = math.random(#letters)
  local letter = letters:sub(index, index)
  local number = math.random(0, 999)
  return string.format("%s-%03d", letter, number)
end

function System:init(x, y, name)
  self.x = x or 0
  self.y = y or 0
  self.name = name or generateSystemName()
  self.connections = {} -- соединения с другими системами (индексы)
  
  -- Настройки системы
  self.waves = {} -- массив волн врагов
  self.hasBoss = false -- есть ли босс-файт
  self.requiredXP = 0 -- требуемый опыт для доступа
  self.isCompleted = false -- пройдена ли система
  self.isAccessible = false -- доступна ли система для прыжка
  
  -- Генерируем случайные настройки для системы
  self:generateSystemConfig()
end

function System:addConnection(otherSystemIndex)
  table.insert(self.connections, otherSystemIndex)
end

function System:distanceTo(otherSystem)
  return distance(self, otherSystem)
end

function System:isFarEnough(systems, minDistance)
  for _, system in ipairs(systems) do
    if self:distanceTo(system) < minDistance then
      return false
    end
  end
  return true
end

-- Генерация конфигурации системы
function System:generateSystemConfig()
  -- Определяем уровень системы на основе позиции (чем дальше от начала, тем сложнее)
  local systemIndex = self:getSystemIndex()
  local difficulty = math.min(systemIndex / 10, 1.0) -- от 0 до 1
  
  -- Количество волн увеличивается с уровнем
  local waveCount = math.floor(2 + difficulty * 3) -- от 2 до 5 волн
  
  -- Генерируем уникальные волны для каждого уровня
  for i = 1, waveCount do
    local wave = self:generateWaveConfig(i, waveCount, difficulty)
    table.insert(self.waves, wave)
  end
  
  -- Босс появляется в системах с высоким уровнем
  self.hasBoss = difficulty > 0.6 and math.random() < (difficulty * 0.8)
  
  -- Требуемый опыт зависит от уровня системы
  self.requiredXP = math.floor(50 + systemIndex * 25 + difficulty * 100)
end

-- Получение индекса системы (нужно будет передавать из меню)
function System:getSystemIndex()
  return self.systemIndex or 1
end

-- Установка индекса системы
function System:setSystemIndex(index)
  self.systemIndex = index
end

-- Генерация конфигурации волны
function System:generateWaveConfig(waveNumber, totalWaves, difficulty)
  local waveTypes = {
    "scout",      -- разведчики - быстрые, слабые
    "fighter",    -- истребители - средние
    "bomber",     -- бомбардировщики - медленные, сильные
    "interceptor", -- перехватчики - агрессивные
    "swarm"       -- рой - много слабых
  }
  
  local waveType = waveTypes[math.min(waveNumber, #waveTypes)]
  
  local config = {
    waveType = waveType,
    waveNumber = waveNumber,
    difficulty = difficulty
  }
  
  if waveType == "scout" then
    config.enemyCount = math.floor(4 + difficulty * 6)
    config.enemySpeed = 0.6 + difficulty * 0.4
    config.enemyHealth = 1
    config.spawnDelay = 0.3 + difficulty * 0.2
    config.waveDelay = 1.5
    config.behavior = "zigzag"
    
  elseif waveType == "fighter" then
    config.enemyCount = math.floor(3 + difficulty * 4)
    config.enemySpeed = 0.4 + difficulty * 0.3
    config.enemyHealth = 2 + math.floor(difficulty * 2)
    config.spawnDelay = 0.5 + difficulty * 0.3
    config.waveDelay = 2.0
    config.behavior = "straight"
    
  elseif waveType == "bomber" then
    config.enemyCount = math.floor(2 + difficulty * 3)
    config.enemySpeed = 0.2 + difficulty * 0.2
    config.enemyHealth = 3 + math.floor(difficulty * 3)
    config.spawnDelay = 1.0 + difficulty * 0.5
    config.waveDelay = 2.5
    config.behavior = "circle"
    
  elseif waveType == "interceptor" then
    config.enemyCount = math.floor(3 + difficulty * 3)
    config.enemySpeed = 0.5 + difficulty * 0.4
    config.enemyHealth = 2 + math.floor(difficulty * 2)
    config.spawnDelay = 0.4 + difficulty * 0.2
    config.waveDelay = 1.8
    config.behavior = "aggressive"
    
  elseif waveType == "swarm" then
    config.enemyCount = math.floor(6 + difficulty * 8)
    config.enemySpeed = 0.3 + difficulty * 0.3
    config.enemyHealth = 1
    config.spawnDelay = 0.2 + difficulty * 0.1
    config.waveDelay = 1.0
    config.behavior = "straight"
  end
  
  return config
end

-- Проверка доступности системы
function System:checkAccessibility(playerXP)
  self.isAccessible = playerXP >= self.requiredXP
  return self.isAccessible
end

-- Отметить систему как пройденную
function System:markCompleted()
  self.isCompleted = true
end

-- Получить информацию о системе
function System:getInfo()
  return {
    name = self.name,
    waveCount = #self.waves,
    hasBoss = self.hasBoss,
    requiredXP = self.requiredXP,
    isCompleted = self.isCompleted,
    isAccessible = self.isAccessible
  }
end

function System.generateSystems(count, width, height, padding, minDistance)
  local systems = {}
  minDistance = minDistance or 20

  local attempts, max_attempts = 0, 1000
  while #systems < count and attempts < max_attempts do
    local x = math.random(padding, width - padding)
    local y = math.random(padding, height - padding)
    
    local newSystem = System:new(x, y)
    if newSystem:isFarEnough(systems, minDistance) then
      -- Устанавливаем индекс системы для правильной генерации конфигурации
      newSystem:setSystemIndex(#systems + 1)
      table.insert(systems, newSystem)
    end
    attempts = attempts + 1
  end
  
  return systems
end

function System.generateClusteredConnections(systems, extra_connections, max_distance)
  local n = #systems
  local inTree = {}
  local edgeList = {}
  local connections = {}

  inTree[1] = true

  for j = 2, n do
    table.insert(edgeList, {
      from = 1, 
      to = j, 
      dist = systems[1]:distanceTo(systems[j])
    })
  end

  local function removeEdge(idx)
    edgeList[idx] = edgeList[#edgeList]
    edgeList[#edgeList] = nil
  end

  for _ = 1, n - 1 do
    local minDist = math.huge
    local minIdx = nil
    local minFrom, minTo

    for i, e in ipairs(edgeList) do
      if inTree[e.from] ~= inTree[e.to] then
        if e.dist and e.dist < minDist then
          minDist = e.dist
          minIdx = i
          minFrom = e.from
          minTo = e.to
        end
      end
    end

    if not minIdx then
      break
    end

    local key = minFrom < minTo and (minFrom .. "-" .. minTo) or (minTo .. "-" .. minFrom)
    connections[key] = {start = minFrom, endd = minTo}

    local newNode = inTree[minFrom] and minTo or minFrom
    inTree[newNode] = true

    for j = 1, n do
      if not inTree[j] and j ~= newNode then
        table.insert(edgeList, {
          from = newNode, 
          to = j, 
          dist = systems[newNode]:distanceTo(systems[j])
        })
      end
    end

    removeEdge(minIdx)
  end

  for i, system in ipairs(systems) do
    local dists = {}
    for j, other in ipairs(systems) do
      if i ~= j then
        local key = i < j and (i .. "-" .. j) or (j .. "-" .. i)
        if not connections[key] then
          local distVal = system:distanceTo(other)
          if distVal <= max_distance then
            table.insert(dists, {idx = j, dist = distVal})
          end
        end
      end
    end

    table.sort(dists, function(a, b) return a.dist < b.dist end)

    for k = 1, math.min(extra_connections or 1, #dists) do
      local other_idx = dists[k].idx
      local key = i < other_idx and (i .. "-" .. other_idx) or (other_idx .. "-" .. i)
      if not connections[key] then
        connections[key] = {start = i, endd = other_idx}
      end
    end
  end

  local conns = {}
  for _, conn in pairs(connections) do
    table.insert(conns, conn)
  end
  return conns
end

function System.generateConnections(systems, max_connections)
  local connections = {}

  for i, system in ipairs(systems) do
    local dists = {}
    for j, other in ipairs(systems) do
      if i ~= j then
        table.insert(dists, {idx = j, dist = system:distanceTo(other)})
      end
    end

    table.sort(dists, function(a, b) return a.dist < b.dist end)

    for k = 1, math.min(max_connections, #dists) do
      local other_idx = dists[k].idx
      local key = i < other_idx and i .. '-' .. other_idx or other_idx .. '-' .. i
      if not connections[key] then
        connections[key] = {start = i, endd = other_idx}
      end
    end
  end

  local conns = {}
  for _, conn in pairs(connections) do
    table.insert(conns, conn)
  end
  return conns
end
