require "ui.element"
require "utils"

Toggle = {
    content_false = nil,
    content_true = nil,
    value = nil,
}
setup_class("Toggle", Element)

function Toggle.new()
    local obj = Element.new()
    setup_instance(obj, Toggle)

    obj.value = false

    return obj
end

function Toggle:get_content_false()
    return self.content_false
end

function Toggle:set_content_false(value)
    if self.content_false == value then
        return
    end
    self.content_false = value

    if not self.value then
        self:update_content()
    end
end

function Toggle:get_content_true()
    return self.content_true
end

function Toggle:set_content_true(value)
    if self.content_true == value then
        return
    end
    self.content_true = value

    if self.value then
        self:update_content()
    end
end

function Toggle:get_value()
    return self.value
end

function Toggle:set_value(value)
    if not value_in(type(value), {"boolean", "nil"}) then
        self:_value_error("Value must be a boolean, or nil.")
    end
    self.value = value
end

function Toggle:click(x, y, button)
    if self.value then
        return self.content_true == nil
    else
        return self.content_false == nil
    end
end

function Toggle:update_content()
    -- Remove all children.
    while #self.children > 0 do
        self:remove_child(self.children[1])
    end
    if self.value then
        if self.content_true ~= nil then
            self:add_child(self.content_true)
            self.bb = self.content_true.bb
        else
            self.bb = BoundingBox.new(0, 0, 0, 0)
        end
    else
        if self.content_false ~= nil then
            self:add_child(self.content_false)
            self.bb = self.content_false.bb
        else
            self.bb = BoundingBox.new(0, 0, 0, 0)
        end
    end
end
