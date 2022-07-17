DeathScreen = {
    crash_text = "You crashed!",
    offroad_text = "You totaled your car offroad!",
    cook_text = "You cooked in your car!",
    unknown_text = "You died!",

    score_intro_text = "Your distance: ",

    cause_text = nil,
    score_text = nil,
}
DeathScreen.__index = DeathScreen

function draw_centred(text, y)
    love.graphics.draw(text, (canvas_w - text:getWidth()) / 2, y)
end

function DeathScreen:new(cause, score)
    local obj = {}
    setmetatable(obj, DeathScreen)

    local cause_str = obj.unknown_text
    if cause == "crash" then
        cause_str = obj.crash_text
    elseif cause == "offroad" then
        cause_str = obj.offroad_text
    elseif cause == "cook" then
        cause_str = obj.cook_text
    end

    obj.cause_text = love.graphics.newText(font, {{0.66, 0.06, 0.08}, cause_str})

    local intro_str = obj.score_intro_text
    local score_str = tostring(math.floor(score)).."m"

    obj.score_text = love.graphics.newText(font, {{0.41, 0.40, 0.39}, intro_str,
                                                  {1.00, 1.00, 1.00}, score_str})

    return obj
end

function DeathScreen:draw()
    draw_centred(self.cause_text, (canvas_h / 2) - 10)
    draw_centred(self.score_text, (canvas_h / 2) + 10)
end

