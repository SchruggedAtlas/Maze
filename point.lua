require "class"

Point = class(
  function(a, name)
    a.name = name
  end
)

function Point:init(x,y)
  self.x = x
  self.y = y
  self.color = {1,1,0,1}
  self.pt_size = 3
end

function Point:update(x,y)
  self.x = x
  self.y = y
end

function Point:draw()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.x, self.y, self.pt_size)
end