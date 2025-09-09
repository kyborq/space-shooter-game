Game = Class()

function Game:init()
  self.player = Player:new()
  self.enemies = Factory:new(Enemy, {
    { x = 30, y = 25 },
    { x = 80, y = 50 },
    { x = 130, y = 25 },
  })
  self.bullets = {}
end

function Game:update(dt)
  self.player:update(dt)

  self.enemies:update(dt)

  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    bullet:update(dt)
    if bullet:isOffScreen() then
      table.remove(self.bullets, i)
    end
  end
end

function Game:draw()
  self.enemies:draw()
  self.player:draw()
  for _, bullet in pairs(self.bullets) do
    bullet:draw()
  end
end
