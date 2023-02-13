require "utils"

Car = {
    ac_settings = { "off", "cold", "hot" },
    ac = "off",
    ac_power = 1,
    temperature = nil,
    radio_station_index = 1,
    radio_station = nil,
    last_horn = 0,
    last_swerve = 0,
    speed = 0,
    radio_stations = {"off", "classic", "metal", "jazz", "country"},

    ambient_temperature = 20,  -- Starting temp, and temp always tends towards this value
    ambient_power = 0.01,  -- How quickly the cars temp will tend towards ambient
    heatup_factor = 0,
    temperature_damage = 2,  -- The damage at 5 degrees past safe
    safe_temperatures = {-15, 40},

    died_from = nil,

    -- driving config
    max_speed = 15,
    accel = 1.5,
    steering = 7,                   -- steering speed
    max_turn_rate = 3,
    terrain_damage = 10,            -- how much damage terrain does
    default_steering_friction = 2,  -- how much the steering amount wants to return to 0
    steering_speed_threshold = 4,   -- how fast before we can steer properly?

    -- driving state
    x = 0,
    steer_speed = 0,                -- amount of steering by user; to include nudges, use `steering_amount()`
    steer_amount_prev = 0,          -- used to calculate x acceleration for visual effects
    health = 100,
    steering_friction = nil,
    steering_nudge = 0,
    d = 0,  -- total distance moved
}
setup_class("Car")

function Car.new()
    local obj = {}
    setup_instance(obj, Car)
    obj.temperature = obj.ambient_temperature
    obj.radio_station = obj.radio_stations[obj.radio_station_index]

    obj.steering_friction = obj.default_steering_friction

    return obj
end

function Car:steering_amount()
    -- if we're going too slow, we can't steer well
    local speed_multiplier = 1
    if self.speed < self.steering_speed_threshold then
        speed_multiplier = (self.speed / self.steering_speed_threshold)
    end

    return (self.steer_speed + self.steering_nudge) * speed_multiplier
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

    if self.temperature < self.safe_temperatures[1] then
        local damage_scale = ((self.safe_temperatures[1] - self.temperature) / 5) ^ 2
        self:hurt(damage_scale * self.temperature_damage * dt, "freeze")
    end

    if self.temperature > self.safe_temperatures[2] then
        local damage_scale = ((self.temperature - self.safe_temperatures[2]) / 5) ^ 2
        self:hurt(damage_scale * self.temperature_damage * dt, "cook")
    end

    self.d = self.d + (self.speed * dt)

    self:accelerate(dt)
    self:steer(dt)

    -- move sideways, in x (ie. 'turn')
    self.x = self.x + (self:steering_amount() * dt)
end

function Car:get_temperature_string()
    local s = tostring(math.floor(self.temperature)).."c"
    if (self.temperature < self.safe_temperatures[1] or self.temperature > self.safe_temperatures[2]) then
        s = s.."!"
    end
    return s
end

function Car:get_radio_station_string()
    return self.radio_station
end

function Car:update_temperature(dt)
    local change = 0

    local ambient_factor = (self.ambient_temperature - self.temperature) * self.ambient_power
    change = change + ambient_factor

    if self.ac == "cold" then
        change = change - self.ac_power
    elseif self.ac == "hot" then
        change = change + self.ac_power
    end

    change = change + self.heatup_factor

    self.temperature = self.temperature + (change * dt)

    -- TODO if it gets too hot, you die
end

function Car:toggle_station()
    self.radio_station_index = (self.radio_station_index % #self.radio_stations) + 1
    self.radio_station = self.radio_stations[self.radio_station_index]
end

function Car:beep()
    self.last_horn = 0
    local beep_sound = assets:get_mp3("Short-horn")
    if beep_sound:tell() > 0.07 then
        beep_sound:seek(0.07)
    end
    beep_sound:play()
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
    -- set the current steering speed
    local holding = false
    if love.keyboard.isDown("left") then
        self.steer_speed = self.steer_speed - self.steering * dt
        holding = true
    elseif love.keyboard.isDown("right") then
        self.steer_speed = self.steer_speed + self.steering * dt
        holding = true
    end

    self.steer_speed = clamp(self.steer_speed, -self.max_turn_rate, self.max_turn_rate)

    -- apply friction to the steering speed
    if not holding then
        if self.steer_speed > 0 then
            self.steer_speed = math.max(self.steer_speed - (self.steering_friction * dt), 0)
        elseif self.steer_speed < 0 then
            self.steer_speed = math.min(self.steer_speed + (self.steering_friction * dt), 0)
        end
    end
end

