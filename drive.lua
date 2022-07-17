--- equiv of basic love functions ---

function drive_load()
    -- car config --
    start_speed = 10         -- default car speed
    max_speed = 1000         -- max car speed
    accel = 1.5              -- acceleration
    steering = 7             -- steering speed
    max_turn_rate = 3        -- maximum rate of turn
    terrain_damage = 10      -- how much damage terrain does
    default_steering_friction = 2  -- how much steering amount want to return to 0

    -- road generation config --
    road_width = 2           -- (is actually half road width, in world coords -1 -> 1)
    farplane = 50
    nearplane = 0.3

    floor_y = -1

    waypoint_range = 10
    max_waypoint_deviation = 3  -- how far apart in x can two waypoints be? (just a clamp)
    waypoint_wobbliness = 3
    distance_between_waypoints = 50

    -- obstacle generation config --
    min_distance_between_obstacles = 10
    max_distance_between_obstacles = 25
    obstacle_range = 10  -- around the current car x-coord at time of creation
    obstacle_types = {
        rock = { img = love.graphics.newImage("assets/rock.png"),
                 width = 500,
                 height = 500,
                 dmg = 10 }
    }

    obstacle_asset_names = {}
    for k, _ in pairs(obstacle_types) do
        table.insert(obstacle_asset_names, k)
    end

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

    horizon = 0 + (love.graphics.getHeight() / 2)  -- just used for adding sky & fog

    default_fog_height = 100
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
    prev_road_t = 0          -- when did we last make a new road segment?
    road_colours = default_road_colours

    current_waypoint = nil
    prev_waypoint_x = 0
    prev_waypoint_z = 0

    -- obstacle generation state --
    obstacles = { }
    d_at_previous_obstacle = 0
    dist_until_next_obstacle = nil

    -- visuals state --
    fog_height = default_fog_height

    -- effects state --
    is_icy = false
    icy_timeout = 0
    is_darkness = false
    darkness_timeout = 0

    -- other state --
    t = 0                    -- time since start
    d = 0                    -- distance travelled since start

    -- run init code --
    init_road()
end

function drive_draw()
    -- bg
    love.graphics.setBackgroundColor(background_colour)

    -- road
    draw_road()

    -- sky background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), horizon)

    -- fog edge
    local scale_factor = fog_height / fog_img:getHeight()
    love.graphics.draw(fog_img, fog_quad, 0, horizon, 0, 1, scale_factor)

    -- obstacles
    draw_obstacles()
end

function drive_update(dt)
    if dbg then print('--- update ---') end

    t = t + dt
    d = d + (speed * dt)

    accelerate(dt)
    steer(dt)
    move(dt)

    set_icy(dt)
    set_darkness(dt)

    get_hurt(dt)

    update_waypoint()
    make_road(dt)

    update_obstacles()

    if dbg then print() end
end

--- other stuff ---
function randfloat(low, high)
    return (math.random() * (high - low)) + low
end

function ob_type(i)
    return obstacle_types[obstacles[i].kind]
end

function accelerate(dt)
    if love.keyboard.isDown("up") then
        speed = math.min(speed + accel * dt, max_speed)
    elseif love.keyboard.isDown("down") then
        speed = math.max(speed - accel * dt, 0)
    end
end

function steer(dt)
    -- if we're going too slow, we can't steer well
    local speed_multiplier = 1
    local speed_multiplier_threshold = start_speed / 2
    if speed < speed_multiplier_threshold then
        speed_multiplier = (speed / speed_multiplier_threshold) * steering
    end

    -- set the current steering speed
    if love.keyboard.isDown("left") then
        steer_speed = math.max(steer_speed - steering * dt * speed_multiplier, -max_turn_rate)
    elseif love.keyboard.isDown("right") then
        steer_speed = math.min(steer_speed + steering * dt * speed_multiplier, max_turn_rate)
    end

    -- apply friction to the steering speed
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

    for i=#obstacles,1,-1 do
        obstacles[i].z = obstacles[i].z - (speed * dt)
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
    if #road > 0 and math.abs(car_x - road[1].x) > 1 then
        if dbg then print('off the road!') end
        health = health - terrain_damage * dt
    end

    for i=1,#obstacles do
        if math.abs(car_x - obstacles[i].x) < 1.0 and
            math.abs(obstacles[i].z - nearplane) < 0.2 then
            health = health - ob_type(i).dmg
            if dbg then print('ouch! -- hit a ', obstacles[i].kind) end
            obstacles[i].z = nearplane - 10 -- move away
            speed = 0
        end
    end

    if health <= 0 then
        if dbg then print('YOU DEAD') end
    end
end

function update_waypoint()
    if current_waypoint == nil then
        prev_waypoint_x = 0
        current_waypoint = 0
        prev_waypoint_z = d
    elseif (d - prev_waypoint_z) > distance_between_waypoints then
        local temp_prev_wpt = current_waypoint or 0

        current_waypoint = temp_prev_wpt + randfloat(-waypoint_wobbliness,
                                                     waypoint_wobbliness)

        prev_waypoint_z = d
        prev_waypoint_x = temp_prev_wpt
    end
end

function get_segment_id()
    next_segment_id = next_segment_id + 1
    return next_segment_id - 1
end

function ease_lerp(fraction)
    return fraction
end

function ease_cubic(fraction)
    if fraction < 0.5 then
        return 4 * fraction * fraction * fraction
    else
        return 1 - math.pow(-2 * fraction + 2, 3) / 2
    end
end

function ease_quad(fraction)
    if fraction < 0.5 then
        return 2 * fraction * fraction
    else
        return 1 - math.pow(-2 * fraction + 2, 2) / 2
    end
end

function make_segment_waypoints(desired_z)
    local desired_z = desired_z or farplane

    if current_waypoint == nil then
        update_waypoint()
    end

    -- interpolate with an easing function to the next waypoint
    local fraction_z_distance_moved = (d - prev_waypoint_z) / distance_between_waypoints
    local progress = ease_quad(fraction_z_distance_moved)
    local total_x_distance_between_waypoints = current_waypoint - prev_waypoint_x
    local adjustment = total_x_distance_between_waypoints * progress
    local desired_x = prev_waypoint_x + adjustment

    return { x = desired_x, y = floor_y, z = desired_z, id = get_segment_id() }
end

function make_segment_wobble(desired_z)
    -- 'globals'
    wobble_accel = 0
    wobbliness = 0.3

    local desired_z = desired_z or farplane

    local current_x = 0
    if #road > 0 then
        current_x = road[#road].x
    end

    wobbliness = wobbliness + randfloat(-wobble_accel, wobble_accel)
    local desired_x = current_x + randfloat(-wobbliness, wobbliness)

    return { x = desired_x, y = floor_y, z = desired_z, id = get_segment_id() }
end

function make_segment_straight(desired_z)
    local desired_x = 0

    local desired_z = desired_z or farplane

    return { x = desired_x, y = floor_y, z = desired_z, id = get_segment_id() }
end

function make_segment(desired_z)
    return make_segment_waypoints(desired_z)
end

function make_road(dt)
    if speed > 0 and t - prev_road_t <= (1 / speed) then
        return
    end
    prev_road_t = t

    table.insert(road, make_segment())
end

function init_road()
    for i=1,farplane do
        table.insert(road, make_segment(i))
    end
end

function world2screen_x(x_world)
    return (x_world + 1)  * love.graphics.getWidth() / 2
end

function world2screen_y(y_world)
    return (2 - (y_world + 1)) * love.graphics.getHeight() / 2
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
        local curr_left_world  = ((curr_x - car_x) - road_width) * curr_scale_factor
        local curr_right_world = ((curr_x - car_x) + road_width) * curr_scale_factor
        local next_left_world  = ((next_x - car_x) - road_width) * next_scale_factor
        local next_right_world = ((next_x - car_x) + road_width) * next_scale_factor

        local curr_y_world = curr_y * curr_scale_factor
        local next_y_world = next_y * next_scale_factor

        -- turn world-space into screen-space
        local curr_left_screen =  world2screen_x(curr_left_world)
        local curr_right_screen = world2screen_x(curr_right_world)
        local next_left_screen =  world2screen_x(next_left_world)
        local next_right_screen = world2screen_x(next_right_world)

        local curr_y_screen = world2screen_y(curr_y_world)
        local next_y_screen = world2screen_y(next_y_world)

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

function draw_road_dots()
    for i=1, #road - 1 do
        local col = road_colours[(road[i].id % 2) + 1]
        love.graphics.setColor(col.r, col.g, col.b)

        local curr_x = road[i].x
        local curr_z = road[i].z

        curr_z = curr_z / farplane

        local curr_x_screen = world2screen_x(curr_x)
        local curr_z_screen = world2screen_y(curr_z)

        love.graphics.circle("fill", curr_x_screen, curr_z_screen, 10)
    end
end

function generate_obstacle_kind()
    return obstacle_asset_names[math.random(1,#obstacle_asset_names)]
end

function make_obstacle(desired_z)
    local desired_z = desired_z or farplane

    local desired_x = randfloat(-obstacle_range, obstacle_range)
    desired_x = desired_x - car_x

    return { x = desired_x, y = floor_y, z = desired_z, kind = generate_obstacle_kind() }
end

function update_obstacles()
    -- maybe make new obstacles
    if dist_until_next_obstacle == nil then
        dist_until_next_obstacle = randfloat(min_distance_between_obstacles,
                                             max_distance_between_obstacles)
    end
    if (d - d_at_previous_obstacle) > dist_until_next_obstacle then
        dist_until_next_obstacle = randfloat(min_distance_between_obstacles,
                                             max_distance_between_obstacles)

        d_at_previous_obstacle = d
        ob = make_obstacle()
        table.insert(obstacles, ob)
    end

    -- maybe remove old obstacles
    for i=#obstacles,1,-1 do
        if obstacles[i].z < nearplane then
            table.remove(obstacles, i)
        end
    end
end

function draw_obstacles()
    for i=#obstacles,1,-1 do -- iterate backwards for painter's algorithm
        if obstacles[i].z <= nearplane then
            goto continue
        end
        local scaling_factor = nearplane / obstacles[i].z

        -- apply scaling factor to get perspective-corrected x & y coords in world-space
        -- (ie. [-1, 1])
        local x_world  = (obstacles[i].x - car_x) * scaling_factor
        local y_world = obstacles[i].y * scaling_factor

        -- turn world-space into screen-space
        local w_screen = scaling_factor * ob_type(i).width
        local h_screen = scaling_factor * ob_type(i).height

        local x_screen = world2screen_x(x_world) - w_screen / 2
        local y_screen = world2screen_y(y_world) - h_screen

        love.graphics.setColor(1, 0, 1)
        local img = ob_type(i).img
        love.graphics.draw(img,
                           x_screen, y_screen,
                           0,
                           w_screen / img:getWidth(),
                           h_screen / img:getHeight())
        ::continue::
    end
end