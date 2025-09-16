--[[
===============================================================================
SCRIPT NAME:      per_map_score_limits.lua
DESCRIPTION:      Sets a static score limit at game start based on the map.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- CONFIG start ----------------------------------------------------------

local MAPS = {
    default = 3, -- fallback if map not listed

    ['bc_raceway_final_mp'] = 6,
    ['bloodgulch'] = 8,
    ['Camtrack-Arena-Race'] = 15,
    ['Cityscape-Adrenaline'] = 10,
    ['cliffhanger'] = 12,
    ['dangercanyon'] = 10,
    ['Gauntlet_Race'] = 10,
    ['gephyrophobia'] = 5,
    ['hornets_nest'] = 10,
    ['icefields'] = 8,
    ['infinity'] = 5,
    ['hypothermia_race'] = 10,
    ['islandthunder_race'] = 12,
    ['LostCove_Race'] = 12,
    ['mercury_falling'] = 10,
    ['Mongoose_Point'] = 10,
    ['mystic_mod'] = 10,
    ['New_Mombasa_Race_v2'] = 5,
    ['sidewinder'] = 8,
    ['timberland'] = 10,
    ['tsce_multiplayerv1'] = 4
}

-- CONFIG end ----------------------------------------------------------

api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'SetScoreLimit')
    SetScoreLimit()
end

function SetScoreLimit()
    if get_var(0, '$gt') == 'n/a' then return end

    local map = get_var(0, '$map')
    local limit = MAPS[map] or MAPS.default

    execute_command('scorelimit ' .. limit)
end

function OnScriptUnload() end
