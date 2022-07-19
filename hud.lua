Hud = {
    mouse_regions = {},
    draw_funcs = {},
    update_funcs = {},
    keypressed_funcs = {},
    default_cursor = nil,
}
Hud.__index = Hud

function Hud.new()
    local obj = {}
    setmetatable(obj, Hud)
    obj.mouse_regions = {}
    obj.draw_funcs = {}
    obj.update_funcs = {}
    obj.keypressed_funcs = {}
    obj.default_cursor = love.mouse.getSystemCursor("arrow")

    return obj
end

function Hud:add_mouse_region(mouse_region)
    table.insert(self.mouse_regions, mouse_region)
end

function Hud:remove_mouse_region(mouse_region)
    local index = 0
    for i,x in ipairs(self.mouse_regions) do
        if (x == mouse_region) then
            index = i
            break
        end
    end
    if (index ~= 0) then
        table.remove(self.mouse_regions, index)
    end
end

function Hud:add_draw_func(draw_func)
    table.insert(self.draw_funcs, draw_func)
end

function Hud:add_update_func(update_func)
    table.insert(self.update_funcs, update_func)
end

function Hud:add_keypressed_func(keypress_func)
    table.insert(self.keypressed_funcs, keypress_func)
end

function Hud:click(x, y, button)
    for _, mouse_region in ipairs(self.mouse_regions) do
        if (mouse_region.button == button and mouse_region.bounding_box:contains(x, y)) then
            mouse_region.click_func()
            break
        end
    end
end

function Hud:update(dt)
    for _, update_func in ipairs(self.update_funcs) do
        update_func(dt)
    end

    local screen_x, screen_y = love.mouse.getPosition( )
    local canvas_x, canvas_y = screen_to_canvas(screen_x, screen_y)

    local cursor = self.default_cursor
    for _, mouse_region in ipairs(self.mouse_regions) do
        if (mouse_region.bounding_box:contains(canvas_x, canvas_y)) then
            cursor = mouse_region.cursor
            break
        end
    end
    love.mouse.setCursor(cursor)

end

function Hud:draw()
    for _, draw_func in ipairs(self.draw_funcs) do
        draw_func()
    end
end

function Hud:keypressed(key)
    for _, keypressed_func in ipairs(self.keypressed_funcs) do
        keypressed_func(key)
    end
end

MouseRegion = {
    bounding_box = BoundingBox.new(0, 0, 0, 0),
    click_func = nil,
    button = 1,
    cursor = nil,
}
MouseRegion.__index = MouseRegion

function MouseRegion.new(bounding_box, click_func, button, cursor)
    local obj = {}
    setmetatable(obj, MouseRegion)
    obj.bounding_box = bounding_box
    obj.click_func = click_func
    obj.button = button or 1
    obj.cursor = cursor or love.mouse.getSystemCursor("hand")

    return obj
end
