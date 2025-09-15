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

require "modules"
require "utils"
require "globals"
require "weapon"
require "player"
require "bullet"
require "enemy"
require "game"
require "wave"
require "intro"
require "cursor"
require "menu"

WIDTH, HEIGHT = 160, 120

local vhsShader

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
    select = "f"
  })
  G.Signals = Signal:new()
  G.State = State:new()

  -- стартуем с интро
  G.State:switch(Intro:new())

    vhsShader = love.graphics.newShader([[
        extern number time;
        extern number scale;
        extern vec2 screenSize;
        extern number noiseIntensity;
        extern number bulgeStrength; // сила эффекта рыбий глаз

        vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
            // -------------------------
            // Bulge / рыбий глаз
            vec2 center = screenSize * 0.5;                  // центр экрана
            vec2 uv = tex_coords * screenSize - center;                // координаты относительно центра
            float dist = length(uv) / length(center);       // нормализованное расстояние от центра
            float factor = 1.0 + bulgeStrength * dist * dist; // чем дальше от центра, тем сильнее смещение
            uv /= factor;                                    // смещаем координаты
            vec2 bulgedCoords = (uv + center) / screenSize;  // нормализуем обратно в [0,1]

            vec4 c = Texel(texture, bulgedCoords);

            // -------------------------
            // Четкие горизонтальные полосы
            float lineHeight = 2.0 * scale;
            float yPos = mod(screen_coords.y, lineHeight);
            if (yPos < 1.0 * scale) {
                c.rgb *= 0.8;  // затемнение полосы
            }

            // -------------------------
            // Пиксельный шум
            vec2 pixelCoord = floor(tex_coords * screenSize);
            float noise = fract(sin(dot(pixelCoord + time*10.0, vec2(12.9898,78.233))) * 43758.5453);
            c.rgb += (noise - 0.5) * noiseIntensity;

            return c * color;
        }
    ]])

end

function love.draw()
  G.Camera:push()

  love.graphics.setShader(vhsShader)
  G.State:draw()
  love.graphics.setShader()
  
  G.Camera:pop()
end

function love.update(dt)
  G.State:update(dt)
  vhsShader:send("time", love.timer.getTime())
  vhsShader:send("scale", G.Camera:getScale())
  vhsShader:send("screenSize", {WIDTH, HEIGHT})
  vhsShader:send("noiseIntensity", 0.05)
  vhsShader:send("bulgeStrength", 0)
end

function love.keypressed(key)
  G.Controls:keyPressed(key)
  G.State:keypressed(key)
end