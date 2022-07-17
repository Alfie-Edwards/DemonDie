require "drive"

Die = {
    number = 1,
    difficulty = 0,
    max_difficulty = 3,
    base_seconds_per_level = 30,

    starting_number_order = { },
    idx = 1
}
Die.__index = Die

function Die.new()
    local obj = {}
    setmetatable(obj, Die)

    local first_three = { 1, 2, 3 }
    shuffle_list(first_three)
    local second_three = { 4, 5, 6 }
    shuffle_list(second_three)

    obj.starting_number_order = concat(first_three, second_three)
    obj.number = obj.starting_number_order[1]
    print('generated starting list:')
    for i=1,#obj.starting_number_order do
        print('* ', obj.starting_number_order[i])
    end
    print('starting die off on ', obj.number)

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
        difficulty_multiplier = difficulty_multiplier / 2
    end

    function is_honking()
        return car.last_horn < 3
    end
    function is_going_fast()
        return car.speed > 13
    end
    function is_hot()
        return car.temperature > 30
    end
    function is_cold()
        return car.temperature < 10
    end

    if (self.number == 1) then
        -- likes loud noises
        if car.radio_station == "metal" or is_honking() then
            diff_down()
        end
        -- hates classical
        if car.radio_station == "classical" then
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
        if car.radio_station == "classical" then
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
        if car.radio_station == "classical" then
            diff_up()
        end
    end

    return difficulty_multiplier
end

function Die:do_effect(dt)
    if (self.number == 1) then
        -- heat up
    elseif (self.number == 2) then
        set_icy()
    elseif (self.number == 3) then
        set_dark()
    elseif (self.number == 4) then
        -- obstacles
    elseif (self.number == 5) then
        -- nudge controls
    elseif (self.number == 6) then
        -- view effects
    end
end

function Die:remove_effect(dt)
    if (self.number == 1) then
    elseif (self.number == 2) then
        unset_icy()
    elseif (self.number == 3) then
        unset_dark()
    elseif (self.number == 4) then
    elseif (self.number == 5) then
    elseif (self.number == 6) then
    end
end

function Die:update(dt, car)
    local difficulty_multiplier = self:get_difficulty_multiplier(car)
    self.difficulty = self.difficulty + (dt * difficulty_multiplier / self.base_seconds_per_level)
    self:do_effect(dt)
end

function Die:reroll(dt)
    self:remove_effect(dt)

    self.idx = self.idx + 1

    if self.idx <= 6 then
        self.number = self.starting_number_order[self.idx]
    else
        self.number = math.random(1, 6)
    end

    print('rerolled die -- number is now ', self.number)
    -- new effect will be done on next update
end