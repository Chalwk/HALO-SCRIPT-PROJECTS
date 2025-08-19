--[[
===============================================================================
SCRIPT NAME:      delay_skip.lua
DESCRIPTION:      Prevents premature map skipping by enforcing:
                  - Configurable minimum wait time
                  - Clear countdown feedback
                  - Simple chat command integration

FEATURES:
                  - Customizable delay duration
                  - Player-friendly time reminders
                  - Automatic game state tracking

CONFIGURATION:    Adjust these settings:
                  - skipDelay: Minimum wait time in seconds
                  - skipDelayMessage: Custom countdown message

Copyright (c) 2020-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Configuration section:
-- Minimum time players must wait before they can skip the map:
local skipDelay = 300

-- Configure the skip delay message template:
local skipDelayMessage = 'Please wait %s %s before skipping the map.'

-- Script API version:
api_version = "1.12.0.0"

-- Configuration ends here.

local gameStartTime

local function addPluralSuffix(n)
    return (n > 1 and 's') or ''
end

local function getRemainingTime()
    return math.ceil(gameStartTime + skipDelay - os.clock())
end

local format = string.format

function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], 'Skip')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
end

function Skip(playerIndex, message)
    if gameStartTime and message:lower() == 'skip' then
        local remainingTime = getRemainingTime()
        if remainingTime > 0 then
            rprint(playerIndex, format(skipDelayMessage, remainingTime, addPluralSuffix(remainingTime)))
            return false
        end
    end
end

function OnStart()
    gameStartTime = (get_var(0, '$gt') ~= 'n/a') and os.clock() or nil
end

function OnEnd()
    gameStartTime = nil
end

function OnScriptUnload() end