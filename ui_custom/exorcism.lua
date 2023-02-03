require "ui.simple_element"
require "ui.image"
require "ui.text"
require "exorcism"

ExorcismView = {
    typing_chars = "^[A-z']$",
    start_image = nil,
    text = nil,
    current_exorcism = nil,
}

setup_class("ExorcismView", SimpleElement)

function ExorcismView.new()
    local obj = SimpleElement.new()
    setup_instance(obj, ExorcismView)

    obj:set_properties(
        {
            width = assets:get_image("begin_ritual"):getWidth(),
            height = assets:get_image("begin_ritual"):getHeight(),
        }
    )

    obj.start_image = Image.new()
    obj.start_image:set_properties(
        {
            image = assets:get_image("begin_ritual"),
            pixel_hit_detection = false,
            cursor = love.mouse.getSystemCursor("hand"),
            click = function() obj:begin() end,
        }
    )
    obj:add_child(obj.start_image)

    obj.text = Drawable.new()
    obj.text:set_properties(
        {
            x = obj:get_width() / 2,
            y = obj:get_height() * 0.425,
            x_align = "center",
            y_align = "center",
        }
    )

    return obj
end

function ExorcismView:keypressed(key)
    if (self.current_exorcism == nil) then
        return false
    end

    local stage = self.current_exorcism.current_stage
    if (stage == nil) then
        return false
    end

    if (stage.type == "typing") then
        if key:match(self.typing_chars) then
            if key == stage.text:sub(stage.pos, stage.pos) then
                self:exorcism_typing_match()
            else
                self:exorcism_typing_mistake()
            end
        end
    end

    return true
end

function ExorcismView:begin()
    self:remove_child(self.text)
    self:remove_child(self.start_image)

    self.current_exorcism = Exorcism.new(die)
    self:update_text()
    self:add_child(self.text)
end

function ExorcismView:stage_complete()
    self:remove_child(self.text)
    self:remove_child(self.start_image)
    self:add_child(self.start_image)

    if self.current_exorcism ~= nil then
        self.current_exorcism:stage_complete()
    end
end

function ExorcismView:update_text()
    if (self.current_exorcism == nil) then
        return
    end

    local stage = self.current_exorcism.current_stage
    if (stage == nil) then
        return
    end

    if (stage.type ~= "typing") then
        return
    end

    self.text:set_drawable(
        love.graphics.newText(
            assets:get_font("font"),
            {
                {0.41, 0.4, 0.39}, stage.text:sub(0,stage.pos-1),
                {0.48, 0.09, 0.09}, stage.text:sub(stage.pos,stage.pos),
                {0.81, 0.8, 0.79}, stage.text:sub(stage.pos+1),
            }
        )
    )
end

function ExorcismView:exorcism_typing_match()
    if (self.current_exorcism == nil) then
        return
    end

    local stage = self.current_exorcism.current_stage
    if (stage == nil) then
        return
    end

    if (stage.type ~= "typing") then
        return
    end

    stage.pos = stage.pos + 1
    while (not stage.text:sub(stage.pos, stage.pos):match(self.typing_chars)
           and not (stage.pos > #(stage.text))) do
        stage.pos = stage.pos + 1
    end

    self:update_text()

    if (stage.pos > #stage.text) then
        self:stage_complete()
    end
end

function ExorcismView:exorcism_typing_mistake()
end