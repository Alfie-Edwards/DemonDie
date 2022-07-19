require "hud"

function create_back_seats()
    local back_seats = Hud.new()
    back_seats:add_draw_func(
        function()
            love.graphics.draw(images.back_seats)
            local die_pos = die_positions[die.number]
            love.graphics.draw(images.die[die.number], die_pos[1], die_pos[2])
            love.graphics.draw(images.eye, 80, 11, 0, -1, 1)

            if (die.difficulty < 1) then
                die_bars[1]:draw()
            elseif (die.difficulty < 2) then
                die_bars[2]:draw()
            else
                die_bars[3]:draw()
            end
        end
    )
    back_seats:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(22, 11, 80, 33),
            function() set_hud("cab") end
        )
    )

    return back_seats
end

