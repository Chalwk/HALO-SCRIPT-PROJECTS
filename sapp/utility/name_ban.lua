--[[
=====================================================================================
SCRIPT NAME:      name_ban.lua
DESCRIPTION:      Default name protection system with automated enforcement.

FEATURES:
                  - Detects and blocks default player names
                  - Configurable grace period before action
                  - Multiple enforcement options:
                    * Kick offenders immediately
                    * Ban repeat violators temporarily
                  - Customizable warning messages
                  - Easily extensible banned names list

CONFIGURATION:
                  - Set action type (kick/ban) and duration
                  - Adjust grace period (seconds)
                  - Customize warning/ban messages
                  - Edit banned names list as needed

USAGE:
                  - Configure settings at top of script
                  - System runs automatically on player join
                  - No admin commands needed

Copyright (c) 2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- config starts --

-- Valid actions: "kick" or "ban"
local action = 'kick'

-- Ban time (in minutes), requires action to be set to "ban".
local time = 10

-- Grace period (in seconds).
local grace = 5

-- Action reason:
local reason = "Default names not allowed!"

-- Warning message:
local warning = "Default names are not allowed! You will be kicked in %d seconds."

-- List of names to kick/ban:
local banned_names = {
    'Butcher', 'Caboose', 'Crazy', 'Cupid', 'Darling', 'Dasher',
    'Disco', 'Donut', 'Dopey', 'Ghost', 'Goat', 'Grumpy',
    'Hambone', 'Hollywood', 'Howard', 'Jack', 'Killer', 'King',
    'Mopey', 'New001', 'Noodle', 'Nuevo001', 'Penguin', 'Pirate',
    'Prancer', 'Saucy', 'Shadow', 'Sleepy', 'Snake', 'Sneak',
    'Stompy', 'Stumpy', 'The Bear', 'The Big L', 'Tooth',
    'Walla Walla', 'Weasel', 'Wheezy', 'Whicker', 'Whisp',
    'Wilshire'
    -- Add more names as needed
}

-- config ends --

api_version = "1.12.0.0"

local players = {}

function OnScriptLoad()
    action = (action == "kick" and "k $n" or "ipban $n " .. time) .. ' "' .. reason .. '"'
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    players = {}
end

function OnJoin(playerId)
    local name = get_var(playerId, "$name")
    for _, banned_name in ipairs(banned_names) do
        if name:lower() == banned_name:lower() then
            players[playerId] = {
                timer = os.clock() + grace
            }
            break
        end
    end
end

local function inform(playerId, data)
    for _ = 1, 25 do
        rprint(playerId, " ")
    end
    local time_left = math.ceil(data.timer - os.clock())
    rprint(playerId, string.format(warning, time_left))
end

function OnTick()
    for playerId, data in pairs(players) do
        if player_present(playerId) and data.timer then
            inform(playerId, data)
            if os.clock() > data.timer then
                data.timer = nil
                execute_command(action:gsub("$n", playerId))
            end
        end
    end
end

function OnQuit(playerId)
    players[playerId] = nil
end

function OnScriptUnload()
    -- N/A
end