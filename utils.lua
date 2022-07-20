BoundingBox = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
}
BoundingBox.__index = BoundingBox

function BoundingBox.new(x1, y1, x2, y2)
    local obj = {}
    setmetatable(obj, BoundingBox)
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

function rotate_about(angle, x, y)
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.translate(-x, -y)
end

function scale_about(scale_x, scale_y, x, y)
    love.graphics.translate(x, y)
    love.graphics.scale(scale_x, scale_y)
    love.graphics.translate(-x, -y)
end

function wrap_text(text, font, width)
    local line_begin = 1
    local word_begin = 1
    local line_end = 1
    while(line_end < #text) do
        if (not text:sub(line_end,line_end):match("^[A-z0-9_]$")) then
            word_begin = line_end + 1
        elseif (font:getWidth(text:sub(line_begin,line_end)) > width) then
            text = text:sub(1,word_begin-1).."\n"..text:sub(word_begin)
            line_begin = word_begin
        end
        line_end = line_end + 1
    end
    return text
end

function canvas_position()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local x_scale = screen_width / canvas_size[1]
    local y_scale = screen_height / canvas_size[2]
    local min_scale = math.min(x_scale, y_scale)
    local x_offset = (screen_width - (canvas_size[1] * min_scale)) / 2
    local y_offset = (screen_height - (canvas_size[2] * min_scale)) / 2
    return x_offset, y_offset, min_scale
end

function screen_to_canvas(screen_x, screen_y)
    local x_offset, y_offset, scale = canvas_position()
    local canvas_x = (screen_x - x_offset) / scale
    local canvas_y = (screen_y - y_offset) / scale
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
    if (type(text) == "table") then
        line_spacing = line_spacing or 0
        for _,line in ipairs(text) do
            draw_centred_text(line, y, color)
            y = y + font:getLineHeight() + font:getHeight() + line_spacing
        end
    elseif (text.getFont ~= nil) then
        -- If text is a love.graphics.Text
        local x = (canvas_size[1] - text:getWidth()) / 2
        love.graphics.draw(text, x, y)
    else
        local x = (canvas_size[1] - font:getWidth(text)) / 2
        love.graphics.print({color, text}, x, y)
    end
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
