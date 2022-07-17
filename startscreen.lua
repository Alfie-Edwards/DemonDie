require "utils"

StartScreen = {
    lines = {
        "You have acidentally awakend the DEMON DIE!",
        "Drive as quickly as possible to the exorcist to seal it away!",
        "Careful though; the die will mess with you!",
        "To calm the die down, open your book and complete the ritual.",
        "Arrow keys to steer, mouse to interact.",
        "Good luck!",
        "Press [space] to start",
    },

    text = nil,
}
StartScreen.__index = StartScreen

function centred_text(text, y)
    love.graphics.draw(text, (canvas_w - text:getWidth()) / 2, y)
end

function StartScreen:new()
    local obj = {}
    setmetatable(obj, StartScreen)

    obj.text = { }
    for i=1,#obj.lines do
        table.insert(obj.text, love.graphics.newText(font, obj.lines[i]))
    end

    return obj
end

function StartScreen:draw()
    for i=1,#self.text do
        draw_centred_text(self.text[i], 30 + (i * self.text[i]:getHeight() * 1.5))
    end
end

