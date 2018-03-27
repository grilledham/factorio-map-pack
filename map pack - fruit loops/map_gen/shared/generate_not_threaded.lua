require("map_gen.shared.builders")
require("utils.poisson_rng")

local function do_row(row, data)
    local y = data.top_y + row
    local top_x = data.top_x

    for x = top_x, top_x + 31 do
        -- local coords need to be 'centered' to allow for correct rotation and scaling.
        local tile, entity = MAP_GEN(x + 0.5, y + 0.5, x, y, data.surface)

        if not tile then
            table.insert(data.tiles, {name = "out-of-map", position = {x, y}})
        elseif type(tile) == "string" then
            table.insert(data.tiles, {name = tile, position = {x, y}})
        end

        if map_gen_decoratives then
            tile_decoratives = check_decorative(tile, x, y)
            for _, tbl in ipairs(tile_decoratives) do
                table.insert(data.decoratives, tbl)
            end

            tile_entities = check_entities(tile, x, y)
            for _, entity in ipairs(tile_entities) do
                table.insert(data.entities, entity)
            end
        end

        if entity then
            table.insert(data.entities, entity)
        end
    end
end

local function do_place_tiles(data)
    data.surface.set_tiles(data.tiles, true)
end

local function do_place_decoratives(data)
    if not map_gen_decoratives then
        return
    end

    for _, e in pairs(surface.find_entities_filtered {area = area, type = "decorative"}) do
        e.destroy()
    end
    for _, e in pairs(surface.find_entities_filtered {area = area, type = "simple-entity"}) do
        e.destroy()
    end

    local surface = data.surface
    for _, d in pairs(data.decoratives) do
        surface.create_decoratives {check_collision = false, decoratives = {d}}
    end
end

local function do_place_entities(data)
    local surface = data.surface
    for _, e in ipairs(data.entities) do
        if surface.can_place_entity(e) then
            surface.create_entity(e)
        end
    end
end

function run_combined_module(event)
    if MAP_GEN == nil then
        game.print("MAP_GEN not set")
        return
    end

    local area = event.area   

    local data = {
        top_x = area.left_top.x,
        top_y = area.left_top.y,
        surface = event.surface,
        tiles = {},
        entities = {},
        decoratives = {}
    }

    for row = 0, 31 do
        do_row(row, data)
    end

    do_place_tiles(data)
    do_place_decoratives(data)
    do_place_entities(data)    
end

local decorative_options = {
    ["concrete"] = {},
    ["deepwater"] = {},
    ["deepwater-green"] = {
        {"brown-carpet-grass", 100},
        {"brown-cane-cluster", 500}
    },
    ["dirt-3"] = {
        {"brown-carpet-grass", 100},
        {"brown-cane-cluster", 200},
        {"sand-rock-small", 150}
    },
    ["dirt-6"] = {
        {"sand-rock-small", 150},
        {"red-asterisk", 45},
        {"red-desert-bush", 12},
        {"rock-medium", 375}
    },
    ["grass-1"] = {
        {"green-carpet-grass-1", 3},
        {"green-hairy-grass-1", 7},
        {"green-bush-mini", 10},
        {"green-pita", 6},
        {"green-small-grass-1", 12},
        {"green-asterisk", 25},
        {"green-bush-mini", 7},
        {"garballo", 20}
    },
    ["grass-3"] = {
        {"green-carpet-grass-1", 12},
        {"green-hairy-grass-1", 28},
        {"green-bush-mini", 40},
        {"green-pita", 24},
        {"green-small-grass-1", 48},
        {"green-asterisk", 100},
        {"green-bush-mini", 28}
    },
    ["grass-2"] = {
        {"green-hairy-grass-1", 56},
        {"green-bush-mini", 80},
        {"green-pita", 48},
        {"green-small-grass-1", 96},
        {"green-asterisk", 200},
        {"green-bush-mini", 56},
        {"brown-cane-cluster", 100},
        {"brown-carpet-grass", 100}
    },
    ["hazard-concrete-left"] = {},
    ["hazard-concrete-right"] = {},
    ["lab-dark-1"] = {},
    ["lab-dark-2"] = {},
    ["red-desert"] = {
        {"brown-carpet-grass", 35},
        {"orange-coral-mini", 45},
        {"red-asterisk", 45},
        {"red-desert-bush", 12},
        {"rock-medium", 375},
        {"sand-rock-small", 200},
        {"sand-rock-small", 30}
    },
    ["red-desert-dark"] = {
        {"brown-carpet-grass", 70},
        {"orange-coral-mini", 90},
        {"red-asterisk", 90},
        {"red-desert-bush", 35},
        {"rock-medium", 375},
        {"sand-rock-small", 200},
        {"sand-rock-small", 150}
    },
    ["sand-1"] = {
        {"brown-carpet-grass", 35},
        {"orange-coral-mini", 45},
        {"red-asterisk", 45},
        {"brown-asterisk", 45}
    },
    ["sand-3"] = {
        {"brown-carpet-grass", 35},
        {"orange-coral-mini", 45},
        {"brown-asterisk", 45}
    },
    ["stone-path"] = {},
    ["water"] = {},
    ["water-green"] = {},
    ["out-of-map"] = {}
}

local function check_decorative(tile, x, y)
    local options = decorative_options[tile]
    local tile_decoratives = {}

    for _, e in ipairs(options) do
        name = e[1]
        high_roll = e[2]
        if poisson_rng_next(high_roll / 2) == 1 then
            table.insert(tile_decoratives, {name = name, amount = 1, position = {x, y}})
        end
    end

    return tile_decoratives
end

local entity_options = {
    ["concrete"] = {},
    ["deepwater"] = {},
    ["deepwater-green"] = {},
    ["water"] = {},
    ["water-green"] = {},
    ["dirt-3"] = {
        {"tree-01", 500},
        {"tree-06", 300},
        {"tree-07", 800},
        {"tree-09", 2000},
        {"rock-big", 400}
    },
    ["dirt-6"] = {
        {"tree-06", 150},
        {"tree-07", 400},
        {"tree-09", 1000},
        {"rock-big", 300}
    },
    ["grass-1"] = {
        {"tree-01", 150},
        {"tree-04", 400},
        {"tree-06", 400},
        {"tree-07", 400},
        {"tree-09", 1000},
        {"rock-big", 400},
        {"green-coral", 10000}
    },
    ["grass-3"] = {
        {"tree-02", 400},
        {"tree-03", 400},
        {"tree-04", 800},
        {"tree-06", 300},
        {"tree-07", 800},
        {"tree-08", 400},
        {"tree-09", 2000},
        {"rock-big", 400}
    },
    ["grass-2"] = {
        {"tree-04", 800},
        {"tree-06", 300},
        {"tree-07", 400},
        {"tree-09", 1000},
        {"dry-tree", 1000},
        {"rock-big", 200}
    },
    ["hazard-concrete-left"] = {},
    ["hazard-concrete-right"] = {},
    ["lab-dark-1"] = {},
    ["lab-dark-2"] = {},
    ["red-desert"] = {
        {"dry-tree", 400},
        {"dry-hairy-tree", 400},
        {"tree-06", 500},
        {"tree-06", 500},
        {"tree-01", 500},
        {"tree-02", 500},
        {"tree-03", 500},
        {"sand-rock-big", 200},
        {"sand-rock-big", 400},
        {"red-desert-rock-huge-02", 400}
    },
    ["red-desert-dark"] = {
        {"dry-tree", 400},
        {"dry-hairy-tree", 400},
        {"tree-06", 500},
        {"tree-06", 500},
        {"tree-01", 500},
        {"tree-02", 500},
        {"tree-03", 500},
        {"sand-rock-big", 200},
        {"sand-rock-big", 400},
        {"red-desert-rock-huge-02", 400}
    },
    ["sand-1"] = {
        {"dry-tree", 1000},
        {"dry-hairy-tree", 1000},
        {"dead-tree", 1000},
        {"rock-big", 150}
    },
    ["sand-3"] = {
        {"dead-tree", 1000},
        {"dry-tree", 1000},
        {"dry-hairy-tree", 1000},
        {"rock-big", 150}
    },
    ["stone-path"] = {},
    ["out-of-map"] = {}
}

function check_entities(tile, x, y)
    local options = entity_options[tile]
    local tile_entity_list = {}

    for _, e in ipairs(options) do
        name = e[1]
        high_roll = e[2]
        if poisson_rng_next(high_roll / 2) == 1 then
            table.insert(tile_entity_list, {name = name, position = {x, y}})
        end
    end

    return tile_entity_list
end
