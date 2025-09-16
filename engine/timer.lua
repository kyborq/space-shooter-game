Timer = Class()

function Timer:init(delay, loop)
  self.delay = delay or 1
  self.timeLeft = self.delay
  self.loop = loop or false
  self.triggered = false
  self.finished = false
end

function Timer:update(dt)
  if self.finished then
    return
  end

  self.timeLeft = self.timeLeft - dt

  if self.timeLeft <= 0 then
    self.triggered = true

    if self.loop then
      self.timeLeft = self.delay + self.timeLeft
    else
      self.finished = true
    end
  else
    self.triggered = false
  end
end

function Timer:reset(newDelay)
  if newDelay then
    self.delay = newDelay
  end
  self.timeLeft = self.delay
  self.triggered = false
  self.finished = false
end

function Timer:isReady()
  return self.triggered
end

function Timer:getTime()
  return self.timeLeft
end

function Timer:getProgress()
  local progress = 1 - (self.timeLeft / self.delay)
  return math.min(math.max(progress, 0), 1)
end

function Timer:isFinished()
  return self.finished
end