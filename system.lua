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
  -- Количество волн (от 2 до 4)
  local waveCount = math.random(2, 4)
  
  -- Генерируем волны
  for i = 1, waveCount do
    local wave = {
      enemyCount = math.random(3, 8), -- количество врагов в волне
      enemySpeed = math.random(0.3, 0.8), -- скорость врагов
      enemyHealth = math.random(1, 3), -- здоровье врагов
      spawnDelay = math.random(0.5, 1.5), -- задержка между появлениями врагов
      waveDelay = math.random(1, 3) -- задержка между волнами
    }
    table.insert(self.waves, wave)
  end
  
  -- Случайно определяем, есть ли босс (30% шанс)
  self.hasBoss = math.random() < 0.3
  
  -- Требуемый опыт зависит от сложности системы
  local baseXP = waveCount * 50
  if self.hasBoss then
    baseXP = baseXP + 100
  end
  self.requiredXP = baseXP + math.random(0, 50)
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
