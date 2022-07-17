require "utils"
require "hud"

function set_hud(name)
    current_hud = huds[name]
end

function create_huds()
    local huds = {}

    huds.cab = Hud.new()
    huds.cab.draw = function()
        love.graphics.draw(images.cab)
        love.graphics.draw(images.eye, 240, 11)
    end
    huds.cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(240, 11, 298, 33),
            function()
                set_hud("back_seats")
            end))
    huds.cab:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(162, 136, 215, 180),
            function() set_hud(last_book_page) end
        )
    )

    huds.back_seats = Hud.new()
    huds.back_seats.draw = function()
        love.graphics.draw(images.back_seats)
        love.graphics.draw(images.eye, 80, 11, 0, -1, 1)
    end
    huds.back_seats:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(22, 11, 80, 33),
            function()
                set_hud("cab")
            end))

    local n_pages = 5
    for i = 1,n_pages,1 do
        local page = Hud.new()
        page.set_left_text = function(text)
            page.left_text = love.graphics.newText(font, {{0.41, 0.4, 0.39}, wrap_text(text, font, 78)})
        end

        page.draw = function()
            love.graphics.draw(images.cab)
            love.graphics.draw(images.book_open, 72, 36)
            love.graphics.draw(page.left_text, 78, 46)
            if (i ~= 1) then
                love.graphics.draw(images.page_arrow, 90, 151, 0, -1, 1)
            end
            if (i ~= n_pages) then
                love.graphics.draw(images.page_arrow, 229, 151)
            end
        end

        local page_name = "book_page_"..tostring(i)
        page.set_left_text(page_name)
        page.update = function(dt)
            last_book_page = page_name
        end
        if (i ~= 1) then
            page:add_mouse_region(
                MouseRegion.new(
                    BoundingBox.new(79, 151, 90, 158),
                    function() set_hud("book_page_"..tostring(i-1)) end))
        end
        if (i ~= n_pages) then
            page:add_mouse_region(
                MouseRegion.new(
                    BoundingBox.new(229, 151, 241, 158),
                    function() set_hud("book_page_"..tostring(i+1)) end))
        end
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(0, 0, 72, 180),
                function() set_hud("cab") end))
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(248, 0, 360, 180),
                function() set_hud("cab") end))
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(72, 0, 248, 36),
                function() set_hud("cab") end))
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(72, 163, 248, 180),
                function() set_hud("cab") end))
        huds[page_name] = page
    end

    return huds
end

function love.load()
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
    }
    cube = {
        points = {{-0.5, -0.5, -0.5}, {-0.5, -0.5,  0.5}, {-0.5,  0.5,  0.5}, {-0.5,  0.5, -0.5},
                  {-0.5, -0.5, -0.5}, {-0.5,  0.5, -0.5}, { 0.5,  0.5, -0.5}, { 0.5, -0.5, -0.5},
                  {-0.5, -0.5, -0.5}, { 0.5, -0.5, -0.5}, { 0.5, -0.5,  0.5}, {-0.5, -0.5,  0.5},
                  { 0.5,  0.5,  0.5}, { 0.5,  0.5, -0.5}, { 0.5, -0.5, -0.5}, { 0.5, -0.5,  0.5},
                  { 0.5,  0.5,  0.5}, { 0.5, -0.5,  0.5}, {-0.5, -0.5,  0.5}, {-0.5,  0.5,  0.5},
                  { 0.5,  0.5,  0.5}, {-0.5,  0.5,  0.5}, {-0.5,  0.5, -0.5}, { 0.5,  0.5, -0.5}},
        draw_order = { 0,  1,  2,  1,  2,  3,
                       4,  5,  6,  5,  6,  7,
                       8,  9, 10,  9, 10, 11,
                      12, 13, 14, 13, 14, 15,
                      16, 17, 18, 17, 18, 19,
                      20, 21, 22, 22, 23, 24}
    }
    last_book_page = "book_page_1"
    huds = create_huds()

    set_hud("cab")
end

function love.mousepressed(x, y, button)
   canvas_x, canvas_y = screen_to_canvas(x, y)
   current_hud:click(canvas_x, canvas_y, button)
end

function love.update(dt)
    current_hud.update(dt)
end

function draw_canvas()
    local x_offset, y_offset, scale = canvas_position()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, x_offset, y_offset, 0, scale, scale)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0.125, 0.333)
    current_hud.draw()
    draw_canvas()
end
