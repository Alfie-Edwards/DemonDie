require "ui.simple_element"
require "ui.image"
require "utils"

ImageButton = {}

setup_class("ImageButton", Image)

function ImageButton.new()
    local obj = Image.new()
    setup_instance(obj, ImageButton)

    return obj
end

function ImageButton:draw()
    Image.draw(self)

    local mouse_x, mouse_y = self:get_mouse_pos()

    if self:contains(mouse_x, mouse_y) then
        if love.mouse.isDown(1) then
            love.graphics.setColor({1, 1, 1, 0.15})
            love.graphics.setBlendMode("subtract")
            self:draw_image()
        else
            love.graphics.setColor({1, 1, 1, 0.15})
            love.graphics.setBlendMode("add")
            self:draw_image()
        end
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor({1, 1, 1, 1})
    end
end

