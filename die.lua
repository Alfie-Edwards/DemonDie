Die = {
    number = 1,
    difficulty = 0,
    max_difficulty = 3,
    base_seconds_per_level = 30,
}
Die.__index = Die

function Die.new()
    local obj = {}
    setmetatable(obj, Die)

    return obj
end

function Die:reset_difficulty()
    self.difficulty = 0
end

function Die:get_difficulty_multiplier(car)
    local difficulty_multiplier = 1

    if (number == 1) then
    elseif (number == 2) then
    elseif (number == 3) then
    elseif (number == 4) then
    elseif (number == 5) then
    elseif (number == 6) then
    end

    return difficulty_multiplier
end

function Die:do_effect(dt)
    if (number == 1) then
    elseif (number == 2) then
    elseif (number == 3) then
    elseif (number == 4) then
    elseif (number == 5) then
    elseif (number == 6) then
    end
end

function Die:update(dt, car)
    local difficulty_multiplier = self:get_difficulty_multiplier(car)
    self.difficulty = math.min(self.max_difficulty, self.difficulty + (dt * difficulty_multiplier / self.base_seconds_per_level))
    self:do_effect(dt)
end