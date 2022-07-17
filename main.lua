require "utils"
require "hud"
require "exorcism"
require "die"
require "car"
require "page"
require "bar"
require "drive"
require "deathscreen"
require "startscreen"

function set_hud(name)
    current_hud = huds[name]
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

function create_huds()
    local huds = {}

    huds.cab = Hud.new()
    huds.cab:add_draw_func(
        function()
            love.graphics.draw(images.cab)
            love.graphics.draw(images.book, 160, 137)
            draw_wheel()
            love.graphics.draw(images.eye, 240, 11)
            health_bar:draw()
        end
    )
    huds.cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(240, 11, 298, 33),
            function()
                set_hud("back_seats")
            end
        )
    )
    huds.cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(162, 140, 215, 180),
            function() set_hud(last_book_page) end
        )
    )

    huds.back_seats = Hud.new()
    huds.back_seats:add_draw_func(
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
    huds.back_seats:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(22, 11, 80, 33),
            function() set_hud("cab") end
        )
    )

    book_text = {
        {
            "\n\nI: I ",
            "\n\nII: "
        },
        {
            "\n\nIII: ",
            "\n\nIV: "
        },
        {
            "\n\nV: ",
            "\n\nVI: "
        },
    }
    local page_int = Hud.new()
    init_page(page_int, 1)
    set_page_text(
        page_int,
        "left",
        "\n\n  GRIMOIRE OF THE\n     DEMON DIE\n\nDemon Dice can be extrmely dangerous, and must handled properly.The most important rule is to never let them out of your sight.\n\nDemon Dice, must have their power regularly sealed using incantations.")
    set_page_text(
        page_int,
        "right",
        "The section at the back of this book will guide you through the incantation process.\nAn uncomfortable Die will need its power sealing more often. Demon Dice take on different characters (faces), with different needs, depending on their orientation. These are detailed in this book.")
    huds[page_name(1)] = page_int

    for i = 1,3,1 do
        local page = Hud.new()
        local page_num = i + 1
        init_page(page, page_num)
        huds[page_name(page_num)] = page
        set_page_text(page, "left", book_text[i][1])
        set_page_text(page, "right", book_text[i][2])
    end

    local page_ex = Hud.new()
    init_page(page_ex, 5)
    set_page_exorcism(page_ex, "right")
    huds[page_name(5)] = page_ex

    return huds
end

function love.load()
    math.randomseed(os.time())

    -- Setup rendering
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    font = love.graphics.newFont("assets/font.ttf", 5, "none")
    font:setFilter("nearest", "nearest", 5)
    love.graphics.setFont(font)
    love.graphics.setLineStyle("rough")
    canvas_size = {320, 180}
    canvas = love.graphics.newCanvas(canvas_size[1], canvas_size[2])

    -- Load assets
    images = {
        cab = love.graphics.newImage("assets/cab.png"),
        eye = love.graphics.newImage("assets/eye.png"),
        back_seats = love.graphics.newImage("assets/back_seats.png"),
        book_open = love.graphics.newImage("assets/book_open.png"),
        book = love.graphics.newImage("assets/book.png"),
        page_arrow = love.graphics.newImage("assets/page_arrow.png"),
        begin_ritual = love.graphics.newImage("assets/begin_ritual.png"),
        wheel = love.graphics.newImage("assets/wheel.png"),
        die = {
            love.graphics.newImage("assets/die_I.png"),
            love.graphics.newImage("assets/die_II.png"),
            love.graphics.newImage("assets/die_III.png"),
            love.graphics.newImage("assets/die_IV.png"),
            love.graphics.newImage("assets/die_V.png"),
            love.graphics.newImage("assets/die_VI.png"),
        }
    }
    die_positions = {
        {20, 90},
        {210, 90},
        {250, 90},
        {100, 90},
        {60, 90},
        {180, 90},
    }

    -- Create huds
    last_book_page = "book_page_1"
    huds = create_huds()

    is_flipped = false
    death_screen = nil
    start_screen = StartScreen:new()

    -- Create state
    car = Car.new()
    drive_load(car)
    die = Die.new()

    health_bar = Bar.new("health", 100, {0.28, 0.57, 0.5}, {0.14, 0.4, 0.34}, {0.96, 0.95, 0.82}, {0, 0, 0})
    die_bars = {
        Bar.new("demonic presence (lvl I)", 1, {0.48, 0.09, 0.09}, {0.28, 0.07, 0.07}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl II)", 1, {0.58, 0.10, 0.10}, {0.38, 0.08, 0.08}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl III)", 1, {0.68, 0.11, 0.11}, {0.48, 0.09, 0.09}, {1, 0.3, 0}, {1, 1, 1}),
    }

    set_hud("cab")
    current_exorcism = nil
end

function set_flipped()
    is_flipped = true
end

function unset_flipped()
    is_flipped = false
end

function love.mousepressed(x, y, button)
    if is_flipped then
        x = love.graphics.getWidth() - x
    end

    canvas_x, canvas_y = screen_to_canvas(x, y)
    current_hud:click(canvas_x, canvas_y, button)
end

function love.keypressed(key, scancode, isrepeat)
   current_hud:keypressed(key)
end

function love.update(dt)
    if start_screen ~= nil then
        if love.keyboard.isDown("space") then
            start_screen = nil
        end
    elseif death_screen ~= nil then
        return
    end

    drive_update(dt)
    health_bar:set(car.health)
    die_bars[1]:set(die.difficulty)
    die_bars[2]:set(die.difficulty - 1)
    die_bars[3]:set(die.difficulty - 2)
    if (die.difficulty == die.max_difficulty) then
        die_bars[3].name = "demonic presence (lvl ?????????????????)"
    else
        die_bars[3].name = "demonic presence (lvl III)"
    end
    current_hud:update(dt)
    car:update(dt)
    die:update(dt, car)

    if car.health <= 0 and death_screen == nil then
        death_screen = DeathScreen:new(car.died_from, car.d)
    end
end

function draw_canvas()
    love.graphics.push()
    love.graphics.origin()

    local x_offset, y_offset, scale = canvas_position()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, x_offset, y_offset, 0, scale, scale)

    love.graphics.pop()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0)

    if start_screen ~= nil then
        start_screen:draw()
    elseif death_screen ~= nil then
        death_screen:draw()
    else
        if is_flipped then
            love.graphics.push()
            love.graphics.scale(-1, 1)
            love.graphics.translate(-canvas_w, 0)
        end

        love.graphics.push()
        love.graphics.translate(0, -25)
        drive_draw()
        love.graphics.pop()

        current_hud:draw()

        if is_flipped then
            love.graphics.pop()
        end

    end

    draw_canvas()
end
