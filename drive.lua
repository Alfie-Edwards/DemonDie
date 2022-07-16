--- equiv of basic love functions ---

function drive_load()
    -- car config
    start_speed = 1
    max_speed = 1000

    accel = 1.5

    -- road generation config
    road_width = 1  -- (is actually half road width, in world coords -1 -> 1)

    -- wobble_accel = 0.1
    wobbliness = 0.1

    -- horizon = love.graphics.getHeight() / 2
    farplane = 20
    nearplane = 1

    -- other config
    dbg = false

    -- state
    t = 0  -- time since start

    speed = start_speed

    road = { }

    -- wobbliness = 0

    max_segment_id = 1

    last_road_t = 0

    init_road()
end

function drive_draw()
    draw_road()
end

function drive_update(dt)
    if dbg then print('--- update ---') end

    t = t + dt

    accelerate(dt)

    drive(dt)

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

function drive(dt)
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
end

function next_segment_id()
    max_segment_id = max_segment_id + 1
    return max_segment_id - 1
end

function make_segment_z(desired_z)
    -- TODO smart generation
    local spawn_margin = 0

    local current_x = 0
    if #road > 0 then
        current_x = road[#road].x
    end

    local desired_x = current_x + (math.random() * 2 * wobbliness) - wobbliness

    -- wobbliness = wobbliness + (math.random() * 2 * wobble_accel) - wobble_accel
    -- local desired_x = current_x + (math.random() * 2 * wobbliness) - wobbliness

    return { x = desired_x, y = -1, z = desired_z, id = next_segment_id() }
end

function make_segment()
    return make_segment_z(farplane)
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
        table.insert(road, make_segment_z(i))
    end
end

function draw_road()
    for i=1, #road - 1 do
        local shade = 0.6
        if road[i].id % 2 == 0 then
            shade = 0.3
        end
        love.graphics.setColor(shade, shade, shade)

        local curr_x = road[i].x
        local curr_y = road[i].y
        local curr_z = road[i].z
        local next_x = road[i + 1].x
        local next_y = road[i + 1].y
        local next_z = road[i + 1].z

        if curr_z < nearplane then
            curr_z = nearplane
        end
        if next_z < nearplane then
            next_z = nearplane
        end

        local curr_scale_factor = nearplane / curr_z
        local next_scale_factor = nearplane / next_z

        local curr_y_screen = road[i].y * curr_scale_factor
        local next_y_screen = road[i + 1].y * next_scale_factor

        curr_y_screen = ((2 - (curr_y_screen + 1)) * love.graphics.getHeight() / 2)
        next_y_screen = ((2 - (next_y_screen + 1)) * love.graphics.getHeight() / 2)

        local curr_left_screen = curr_x - road_width * curr_scale_factor
        local curr_right_screen = curr_x + road_width * curr_scale_factor
        local next_left_screen = next_x - road_width * next_scale_factor
        local next_right_screen = next_x + road_width * next_scale_factor

        curr_left_screen = ((curr_left_screen + 1) * love.graphics.getWidth() / 2)
        curr_right_screen = ((curr_right_screen + 1) * love.graphics.getWidth() / 2)
        next_left_screen = ((next_left_screen + 1) * love.graphics.getWidth() / 2)
        next_right_screen = ((next_right_screen + 1) * love.graphics.getWidth() / 2)

        vertices = {
            curr_left_screen, curr_y_screen,
            curr_right_screen, curr_y_screen,

            next_right_screen, next_y_screen,
            next_left_screen, next_y_screen
        }

        love.graphics.polygon("fill", vertices)
    end
end
