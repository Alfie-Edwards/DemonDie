require "hud"
require "utils"

death_screen_text = {
    crash_text = "You crashed!",
    offroad_text = "You totaled your car offroad!",
    cook_text = "You cooked in your car!",
    unknown_text = "You died!",

    score_intro_text = "Your distance: "
}

function create_death_screen(cause, score)
    local death_screen = Hud.new()

    local cause_str = death_screen_text.unknown_text
    if cause == "crash" then
        cause_str = death_screen_text.crash_text
    elseif cause == "offroad" then
        cause_str = death_screen_text.offroad_text
    elseif cause == "cook" then
        cause_str = death_screen_text.cook_text
    end
    local cause_text = love.graphics.newText(font, {{0.66, 0.06, 0.08}, cause_str})


    local intro_str = obj.score_intro_text
    local score_str = tostring(math.floor(score)).."m"
    local score_text = love.graphics.newText(font, {{0.41, 0.40, 0.39}, intro_str,
                                                    {1.00, 1.00, 1.00}, score_str})

    death_screen:add_draw_function(
        function()
            love.graphics.clear(0, 0, 0)
            draw_centred_text(cause_text, (canvas_size[2] / 2) - 10)
            draw_centred_text(score_text, (canvas_size[2] / 2) + 10)
        end
    )

    return death_screen
end

