--- equiv of basic love functions ---

function drive_load()
    -- car config --
    start_speed = 1          -- default car speed
    max_speed = 1000         -- max car speed
    accel = 1.5              -- acceleration
    steering = 4             -- steering speed
    max_turn_rate = 3        -- maximum rate of turn
    terrain_damage = 10      -- how much damage terrain does
    default_steering_friction = 2  -- how much steering amount want to return to 0

    -- road generation config --
    road_width = 1           -- (is actually half road width, in world coords -1 -> 1)
    -- wobble_accel = 0.1
    wobbliness = 0.1
    farplane = 20
    nearplane = 1

    -- visuals config --
    background_colour = { 0.91, 0.78, 0.47 }

    default_road_colours = {
        { r = 0.3, g = 0.3, b = 0.3 },
        { r = 0.6, g = 0.6, b = 0.6 },
    }

    icy_road_colours = {
        { r = 0.57, g = 0.85, b = 0.90 },
        { r = 0.67, g = 0.90, b = 0.91 },
    }

    horizon = 10 + (love.graphics.getHeight() / 2)  -- just used for adding sky & fog

    default_fog_height = 200
    fog_img = love.graphics.newImage('assets/fog fade.png')
    fog_img:setWrap('repeat', 'clamp')
    fog_quad = love.graphics.newQuad(
        0, 0,
        love.graphics.getWidth(), fog_img:getHeight(),
        fog_img:getWidth(), fog_img:getHeight()
    )

    -- effects config --
    icy_timeout_duration = 0.2
    darkness_timeout_duration = 0.2

    darkness_fog_height = 750

    -- other config --
    dbg = false

    -- car state --
    speed = start_speed
    car_x = 0
    steer_speed = 0
    health = 100
    steering_friction = default_steering_friction

    -- road generation state --
    road = { }
    next_segment_id = 1      -- id to give to new road segments
    last_road_t = 0          -- when did we last make a new road segment?
    road_colours = default_road_colours

    -- visuals state --
    fog_height = default_fog_height

    -- effects state --
    is_icy = false
    icy_timeout = 0
    is_darkness = false
    darkness_timeout = 0

    -- other state --
    t = 0                    -- time since start

    -- run init code --
    init_road()
end

function drive_draw()
    -- bg
    love.graphics.setBackgroundColor(background_colour)

    -- road
    local t = get_steer_transform()
    love.graphics.replaceTransform(t)

    draw_road()

    love.graphics.origin()

    -- sky background
    love.graphics.setColor(0, 0, 0)
    -- local fog_border_height = ((2 - (horizon + 1)) * love.graphics.getHeight() / 2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), horizon)

    -- fog edge
    local scale_factor = fog_height / fog_img:getHeight()
    love.graphics.draw(fog_img, fog_quad, 0, horizon, 0, 1, scale_factor)
end

function drive_update(dt)
    if dbg then print('--- update ---') end

    t = t + dt

    accelerate(dt)

    steer(dt)

    move(dt)

    set_icy(dt)

    set_darkness(dt)

    get_hurt(dt)

    make_road(dt)

    if dbg then print() end
end

--- other stuff ---

function accelerate(dt)
    if love.keyboard.isDown("up") then
        speed = math.min(speed + accel * dt, max_speed)
    elseif love.keyboard.isDown("down") then
        speed = math.max(speed - accel * dt, 0)
    end
end

function steer(dt)
    if love.keyboard.isDown("left") then
        steer_speed = math.max(steer_speed + steering * dt, -max_turn_rate)
    elseif love.keyboard.isDown("right") then
        steer_speed = math.min(steer_speed - steering * dt, max_turn_rate)
    end

    if steer_speed > 0 then
        steer_speed = math.max(steer_speed - (steering_friction * dt), 0)
    elseif steer_speed < 0 then
        steer_speed = math.min(steer_speed + (steering_friction * dt), 0)
    end
end

function move(dt)
    -- move forwards, in z (just move road backwards)
    local points_behind_nearplane = 0
    for i=#road,1,-1 do
        road[i].z = road[i].z - (speed * dt)

        if road[i].z <= nearplane then
            points_behind_nearplane = points_behind_nearplane + 1
        end

        if points_behind_nearplane > 2 then
            table.remove(road, i)
        end
    end

    -- move sideways, in x (ie. 'turn')
    car_x = car_x + (steer_speed * dt)
end

function set_icy(dt)
    icy_timeout = icy_timeout - dt

    if not is_icy and icy_timeout < 0 and love.keyboard.isDown("space") then
        is_icy = true
        icy_timeout = icy_timeout_duration
        steering_friction = 0
        road_colours = icy_road_colours
    elseif is_icy and icy_timeout < 0 and love.keyboard.isDown("space") then
        is_icy = false
        icy_timeout = icy_timeout_duration
        steering_friction = default_steering_friction
        road_colours = default_road_colours
    end
end

function set_darkness(dt)
    darkness_timeout = darkness_timeout - dt

    if not is_darkness and darkness_timeout < 0 and love.keyboard.isDown("d") then
        is_darkness = true
        darkness_timeout = darkness_timeout_duration
        fog_height = darkness_fog_height
    elseif is_darkness and darkness_timeout < 0 and love.keyboard.isDown("d") then
        is_darkness = false
        darkness_timeout = darkness_timeout_duration
        fog_height = default_fog_height
    end
end

function get_hurt(dt)
    if math.abs(car_x) > 1 then
        health = health - terrain_damage * dt
    end

    if health <= 0 then
        print('YOU DEAD')
    end
end

function get_segment_id()
    next_segment_id = next_segment_id + 1
    return next_segment_id - 1
end

function make_segment(desired_z)
    -- TODO smart generation
    local desired_z = desired_z or farplane
    local spawn_margin = 0

    local current_x = 0
    if #road > 0 then
        current_x = road[#road].x
    end

    -- wobbliness = wobbliness + (math.random() * 2 * wobble_accel) - wobble_accel
    local desired_x = current_x + (math.random() * 2 * wobbliness) - wobbliness

    return { x = desired_x, y = -1, z = desired_z, id = get_segment_id() }
end

function make_road(dt)
    if speed > 0 and t - last_road_t <= (1 / speed) then
        return
    end
    last_road_t = t

    table.insert(road, make_segment())
end

function init_road()
    for i=1,farplane do
        table.insert(road, make_segment(i))
    end
end

function draw_road()
    for i=1, #road - 1 do
        local col = road_colours[(road[i].id % 2) + 1]
        love.graphics.setColor(col.r, col.g, col.b)

        -- get coords of current & next road segment
        local curr_x = road[i].x
        local curr_y = road[i].y
        local curr_z = road[i].z
        local next_x = road[i + 1].x
        local next_y = road[i + 1].y
        local next_z = road[i + 1].z

        -- clamp to nearplane to prevent rendering errors (they'll get culled later)
        if curr_z < nearplane then
            curr_z = nearplane
        end
        if next_z < nearplane then
            next_z = nearplane
        end

        -- calculate a scaling factor, for basic perspective projection
        local curr_scale_factor = nearplane / curr_z
        local next_scale_factor = nearplane / next_z

        -- apply scaling factor to get perspective-corrected x & y coords in world-space
        -- (ie. [-1, 1])
        local curr_left_screen = curr_x - road_width * curr_scale_factor
        local curr_right_screen = curr_x + road_width * curr_scale_factor
        local next_left_screen = next_x - road_width * next_scale_factor
        local next_right_screen = next_x + road_width * next_scale_factor

        local curr_y_screen = curr_y * curr_scale_factor
        local next_y_screen = next_y * next_scale_factor

        -- turn world-space into screen-space
        curr_left_screen = ((curr_left_screen + 1) * love.graphics.getWidth() / 2)
        curr_right_screen = ((curr_right_screen + 1) * love.graphics.getWidth() / 2)
        next_left_screen = ((next_left_screen + 1) * love.graphics.getWidth() / 2)
        next_right_screen = ((next_right_screen + 1) * love.graphics.getWidth() / 2)

        curr_y_screen = ((2 - (curr_y_screen + 1)) * love.graphics.getHeight() / 2)
        next_y_screen = ((2 - (next_y_screen + 1)) * love.graphics.getHeight() / 2)

        -- draw the quad for this road segment
        vertices = {
            curr_left_screen, curr_y_screen,
            curr_right_screen, curr_y_screen,

            next_right_screen, next_y_screen,
            next_left_screen, next_y_screen
        }

        love.graphics.polygon("fill", vertices)
    end
end

function get_steer_transform()
    local t = love.math.newTransform()

    t:translate(car_x * love.graphics.getWidth() / 2, 0)

    return t
end

