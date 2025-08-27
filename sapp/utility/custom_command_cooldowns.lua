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
                  - Format: ["command"] = cooldown_seconds
                  - Example: ["heal"] = 30 (30 second cooldown)

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = "1.12.0.0"

-- Config Start ---------------------------------------------------------
local COMMANDS = {
    -- Example commands:
    ["teleport"] = 10, -- 10 seconds cooldown for teleport command
    ["team"] = 5,      -- 5 seconds cooldown for team command
    ["heal"] = 30,     -- 30 seconds cooldown for heal command

    -- Add more commands here...
}

local WAIT_MESSAGE = "You must wait %.1f seconds before using this command again."
-- Config End -----------------------------------------------------------

-- table to hold the last used time for each command
local cooldowns = {}
local os_time = os.time

local function canUseCommand(playerId, command, now, cooldownTime)
    local lastUsedTime = cooldowns[playerId] and cooldowns[playerId][command]

    if lastUsedTime then
        if now - lastUsedTime < cooldownTime then
            -- Not enough time has passed, so the command is on cooldown
            local remainingTime = cooldownTime - (now - lastUsedTime)
            local message = string.format(WAIT_MESSAGE, remainingTime)
            rprint(playerId, message)
            return false
        end
    end

    -- Command can be used
    return true
end

function OnCommand(playerId, command)
    -- Allow commands from console
    if playerId == 0 then return true end

    -- Check if the command exists in the cooldown table
    local cooldown_time = COMMANDS[command]
    if cooldown_time then
        local now = os_time()

        -- Check if the player can use the command based on the cooldown
        if canUseCommand(playerId, command, now, cooldown_time) then
            -- Update the cooldown after successful execution
            cooldowns[playerId] = cooldowns[playerId] or {}
            cooldowns[playerId][command] = now
            return true
        end
        return false
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return nil end
    cooldowns = {}
end

function OnScriptUnload() end
