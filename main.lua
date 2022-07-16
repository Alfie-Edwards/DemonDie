function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.graphics.setLineStyle("rough")
    canvas_size = {320, 180}
    canvas = love.graphics.newCanvas(canvas_size[1], canvas_size[2])
end

function love.update(dt)
end

function draw_canvas()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local x_scale = screen_width / canvas_size[1]
    local y_scale = screen_height / canvas_size[2]
    local min_scale = math.min(x_scale, y_scale)
    local x_offset = (screen_width - (canvas_size[1] * min_scale)) / 2
    local y_offset = (screen_height - (canvas_size[2] * min_scale)) / 2

    love.graphics.setCanvas()
    love.graphics.draw(canvas, x_offset, y_offset, 0, min_scale, min_scale)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0.125, 0.333)

    draw_canvas()
end
