Car = {
    ac = false,
    temperature = 20,
    radio_station_index = 1,
    radio_station = nil,
    last_horn = 0,
    last_swerve = 0,
    speed = 0,
    radio_stations = {"off", "classic", "metal", "jazz", "country"},
}
Car.__index = Car

function Car.new()
    local obj = {}
    setmetatable(obj, Car)
    obj.radio_station = obj.radio_stations[obj.radio_station_index]

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
end

function Car:toggle_station()
    self.radio_station_index = (self.radio_station_index % #self.radio_stations) + 1
    self.radio_station = self.radio_stations[self.radio_station_index]
end

function Car:beep()
    self.last_horn = 0
end

