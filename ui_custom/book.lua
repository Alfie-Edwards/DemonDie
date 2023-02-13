require "ui.image"
require "ui.text"
require "ui_custom.exorcism"
require "ui_custom.image_button"

Book = {
    left_bb = BoundingBox.new(6, 10, 84, 120),
    right_bb = BoundingBox.new(92, 10, 170, 120),
    count = 5,
    typing_chars = "^[A-z']$",
    left_page = nil,
    right_page = nil,
    page_text = {
        "\n\n  GRIMOIRE OF THE\n     DEMON DIE\n\nDemon Dice can be extrmely dangerous, and must handled properly.The most important rule is to never let them out of your sight.\n\nDemon Dice, must have their power regularly sealed using incantations.",
        "The section at the back of this book will guide you through the incantation process.\nAn uncomfortable Die will need its power sealing more often. Demon Dice take on different characters (faces), with different needs, depending on their orientation. These are detailed in this book.",
        "\n\n      FACE I:\n\nThis face is passionate and hot-headed. It loves loud noises and extreme heat.\n\nWhat ever you do, do not play it classical music.",
        "\n\n       FACE II:\n\nThis face has a rather cold personality. It hates to disturbed.\n\nTry to provide silence, and stillness.",
        "\n\n      FACE III:\n\nThis face can be difficult as it is very particular. It likes a dark environment, with a moderate temperature.\n\n If it seems unhappy, try playing some classical music.",
        "\n\n       FACE IV:\n\nThis face is a thrill seeker. Unhelpfully, it has a tendency create dangerous situations. Just do your best to keep it entertained.\n\nFor whatever reason it despises country music.",
        "\n\n      FACE V:\n\nThis face is best described as nervous, and has a tendency to lash out if it feels threatened.\n\nKeep it in a cool place and avoid loud noises.",
        "\n\n       FACE VI:\n\nThis troublesome face somewhat of a prankster.\n\nPlaying Jazz seems to keep it preoccupied, but avoid classical music.",
        "\n\n      SEALING\n    INCANTATION\n\n\nIf a Demon Die in your posession begins causing too much trouble, recite the incantation on the next page to seal away its power.",
    },
    pages = nil,
    current_page_num = nil,
    current_page_left = nil,
    current_page_right = nil,
    prev_page_arrow = nil,
    next_page_arrow = nil
}

setup_class("Book", Image)

function Book.new()
    local obj = Image.new()
    setup_instance(obj, Book)

    obj.pages = {}
    obj.current_page_num = 1
    obj:set_properties(
        {
            image = assets:get_image("book_open"),
            image_data = assets:get_image_data("book_open"),
        }
    )

    obj.next_page_arrow = ImageButton.new()
    obj.next_page_arrow:set_properties(
        {
            x = 157,
            y = 115,
            image = assets:get_image("page_arrow"),
            image_data = assets:get_image_data("page_arrow"),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                obj:next_page()
                assets:get_mp3("page_turn"):seek(0)
                assets:get_mp3("page_turn"):play()
            end,
        }
    )

    obj.prev_page_arrow = ImageButton.new()
    obj.prev_page_arrow:set_properties(
        {
            x = 7,
            y = 115,
            image = assets:get_image("page_arrow"),
            image_data = assets:get_image_data("page_arrow"),
            transform = scale_about(-1, 1, assets:get_image("page_arrow"):getWidth() / 2, assets:get_image("page_arrow"):getHeight() / 2),
            cursor = love.mouse.getSystemCursor("hand"),
            click = function()
                obj:prev_page()
                assets:get_mp3("page_turn"):seek(0)
                assets:get_mp3("page_turn"):play()
            end,
        }
    )

    for _,page_text in pairs(Book.page_text) do
        local text = Text.new()
        text:set_properties(
            {
                width = Book.left_bb:width(),
                height = Book.left_bb:height(),

                text = page_text,
                line_spacing = 0,
                font = assets:get_font("font"),
                color = {0.41, 0.4, 0.39, 1}
            }
        )
        obj:add_page(text)
    end
    obj:add_page(ExorcismView.new())

    obj:refresh_pages()

    return obj
end

function Book:add_page(page)
    table.insert(self.pages, page)
    self:refresh_pages()
end

function Book:next_page()
    self.current_page_num = self.current_page_num + 2
    self:refresh_pages()
end

function Book:prev_page()
    self.current_page_num = self.current_page_num - 2
    self:refresh_pages()
end

function Book:refresh_pages()
    if self.current_page_left ~= nil then
        self:remove_child(self.current_page_left)
    end
    if self.current_page_right ~= nil then
        self:remove_child(self.current_page_right)
    end

    self.current_page_left = self.pages[self.current_page_num]
    self.current_page_right = self.pages[self.current_page_num + 1]

    if self.current_page_left ~= nil then
        self.current_page_left:set_x(Book.left_bb.x1)
        self.current_page_left:set_y(Book.left_bb.y1)
        self:add_child(self.current_page_left)
    end

    if self.current_page_right ~= nil then
        self.current_page_right:set_x(Book.right_bb.x1)
        self.current_page_right:set_y(Book.right_bb.y1)
        self:add_child(self.current_page_right)
    end

    self:remove_child(self.prev_page_arrow)
    if self.current_page_num > 1 then
        self:add_child(self.prev_page_arrow)
    end

    self:remove_child(self.next_page_arrow)
    if self.current_page_num < (#(self.pages) - 1) then
        self:add_child(self.next_page_arrow)
    end

end
