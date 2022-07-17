--- equiv of basic love functions ---

function drive_load()
    -- car config --
    start_speed = 10         -- default car speed
    max_speed = 1000         -- max car speed
    accel = 1.5              -- acceleration
    steering = 4             -- steering speed
    max_turn_rate = 3        -- maximum rate of turn
    terrain_damage = 10      -- how much damage terrain does
    default_steering_friction = 2  -- how much steering amount want to return to 0

    -- road generation config --
    road_width = 2           -- (is actually half road width, in world coords -1 -> 1)
    farplane = 50
    nearplane = 0.3

    floor_y = -1

    waypoint_range = 10
    distance_between_waypoints = 50

    -- obstacle generation config --
    min_distance_between_obstacles = 5
    max_distance_between_obstacles = 20
    obstacle_range = 0  -- around the current car x-coord at time of creation

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
    prev_obstacle_z = 0
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

    -- obstacles
    draw_obstacles()

    -- sky background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), horizon)

    -- fog edge
    local scale_factor = fog_height / fog_img:getHeight()
    love.graphics.draw(fog_img, fog_quad, 0, horizon, 0, 1, scale_factor)
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
    if #road > 0 and math.abs(car_x - road[1].x) > 0.5 then
        if dbg then print('uh oh') end
        health = health - terrain_damage * dt
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
        prev_waypoint_x = current_waypoint or 0
        -- current_waypoint = (math.random() * 2 * waypoint_range) - waypoint_range
        current_waypoint = randfloat(-waypoint_range, waypoint_range)
        prev_waypoint_z = d
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
        local curr_left_world  = ((car_x + curr_x) - road_width) * curr_scale_factor
        local curr_right_world = ((car_x + curr_x) + road_width) * curr_scale_factor
        local next_left_world  = ((car_x + next_x) - road_width) * next_scale_factor
        local next_right_world = ((car_x + next_x) + road_width) * next_scale_factor

        local curr_y_world = curr_y * curr_scale_factor
        local next_y_world = next_y * next_scale_factor

        -- turn world-space into screen-space
        local curr_left_screen =  (curr_left_world + 1)  * love.graphics.getWidth() / 2
        local curr_right_screen = (curr_right_world + 1) * love.graphics.getWidth() / 2
        local next_left_screen =  (next_left_world + 1)  * love.graphics.getWidth() / 2
        local next_right_screen = (next_right_world + 1) * love.graphics.getWidth() / 2

        local curr_y_screen = (2 - (curr_y_world + 1)) * love.graphics.getHeight() / 2
        local next_y_screen = (2 - (next_y_world + 1)) * love.graphics.getHeight() / 2

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

        local curr_x_screen = (curr_x + 1) * love.graphics.getWidth() / 2
        local curr_z_screen = (2 - (curr_z + 1)) * love.graphics.getHeight() / 2

        love.graphics.circle("fill", curr_x_screen, curr_z_screen, 10)
    end
end

function generate_obstacle_sprite()
    return nil
end

function make_obstacle(desired_z)
    local desired_z = desired_z or farplane

    desired_x = randfloat(-obstacle_range, obstacle_range) + car_x

    print('making an obstacle at ', desired_x, floor_y, desired_z)
    return { x = desired_x, y = floor_y, z = desired_z, spr = generate_obstacle_sprite() }
end

function update_obstacles()
    if dist_until_next_obstacle == nil then
        dist_until_next_obstacle = randfloat(min_distance_between_obstacles,
                                             max_distance_between_obstacles)
    end
    if (d - prev_obstacle_z) > dist_until_next_obstacle then
        dist_until_next_obstacle = randfloat(min_distance_between_obstacles,
                                             max_distance_between_obstacles)

        print('-----')
        print('d - prev_obstacle_z = ', d - prev_obstacle_z, ' which is greater than ', dist_until_next_obstacle)
        ob = make_obstacle()
        prev_obstacle_z = ob.z
        table.insert(obstacles, ob)
    end
end

function draw_obstacles()
    for i=1,#obstacles do
        local true_size = 250

        local scaling_factor = nearplane / obstacles[i].z

        -- apply scaling factor to get perspective-corrected x & y coords in world-space
        -- (ie. [-1, 1])
        local x_world  = (car_x + obstacles[i].x) * scaling_factor

        local y_world = obstacles[i].y * scaling_factor

        -- turn world-space into screen-space
        local x_screen = (x_world + 1)  * love.graphics.getWidth() / 2
        local y_screen = (2 - (y_world + 1)) * love.graphics.getHeight() / 2

        love.graphics.circle("fill", x_screen, y_screen, true_size * scaling_factor)
    end
end
