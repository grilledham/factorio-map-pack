require "map_gen.shared.generate"

local pic = require "map_gen.data.presets.template"
local pic = decompress(pic)
local map = picture_builder(pic)

-- this changes the size of the map
--map = scale(map, 2, 2)

-- this rotates the map
--map = rotate(map, degrees(45))

-- this moves the map, effectively changing the spawn point.
--map = translate(map, 0, -200)

-- this sets the tile outside the bounds of the map to deepwater, remove this and it will be void.
--map = change_tile(map, false, "deepwater")

return map