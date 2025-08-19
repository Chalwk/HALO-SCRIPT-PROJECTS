--[[
=====================================================================================
SCRIPT NAME:      timed_server_password.lua
DESCRIPTION:      Automatically removes server password after configurable duration.

FEATURES:
                  - Set password expiration time (seconds)
                  - Automatic password clearing
                  - Server-wide notifications
                  - Admin command integration
                  - Simple configuration

CONFIGURATION:
                  duration = 300 - Password duration in seconds (5 minutes)
                  - Edit script directly to change duration

USAGE:
                  - Password automatically removes after set duration
                  - New passwords reset the timer
                  - Notifies players when password is removed

DEVELOPED FOR:    BK Clan (@Rev)

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration Starts ---------------------------
local duration = 300  -- Duration (in seconds) before the server password is removed
-- Configuration Ends -----------------------------

api_version = '1.12.0.0'

local currentTime, passwordRemovalTime = os.time, nil  -- Initialize time functions

-- Start the timer to remove the server password
local function StartTimer()
    passwordRemovalTime = nil  -- Reset the countdown
    if get_var(0, '$gt') ~= 'n/a' then
        passwordRemovalTime = currentTime() + duration  -- Set the removal time
    end
end

-- Load the script and register necessary callbacks
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'StartTimer')
    StartTimer()  -- Start the timer upon script load
end

-- Check each tick if the password should be removed
function OnTick()
    if passwordRemovalTime and currentTime() >= passwordRemovalTime then
        passwordRemovalTime = nil  -- Clear the countdown
        execute_command('sv_password ""')  -- Remove the server password
        say_all('Server password has been removed!')  -- Notify all players
    end
end

-- Split a string into lowercase arguments
local function stringSplit(str)
    local args = {}
    for arg in str:gmatch('([^%s]+)') do
        args[#args + 1] = arg:lower()
    end
    return args
end

-- Check if the player has permission to execute the command
local function hasPermission(playerId)
    return playerId == 0 or tonumber(get_var(playerId, '$lvl')) >= 4
end

-- Send a message to the player or to the console
local function sendMessage(playerId, message)
    if playerId == 0 then
        cprint(message)  -- Send to console
    else
        rprint(playerId, message)  -- Send to player
    end
end

-- Handle commands from players
function OnCommand(playerId, commandInput, _)
    local args = stringSplit(commandInput)
    if #args > 0 and args[1] == 'sv_password' and hasPermission(playerId) and args[2] then
        StartTimer()  -- Start the password removal timer
        sendMessage(playerId, 'Server password will be removed in ' .. duration .. ' seconds')
    end
end

function OnScriptUnload()
    -- N/A
end