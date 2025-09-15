--[[
===============================================================================
SCRIPT NAME:      dynamic_score_limit.lua
DESCRIPTION:      Automatically adjusts score limits based on player count with:
                  - Custom configurations for each game type
                  - Team vs FFA mode differentiation
                  - Dynamic message formatting

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- CONFIG start ---------------------------------------------------------------------

local config = {
    -- Messages can use the following variables:
    -- %s  = the new score limit
    -- %s  = pluralization character for laps/minutes

    -- Example format: { min_players, max_players, score_limit }

    -- Custom game mode score limits:
    game_modes = {
        ['example_game_mode'] = {
            { 1,  4,  25 },
            { 5,  8,  35 },
            { 9,  12, 45 },
            { 13, 16, 50 },
            'Score limit changed to: %s'
        },
        ['another_example_game_mode'] = {
            { 1,  4,  25 },
            { 5,  8,  35 },
            { 9,  12, 45 },
            { 13, 16, 50 },
            'Score limit changed to: %s'
        },
    },

    -- Default game type score limits:
    default_modes = {
        ctf = {
            { { 1, 4, 1 }, { 5, 8, 2 }, { 9, 12, 3 }, { 13, 16, 4 }, 'Score limit changed to: %s' }
        },
        slayer = {
            { -- Free-for-All:
                { 1, 4, 15 }, { 5, 8, 25 }, { 9, 12, 45 }, { 13, 16, 50 }, 'Score limit changed to: %s'
            },
            { -- Team Slayer:
                { 1, 4, 25 }, { 5, 8, 35 }, { 9, 12, 45 }, { 13, 16, 50 }, 'Score limit changed to: %s'
            }
        },
        king = {
            { -- Free-for-All:
                { 1, 4, 2 }, { 5, 8, 3 }, { 9, 12, 4 }, { 13, 16, 5 }, 'Score limit changed to: %s minute%s'
            },
            { -- Team King:
                { 1, 4, 3 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: %s minute%s'
            }
        },
        oddball = {
            { -- Free-for-All:
                { 1, 4, 2 }, { 5, 8, 3 }, { 9, 12, 4 }, { 13, 16, 5 }, 'Score limit changed to: %s minute%s'
            },
            { -- Team Oddball:
                { 1, 4, 3 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: %s minute%s'
            }
        },
        race = {
            { -- Free-for-All:
                { 1, 4, 4 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: %s lap%s'
            },
            { -- Team Race:
                { 1, 4, 4 }, { 5, 8, 5 }, { 9, 12, 6 }, { 13, 16, 7 }, 'Score limit changed to: %s lap%s'
            }
        }
    }
}

-- CONFIG end ---------------------------------------------------------------------

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
    local message = score_table[#score_table]
    say_all(string.format(message, limit, limit ~= 1 and 's' or ''))
end

local function changeScoreLimit(quitFlag)
    if not score_table then return end

    local player_count = tonumber(get_var(0, '$pn'))
    player_count = quitFlag and player_count - 1 or player_count

    for _, limit_data in ipairs(score_table) do
        local min, max, limit = unpack(limit_data)
        if player_count >= min and player_count <= max and limit ~= current_limit then
            current_limit = limit
            execute_command('scorelimit ' .. limit)
            announceChange(limit)
            return
        end
    end
end

function OnStart()
    local game_type = get_var(0, '$gt')
    if game_type == 'n/a' then return end

    score_table, current_limit = nil, nil
    local mode = get_var(0, '$mode')
    local ffa = get_var(0, '$ffa') == '1'

    score_table = config.game_modes[mode]
    if not score_table then
        score_table = (ffa and config.default_modes[game_type][1]) or config.default_modes[game_type][2]
    end
    changeScoreLimit()
end

function OnEnd() score_table, current_limit = nil, nil end

function OnJoin() changeScoreLimit() end

function OnQuit() changeScoreLimit(true) end

function OnScriptUnload() end
