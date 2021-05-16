require 'class'

Cell = class(
  function(a, name)
    a.name = name
  end
)

-- NORTH = 1
-- WEST  = 2
-- SOUTH = 3
-- EAST  = 4

function Cell:init(max, row, col, x, y, width, height)
    self.visited = false
    self.max = max
    self.row = row
    self.col = col
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.num_neighbors = 4
    self.neighbors = {}
    self:set_neighbors()
    self.invalid = "invalid"
    self.north_idx = 1
    self.west_idx = 2
    self.south_idx = 3
    self.east_idx = 4
    self.unvisited_color = {0,1,0,.2}
    self.visited_color = {0,0,0,0.0}
    self.color = self.unvisited_color
end

function Cell:set_visited(state)
    self.visited = state
    if self.visited == true then
        self:set_color(self.visited_color)
    else
        self:set_color(self.unvisited_color)
    end
end

function Cell:get_visited()
    return self.visited
end

function Cell:set_neighbors()
    for i=1, self.num_neighbors do
        if i == 1 then
            -- north
            self.neighbors[i] = "H"..tostring(self.row)..","..tostring(self.col)
        elseif i == 2 then
            -- west
            self.neighbors[i] = "V"..tostring(self.row)..","..tostring(self.col)
        elseif i == 3 then
            -- south
            self.neighbors[i] = "H"..tostring(self.row+1)..","..tostring(self.col)
        else -- i == 4
            -- east
            self.neighbors[i] = "V"..tostring(self.row)..","..tostring(self.col+1)
        end
    end
end

function Cell:get_neighbor(label)
    if label == "N" then
        return self.neighbors[self.north_idx]
    elseif label == "W" then
        return self.neighbors[self.west_idx]
    elseif label == "S" then
        return self.neighbors[self.south_idx]
    elseif label == "E" then
        return self.neighbors[self.east_idx]
    else
        return self.invalid
    end
end

function Cell:set_color(color)
    self.color = color
end

function Cell:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end