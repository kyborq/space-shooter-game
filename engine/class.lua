function Class(base)
  local c = {}

  if base then
    setmetatable(c, { __index = base })
    c._base = base
  end

  c.__index = c
  
  function c:new(...)
    local instance = setmetatable({}, c)

    if instance.init then
      instance:init(...)
    end
    
    return instance
  end

  return c
end
