require "car"


Radio = {
    stations = {
        classic = love.audio.newSource("assets/audio/Hall of the Mountain King.mp3", "stream"),
        metal   = love.audio.newSource("assets/audio/Metalmania.mp3", "stream"),
        jazz    = love.audio.newSource("assets/audio/Shades of Spring.mp3", "stream"),
        country = love.audio.newSource("assets/audio/Hillbilly Swing.mp3", "stream"),
    },

    current_station = nil,  -- just used to know when to play the switching sound

    switching_sound = love.audio.newSource("assets/audio/radio_noises.ogg", "static"),

    car = nil,
}
Radio.__index = Radio

function Radio.new(car)
    local obj = {}
    setmetatable(obj, Radio)
    obj.car = car

    obj:update()

    for _, au in pairs(obj.stations) do
        au:setLooping(true)
        au:play()
    end

    return obj
end

function Radio:update()
    for _, au in pairs(self.stations) do
        au:setVolume(0)
    end

    local st = self.car:get_radio_station_string()

    if st ~= self.current_station then
        if self.current_station ~= nil then
            if self.switching_sound:isPlaying() then
                self.switching_sound:stop()
            end
            self.switching_sound:play()
        end
        self.current_station = st
    end

    if st == nil or st == "off" then
        -- pass
    elseif self.stations[st] == nil then
        print("WARN: unknown radio station", st)
    else
        self.stations[st]:setVolume(1)
    end
end
