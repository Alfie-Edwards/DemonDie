require "ui.simple_element"
require "ui.text"
require "utils"

StartScreen = {
    text = {
        "You have acidentally awakend the DEMON DIE!",
        "Drive as quickly as possible to the exorcist to seal it away!",
        "Careful though; the die will mess with you!",
        "To calm the die down, open your book and complete the ritual.",
        "Arrow keys to steer, mouse to interact.",
        "Good luck!",
        "Press [space] to start",
    },
}

setup_class("StartScreen", SimpleElement)

function StartScreen.new()
    local obj = SimpleElement.new()
    setup_instance(obj, StartScreen)

    obj:set_properties(
        {
            width = canvas_size[1],
            height = canvas_size[2],
            background_color = {0, 0, 0, 1},
        }
    )

    local text = Text.new()
    text:set_properties(
        {
            x = canvas_size[1] / 2,
            y = canvas_size[2] * 0.425,
            x_align = "center",
            y_align = "center",

            text = StartScreen.text,
            font = assets:get_font("font"),
            line_spacing = 2,
            wrap_width = canvas_size[1],
            text_align = "center",
        }
    )
    obj:add_child(text)

    return obj
end


function StartScreen:keypressed(key)
    if (key == "space") then
        set_screen("cab")
    end
end

