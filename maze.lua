require 'class'
require 'point'
require 'edge'
require 'cell'

-- http://weblog.jamisbuck.org/2011/1/24/maze-generation-hunt-and-kill-algorithm

Maze = class(
  function(a, name)
    a.name = name
  end
)

function Maze:init(screen_w, screen_h, edge_offset, num_points)
  self.started = false
  self.walking = false
  self.hunting = false
  self.finished = false
  self.num_directions = 4
  self.screen_w = screen_w
  self.screen_h = screen_h
  self.edge_offset = edge_offset
  self.num_points = num_points
  self.left_edge = self.edge_offset
  self.right_edge = self.screen_w - self.edge_offset
  self.top_edge = self.edge_offset
  self.bottom_edge = self.screen_h - self.edge_offset
  self.x_space = Maze:get_line_space(self.left_edge, self.right_edge, self.num_points)
  self.y_space = Maze:get_line_space(self.top_edge, self.bottom_edge, self.num_points)
  self.cell_width = self.x_space[2] - self.x_space[1]
  self.cell_height = self.y_space[2] - self.y_space[1]
  self.vertices = {}
  self.edges = {}
  self.edge_names = {}
  self.cells = {}
  self.cell_names = {}
  self.cell_color = {0,1,0,.2}
  -- set cells
  self:set_cells()
  -- set vertices
  self:set_vertices()
  -- set boundaries
  self:set_boundaries()
end

function Maze:set_cells()
  -- cells
  for index_x=1, num_points-1 do
    self.cells[index_x] = {}
    for index_y=1, num_points-1 do
      local new_cell = Cell()
      new_cell:init(self.num_points, index_y, index_x, self.x_space[index_x], self.y_space[index_y], self.cell_width, self.cell_height)
      self.cells[index_x][index_y] = new_cell
    end
  end
end

function Maze:set_vertices()
  -- points
  for i = 1, #self.x_space do
    self.vertices[i] = {}
    for j = 1, #self.y_space do
      local vertex = Point()
      vertex:init(self.x_space[i], self.y_space[j])
      self.vertices[i][j] = vertex
    end
  end
end

function Maze:set_boundaries()
  -- horizontal lines
  for index_x, x_value in ipairs(self.x_space) do
      for index_y, y_value in ipairs(self.y_space) do
          if index_x < #self.x_space then
              local new_edge = Edge()
              new_edge:init(x_value, y_value, self.x_space[index_x +1], y_value)
              local new_name = "H"..index_y..","..index_x
              --print(new_name)
              table.insert(self.edges, new_edge)
              -- name indexes mirror edge indexes
              self.edge_names[#self.edges] = new_name
          end
      end
  end
  -- vertical lines
  for index_y, y_value in ipairs(self.y_space) do
      for index_x, x_value in ipairs(self.x_space) do
          if index_y < #self.y_space then
              local new_edge = Edge()
              new_edge:init(x_value, y_value, x_value, self.y_space[index_y + 1])
              local new_name = "V"..index_y..","..index_x
              --print(new_name)
              table.insert(self.edges, new_edge)
              -- name indexes mirror edge indexes
              self.edge_names[#self.edges] = new_name
          end
      end
  end
end

function Maze:get_line_space(a, b, num_points)
  local linespace = {}
  local num_spaces = num_points - 1
  local increment = (b - a)/num_spaces
  for i=1, num_points do
       if i == 1 then
           table.insert(linespace, a)
       elseif i == num_points then
           table.insert(linespace, b)
       else
           table.insert(linespace, a + increment*(i-1))
       end
  end
  return linespace
end

function Maze:update()
  if not(self.started) then
    self.selected_cell = self:get_random_selection()
    self.selected_cell:set_visited(true)
    self.started = true
    self.walking = true
    return
  end

  if (self.walking) then
    self:walk()
  end

  if (self.hunting) then
    self:hunt()
  end
end

function Maze:walk()
  local neighbor, direction = self:scan_neighbors(self.selected_cell)
  if not(neighbor == nil) then
    neighbor:set_visited(true)
    local edge_name = self.selected_cell:get_neighbor(direction)
    local edge_index = self:get_name_index(edge_name)
    self.edges[edge_index]:set_visible(false)
    self.selected_cell = neighbor
  else
    print("Switching to HUNT mode")
    self.walking = false
    self.hunting = true
  end
end

function Maze:hunt()
  -- Find an unvisited cell
    -- Find an visited cell next to the unvisited cell
    -- Erase the edge between the visited cell and the unvisited cell
    -- Set the unvisited cell as the selected_cell and make it visited
    -- Return to walking state
  -- If none found
    -- Transition to finished state
  for index_x=1, num_points-1 do
    for index_y=1, num_points-1 do
      if not(self.cells[index_x][index_y]:get_visited()) then
        local found, direction = self:any_adjacent_visited(self.cells[index_x][index_y])
        if found then
        -- found a qualified unvisited cell
          self.cells[index_x][index_y]:set_visited(true)
          local edge_name = self.cells[index_x][index_y]:get_neighbor(direction)
          local edge_index = self:get_name_index(edge_name)
          self.edges[edge_index]:set_visible(false)
          self.selected_cell = self.cells[index_x][index_y]
          self.hunting = false
          self.walking = true
          print("Switching to WALK mode")
          return
        end
      end
    end
  end
  self.hunting = false
  self.walking = false
  self.finished = true
  print("FINIHSED")
end

function Maze:any_adjacent_visited(check_cell)
  local x = 0
  local y = 0

  -- scan for visited neighbors
  x = check_cell.col - 1
  y = check_cell.row
  if(x > 0) then
    if self.cells[x][y]:get_visited() then
      return true, "W"
    end
  end

  x = check_cell.col + 1
  y = check_cell.row
  if(x < self.num_points) then
    if self.cells[x][y]:get_visited() then
      return true, "E"
    end
  end

  x = check_cell.col
  y = check_cell.row - 1
  if(y > 0) then
    if self.cells[x][y]:get_visited() then
      return true, "N"
    end
  end

  x = check_cell.col
  y = check_cell.row + 1
  if(y < self.num_points) then
    if self.cells[x][y]:get_visited() then
      return true, "S"
    end
  end

  return false, nil
end

function Maze:get_name_index(name)
  for index, edge_name in ipairs(self.edge_names) do
    if edge_name == name then
      return index
    end
  end
  return 0
end

function Maze:scan_neighbors(check_cell)
  local unvisited_neighbors = {}
  local directions = {}
  local x = 0
  local y = 0

  -- scan for unvisited neighbors
  x = check_cell.col - 1
  y = check_cell.row
  if(x > 0) then
    if not (self.cells[x][y]:get_visited()) then
      table.insert(unvisited_neighbors, self.cells[x][y])
      table.insert(directions, "W")
    end
  end

  x = check_cell.col + 1
  y = check_cell.row
  if(x < self.num_points) then
    if not (self.cells[x][y]:get_visited()) then
      table.insert(unvisited_neighbors, self.cells[x][y])
      table.insert(directions, "E")
    end
  end

  x = check_cell.col
  y = check_cell.row - 1
  if(y > 0) then
    if not (self.cells[x][y]:get_visited()) then
      table.insert(unvisited_neighbors, self.cells[x][y])
      table.insert(directions, "N")
    end
  end

  x = check_cell.col
  y = check_cell.row + 1
  if(y < self.num_points) then
    if not (self.cells[x][y]:get_visited()) then
      table.insert(unvisited_neighbors, self.cells[x][y])
      table.insert(directions, "S")
    end
  end

  if(#unvisited_neighbors > 0) then
    local selection = love.math.random(1, #unvisited_neighbors)
    return unvisited_neighbors[selection], directions[selection]
  else
    return nil, nil
  end
end

function Maze:get_random_selection()
  local x = love.math.random(1, #self.x_space-1)
  local y = love.math.random(1, #self.y_space-1)
  return self.cells[x][y]
end

function Maze:reset()
  for index, e in ipairs(self.edges) do
    e:set_visible(true)
  end

  for index_x=1, num_points-1 do
    for index_y=1, num_points-1 do
      self.cells[index_x][index_y]:set_visited(false)
    end
  end

  self.started = false
  self.walking = false
  self.hunting = false
  self.finished = false
end

function Maze:draw()
  -- draw edges
  for index, e in ipairs(self.edges) do
      e:draw()
  end
  -- draw cells
  for index_x=1, num_points-1 do
    for index_y=1, num_points-1 do
      self.cells[index_x][index_y]:draw()
    end
  end
end