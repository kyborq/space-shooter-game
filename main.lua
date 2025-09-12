require "lib.class"
require "lib.camera"
require "lib.sprite"
require "lib.sprite_sheet"
require "lib.anchor"
require "lib.controller"
require "lib.timer"
require "lib.factory"
require "lib.signal"
require "lib.state"

require "utils"
require "globals"
require "weapon"
require "player"
require "bullet"
require "enemy"
require "game"
require "wave"
require "intro"
require "menu"

WIDTH, HEIGHT = 160, 120

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  local font = love.graphics.newImageFont("assets/font.png", G.Chars)
  love.graphics.setFont(font)

  G.Camera = Camera:new(WIDTH, HEIGHT)
  G.Controls = Controller:new({
    up = "w",
    down = "s",
    left = "a",
    right = "d",
    fire = "space",
    nextTab = "e",
    prevTab = "q",
  })
  G.Signals = Signal:new()
  G.State = State:new()

  -- стартуем с интро
  G.State:switch(Menu:new())
end

function love.draw()
  G.Camera:push()
  G.State:draw()
  G.Camera:pop()
end

function love.update(dt)
  G.State:update(dt)
end

function love.keypressed(key)
  G.Controls:keyPressed(key)
  G.State:keypressed(key)
end