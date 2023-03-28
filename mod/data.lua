require("data-util")

local science_packs = {
    red = {
        name = "automation-science-pack",
        recipe = "automation-science-pack",
        tech = nil,
        result = 1,
        order = 1,
    },
    green = {
        name = "logistic-science-pack",
        recipe = "logistic-science-pack",
        tech = "logistic-science-pack",
        result = 1,
        order = 2,
    },
    gray = {
        name = "military-science-pack",
        recipe = "military-science-pack",
        tech = "military-science-pack",
        result = 2,
        order = 3,
    },
    blue = {
        name = "chemical-science-pack",
        recipe = "chemical-science-pack",
        tech = "chemical-science-pack",
        result = 2,
        order = 4,
    },
    purple = {
        name = "production-science-pack",
        recipe = "production-science-pack",
        tech = "production-science-pack",
        result = 3,
        order = 5,
    },
    yellow = {
        name = "utility-science-pack",
        recipe = "utility-science-pack",
        tech = "utility-science-pack",
        result = 3,
        order = 6,
    },
    white = {
        name = "space-science-pack",
        recipe = "satellite",
        tech = "space-science-pack",
        result = 1000,
        order = 7,
    },
}

local function swap (first, second)
    science_packs[first].order, science_packs[second].order = science_packs[second].order, science_packs[first].order
end

local function rem(science)
    science_packs[science] = nil
end

if cfg_start("yellow-before-purple") then swap("purple", "yellow") end
if cfg_start("blue-before-gray") then swap("gray", "blue") end
if cfg_start("ignore-gray") then rem("gray") end

local function sorter (a, b)
    return science_packs[a].order < science_packs[b].order
end

local keys = {}

for name in pairs(science_packs) do
    table.insert(keys, name)
end

table.sort(keys, sorter)

local prev, cur
local research_cost = {}

for _, key in ipairs(keys) do
    prev, cur = cur, science_packs[key]

    if not prev then goto continue end

    -- In theory only the first does not have a tech
    if prev.tech and cur.tech then add_prereq_to_tech(prev.tech, cur.tech) end

    add_pack_as_ingredient(prev.name, cur)

    table.insert(research_cost, {prev.name, 1})
    set_research_cost(cur.tech, table.deepcopy(research_cost))

    ::continue::
end
