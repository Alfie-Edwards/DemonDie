require "utils"
require "hud"
require "huds/cab"

page_text = {
    {
        "\n\n  GRIMOIRE OF THE\n     DEMON DIE\n\nDemon Dice can be extrmely dangerous, and must handled properly.The most important rule is to never let them out of your sight.\n\nDemon Dice, must have their power regularly sealed using incantations.",
        "The section at the back of this book will guide you through the incantation process.\nAn uncomfortable Die will need its power sealing more often. Demon Dice take on different characters (faces), with different needs, depending on their orientation. These are detailed in this book.",
    },
    {
        "\n\n      FACE I:\n\nThis face is passionate and hot-headed. It loves loud noises and extreme heat.\n\nWhat ever you do, do not play it classical music.",
        "\n\n       FACE II:\n\nThis face has a rather cold personality. It hates to disturbed.\n\nTry to provide silence, and stillness."
    },
    {
        "\n\n      FACE III:\n\nThis face can be difficult as it is very particular. It likes a dark environment, with a moderate temperature.\n\n If it seems unhappy, try playing some classical music.",
        "\n\n       FACE IV:\n\nThis face is a thrill seeker. Unhelpfully, it has a tendency create dangerous situations. Just do your best to keep it entertained.\n\nFor whatever reason it despises country music."
    },
    {
        "\n\n      FACE V:\n\nThis face is best described as nervous, and has a tendency to lash out if it feels threatened.\n\nKeep it in a cool place and avoid loud noises.",
        "\n\n       FACE VI:\n\nThis troublesome face somewhat of a prankster.\n\nPlaying Jazz seems to keep it preoccupied, but avoid classical music."
    },
    {
        "\n\n      SEALING\n    INCANTATION\n\n\nIf a Demon Die in your posession begins causing too much trouble, recite the incantation on the next page to seal away its power.",
    },
}

function page_name(num)
    return "book_page_"..tostring(num)
end

num_pages = 5
book_bb = BoundingBox.new(72, 36, 248, 163)
left_bb = BoundingBox.new(78, 46, 156, 156)
right_bb = BoundingBox.new(164, 46, 242, 156)
typing_chars = "^[A-z']$"

function create_page(number)
    local page = Hud.new()
    init_page(page, number)

    set_page_text(page, "left", page_text[number][1])

    if (number == 5) then
        set_page_exorcism(page, "right")
    else
        set_page_text(page, "right", page_text[number][2])
    end
    return page
end

function draw_on_side(page, side, draw_func)
    page:add_draw_func(
        function()
            if (side == "left") then
                love.graphics.push()
                love.graphics.translate(left_bb.x1, left_bb.y1)
            else
                love.graphics.push()
                love.graphics.translate(right_bb.x1, right_bb.y1)
            end
            draw_func()
            love.graphics.pop()
        end
    )
end

function set_page_text(page, side, text)
    local text = love.graphics.newText(font, {{0.41, 0.4, 0.39}, wrap_text(text, font, 78)})
    draw_on_side(
        page, side,
        function() love.graphics.draw(text) end
    )
end

function get_bb(side)
    if (side == "left") then
        return left_bb
    else
        return right_bb
    end
end

function set_page_exorcism(page, side)
    local start_exorcism_mr = MouseRegion.new()
    local bb = get_bb(side)
    start_exorcism_mr.bounding_box = BoundingBox.new(bb.x1, bb.y1+12, bb.x2, bb.y2-30)
    start_exorcism_mr.click_func = function()
        current_exorcism = Exorcism.new(die)
        page:remove_mouse_region(start_exorcism_mr)
    end
    page:add_mouse_region(start_exorcism_mr)

    local update_func = function()
        if (current_exorcism ~= nil and current_exorcism.complete) then
            current_exorcism = nil
            page:add_mouse_region(start_exorcism_mr)
        end
    end

    local keypresed_func = function(key)
        if (current_exorcism == nil) then
            return
        end

        local stage = current_exorcism.current_stage
        if (stage == nil) then
            return
        end

        if (stage.type == "typing") then
            if key:match(typing_chars) then
                if key == stage.text:sub(stage.pos, stage.pos) then
                    stage.pos = stage.pos + 1
                    while (not stage.text:sub(stage.pos, stage.pos):match(typing_chars)
                           and not (stage.pos > #(stage.text))) do
                        stage.pos = stage.pos + 1
                    end
                    if (stage.pos > #stage.text) then
                        current_exorcism:stage_complete()
                    end
                else
                    exorcism_typing_mistake()
                end
            end
        end
    end

    local draw_func = function()
        if (current_exorcism == nil) then
            love.graphics.draw(images.begin_ritual)
            return
        end
        local stage = current_exorcism.current_stage
        if (stage == nil) then
            return
        end
        if (stage.type == "typing") then
            local w = font:getWidth(stage.text)
            local _, lines = stage.text:gsub("\n","")
            local h = lines * font:getLineHeight()
            local x = (bb:width() - w) / 2
            local y = -6 + (bb:height() - h) / 2
            love.graphics.print(
                {{0.41, 0.4, 0.39}, stage.text:sub(0,stage.pos-1),
                 {0.48, 0.09, 0.09}, stage.text:sub(stage.pos,stage.pos),
                 {0.81, 0.8, 0.79}, stage.text:sub(stage.pos+1)},
                x, y)
        end
    end

    page:add_update_func(update_func)
    page:add_keypressed_func(keypresed_func)
    draw_on_side(page, side, draw_func)
end

function exorcism_typing_mistake()
end

function init_page(page, num)
    page:add_draw_func(
        function()
            love.graphics.draw(images.cab)
            draw_wheel()
            love.graphics.draw(images.book_open, book_bb.x1, book_bb.y1)
            if (num ~= 1) then
                love.graphics.draw(images.page_arrow, 90, 151, 0, -1, 1)
            end
            if (num ~= num_pages) then
                love.graphics.draw(images.page_arrow, 229, 151)
            end
            health_bar:draw()
        end
    )

    page:add_update_func(
        function(dt)
            last_book_page = page_name(num)
        end
    )
    if (num ~= 1) then
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(79, 151, 90, 158),
                function() set_hud(page_name(num-1)) end
            )
        )
    end
    if (num ~= num_pages) then
        page:add_mouse_region(
            MouseRegion.new(
                BoundingBox.new(229, 151, 241, 158),
                function() set_hud(page_name(num+1)) end
            )
        )
    end
    page:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(0, 0, 72, 180),
            function() set_hud("cab") end)
    )
    page:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(248, 0, 360, 180),
            function() set_hud("cab") end
        )
    )
    page:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(72, 0, 248, 36),
            function() set_hud("cab") end
        )
    )
    page:add_mouse_region(
        MouseRegion.new(
            BoundingBox.new(72, 163, 248, 180),
            function() set_hud("cab") end
        )
    )
end