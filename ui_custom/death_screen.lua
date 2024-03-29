require "ui.simple_element"
require "ui.drawable"
require "ui.text"
require "utils"

DeathScreen = {
    causes = {
        crash = "You crashed!",
        offroad = "You totaled your car offroad!",
        freeze = "You froze solid!",
        cook = "You cooked in your car!",
        unknown = "You died!",
    },
    score_intro_text = "Your distance: "
}
setup_class("DeathScreen", SimpleElement)

function DeathScreen.new(cause, score)
    local obj = SimpleElement.new()
    setup_instance(obj, DeathScreen)

    obj:set_properties(
        {
            width = canvas_size[1],
            height = canvas_size[2],
            background_color = {0, 0, 0, 1},
        }
    )

    local cause_str = DeathScreen.causes[cause] or DeathScreen.causes.unknown_text

    local cause_text = Text.new()
    cause_text:set_properties(
        {
            x = canvas_size[1] / 2,
            y = canvas_size[2] * 0.425,
            x_align = "center",
            y_align = "center",

            text = cause_str,
            font = assets:get_font("font"),
            line_spacing = 10,
            wrap_width = canvas_size[1],
            text_align = "center",
            color = {0.66, 0.06, 0.08, 1},
        }
    )
    obj:add_child(cause_text)

    local intro_str = DeathScreen.score_intro_text
    local score_str = tostring(math.floor(score)).."m"

    local score_text = Drawable.new()
    score_text:set_properties(
        {
            x = canvas_size[1] / 2,
            y = canvas_size[2] * 0.575,
            x_align = "center",
            y_align = "center",
            drawable = love.graphics.newText(font, {{0.41, 0.40, 0.39}, intro_str,
                                                      {1.00, 1.00, 1.00}, score_str}),
        }
    )
    obj:add_child(score_text)

    return obj
end
