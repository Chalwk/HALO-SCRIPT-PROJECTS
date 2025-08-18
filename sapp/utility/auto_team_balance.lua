--[[
--=====================================================================================================--
Script Name: Auto Team Balance, for SAPP (PC & CE)
Description: Automatically balances teams based on player count.

Copyright (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

-- Configuration
local config = {
    delay = 5, -- How often to balance teams in seconds
    minPlayersPerTeam = 4, -- Minimum number of players needed before balancing
    maxTeamDifference = 8, -- Maximum difference allowed between teams before balancing
    switchingPriority = "smaller" -- Options: "smaller" or "larger"
}
-- End Configurations

local lastBalanceTime = 0

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
end

local function getTeamCounts()
    local reds, blues
    for i = 1, 16 do
        if player_present(i) then
            local team = get_var(i, "$team")
            if team == "red" then
                reds = reds + 1
            elseif team == "blue" then
                blues = blues + 1
            end
        end
    end
    return reds, blues
end

local function switchTeam(playerId, fromTeam, toTeam)
    if get_var(playerId, "$team") == fromTeam then
        execute_command("st " .. playerId .. " " .. toTeam)
        return true
    end
    return false
end

local function balanceTeams()
    local reds, blues = getTeamCounts()
    local totalPlayers = reds + blues

    if totalPlayers < config.minPlayersPerTeam * 2 or math.abs(reds - blues) <= config.maxTeamDifference then
        return
    end

    local fromTeam, toTeam
    if config.switchingPriority == "smaller" then
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
    local currentTime = os.clock()
    if currentTime - lastBalanceTime >= config.delay then
        lastBalanceTime = currentTime
        if tonumber(get_var(0, "$pn")) > 0 then
            balanceTeams()
        end
    end
end

function OnScriptUnload()
    -- N/A
end