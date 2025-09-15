--[[
===============================================================================
SCRIPT NAME:      dynamic_race_laps.lua
DESCRIPTION:      Automatically adjusts lap score limit based on player count.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- CONFIG start ----------------------------------------------------------

local SCORE_LIMIT_MESSAGE = 'Score limit changed to %s lap%s'

local MAPS = {

    -- Example format: { min_players, max_players, score_limit }
    -- Last entry in each map is the message string.

    default = { -- if map is not found in the table, use this
        { 1,  4,  10 },
        { 5,  8,  20 },
        { 9,  12, 30 },
        { 13, 16, 40 }
    },

    ['bloodgulch'] = {
        { 1,  4,  25 },
        { 5,  8,  35 },
        { 9,  12, 45 },
        { 13, 16, 50 }
    },
    ['sidewinder'] = {
        { 1,  4,  15 },
        { 5,  8,  25 },
        { 9,  12, 35 },
        { 13, 16, 50 }
    },
}

-- CONFIG end ----------------------------------------------------------

api_version = "1.12.0.0"

local score_table, current_limit

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function announceChange(limit)
    say_all(string.format(SCORE_LIMIT_MESSAGE, limit, limit ~= 1 and 's' or ''))
end

local function changeScoreLimit(quitFlag)
    if not score_table then return end

    local player_count = tonumber(get_var(0, '$pn'))
    if quitFlag then
        player_count = player_count - 1
    end

    for _, limit_data in ipairs(score_table) do
        local min, max, limit = table.unpack(limit_data)
        if player_count >= min and player_count <= max and limit ~= current_limit then
            current_limit = limit
            execute_command('scorelimit ' .. limit)
            announceChange(limit)
            return
        end
    end
end

function OnStart()
    current_limit = nil
    score_table = MAPS[get_var(0, '$map')] or MAPS.default
    changeScoreLimit()
end

function OnEnd() score_table, current_limit = nil, nil end

function OnJoin() changeScoreLimit() end

function OnQuit() changeScoreLimit(true) end

function OnScriptUnload() end
