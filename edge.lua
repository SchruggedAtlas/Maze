require "class"

Edge = class(
  function(a, name)
    a.name = name
  end
)

function Edge:init(x1,y1,x2,y2)
  self.x1 = x1
  self.y1 = y1
  self.x2 = x2
  self.y2 = y2
  self.visible = true
  self.visible_color = {0,1,0,1}
  self.not_visible_color = {0,0,0,0}
end

function Edge:update(x1,y1,x2,y2)
  self.x1 = x1
  self.y1 = y1
  self.x2 = x2
  self.y2 = y2
end

function Edge:set_visible(state)
  self.visible = state
end

function Edge:draw()
  if(self.visible) then
    love.graphics.setColor(self.visible_color)
  else
    love.graphics.setColor(self.not_visible_color)
  end
  love.graphics.line(self.x1, self.y1, self.x2, self.y2)
end
