require "utils"
require "asset_cache"
require "effects"
require "die"
require "car"
require "drive"
require "ui.view"
require "ui_custom.back_seats"
require "ui_custom.cab"
require "ui_custom.start_screen"
require "ui_custom.death_screen"
require "radio"

function set_screen(name)
    print("set view to "..name.." ("..tostring(screens[name])..")")
    view:set_content(screens[name])
end

function is_screen(name)
    return (screens[name] ~= nil) and (view:get_content() == screens[name])
end

function show_death_screen(cause, score)
    screens.death_screen = DeathScreen.new(cause, score)
    set_screen("death_screen")
end

function create_screens()
    return {
        cab = Cab.new(),
        back_seats = BackSeats.new(),
        start_screen = StartScreen.new(),
        death_screen = nil,
    }
end

function love.load()
    math.randomseed(os.time())

    -- Setup rendering
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    font = love.graphics.newFont("assets/font.ttf", 5, "none")
    love.graphics.setFont(font)
    love.graphics.setLineStyle("rough")
    canvas_size = {320, 180}
    canvas = love.graphics.newCanvas(canvas_size[1], canvas_size[2])

    -- Load assets
    assets = AssetCache.new()

    -- Create screens
    view = View.new()
    screens = create_screens()
    set_screen("start_screen")

    -- Create state
    effects = Effects.new()
    car = Car.new()
    drive_load(car)
    die = Die.new()

    radio = Radio.new(car)

    health_bar = Bar.new("health", 100, {0.28, 0.57, 0.5}, {0.14, 0.4, 0.34}, {0.37, 0.69, 0.61}, {1, 1, 1})
    die_bars = {
        Bar.new("demonic presence (lvl I)", 1, {0.48, 0.09, 0.09}, {0.28, 0.07, 0.07}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl II)", 1, {0.58, 0.10, 0.10}, {0.38, 0.08, 0.08}, {1, 0.3, 0}, {1, 1, 1}),
        Bar.new("demonic presence (lvl III)", 1, {0.68, 0.11, 0.11}, {0.48, 0.09, 0.09}, {1, 0.3, 0}, {1, 1, 1}),
    }
end

function love.mousemoved(x, y, dx, dy, istouch)
    local canvas_x, canvas_y = screen_to_canvas(x, y)
    view:mousemoved(canvas_x, canvas_y, dx, dy)
end

function love.mousepressed(x, y, button)
    local canvas_x, canvas_y = screen_to_canvas(x, y)
    view:click(canvas_x, canvas_y, button)
end

function love.keypressed(key, scancode, isrepeat)
   view:keypressed(key)
end

function love.update(dt)
    -- Pause at start screen
    view:update(dt)
    if is_screen("start_screen") or
       is_screen("death_screen") then
        return
    end

    drive_update(dt)
    car:update(dt)
    die:update(dt, car)
    radio:update(car)

    if car.health <= 0 then
        show_death_screen(car.died_from, car.d)
    end

    -- Update effects

    local roll = (car:steering_amount() - car.steer_amount_prev) * car.speed ^ 2 * 0.0007
    car.steer_amount_prev = car:steering_amount()
    effects:update_roll(roll, dt)
    if (is_offroad()) then
        effects:set_screen_shake()
    else
        effects:unset_screen_shake()
    end

    -- Begin tinting the screen withing 10 degrees of dangerous temps
    -- Screen is fully tinted at 50 degrees past dangerous (60 - 10)
    local cold_opacity = clamp((car.safe_temperatures[1] + 10 - car.temperature) / 60, 0, 1)
    local hot_opacity = clamp((car.temperature - car.safe_temperatures[2] + 10) / 60, 0, 1)
    if (cold_opacity > 0) then
        effects:set_tint({0, 1, 1, cold_opacity})
    elseif (hot_opacity > 0) then
        effects:set_tint({1, 0, 0, hot_opacity})
    end
end

function draw_canvas()
    love.graphics.push()
    love.graphics.origin()

    local x_offset, y_offset, scale = canvas_position()
    love.graphics.setCanvas()
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.draw(canvas, x_offset, y_offset, 0, scale, scale)

    love.graphics.pop()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0)

    if is_screen("start_screen") or
       is_screen("death_screen") then
        view:draw()
    else
        effects:push()

        love.graphics.push()
        love.graphics.translate(0, -25)
        drive_draw()
        love.graphics.pop()

        view:draw()

        effects:pop()
    end

    draw_canvas()
end
