require "engine.class"
require "system"

SystemManager = Class()

function SystemManager:init()
  self.systems = {}
  self.connections = {}
  self.cursor = {
    x = 0,
    y = 0,
    closestSystem = nil
  }
  self.snapThreshold = 15
  self.lerpSpeed = 0.1
end

function SystemManager:generateMap(count, width, height, padding, minDistance)
  self.systems = System.generateSystems(count, width, height, padding, minDistance)
  self.connections = System.generateClusteredConnections(self.systems, 2, 40)
end

function SystemManager:updateCursor(targetX, targetY)
  -- find closest system and distance
  local closestSystem = nil
  local closestDist = math.huge
  
  for _, system in ipairs(self.systems) do
    local distToCursor = system:distanceTo({x = targetX, y = targetY})
    if distToCursor < closestDist then
      closestDist = distToCursor
      closestSystem = system
    end
  end

  -- if cursor is close, pull to system, otherwise to cursor
  if closestDist < self.snapThreshold then
    self.cursor.x = self.cursor.x + (closestSystem.x - self.cursor.x) * self.lerpSpeed
    self.cursor.y = self.cursor.y + (closestSystem.y - self.cursor.y) * self.lerpSpeed
  else
    self.cursor.x = self.cursor.x + (targetX - self.cursor.x) * self.lerpSpeed
    self.cursor.y = self.cursor.y + (targetY - self.cursor.y) * self.lerpSpeed
    closestSystem = nil
  end
  
  self.cursor.closestSystem = closestSystem
end

-- get closest system to cursor
function SystemManager:getClosestSystem()
  return self.cursor.closestSystem
end

-- get cursor position
function SystemManager:getCursorPosition()
  return self.cursor.x, self.cursor.y
end

-- get all systems
function SystemManager:getSystems()
  return self.systems
end

-- get all connections
function SystemManager:getConnections()
  return self.connections
end
