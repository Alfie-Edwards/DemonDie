require "utils"

Effects = {
    is_flipped_x = false,
    is_flipped_y = false,
    screen_shake = false,
    roll = 0,
    tint = {1, 1, 1, 0},
}
Effects.__index = Effects

function Effects.new()
    local obj = {}
    setmetatable(obj, Effects)
    return obj
end

function Effects:update_roll(angle)
    -- Do not allow roll values which are too large
    angle = clamp(angle, -0.02, 0.02)

    -- Clip low roll values to zero
    if (math.abs(angle) < 0.018) then
        angle = ((angle / 0.018) ^ 9) * 0.018
    end
    if (math.abs(angle) < 0.005) then
        angle = 0
    end

    -- Smooth out roll effects (lerp with prev angle, enforce max decay rate unless sign change)
    local max_decay = lerp(self.roll, 0, 0.2)
    local next_value = lerp(self.roll, angle, 0.8)
    if (next_value * max_decay < 0 or
        math.abs(next_value) > math.abs(max_decay)) then
        self.roll = next_value
    else
        self.roll = max_decay
    end
end

function Effects:reset_roll(angle)
    self.roll = angle
end

function Effects:set_tint(color)
    self.tint = color
end

function Effects:unset_tint()
    set_tint({0, 0, 0, 0})
end

function Effects:set_flipped_x()
    self.is_flipped_x = true
end

function Effects:toggle_flipped_x()
    self.is_flipped_x = not self.is_flipped_x
end

function Effects:unset_flipped_x()
    self.is_flipped_x = false
end

function Effects:set_flipped_y()
    self.is_flipped_y = true
end

function Effects:toggle_flipped_y()
    self.is_flipped_y = not self.is_flipped_y
end

function Effects:unset_flipped_y()
    self.is_flipped_y = false
end

function Effects:set_screen_shake()
    self.screen_shake = true
end

function Effects:unset_screen_shake()
    self.screen_shake = false
end

function Effects:get_transform()
    local translate_x = 0
    local translate_y = 0
    local rotate_angle = 0
    local scale_x = 1
    local scale_y = 1

    if (self.roll ~= 0) then
        if (current_hud == huds.back_seats) then
            -- Reverse roll when looking backwards
            rotate_angle = rotate_angle - self.roll
        else
            rotate_angle = rotate_angle + self.roll
        end
    end

    if (self.screen_shake) then
        translate_x = translate_x + (math.random() - 0.5) * 1.5
        translate_y = translate_y + (math.random() - 0.5) * 1.5
        rotate_angle = rotate_angle + (math.random() - 0.5) * 0.01
    end

    if (self.is_flipped_x) then
        scale_x = scale_x * -1
    end

    if (self.is_flipped_y) then
        scale_y = scale_y * -1
    end

    -- Apply scale if we are rotating to keep the canvas filling the frame.
    local hyp = math.sqrt(canvas_size[1] ^ 2 + canvas_size[2] ^ 2)
    local theta = math.atan(canvas_size[2] / canvas_size[1])
    local min_scale_x = math.ceil(math.abs(math.cos(theta - math.abs(rotate_angle))) * hyp) / canvas_size[1]
    local min_scale_y = math.ceil(math.abs(math.sin(theta + math.abs(rotate_angle))) * hyp) / canvas_size[2]
    if (scale_x ~= 0 and math.abs(scale_x) < min_scale_x) then
        scale_x = scale_x * (min_scale_x / math.abs(scale_x))
    end
    if (scale_y ~= 0 and math.abs(scale_y) < min_scale_y) then
        scale_y = scale_y * (min_scale_y / math.abs(scale_y))
    end

    return love.math.newTransform(
        canvas_size[1] / 2 + translate_x,
        canvas_size[2] / 2 + translate_y,
        rotate_angle,
        scale_x,
        scale_y,
        canvas_size[1] / 2,
        canvas_size[2] / 2
    )
end

function Effects:push()
    love.graphics.push()
    love.graphics.applyTransform(self:get_transform())
end

function Effects:pop()
    local prev_blend_mode = love.graphics.getBlendMode()
    local prev_r, prev_g, prev_b, prev_a = love.graphics.getColor()

    love.graphics.setBlendMode("add", "alphamultiply")
    love.graphics.setColor(self.tint[1], self.tint[2], self.tint[3], self.tint[4])
    love.graphics.rectangle("fill", 0, 0, canvas_size[1], canvas_size[2])

    love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)
    love.graphics.setBlendMode(prev_blend_mode)
    love.graphics.pop()
end