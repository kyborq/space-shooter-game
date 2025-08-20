SpriteSheet = Class()

function SpriteSheet:init(asset, frameWidth, frameHeight, originX, originY)
  self.image = love.graphics.newImage(asset)
  self.frameWidth = frameWidth
  self.frameHeight = frameHeight

  self.width = self.image:getWidth()
  self.height = self.image:getHeight()

  self.rows = math.floor(self.height / self.frameHeight)
  self.cols = math.floor(self.width / self.frameWidth)

  -- generating frames
  self.frames = {}
  for y = 0, self.rows - 1 do
    for x = 0, self.cols - 1 do
      local quad = love.graphics.newQuad(
        x * self.frameWidth,
        y * self.frameHeight,
        self.frameWidth,
        self.frameHeight,
        self.width,
        self.height
      )
      table.insert(self.frames, quad)
    end
  end

  self.currentFrame = 1
  self.originX = originX or 0
  self.originY = originY or self.originX

  -- for animation
  self.timer = 0
  self.fps = 0
  self.playing = false
  self.loop = true
  self.pingpong = false
  self.forward = true

  self.animations = {} -- { name = {startFrame, endFrame, fps, loop, pingpong} }
  self.currentAnim = nil
  self.startFrame = 1
  self.endFrame = #self.frames
end

function SpriteSheet:setFrame(index)
  if index >= 1 and index <= #self.frames then
    self.currentFrame = index
  end
end

function SpriteSheet:nextFrame()
  self.currentFrame = self.currentFrame + 1
  if self.currentFrame > #self.frames then
    self.currentFrame = 1
  end
end

function SpriteSheet:previousFrame()
  self.currentFrame = self.currentFrame - 1
  if self.currentFrame < 1 then
    self.currentFrame = #self.frames
  end
end

-- регистрируем анимацию
function SpriteSheet:addAnimation(name, startFrame, endFrame, fps, loop, pingpong)
  self.animations[name] = {
    startFrame = startFrame,
    endFrame = endFrame,
    fps = fps or 10,
    loop = loop ~= false,
    pingpong = pingpong or false
  }
end

-- запускаем анимацию
function SpriteSheet:play(name)
  local anim = self.animations[name]
  if not anim then return end

  self.currentAnim = anim
  self.currentFrame = anim.startFrame
  self.startFrame = anim.startFrame
  self.endFrame = anim.endFrame
  self.fps = anim.fps
  self.loop = anim.loop
  self.pingpong = anim.pingpong
  self.playing = true
  self.timer = 0
  self.forward = true
end

function SpriteSheet:stop()
  self.playing = false
end

function SpriteSheet:update(dt)
  if not self.playing or self.fps <= 0 then return end

  self.timer = self.timer + dt
  local frameTime = 1 / self.fps

  while self.timer >= frameTime do
    self.timer = self.timer - frameTime

    if self.pingpong then
      if self.forward then
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > self.endFrame then
          if self.loop then
            self.forward = false
            self.currentFrame = self.endFrame - 1
          else
            self.currentFrame = self.endFrame
            self:stop()
          end
        end
      else
        self.currentFrame = self.currentFrame - 1
        if self.currentFrame < self.startFrame then
          if self.loop then
            self.forward = true
            self.currentFrame = self.startFrame + 1
          else
            self.currentFrame = self.startFrame
            self:stop()
          end
        end
      end
    else
      self.currentFrame = self.currentFrame + 1
      if self.currentFrame > self.endFrame then
        if self.loop then
          self.currentFrame = self.startFrame
        else
          self.currentFrame = self.endFrame
          self:stop()
        end
      end
    end
  end
end

function SpriteSheet:draw(x, y)
  local offsetX = self.originX * self.frameWidth
  local offsetY = self.originY * self.frameHeight

  love.graphics.draw(
    self.image,
    self.frames[self.currentFrame],
    x or 0,
    y or 0,
    0,
    1, 1,
    offsetX,
    offsetY
  )
end

function SpriteSheet:getBounds(x, y)
  local offsetX = self.originX * self.frameWidth
  local offsetY = self.originY * self.frameHeight

  local left = (x or 0) - offsetX
  local top = (y or 0) - offsetY
  local right = left + self.frameWidth
  local bottom = top + self.frameHeight

  return left, top, right, bottom
end
