require "utils"

Exorcism = {
    num_stages = 1,
    stages_complete = 0,
    current_stage = nil,
    die = nil,
    complete = false,
}
setup_class("Exorcism")

function Exorcism.new(die)
    local obj = {}
    setup_instance(obj, Exorcism)
    obj.die = die
    obj.current_stage = create_typing_stage(die.difficulty / die.max_difficulty)

    return obj
end

function Exorcism:begin()
    assets:get_mp3("Big Bell"):seek(0)
    assets:get_mp3("Big Bell"):play()
end

function Exorcism:stage_complete()
    self.stages_complete = self.stages_complete + 1
    if (self.stages_complete == self.num_stages) then
        self.die:reset_difficulty()
        self.complete = true
        self.die:reroll()
        assets:get_mp3("Soul Steal 02"):seek(0)
        assets:get_mp3("Soul Steal 02"):play()
    else
        self.current_stage = create_typing_stage(die.difficulty / die.max_difficulty)
    end
end

ExorcismStage = {
    type = nil,
    data = nil,
}
setup_class("ExorcismStage")

function ExorcismStage.new(type)
    local obj = {}
    setup_instance(obj, ExorcismStage)
    obj.type = type

    return obj
end

function create_typing_stage(difficulty)
    local window_size = math.floor(0.6 * #words)
    local window_start = math.floor((#words - window_size) * difficulty) + 1

    local index1 = math.random(window_start, window_start + window_size - 1)
    local index2 = math.random(window_start, window_start + window_size - 1)
    local index3 = math.random(window_start, window_start + window_size - 1)
    local text = words[index1].." "..words[index2].." "..words[index3]

    local stage = ExorcismStage.new("typing")
    local lines = wrap_text(text, font, 78)
    stage.text = table.concat(lines, "\n")
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