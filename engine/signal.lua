Signal = Class()

function Signal:init()
  self.signals = {}
end

function Signal:connect(name, callback)
  if not self.signals[name] then
    self.signals[name] = {}
  end
  table.insert(self.signals[name], callback)
end

function Signal:disconnect(name, callback)
  if self.signals[name] then
    for i, cb in ipairs(self.signals[name]) do
      if cb == callback then
        table.remove(self.signals[name], i)
        break
      end
    end
  end
end

function Signal:emit(name, ...)
  if self.signals[name] then
    for _, callback in ipairs(self.signals[name]) do
      callback(...)
    end
  end
end