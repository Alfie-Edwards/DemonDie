require "utils"
require "hud"
require "exorcism"
require "die"
require "car"
require "page"

require "drive"

function set_hud(name)
    current_hud = huds[name]
end

function create_huds()
    local huds = {}

    huds.cab = Hud.new()
    huds.cab:add_draw_func(
        function()
            love.graphics.draw(images.cab)
            love.graphics.draw(images.book, 160, 137)

            love.graphics.push()
            rotate_about(
                car:steering_amount() / car.max_turn_rate,
                60 + images.wheel:getWidth() / 2,
                90 + images.wheel:getHeight() / 2
            )
            love.graphics.draw(images.wheel, 60, 90)
            love.graphics.pop()

            love.graphics.draw(images.eye, 240, 11)
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
        end
    )
    huds.back_seats:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(22, 11, 80, 33),
            function() set_hud("cab") end
        )
    )

    for i = 1,6,1 do
        local page = Hud.new()
        init_page(page, i)
        huds[page_name(i)] = page
    end
    local page_ex = Hud.new()
    init_page(page_ex, 7)
    set_page_exorcism(page_ex, "right")
    huds[page_name(7)] = page_ex

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

    -- Create state
    die = Die.new()
    car = Car.new()

    -- Create road
    drive_load(car)

    set_hud("cab")
    current_exorcism = nil
end

function love.mousepressed(x, y, button)
   canvas_x, canvas_y = screen_to_canvas(x, y)
   current_hud:click(canvas_x, canvas_y, button)
end

function love.keypressed(key, scancode, isrepeat)
   current_hud:keypressed(key)
end

function love.update(dt)
    drive_update(dt)
    current_hud:update(dt)
    car:update(dt)
    die:update(dt, car)
end

function draw_canvas()
    local x_offset, y_offset, scale = canvas_position()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, x_offset, y_offset, 0, scale, scale)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0)

    local road_transform = love.math.newTransform()
    road_transform:translate(0, -25)
    love.graphics.replaceTransform(road_transform)
    drive_draw()
    love.graphics.origin()

    current_hud:draw()
    draw_canvas()
end
