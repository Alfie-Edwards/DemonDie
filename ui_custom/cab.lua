require "ui.simple_element"
require "ui.drawable"
require "ui.image"
require "ui.bar"
require "ui_custom.book"
require "ui_custom.image_button"

Cab = {
    wheel = nil,
    radio_text = nil,
    book_closed = nil,
    book_open = nil,
    book_exit = nil,
}

setup_class("Cab", SimpleElement)

function Cab.new()
    local obj = SimpleElement.new()
    setup_instance(obj, Cab)

    obj:set_properties(
        {
            width = canvas_size[1],
            height = canvas_size[2],
        }
    )

    local bg_image = Image.new()
    bg_image:set_properties(
        {
            image = assets:get_image("cab"),
            image_data = assets:get_image_data("cab"),
        }
    )
    obj:add_child(bg_image)

    obj.radio_text = Drawable.new()
    obj.radio_text:set_properties(
        {
            x = 155,
            y = 117,
            drawable = love.graphics.newText(font, ""),
        }
    )
    obj:add_child(obj.radio_text)

    obj.wheel = Image.new()
    obj.wheel:set_properties(
        {
            x = 99,
            y = 129,
            x_align = "center",
            y_align = "center",
            image = assets:get_image("wheel"),
            image_data = assets:get_image_data("wheel"),
        }
    )
    obj:add_child(obj.wheel)

    local horn = ImageButton.new()
    horn:set_properties(
        {
            x = 35,
            y = 34,
            image = assets:get_image("horn"),
            image_data = assets:get_image_data("horn"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function() car:beep() end,
        }
    )
    obj.wheel:add_child(horn)

    local ac_cold = ImageButton.new()
    local ac_off = ImageButton.new()
    local ac_hot = ImageButton.new()
    ac_cold:set_properties(
        {
            x = 152,
            y = 142,
            image = assets:get_image("ac_cold"),
            image_data = assets:get_image_data("ac_cold"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                if car.ac == "cold" then
                    assets:get_mp3("button_off"):seek(0)
                    assets:get_mp3("button_off"):play()
                else
                    car.ac = "cold"
                    ac_cold:set_transform(scale_about(1, -1, assets:get_image("ac_cold"):getWidth() / 2, assets:get_image("ac_cold"):getHeight() / 2))
                    ac_hot:set_transform(love.math.newTransform())
                    assets:get_mp3("Button_plastic_4-4"):seek(0)
                    assets:get_mp3("Button_plastic_4-4"):play()
                end
            end,
        }
    )
    ac_off:set_properties(
        {
            x = 156,
            y = 142,
            image = assets:get_image("ac_off"),
            image_data = assets:get_image_data("ac_off"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                if car.ac == "off" then
                    assets:get_mp3("button_off"):seek(0)
                    assets:get_mp3("button_off"):play()
                else
                    car.ac = "off"
                    ac_cold:set_transform(love.math.newTransform())
                    ac_hot:set_transform(love.math.newTransform())
                    assets:get_mp3("Button_plastic_4-4"):seek(0)
                    assets:get_mp3("Button_plastic_4-4"):play()
                end
            end,
        }
    )
    ac_hot:set_properties(
        {
            x = 160,
            y = 142,
            image = assets:get_image("ac_hot"),
            image_data = assets:get_image_data("ac_hot"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                if car.ac == "hot" then
                    assets:get_mp3("button_off"):seek(0)
                    assets:get_mp3("button_off"):play()
                else
                    car.ac = "hot"
                    ac_cold:set_transform(love.math.newTransform())
                    ac_hot:set_transform(scale_about(1, -1, assets:get_image("ac_hot"):getWidth() / 2, assets:get_image("ac_hot"):getHeight() / 2))
                    assets:get_mp3("Button_plastic_4-4"):seek(0)
                    assets:get_mp3("Button_plastic_4-4"):play()
                end
            end,
        }
    )
    obj:add_child(ac_cold)
    obj:add_child(ac_off)
    obj:add_child(ac_hot)

    local radio = ImageButton.new()
    radio:set_properties(
        {
            x = 151,
            y = 135,
            image = assets:get_image("radio"),
            image_data = assets:get_image_data("radio"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function() car:toggle_station() end,
        }
    )
    obj:add_child(radio)

    local eye = ImageButton.new()
    eye:set_properties(
        {
            x = 240,
            y = 11,
            image = assets:get_image("eye"),
            image_data = assets:get_image_data("eye"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                set_screen("back_seats")
                assets:get_mp3("look"):seek(0)
                assets:get_mp3("look"):play()
            end,
        }
    )
    obj:add_child(eye)

    obj.bar = Bar.new()
    obj.bar:set_properties(
        {
            x = 1,
            y = 1,
            width = 318,
            height = 9,
            border_thickness = 1,
            border_color = {0.28, 0.57, 0.5, 1},
            bar_color = {0.37, 0.69, 0.61, 1},
            background_color = {0.14, 0.4, 0.34, 1},
            label_color = {1, 1, 1, 1},
            label = "health",
        }
    )
    obj:add_child(obj.bar)

    obj.book_closed = ImageButton.new()
    obj.book_closed:set_properties(
        {
            x = 160,
            y = 137,
            image = assets:get_image("book"),
            image_data = assets:get_image_data("book"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                obj:open_book()
                assets:get_mp3("book_open"):seek(0)
                assets:get_mp3("book_open"):play()
            end,
        }
    )
    
    obj.book_open = Book.new()
    obj.book_open:set_properties(
        {
            x = canvas_size[1] / 2,
            y = canvas_size[2] / 2,
            x_align = "center",
            y_align = "center",
            cursor = love.mouse.getSystemCursor("arrow"),
            click = function() return true end, -- Consume mouse click.
        }
    )

    obj.book_exit = SimpleElement.new()
    obj.book_exit:set_properties(
        {
            width = canvas_size[1],
            height = canvas_size[2],
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                obj:close_book()
                assets:get_mp3("Book close"):seek(0)
                assets:get_mp3("Book close"):play()
            end,
        }
    )

    obj:close_book()

    return obj
end

function Cab:open_book()
    self:remove_child(self.book_open)
    self:remove_child(self.book_closed)
    self:remove_child(self.book_exit)

    self:add_child(self.book_exit)
    self:add_child(self.book_open)
end

function Cab:close_book()
    self:remove_child(self.book_open)
    self:remove_child(self.book_closed)
    self:remove_child(self.book_exit)

    self:add_child(self.book_closed)
end

function Cab:update(dt)
    SimpleElement.update(self, dt)

    -- Update steering wheel rotation.
    local transform = rotate_about(
        car:steering_amount() / car.max_turn_rate,
        self.wheel.bb:width() / 2,
        self.wheel.bb:height() / 2
    )
    self.wheel:set_transform(transform)

    -- Update radio text.
    self.radio_text:get_drawable():set(
        {{1, 1, 1, 0.6}, car:get_temperature_string().."\n"..car:get_radio_station_string()})
    -- Manually update layout as we have caused the drawable to change size.
    self.radio_text:update_layout()

    -- Update health bar
    self.bar:set_progress(car.health / 100)
end
