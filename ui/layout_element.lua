require "ui.element"
require "utils"

SimpleElement = {
    background = nil,
    parent = nil,
    children = nil,
    cursor = nil,
    _layout = nil,
}
setup_class("SimpleElement", Element)

function SimpleElement.new()
    local obj = Element.new()
    setup_instance(obj, SimpleElement)

    obj.x = 0
    obj.y = 0
    obj.width = 0
    obj.height = 0
    obj.align_x = "center"
    obj.align_y = "center"

    return obj
end

function SimpleElement:update_layout()
    obj.bb = BoundingBox.new(0, 0, 0, 0)
end
