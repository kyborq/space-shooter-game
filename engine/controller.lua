Controller = Class()

function Controller:init(actions)
  self.actions = actions or {}
  self.pressed = {}
  self.justPressed = {}
end

function Controller:isActionPressed(action)
  local keys = self.actions[action]
  if not keys then return false end

  if type(keys) == "string" then
    return love.keyboard.isDown(keys)
  elseif type(keys) == "table" then
    for _, key in ipairs(keys) do
      if love.keyboard.isDown(key) then
        return true
      end
    end
  end

  return false
end

function Controller:isActionJustPressed(action)
  local keys = self.actions[action]
  if not keys then return false end

  local function checkKey(key)
    if self.justPressed[key] then
      self.justPressed[key] = false
      return true
    end
    return false
  end

  if type(keys) == "string" then
    return checkKey(keys)
  elseif type(keys) == "table" then
    for _, key in ipairs(keys) do
      if checkKey(key) then
        return true
      end
    end
  end

  return false
end

function Controller:keyPressed(key)
  self.pressed[key] = true
  self.justPressed[key] = true
end

function Controller:reset()
  self.pressed = {}
  self.justPressed = {}
end

return Controller
