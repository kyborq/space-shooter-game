Weapon = Class()

function Weapon:init(cooldown)
  -- params
  self.cooldown = cooldown or 0.25

  -- misc
  self.timer = Timer:new(self.cooldown)
end

function Weapon:update(dt)
  self.timer:update(dt)
end

function Weapon:tryFire()
  if self.timer:isReady() then
    self.timer:reset(self.cooldown)
    return true
  end
  return false
end