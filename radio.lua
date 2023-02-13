require "car"


Radio = {
    stations = nil,
    current_station = nil,  -- just used to know when to play the switching sound
    switching_sound = nil,
    car = nil,
}
Radio.__index = Radio

function Radio.new(car)
    local obj = {}
    setmetatable(obj, Radio)
    obj.car = car

    obj.stations = {
        classic = assets:get_mp3("Hall of the Mountain King", "stream"),
        metal   = assets:get_mp3("Metalmania", "stream"),
        jazz    = assets:get_mp3("Shades of Spring", "stream"),
        country = assets:get_mp3("Hillbilly Swing", "stream"),
    }
    obj.switching_sound = assets:get_sound("radio_noises", "ogg"),

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
