Car = {
    ac = false,
    temperature = 20,
    radio_station_index = 1,
    radio_station = nil,
    last_horn = 0,
    last_swerve = 0,
    speed = 0,
    radio_stations = {"off", "classic", "metal", "jazz", "country"},

    -- driving config
    max_speed = 1000,
    accel = 1.5,
    steering = 7,                   -- steering speed
    max_turn_rate = 3,
    terrain_damage = 10,            -- how much damage terrain does
    default_steering_friction = 2,  -- how much the steering amount wants to return to 0

    -- driving state
    x = 0,
    steer_speed = 0,
    health = 100,
    steering_friction = nil,
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

function Car:update(dt)
    self.last_horn = self.last_horn + dt
    self.last_swerve = self.last_swerve + dt
    if (self.ac) then
        self.temperature = self.temperature - dt / 6000
    else
        self.temperature = self.temperature + dt / 6000
    end

    self.d = self.d + (self.speed * dt)

    self:accelerate(dt)
    self:steer(dt)

    -- move sideways, in x (ie. 'turn')
    self.x = self.x + (self.steer_speed * dt)
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

