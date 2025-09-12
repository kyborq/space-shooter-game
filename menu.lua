Menu = Class()

function Menu:init()
  self.selection = 1 -- 1 = играть, 2 = апгрейды
end

function Menu:update(dt)
end

function Menu:draw()
  love.graphics.print("== MENU ==", 60, 30)

  local options = { "START", "UPGRADES" }
  for i, opt in ipairs(options) do
    local prefix = (i == self.selection) and "> " or "  "
    love.graphics.print(prefix .. opt, 50, 50 + i * 10)
  end
end

function Menu:keypressed(key)
  if key == "up" then
    self.selection = math.max(1, self.selection - 1)
  elseif key == "down" then
    self.selection = math.min(2, self.selection + 1)
  elseif key == "return" or key == "space" then
    if self.selection == 1 then
      -- запуск игры с параметрами волн
      local waves = {
        {
          positions = {
            { x = 30, y = 35 },
            { x = 80, y = 50 },
            { x = 130, y = 35 },
          }
        },
        {
          positions = {
            { x = 30, y = 35 },
            { x = 130, y = 35 },
          }
        },
        {
          positions = {
            { x = 80, y = 50 },
          }
        },
      }
      local game = Game:new(waves)
      G.State:switch(game)
    elseif self.selection == 2 then
      -- пока пусто
      -- print("Upgrades menu TODO")
    end
  end
end
