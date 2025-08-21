require "lib.class"
require "lib.camera"
require "lib.sprite"
require "lib.sprite_sheet"
require "lib.anchor"
require "lib.controller"
require "lib.timer"

require "utils"
require "globals"
require "weapon"
require "player"
require "bullet"

WIDTH, HEIGHT = 160, 120

local camera = nil
local background = nil
local frame = nil
local player = nil

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
end

function love.draw()
  camera:push()

  background:draw()
  player:draw()
  frame:draw()

  camera:pop()
end

function love.update(dt)
  player:update(dt)
end

function love.keypressed(key)
  G.Controls:keyPressed(key)
end