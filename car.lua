Car = {
    ac_settings = { "off", "cold", "hot" },
    ac = "off",
    ac_power = 1,
    temperature = 20,
    radio_station_index = 1,
    radio_station = nil,
    last_horn = 0,
    last_swerve = 0,
    speed = 0,
    radio_stations = {"off", "classic", "metal", "jazz", "country"},

    heatup_factor = 0,
    temperature_damage = 15,

    died_from = nil,

    -- driving config
    max_speed = 15,
    accel = 1.5,
    steering = 7,                   -- steering speed
    max_turn_rate = 3,
    terrain_damage = 10,            -- how much damage terrain does
    default_steering_friction = 2,  -- how much the steering amount wants to return to 0

    -- driving state
    x = 0,
    steer_speed = 0,                -- amount of steering by user; to include nudges, use `steering_amount()`
    health = 100,
    steering_friction = nil,
    steering_nudge = 0,
    d = 0,  -- total distance moved

}
Car.__index = Car

function Car.new()
    local obj = {}
    setmetatable(obj, Car)
    obj.radio_station = obj.radio_stations[obj.radio_station_index]

    obj.steering_friction = obj.default_steering_friction

    return obj
end

function Car:steering_amount()
    return self.steer_speed + self.steering_nudge
end

function Car:hurt(amount, kind)
    self.health = math.max(self.health - amount, 0)

    if self.health == 0 and self.died_from == nil then
        self.died_from = kind
    end
end

function Car:update(dt)
    self.last_horn = self.last_horn + dt
    self.last_swerve = self.last_swerve + dt

    self:update_temperature(dt)

    if self.temperature > 45 then
        self:hurt(self.temperature_damage * dt, "cook")
    end

    self.d = self.d + (self.speed * dt)

    self:accelerate(dt)
    self:steer(dt)

    -- move sideways, in x (ie. 'turn')
    self.x = self.x + (self:steering_amount() * dt)
end

function Car:update_temperature(dt)
    local change = 0

    if self.ac == "cold" then
        change = -self.ac_power
    elseif self.ac == "hot" then
        change = self.ac_power
    end

    change = (change + self.heatup_factor) * dt

    self.temperature = self.temperature + change

    -- TODO if it gets too hot, you die
end

function Car:toggle_station()
    self.radio_station_index = (self.radio_station_index % #self.radio_stations) + 1
    self.radio_station = self.radio_stations[self.radio_station_index]
end

function Car:beep()
    self.last_horn = 0
end

-- driving
function Car:accelerate(dt)
    if love.keyboard.isDown("up") then
        self.speed = math.min(self.speed + self.accel * dt, self.max_speed)
    elseif love.keyboard.isDown("down") then
        self.speed = math.max(self.speed - self.accel * dt, 0)
    end
end

function Car:steer(dt)
    -- if we're going too slow, we can't steer well
    local speed_multiplier = 1
    local speed_multiplier_threshold = 5
    if self.speed < speed_multiplier_threshold then
        speed_multiplier = (self.speed / speed_multiplier_threshold) * self.steering
    end

    -- set the current steering speed
    if love.keyboard.isDown("left") then
        self.steer_speed = math.max(self.steer_speed - self.steering * dt * speed_multiplier, -self.max_turn_rate)
    elseif love.keyboard.isDown("right") then
        self.steer_speed = math.min(self.steer_speed + self.steering * dt * speed_multiplier, self.max_turn_rate)
    end

    -- apply friction to the steering speed
    if self.steer_speed > 0 then
        self.steer_speed = math.max(self.steer_speed - (self.steering_friction * dt), 0)
    elseif self.steer_speed < 0 then
        self.steer_speed = math.min(self.steer_speed + (self.steering_friction * dt), 0)
    end
end

