Hud = {
    mouse_regions = {},
}
Hud.__index = Hud

function Hud.new()
    local obj = {}
    setmetatable(obj, Hud)
    obj.mouse_regions = {}

    return obj
end

function Hud:add_mouse_region(mouse_region)
    table.insert(self.mouse_regions, mouse_region)
end

function Hud:click(x, y, button)
    for _, mouse_region in ipairs(self.mouse_regions) do
        if (mouse_region.button == button and mouse_region.bounding_box:contains(x, y)) then
            mouse_region.click_func()
            break
        end
    end
end

function Hud.update(dt)
end

function Hud.draw()
end

MouseRegion = {
    bounding_box = BoundingBox.new(0, 0, 0, 0),
    click_func = nil,
    button = 1
}
MouseRegion.__index = MouseRegion

function MouseRegion.new(bounding_box, click_func, button)
    local obj = {}
    setmetatable(obj, MouseRegion)
    obj.bounding_box = bounding_box
    obj.click_func = click_func
    obj.button = button or 1

    return obj
end
