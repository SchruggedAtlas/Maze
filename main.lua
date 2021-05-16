require 'point'
require 'edge'
require 'maze'

function love.load()
    love.window.setMode(0,0)
    screen_w = love.graphics.getWidth()
    screen_h = love.graphics.getHeight()
    edge_offset = 10
    num_points = 39
    the_maze = Maze()
    the_maze:init(screen_w, screen_h, edge_offset, num_points)
    total_time = 0
end

function get_line_space(a, b, num_points)
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

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    if key == "i" then
        the_maze:reset()    
    end
end

function love.update(dt)
    total_time = total_time + dt
    if total_time > 0.0 then
        the_maze:update()
        total_time = 0
    end
end

function love.draw()
    the_maze:draw()
end