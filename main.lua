require "lib.class"
require "lib.camera"
require "lib.sprite"
require "lib.sprite_sheet"
require "lib.anchor"
require "lib.controller"

require "globals"
require "player"

WIDTH, HEIGHT = 160, 120

local camera = nil
local background = nil
local player = nil

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  camera = Camera:new(WIDTH, HEIGHT)
  background = Sprite:new("assets/background.png")
  G.Controls = Controller:new({
    up = "w",
    down = "s",
    left = "a",
    right = "d",
  })

  player = Player:new()
end

function love.draw()
  camera:push()

  background:draw(0, 0)
  player:draw()

  camera:pop()
end

function love.update(dt)
  player:update(dt)
end

function love.keypressed(key)
  G.Controls:keyPressed(key)
end