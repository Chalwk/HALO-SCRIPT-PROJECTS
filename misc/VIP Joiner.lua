--[[
Script Name: VIP Management, for SAPP (PC & CE)
Description: This script manages VIP player access and enforces player limits based on game modes.

Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
]]--

local VIP = {
    -- List of VIP players (case sensitive):
    names = {
        "Chalwk",
        "example_name",
    },

    -- Modes this script will work on:
    -- Format: ["example game mode"] = max player limit
    modes = {
        ["MyOddball"] = 2,
        -- Repeat the structure to add more entries:
    }
}

api_version = "1.12.0.0"

local playerLimit  -- Variable to store the maximum number of players allowed

-- Load the script and register the game start callback
function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
end

-- Start the script and set up player limits based on the game mode
function OnStart()
    if get_var(0, "$gt") ~= "n/a" then
        local currentMode = get_var(0, "$mode")
        if VIP.modes[currentMode] then
            playerLimit = VIP.modes[currentMode]
            register_callback(cb["EVENT_PREJOIN"], "OnPreJoin")
        else
            unregister_callback(cb["EVENT_PREJOIN"])
        end
    end
end

-- Check if a player is a VIP
local function IsVIP(playerName)
    for _, vipName in pairs(VIP.names) do
        if playerName == vipName then
            return true
        end
    end
    return false
end

-- Handle pre-join event for players
function OnPreJoin(playerId)
    local playerName = get_var(playerId, "$name")
    if IsVIP(playerName) then
        local nonVIPPlayers = {}

        -- Collect IDs of non-VIP players
        for i = 1, 16 do
            if player_present(i) then
                local currentPlayerName = get_var(i, "$name")
                if not IsVIP(currentPlayerName) then
                    table.insert(nonVIPPlayers, i)
                end
            end
        end

        -- If the number of non-VIP players equals the limit, kick a random one
        if #nonVIPPlayers == playerLimit then
            local randomIndex = rand(1, #nonVIPPlayers + 1)
            local playerToKick = nonVIPPlayers[randomIndex]
            execute_command("k " .. playerToKick)
        end
    end
end

function OnScriptUnload()
    -- N/A
end