require "lib.class"
require "lib.camera"
require "lib.sprite"
require "lib.sprite_sheet"
require "lib.anchor"
require "lib.controller"
require "lib.timer"
require "lib.factory"

require "utils"
require "globals"
require "weapon"
require "player"
require "bullet"
require "enemy"
require "game"

WIDTH, HEIGHT = 160, 120

local camera = nil
local background = nil
local frame = nil
local player = nil

-- factories
local enemies = nil

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  camera = Camera:new(WIDTH, HEIGHT)
  background = Sprite:new("assets/background.png")
  frame = Sprite:new("assets/frame.png")
  G.Controls = Controller:new({
    up = "w",
    down = "s",
    left = "a",
    right = "d",
    fire = "space",
  })

  player = Player:new()

  enemies = Factory:new(Enemy, {
    { x = 30, y = 35 },
    { x = 80, y = 50 },
    { x = 130, y = 35 },
  })
end

function love.draw()
  camera:push()

  background:draw()
  enemies:draw()
  player:draw()
  frame:draw()

  camera:pop()
end

function love.update(dt)
  player:update(dt)
  enemies:update(dt)

  for i, bullet in pairs(player.bullets) do
    for _, enemy in pairs(enemies.objects) do
      if bullet:collidesWithEnemy(enemy) then
        enemy:hit()
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

function love.keypressed(key)
  G.Controls:keyPressed(key)
end