--[[
===============================================================================
SCRIPT NAME:      auto_team_balance.lua
DESCRIPTION:      Automatically balances teams based on player counts with:
                  - Configurable balancing thresholds
                  - Multiple switching priority options
                  - Minimum player requirements

CONFIGURATION:    Adjust these settings in the CONFIG table:
                  - DELAY: Balancing frequency (seconds)
                  - MIN_PLAYERS: Minimum players before balancing
                  - MAX_DIFFERENCE: Allowed team size difference
                  - SWITCHING_PRIORITY: "smaller" or "larger" team preference

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Config Start --------------------------------------
local CONFIG = {
    DELAY = 300,                   -- How often to balance teams in seconds
    MIN_PLAYERS = 4,               -- Minimum number of players needed before balancing
    MAX_DIFFERENCE = 8,            -- Maximum difference allowed between teams before balancing
    SWITCHING_PRIORITY = "smaller" -- Options: "smaller" or "larger"
}
-- Config ends ----------------------------------------

api_version = "1.12.0.0"

local player_present, get_var = player_present, get_var

local last_balance_time
local os_time, math_abs, tonumber = os.time, math.abs, tonumber

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_GAME_END'], "OnEnd")
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    last_balance_time = 0
end

function OnEnd() -- post game carnage report showing, reset the timer
    last_balance_time = nil
end

local function getTeamCounts()
    local reds = tonumber(get_var(0, '$reds'))
    local blues = tonumber(get_var(0, '$blues'))

    return reds, blues
end

local function switchTeam(playerId, fromTeam, toTeam)
    local team = get_var(playerId, '$team')
    if team == fromTeam then
        execute_command("st " .. playerId .. " " .. toTeam)
        return true
    end
    return false
end

local function balanceTeams()
    local reds, blues = getTeamCounts()
    local total_players = reds + blues

    if total_players < CONFIG.MIN_PLAYERS * 2 or math_abs(reds - blues) <= CONFIG.MAX_DIFFERENCE then
        return
    end

    local fromTeam, toTeam
    if CONFIG.SWITCHING_PRIORITY == "smaller" then
        fromTeam, toTeam = reds > blues and "red" or "blue", reds > blues and "blue" or "red"
    else
        fromTeam, toTeam = reds < blues and "blue" or "red", reds < blues and "red" or "blue"
    end

    for i = 1, 16 do
        if player_present(i) and switchTeam(i, fromTeam, toTeam) then
            break
        end
    end
end

function OnTick()
    if last_balance_time == nil then return end

    local now = os_time()
    if now - last_balance_time >= CONFIG.DELAY then
        last_balance_time = now
        local total_players = tonumber(get_var(0, '$pn'))
        if total_players > 0 then
            balanceTeams()
        end
    end
end

function OnScriptUnload() end
