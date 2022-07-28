require "utils"
require "drive"

Die = {
    number = 1,
    difficulty = 0,
    max_difficulty = 3,
    base_seconds_per_level = 8,
    seconds_since_last_flip = 0,

    starting_number_order = { },
    idx = 0
}
setup_class("Die")

function Die.new()
    local obj = {}
    setup_instance(obj, Die)

    local first_three = { 1, 2, 3 }
    shuffle_list(first_three)
    local second_three = { 4, 5, 6 }
    shuffle_list(second_three)

    obj.starting_number_order = concat(first_three, second_three)
    obj:reroll()

    return obj
end

function Die:reset_difficulty()
    self.difficulty = 0
end

function Die:get_difficulty_multiplier(car)
    local difficulty_multiplier = 1

    function diff_up()
        difficulty_multiplier = difficulty_multiplier * 2
    end
    function diff_down()
        difficulty_multiplier = difficulty_multiplier / 1.5
    end

    function is_honking()
        return car.last_horn < 3
    end
    function is_going_fast()
        return car.speed > 10
    end
    function is_hot()
        return car.temperature > 30
    end
    function is_cold()
        return car.temperature < 5
    end

    if (self.number == 1) then
        -- likes loud noises
        if car.radio_station == "metal" or is_honking() then
            diff_down()
        end
        -- hates classical
        if car.radio_station == "classic" then
            diff_up()
        end
    elseif (self.number == 2) then
        -- likes silence
        if car.radio_station == "off" and not is_honking() then
            diff_down()
        end
        -- hates speed
        if is_going_fast() then
            diff_up()
        end
    elseif (self.number == 3) then
        -- likes classical
        if car.radio_station == "classic" then
            diff_down()
        end
        -- hates extreme temperatures
        if is_hot() or is_cold() then
            diff_up()
        end
    elseif (self.number == 4) then
        -- likes speed
        if is_going_fast() then
            diff_down()
        end
        -- hates country
        if car.radio_station == "country" then
            diff_up()
        end
    elseif (self.number == 5) then
        -- likes cold
        if is_cold() then
            diff_down()
        end
        -- hates loud noises
        if car.radio_station == "metal" or is_honking() then
            diff_up()
        end
    elseif (self.number == 6) then
        -- likes jazz
        if car.radio_station == "jazz" then
            diff_down()
        end
        -- hates classical
        if car.radio_station == "classic" then
            diff_up()
        end
    end

    return difficulty_multiplier
end

function Die:apply_effect(dt)
    -- Difficulty has 4 stages (0->1, 1->2, 2->3, and 3)
    local diff_ratio = math.floor(self.difficulty) / self.max_difficulty;

    if (self.number == 1) then
        -- heat up
        car.heatup_factor = 2.5 * diff_ratio
    elseif (self.number == 2) then
        -- icy road
        car.heatup_factor = -0.5 * diff_ratio
        set_icy(diff_ratio)
    elseif (self.number == 3) then
        -- darkness
        set_dark(diff_ratio)
    elseif (self.number == 4) then
        -- obstacles
        set_demonic_obstacles(diff_ratio)
    elseif (self.number == 5) then
        -- nudge controls
        set_nudging(diff_ratio)
    elseif (self.number == 6) then
        -- flipped view
        if (self.seconds_since_last_flip > 3) then
            local flip_chance = 0.5 * diff_ratio * dt

            if (diff_ratio == 1) then
                if (math.random() < flip_chance) then
                    effects:toggle_flipped_y()
                    self.seconds_since_last_flip = 0
                end
            end

            if (math.random() < flip_chance) then
                effects:toggle_flipped_x()
                self.seconds_since_last_flip = 0
            end
        end
    end
end

function Die:remove_effect(dt)
    if (self.number == 1) then
        car.heatup_factor = 0
    elseif (self.number == 2) then
        car.heatup_factor = 0
        unset_icy()
    elseif (self.number == 3) then
        unset_dark()
    elseif (self.number == 4) then
        unset_demonic_obstacles()
    elseif (self.number == 5) then
        unset_nudging()
    elseif (self.number == 6) then
        effects:unset_flipped_x()
        effects:unset_flipped_y()
    end
end

function Die:update(dt, car)
    self.seconds_since_last_flip = self.seconds_since_last_flip + dt
    local difficulty_multiplier = self:get_difficulty_multiplier(car)

    -- Lvl 0->1 takes n seconds, 1->2 takes 1.5n seconds, 2->3 takes 2n seconds.
    local seconds_multiplier = 1 + math.floor(self.difficulty) * 0.5
    local seconds_per_level = self.base_seconds_per_level * seconds_multiplier

    self.difficulty = math.min(self.max_difficulty, self.difficulty + (dt * difficulty_multiplier / seconds_per_level))
    self:apply_effect(dt)
end

function Die:reroll(dt)
    if dt == nil then
        dt = 0
    end

    self:remove_effect(dt)

    self.idx = self.idx + 1

    if self.idx <= 6 then
        self.number = self.starting_number_order[self.idx]
    else
        self.number = math.random(1, 6)
    end

    if (current_hud == huds.back_seats) then
        set_hud("cab")
    end

    self:apply_effect(dt)
end