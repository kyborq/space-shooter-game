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
require "wave"

WIDTH, HEIGHT = 160, 120

-- states
local game = nil

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  G.Camera = Camera:new(WIDTH, HEIGHT)
  G.Controls = Controller:new({
    up = "w",
    down = "s",
    left = "a",
    right = "d",
    fire = "space",
  })

  game = Game:new()
end

function love.draw()
  G.Camera:push()
  game:draw()
  G.Camera:pop()
end

function love.update(dt)
  game:update(dt)
end

function love.keypressed(key)
  G.Controls:keyPressed(key)
end