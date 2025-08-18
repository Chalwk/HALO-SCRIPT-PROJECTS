--[[
--=====================================================================================================--
Script Name: SkipDelay, for SAPP (PC & CE)
Description: Prevent players from skipping the map too early.

Copyright (c) 2020-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- Configuration section:
-- Minimum time players must wait before they can skip the map:
local skipDelay = 300

-- Configure the skip delay message template:
local skipDelayMessage = 'Please wait %s %s before skipping the map.'

-- Script API version:
api_version = "1.12.0.0"

-- Configuration ends here.

-- Tracks the time when the game starts:
local gameStartTime

-- Local helper function to add a plural suffix if needed:
local function addPluralSuffix(n)
    return (n > 1 and 's') or ''
end

-- Calculates remaining time before players can skip:
local function getRemainingTime()
    return math.ceil(gameStartTime + skipDelay - os.clock())
end

-- Local references to built-in functions:
local format = string.format

-- Script events and functions:
function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], 'Skip')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
end

-- Handles skipping the map:
function Skip(playerIndex, message)
    if gameStartTime and message:lower() == 'skip' then
        local remainingTime = getRemainingTime()
        if remainingTime > 0 then
            rprint(playerIndex, format(skipDelayMessage, remainingTime, addPluralSuffix(remainingTime)))
            return false
        end
    end
end

-- Called when a game starts:
function OnStart()
    gameStartTime = (get_var(0, '$gt') ~= 'n/a') and os.clock() or nil
end

-- Called when a game ends:
function OnEnd()
    gameStartTime = nil
end

-- Placeholder function for unloading the script:
function OnScriptUnload()
    -- N/A
end