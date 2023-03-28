require("prefix")

-- Generic helper functions

function pflog (message)
    log(pf(" " .. message))
end


-- Factorio-specific functions

function cfg_start (setting)
    local config = settings.startup[pf(setting)]

    if not config then
        pflog("Cannot get startup setting '" .. pf(setting) .. "': it doesn't exist.")
        return;
    end

    return config.value
end


-- Recipe functions

function add_pack_as_ingredient (ingredient, pack)
    local recipe = data.raw.recipe[pack.recipe]

    if not recipe then
        pflog("Cannot add '" .. ingredient .. "' as ingredient: the recipe '" .. pack.recipe .. "' doesn't exist.")
        return
    end

    table.insert(recipe.ingredients, {ingredient, pack.result})
end


-- Tech functions

function add_prereq_to_tech (prereq, techName)
    local technology = data.raw.technology
    local tech = technology[techName]

    if not tech or not technology[prereq] then
        pflog("Cannot add prereq '" .. prereq .. "' to tech '" .. techName .. "': they don't both exist.")
        return
    end

    if not tech.prerequisites then
        tech.prerequisites = {prereq}
    elseif not table_contains(tech.prerequisites, prereq) then
        table.insert(tech.prerequisites, prereq)
    else
        pflog("'" .. prereq .. "' is already a prerequisite of '" .. techName .. "'.")
    end
end

function set_research_cost (techName, ingredients)
    local tech = data.raw.technology[techName]

    if not tech then
        pflog("Cannot set the research cost for '" .. techName .. "': it doesn't exist.")
        return
    end

    tech.unit.ingredients = ingredients
end
