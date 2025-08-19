--[[
===============================================================================
SCRIPT NAME:      custom_command_cooldowns.lua
DESCRIPTION:      Prevents command spamming by enforcing:
                  - Custom cooldown timers per command
                  - Player-specific usage tracking
                  - Clear cooldown feedback

FEATURES:
                  - Simple configuration for any command
                  - Precise cooldown timing
                  - Helpful player notifications

CONFIGURATION:    Add commands to commandCooldowns table:
                  - Format: ["/command"] = cooldown_seconds
                  - Example: ["/heal"] = 30 (30 second cooldown)

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = "1.12.0.0"

---------------------------------
-- config starts
---------------------------------
local commandCooldowns = {
    -- Example commands:
    ["/teleport"] = 10, -- 10 seconds cooldown for teleport command
    ["/team"] = 5, -- 5 seconds cooldown for team command
    ["/heal"] = 30, -- 30 seconds cooldown for heal command
    -- Add more commands here...
}
---------------------------------
-- config ends
---------------------------------

-- table to hold the last used time for each command
local playerCooldowns = {}

local function canUseCommand(playerId, command)
    local currentTime = os.clock()
    local lastUsedTime = playerCooldowns[playerId] and playerCooldowns[playerId][command]

    if lastUsedTime then
        local cooldownTime = commandCooldowns[command]
        if currentTime - lastUsedTime < cooldownTime then
            -- Not enough time has passed, so the command is on cooldown
            local remainingTime = cooldownTime - (currentTime - lastUsedTime)
            local message = string.format("You must wait %.1f seconds before using this command again.", remainingTime)
            rprint(playerId, message)
            return false
        end
    end
    -- Command can be used
    return true
end

local function updateCommandCooldown(playerId, command)
    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = {}
    end
    playerCooldowns[playerId][command] = os.clock()
end

function onCommand(playerId, command, params)
    -- Check if the command exists in the cooldown table
    if commandCooldowns[command] then
        -- Check if the player can use the command based on the cooldown
        if canUseCommand(playerId, command) then
            updateCommandCooldown(playerId, command)
            -- Update the cooldown after successful execution
            return true
        end
        return false
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_COMMAND"], "onCommand")
    register_callback(cb["EVENT_GAME_START"], "onStart")
    onStart()
end

function OnScriptUnload()
    -- N/A
end

function onStart()
    if get_var(0, "$gt") == "n/a" then
        playerCooldowns = {}
    end
end