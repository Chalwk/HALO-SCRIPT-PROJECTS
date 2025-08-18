--[[
--=====================================================================================================--
Script Name: Dynamic Score Limit, for SAPP (PC & CE)
Description: Automatically adjusts the score limit based on the current number of online players.

            Supports custom game mode overrides.
            If your game mode isn't listed in the `score_limits` table,
            the server will default to pre-configured game type values.

Copyright (c) 2022-2025, Jericho Crosby
Notice: You can use this script under the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-----------------------------------------
-- Config starts here, edit as needed --
-----------------------------------------
---
local config = {
    -- Messages can use the following variables:
    -- $limit   = the new score limit
    -- $s       = pluralization character for laps/minutes

    -- Example format: { min_players, max_players, score_limit }

    -- Custom game mode score limits:
    game_modes = {
        ['example_game_mode'] = {
            { 1, 4, 25 },
            { 5, 8, 35 },
            { 9, 12, 45 },
            { 13, 16, 50 },
            'Score limit changed to: $limit'
        },
        ['another_example_game_mode'] = {
            { 1, 4, 25 },
            { 5, 8, 35 },
            { 9, 12, 45 },
            { 13, 16, 50 },
            'Score limit changed to: $limit'
        },
    },

    -- Default game type score limits:
    default_modes = {
        ctf = {
            { { 1, 4, 1 }, { 5, 8, 2 }, { 9, 12, 3 }, { 13, 16, 4 }, 'Score limit changed to: $limit' }
        },
        slayer = {
            {   -- Free-for-All:
                { 1, 4, 15 }, { 5, 8, 25 }, { 9, 12, 45 }, { 13, 16, 50 }, 'Score limit changed to: $limit'
            },
            {   -- Team Slayer:
                { 1, 4, 25 }, { 5, 8, 35 }, { 9, 12, 45 }, { 13, 16, 50 }, 'Score limit changed to: $limit'
            }
        },
        king = {
            {   -- Free-for-All:
                { 1, 4, 2 }, { 5, 8, 3 }, { 9, 12, 4 }, { 13, 16, 5 }, 'Score limit changed to: $limit minute$s'
            },
            {   -- Team King:
                { 1, 4, 3 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: $limit minute$s'
            }
        },
        oddball = {
            {   -- Free-for-All:
                { 1, 4, 2 }, { 5, 8, 3 }, { 9, 12, 4 }, { 13, 16, 5 }, 'Score limit changed to: $limit minute$s'
            },
            {   -- Team Oddball:
                { 1, 4, 3 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: $limit minute$s'
            }
        },
        race = {
            {   -- Free-for-All:
                { 1, 4, 4 }, { 5, 8, 4 }, { 9, 12, 5 }, { 13, 16, 6 }, 'Score limit changed to: $limit lap$s'
            },
            {   -- Team Race:
                { 1, 4, 4 }, { 5, 8, 5 }, { 9, 12, 6 }, { 13, 16, 7 }, 'Score limit changed to: $limit lap$s'
            }
        }
    }
}

-----------------------------------------
-- Config ends here, do not edit below --
-----------------------------------------

api_version = "1.12.0.0"


-- Variables to hold dynamic values:
local score_table, current_limit

-- Register script events:
function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

-- Set the score table based on game mode or type:
local function SetScoreTable(mode, game_type)
    score_table = config.game_modes[mode]
    if not score_table then
        local ffa = (get_var(0, '$ffa') == '1')
        score_table = (ffa and config.default_modes[game_type][1]) or config.default_modes[game_type][2]
    end
end

-- Get pluralization character (s):
local function GetPluralizationChar(n)
    return (n > 1 and 's') or ''
end

-- Generate message for new score limit:
local function GenerateScoreLimitMessage(limit)
    local message = score_table[#score_table]
    return message:gsub('$limit', limit):gsub('$s', GetPluralizationChar(limit))
end

-- Modify the score limit based on player count:
local function ModifyScoreLimit(isPlayerQuitting)
    if score_table then
        local player_count = tonumber(get_var(0, '$pn'))
        for _, limit_data in ipairs(score_table) do
            local min, max, limit = limit_data[1], limit_data[2], limit_data[3]
            if min and ((isPlayerQuitting and player_count - 1 >= min) or player_count >= min) and player_count <= max and limit ~= current_limit then
                current_limit = limit
                execute_command('scorelimit ' .. limit)
                local msg = GenerateScoreLimitMessage(limit)
                say_all(msg)
                cprint(msg, 10)
            end
        end
    end
end

function OnStart()
    score_table, current_limit = nil, nil
    local game_type = get_var(0, '$gt')
    local mode = get_var(0, '$mode')

    if game_type ~= 'n/a' then
        SetScoreTable(mode, game_type)
        ModifyScoreLimit()
    end
end

function OnEnd()
    score_table = nil
end

function OnJoin()
    ModifyScoreLimit()
end

function OnQuit()
    ModifyScoreLimit(true)
end

function OnScriptUnload()
    -- N/A
end