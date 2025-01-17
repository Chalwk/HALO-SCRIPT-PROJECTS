--[[
--=====================================================================================================--
Script Name: Name Ban, for SAPP (PC & CE)
Description: Automatically kicks or bans players that join with "default" names after a grace period.

Copyright (c) 2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- config starts --

-- Valid actions: "kick" or "ban"
--
local action = 'kick'

-- Ban time (in minutes), requires action to be set to "ban".
--
local time = 10

-- Grace period (in seconds).
--
local grace = 30

-- Action reason:
--
local reason = 'Sorry! Default names not allowed! You will be kicked in %d seconds.'

-- List of names to kick/ban:
--
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
    action = (action == "kick" and 'k $n' or 'ipban $n ' .. time) .. ' "' .. reason .. '"'
    players = {}
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_TICK"], "OnTick")
end

function OnJoin(playerId)
    local name = get_var(playerId, "$name")
    for _, banned_name in ipairs(banned_names) do
        if name:lower() == banned_name:lower() then
            players[playerId] = {
                timer = os.clock() + grace,
                action_taken = false
            }
            break
        end
    end
end

local function inform(playerId, data)
    local time_left = math.ceil(data.timer - os.clock())
    rprint(playerId, string.format(reason, time_left))
end

function OnTick()
    for playerId, data in pairs(players) do
        if player_present(playerId) and not data.action_taken then
            if os.clock() >= data.timer then
                execute_command(string.format("%s %d", action, playerId))
                data.action_taken = true
            else
                inform(playerId, data)
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