require "ui.simple_element"
require "ui.image"
require "ui.bar"
require "ui_custom.image_button"

BackSeats = {
    bar = nil,
    die = nil,
    bar_config = {
        labels = {
            "demonic presence (lvl I)",
            "demonic presence (lvl II)",
            "demonic presence (lvl III)",
            "demonic presence (lvl ?????????????????)"
        },
        border_colors = {
            {0.48, 0.09, 0.09, 1},
            {0.58, 0.10, 0.10, 1},
            {0.68, 0.11, 0.11, 1},
        },
        background_colors = {
            {0.28, 0.07, 0.07, 1},
            {0.38, 0.08, 0.08, 1},
            {0.48, 0.09, 0.09, 1},
        },
        label_colors = {
            {1, 1, 0.9, 1},
            {1, 0.95, 0.8, 1},
            {1, 0.9, 0.7, 1},
            {0.4, 0.1, 0, 1},
        },
    },
    die_config = {
        positions = {
            {20, 90},
            {210, 90},
            {250, 90},
            {100, 90},
            {60, 90},
            {180, 90},
        },
        images = {
            "die_I",
            "die_II",
            "die_III",
            "die_IV",
            "die_V",
            "die_VI",
        },
    },
}

setup_class("BackSeats", SimpleElement)

function BackSeats.new()
    local obj = SimpleElement.new()
    setup_instance(obj, BackSeats)

    obj:set_properties(
        {
            width = canvas_size[1],
            height = canvas_size[2],
        }
    )

    local bg_image = Image.new()
    bg_image:set_properties(
        {
            image = assets:get_image("back_seats"),
            image_data = assets:get_image_data("back_seats"),
        }
    )
    obj:add_child(bg_image)

    local eye = ImageButton.new()
    eye:set_properties(
        {
            x = 22,
            y = 11,
            image = assets:get_image("eye"),
            image_data = assets:get_image_data("eye"),
            transform = scale_about(-1, 1, assets:get_image("eye"):getWidth() / 2, assets:get_image("eye"):getHeight() / 2),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                set_screen("cab")
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
            bar_color = {1, 0.3, 0, 1},
        }
    )
    obj:add_child(obj.bar)

    obj.die = Image.new()
    obj:add_child(obj.die)

    return obj
end

function BackSeats:update(dt)
    SimpleElement.update(self, dt)

    -- Update bar.
    if (die.difficulty < 1) then
        self.bar:set_progress(die.difficulty)
        self.bar:set_border_color(self.bar_config.border_colors[1])
        self.bar:set_background_color(self.bar_config.background_colors[1])
        self.bar:set_label(self.bar_config.labels[1])
        self.bar:set_label_color(self.bar_config.label_colors[1])

    elseif (die.difficulty < 2) then
        self.bar:set_progress(die.difficulty - 1)
        self.bar:set_border_color(self.bar_config.border_colors[2])
        self.bar:set_background_color(self.bar_config.background_colors[2])
        self.bar:set_label(self.bar_config.labels[2])
        self.bar:set_label_color(self.bar_config.label_colors[2])

    else
        self.bar:set_progress(die.difficulty - 2)
        self.bar:set_border_color(self.bar_config.border_colors[3])
        self.bar:set_background_color(self.bar_config.background_colors[3])
        if (die.difficulty == die.max_difficulty) then
            self.bar:set_label(self.bar_config.labels[4])
            self.bar:set_label_color(self.bar_config.label_colors[4])
        else
            self.bar:set_label(self.bar_config.labels[3])
            self.bar:set_label_color(self.bar_config.label_colors[3])
        end
    end

    -- Update die.
    self.die:set_x(self.die_config.positions[die.number][1])
    self.die:set_y(self.die_config.positions[die.number][2])
    self.die:set_image(assets:get_image(self.die_config.images[die.number]))
    self.die:set_image_data(assets:get_image_data(self.die_config.images[die.number]))
end
