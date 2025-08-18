--[[
=====================================================================================
SCRIPT NAME:      aim_bot_scores.lua
DESCRIPTION:      Displays player accuracy statistics with customizable filters.

                  Command Syntax:
                  /aimstats [target] [mode]
                  - target: 1-16 | me | all | *
                  - mode: 0 (basic) | 1 (detailed)

                  Credits:
                  Original concept by mouseboyx (OpenCarnage)

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

local command = 'botscore'
local players = {}

-- Registering callbacks
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

-- Initialize players on game start
function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}
        for playerId = 1, 16 do
            if player_present(playerId) then
                OnJoin(playerId)
            end
        end
    end
end

-- Handle player ticks
function OnTick()
    for playerId, data in pairs(players) do
        if #data.suspects > 0 then
            data:clear(playerId)
            for _, suspect in ipairs(data.suspects) do
                rprint(playerId, string.format("%s: %s", suspect.name, suspect:score()))
            end
        end
    end
end

-- Split a string into a table of arguments
local function stringSplit(str)
    local args = {}
    for arg in str:gmatch('%S+') do
        args[#args + 1] = arg:lower()
    end
    return args
end

-- Check player permission
local function hasPermission(id)
    local lvl = tonumber(get_var(id, '$lvl'))
    if lvl >= 1 then
        return true
    end
    rprint(id, 'Insufficient Permission')
    return true
end

-- Get target players based on command arguments
local function getPlayers(playerId, args)
    local targets = {}
    local suspect = args[2]

    if suspect == 'me' and playerId ~= 0 then
        table.insert(targets, playerId)
    elseif tonumber(suspect) and player_present(tonumber(suspect)) then
        table.insert(targets, tonumber(suspect))
    elseif suspect == 'all' or suspect == '*' then
        for i = 1, 16 do
            if player_present(i) then
                table.insert(targets, i)
            end
        end
    else
        rprint(playerId, string.format("Invalid Player ID. Usage: /%s [1-16/me/all/*] [0/1]", command))
    end
    return targets
end

-- Determine whether to show scores
local function getShowScores(showScoresArg)
    return showScoresArg == '1' or showScoresArg == nil
end

-- Add a suspect to the player's list
local function addSuspect(playerId, suspect)
    table.insert(players[playerId].suspects, {
        name = get_var(suspect, '$name'),
        score = function()
            local botScore = get_var(suspect, '$botscore')
            return botScore .. (player_alive(suspect) and '' or ' [respawning]')
        end
    })
end

-- Handle commands from players
function OnCommand(playerId, cmd)
    local args = stringSplit(cmd)

    if args[1] == command and hasPermission(playerId) then
        local showScores = getShowScores(args[3])

        if not showScores then
            rprint(playerId, 'Hiding bot scores')
            players[playerId].suspects = {}
            return false
        end

        for _, pl in ipairs(getPlayers(playerId, args)) do
            addSuspect(playerId, pl)
        end
    end
end

-- Handle player joining
function OnJoin(playerId)
    players[playerId] = {
        suspects = {},
        clear = function(i)
            for _ = 1, 25 do rprint(i, ' ') end
        end
    }
end

-- Handle player quitting
function OnQuit(playerId)
    players[playerId] = nil
end

-- Handle script unloading
function OnScriptUnload()
    -- No specific actions needed on unload
end
