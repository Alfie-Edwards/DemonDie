require "utils"

AssetCache = {
    images = nil,
    image_data = nil,
}
setup_class("AssetCache")

function AssetCache.new()
    local obj = {}
    setup_instance(obj, AssetCache)

    obj.images = {}
    obj.image_data = {}

    return obj
end

function AssetCache:get_image(name)
    if images[name] == nil then
        images[name] = love.graphics.newImage("assets/"..name..".png")
    end
    return images[name]
end

function AssetCache:get_image_data(name)
    if image_data[name] == nil then
        image_data[name] = love.image.newImageData("assets/"..name..".png")
    end
    return image_data[name]
end
