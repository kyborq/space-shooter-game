Game = Class()

-- decorations
local background = nil
local frame = nil

-- objects
local player = nil
local enemies = nil

function Game:init()
  background = Sprite:new("assets/background.png")
  frame = Sprite:new("assets/frame.png")

  player = Player:new()
  enemies = Factory:new(Enemy, {
    { x = 30, y = 35 },
    { x = 80, y = 50 },
    { x = 130, y = 35 },
  })
end

function Game:update(dt)
  player:update(dt)
  enemies:update(dt)

  for i, bullet in pairs(player.bullets) do
    for _, enemy in pairs(enemies.objects) do
      if bullet:collidesWithEnemy(enemy) then
        local angle = Utils.degtorad(bullet.direction)
        local dx = math.cos(angle)
        local dy = math.sin(angle)

        enemy:hit(dx, dy, 2.0)
        table.remove(player.bullets, i)
        break
      end
    end
  end

  for i, enemy in pairs(enemies.objects) do
    if enemy.dead then
      table.remove(enemies.objects, i)
    end
  end
end

function Game:draw()
  background:draw()
  enemies:draw()
  player:draw()
  frame:draw()
end
