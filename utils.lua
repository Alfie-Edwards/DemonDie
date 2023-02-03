function setup_instance(inst, class)
    assert(class ~= nil)
    setmetatable(inst, {__index = class})
end

function setup_class(name, super)
    if (super == nil) then
        super = Object
    end
    local template = _G[name]
    setmetatable(template, {__index = super})
    template.type = function(obj) return name end
end

BoundingBox = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
}
setup_class("BoundingBox")

function BoundingBox.new(x1, y1, x2, y2)
    local obj = {}
    setup_instance(obj, BoundingBox)
    obj.x1 = x1
    obj.y1 = y1
    obj.x2 = x2
    obj.y2 = y2

    return obj
end

function BoundingBox:contains(x, y)
    return (x >= self.x1 and x < self.x2 and y >= self.y1 and y < self.y2)
end

function BoundingBox:width()
    return self.x2 - self.x1
end

function BoundingBox:height()
    return self.y2 - self.y1
end

function BoundingBox:center_x()
    return (self.x2 + self.x1) / 2
end

function BoundingBox:center_y()
    return (self.y2 + self.y1) / 2
end

function rotate_about(angle, x, y)
    local transform = love.math.newTransform()
    transform:translate(x, y)
    transform:rotate(angle)
    transform:translate(-x, -y)
    return transform
end

function scale_about(scale_x, scale_y, x, y)
    local transform = love.math.newTransform()
    transform:translate(x, y)
    transform:scale(scale_x, scale_y)
    transform:translate(-x, -y)
    return transform
end

function wrap_text(text, font, width)
    local line_begin = 1
    local word_begin = 1
    local line_end = 1
    local result = {}
    while line_end < #text do
        if text:sub(line_end,line_end) == "\n" then
            table.insert(result, text:sub(line_begin,line_end-1))
            line_begin = line_end + 1
        elseif not text:sub(line_end,line_end):match("^[A-z0-9_]$") then
            word_begin = line_end + 1
        elseif line_begin ~= word_begin and font:getWidth(text:sub(line_begin,line_end)) > width then
            table.insert(result, text:sub(line_begin,word_begin-1))
            line_begin = word_begin
        end
        line_end = line_end + 1
    end
    table.insert(result, text:sub(line_begin,#text))
    return result
end

function canvas_position()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local x_scale = screen_width / canvas_size[1]
    local y_scale = screen_height / canvas_size[2]
    local min_scale = math.min(x_scale, y_scale)
    local x_offset = (screen_width - (canvas_size[1] * min_scale)) / 2
    local y_offset = ((screen_height - (canvas_size[2] * min_scale)) / 2) + 50
    return x_offset, y_offset, min_scale
end

function screen_to_canvas(screen_x, screen_y)
    local x_offset, y_offset, scale = canvas_position()
    local canvas_x = (screen_x - x_offset) / scale
    local canvas_y = (screen_y - y_offset) / scale
    local canvas_x, canvas_y = effects:get_transform():transformPoint(canvas_x, canvas_y)
    return canvas_x, canvas_y
end

function shuffle_list(list)
  for i = #list, 2, -1 do
    local j = math.random(i)
    list[i], list[j] = list[j], list[i]
  end
end

function concat(a, b)
    local ab = {}
    table.move(a, 1, #a, 1, ab)
    table.move(b, 1, #b, #ab + 1, ab)
    return ab
end

function randfloat(low, high)
    return (math.random() * (high - low)) + low
end

function draw_centred_text(text, y, color, line_spacing)
    color = color or {1, 1, 1}
    local text_type = type_string(text)
    if (text_type == "table") then
        line_spacing = line_spacing or 0
        for _,line in ipairs(text) do
            draw_centred_text(line, y, color)
            y = y + font:getLineHeight() + font:getHeight() + line_spacing
        end
    elseif (text_type == "Text") then
        -- If text is a love.graphics.Text
        local x = (canvas_size[1] - text:getWidth()) / 2
        love.graphics.draw(text, x, y)
    else
        local x = (canvas_size[1] - font:getWidth(text)) / 2
        love.graphics.print({color, text}, x, y)
    end
end

function draw_bb(bb, color)
    if (color == nil) or (bb == nil) or (color[4] == 0) then
        return
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", bb.x1, bb.y1, bb:width(), bb:height())
end

function clamp(x, min, max)
    x = math.min(x, max)
    x = math.max(x, min)
    return x
end

function lerp(a, b, ratio)
    ratio = clamp(ratio, 0, 1)
    return a * (1 - ratio) + b * ratio
end

function lerp_list(a, b, ratio)
    if (#a ~= #b) then
        error("lerp_list requires lists of equal length ("..tostring(#a).." != "..tostring(#b)..")")
    end
    local result = {}
    for i, a_item in ipairs(a) do
        b_item = b[i]
        result[i] = lerp(a_item, b_item, ratio)
    end
    return result
end

function type_string(obj)
    -- LOVE objects have their own type field.
    if (obj ~= nil and obj.type ~= nil) then
        return obj:type()
    end
    return type(obj)
end

function index_of(list, value)
    for i,v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return nil
end

function remove_value(list, value_to_remove)
    local i = index_of(list, value_to_remove)
    if i ~= nil then
        table.remove(list, i)
    end
end

function value_in(value, list)
    for _,item in ipairs(list) do
        if value == item then
            return true
        end
    end
    return false
end

function get_key(table, value)
    for k,v in pairs(table) do
        if v == value then
            return k
        end
    end

    local metatable = getmetatable(table)
    if metatable ~= nil and metatable.__index ~= nil then
        return get_key(metatable.__index, value)
    end

    return nil
end

function get_local(name, default, stack_level)
    if stack_level == nil then
        stack_level = 1
    end

    local var_index = 1
    while true do
        local var_name, value = debug.getlocal(stack_level, var_index)
        print(tostring(var_name)..": "..tostring(value))
        if var_name == name then
            return value
        elseif var_name == nil then
            return default
        end
        var_index = var_index + 1
    end
end
