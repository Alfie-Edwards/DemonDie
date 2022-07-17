Bar = {
    name = nil,
    max = 0,
    current = 0,
    border_color = nil,
    bar_color = nil,
    back_color = nil,
    text_color = nil,
}
Bar.__index = Bar

function Bar.new(name, max, border_color, bar_color, back_color, text_color)
    local obj = {}
    setmetatable(obj, Bar)
    obj.name = name
    obj.max = max
    obj.border_color = border_color
    obj.bar_color = bar_color
    obj.back_color = back_color
    obj.text_color = text_color

    return obj
end

function Bar:set(current)
    self.current = current
end

function Bar:draw()
    love.graphics.setColor(
        self.border_color[1],
        self.border_color[2],
        self.border_color[3]
    )
    love.graphics.rectangle("fill", 1, 1, 318, 9)
    love.graphics.setColor(
        self.bar_color[1],
        self.bar_color[2],
        self.bar_color[3]
    )
    love.graphics.rectangle("fill", 2, 2, 316, 7)
    love.graphics.setColor(
        self.back_color[1],
        self.back_color[2],
        self.back_color[3]
    )
    love.graphics.rectangle("fill", 2, 2, 316 * (self.current / self.max), 7)
    love.graphics.setColor(
        self.text_color[1],
        self.text_color[2],
        self.text_color[3]
    )
    love.graphics.print(self.name, 3, 3)
    love.graphics.setColor(1, 1, 1)
end