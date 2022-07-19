require "hud"

function create_cab()
    local cab = Hud.new()
    cab:add_draw_func(
        function()
            love.graphics.draw(images.cab)
            love.graphics.print({{1, 1, 1, 0.6}, car:get_temperature_string().."\n"..car:get_radio_station_string()}, 155, 117)
            love.graphics.draw(images.book, 160, 137)
            draw_wheel()
            love.graphics.draw(images.eye, 240, 11)
            health_bar:draw()
        end
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(240, 11, 298, 33),
            function()
                set_hud("back_seats")
            end
        )
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(163, 140, 216, 180),
            function() set_hud_to_last_book_page() end
        )
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(152, 142, 155, 156),
            function() car.ac = "cold" end
        )
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(156, 142, 159, 156),
            function() car.ac = "off" end
        )
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(160, 142, 163, 156),
            function() car.ac = "hot" end
        )
    )
    cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(151, 135, 155, 140),
            function() car:toggle_station() end
        )
    )

    return cab
end

function draw_wheel()
    love.graphics.push()
    rotate_about(
        car:steering_amount() / car.max_turn_rate,
        60 + images.wheel:getWidth() / 2,
        90 + images.wheel:getHeight() / 2
    )
    love.graphics.draw(images.wheel, 60, 90)
    love.graphics.pop()
end
