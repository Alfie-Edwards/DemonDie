require "utils"
require "exorcism"
require "die"
require "car"
require "bar"
require "drive"
require "hud"
require "huds/back_seats"
require "huds/cab"
require "huds/page"
require "huds/start_screen"
require "huds/death_screen"

print("test")

function set_hud(name)
    print("set hud to "..name.." ("..tostring(huds[name])..")")
    current_hud = huds[name]
end

function set_hud_to_death_screen(cause, score)
    huds.death_screen = create_death_screen(cause, score)
    set_hud("death_screen")
end

function set_hud_to_last_book_page()
    set_hud(last_book_page)
end

function create_huds()
    local huds = {}

    huds.cab = create_cab()
    huds.back_seats = create_back_seats()
    huds.start_screen = create_start_screen()
    huds.death_screen = nil

    for number = 1,num_pages,1 do
        huds[page_name(number)] = create_page(number)
    end

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
    set_hud("start_screen")

    is_flipped = false

    -- Create state
    car = Car.new()
    drive_load(car)
    die = Die.new()

    health_bar = Bar.new("health", 100, {0.28, 0.57, 0.5}, {0.14, 0.4, 0.34}, {0.37, 0.69, 0.61}, {1, 1, 1})
    die_bars = {
        Bar.new("demonic presence (lvl I)", 1, {0.48, 0.09, 0.09}, {0.28, 0.07, 0.07}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl II)", 1, {0.58, 0.10, 0.10}, {0.38, 0.08, 0.08}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl III)", 1, {0.68, 0.11, 0.11}, {0.48, 0.09, 0.09}, {1, 0.3, 0}, {1, 1, 1}),
    }

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

    local canvas_x, canvas_y = screen_to_canvas(x, y)
    current_hud:click(canvas_x, canvas_y, button)
end

function love.keypressed(key, scancode, isrepeat)
   current_hud:keypressed(key)
end

function love.update(dt)
    -- Pause at start screen
    if (current_hud == huds.start_screen or
        current_hud == huds.death_screen) then
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

    if car.health <= 0 and current_hud ~= huds.death_screen then
        set_hud_to_death_screen(car.died_from, car.d)
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
