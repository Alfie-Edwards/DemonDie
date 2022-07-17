require "utils"

Exorcism = {
    num_stages = 6,
    stages_complete = 0,
    current_stage = nil,
    die = nil,
    complete = false,
}
Exorcism.__index = Exorcism

function Exorcism.new(die)
    local obj = {}
    setmetatable(obj, Exorcism)
    obj.die = die
    obj.current_stage = create_typing_stage(die.difficulty / die.max_difficulty)

    return obj
end

function Exorcism:begin()

end

function Exorcism:stage_complete()
    self.stages_complete = self.stages_complete + 1
    if (self.stages_complete == self.num_stages) then
        self.die:reset_difficulty()
        self.complete = true
        self.die:reroll()
    else
        self.current_stage = create_typing_stage(die.difficulty / die.max_difficulty)
    end
end

ExorcismStage = {
    type = nil,
    data = nil,
}
ExorcismStage.__index = ExorcismStage

function ExorcismStage.new(type)
    local obj = {}
    setmetatable(obj, ExorcismStage)
    obj.type = type

    return obj
end

function create_typing_stage(difficulty)
    local window_size = math.floor(0.5 * #words)
    local window_start = math.floor((#words - window_size) * difficulty) + 1
    local index = math.random(window_start, window_start + window_size - 1)
    local stage = ExorcismStage.new("typing")
    stage.text = wrap_text(words[index], font, 78)
    stage.pos = 1
    return stage
end


words = {
    "ko",
    "zan",
    "woa",
    "kor",
    "vitae",
    "mortis",
    "vo'sol",
    "kar kor",
    "morakan",
    "mordaka",
    "sha sha",
    "cessare",
    "ka ra ka",
    "mordakar",
    "ad nihil",
    "vox vito",
    "so sah zan",
    "kar korzon",
    "guah nakor",
    "karaka zan",
    "vo'sol izh",
    "zan korabos",
    "alibi vitae",
    "ergo bellum",
    "izh sol fek",
    "kor karamord",
    "mardakaramon",
    "kor mordakar",
    "aligxu al ni",
    "vita et mors",
    "mor tor cheea",
    "tranquillitas",
    "hahsh ozh poz",
    "sha sha karakas",
    "talis evolvere",
    "ozh omoz groth",
    "daemonium talis",
    "izh icha safras",
    "eyik vo'hollom.",
    "karabos karakas",
    "ozkavosh tak izh",
    "et sigillum satis",
    "ahm'irush tak izh",
    "ozh icha tak lash",
    "ha ka mor dor cheea",
    "izh vo'poz doq nith",
    "sha sha karakas shon",
    "karabos kor koramond",
    "izh greesh vo'lieyev",
    "deglutire animam tuam",
    "ozh vo'chron izh rasth",
    "ahm'vo'izh fek sa chron",
    "zan korobos kor koramord",
    "ozh poz icha gluth wroth",
}