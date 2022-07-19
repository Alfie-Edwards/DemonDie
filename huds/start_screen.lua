require "hud"
require "utils"

start_screen_text = {
    "You have acidentally awakend the DEMON DIE!",
    "Drive as quickly as possible to the exorcist to seal it away!",
    "Careful though; the die will mess with you!",
    "To calm the die down, open your book and complete the ritual.",
    "Arrow keys to steer, mouse to interact.",
    "Good luck!",
    "Press [space] to start",
}

function create_start_screen()
    local start_screen = Hud:new()
    start_screen:add_draw_func(
        function()
            love.graphics.clear(0, 0, 0)
            draw_centred_text(start_screen_text, 50, {1, 1, 1} , 2)
        end
    )

    start_screen:add_keypressed_func(
        function(key)
            if (key == "space") then
                set_hud("cab")
            end
        end
    )

    return start_screen
end

