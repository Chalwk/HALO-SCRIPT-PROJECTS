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

-- config starts
local delay = 5 -- How often to balance teams in seconds
-- config ends

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
end

local function getTeamCounts()
    local reds, blues = 0, 0
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

    if reds > blues then
        for i = 1, 16 do
            if player_present(i) and switchTeam(i, "red", "blue") then
                break
            end
        end
    elseif blues > reds then
        for i = 1, 16 do
            if player_present(i) and switchTeam(i, "blue", "red") then
                break
            end
        end
    end
end

local lastBalanceTime = 0

function OnTick()
    local currentTime = os.clock()
    if currentTime - lastBalanceTime >= delay then
        lastBalanceTime = currentTime  -- Update last balance time
        if tonumber(get_var(0, "$pn")) > 0 then
            balanceTeams()
        end
    end
end

function OnScriptUnload()
    -- N/A
end