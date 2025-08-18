--[[
=====================================================================================
SCRIPT NAME:      kill_zones.lua
DESCRIPTION:      Configurable danger zone system with:
                  - Map-specific kill zones:
                    * Custom locations and radii
                    * Adjustable kill delay timers
                  - Player warnings:
                    * Countdown notifications
                    * Custom alert messages
                  - Team support:
                    * FFA and team-specific zones
                    * Custom death messages

Copyright (c) 2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

local config = {
    -- MESSAGES:
    warningMessage = "Warning: Forbidden zone [%]!",
    killMessage = "Player $name was killed for staying too long in zone $zone.",
    serverPrefix = "SERVER",

    -- KILL ZONE SETTINGS:
    -- team                 = Player Team: 'red', 'blue', 'FFA'
    -- x, y, z, radius      = Zone coordinates.
    -- seconds until death  = A player has this many seconds to leave a kill zone or they are killed.
    ['bloodgulch'] = {
        { 'FFA', 82.68, -114.61, 0.67, 5, 15, "Base Camp" },
        -- Add more zones for bloodgulch or other maps.
    },
    -- Add more maps and zones as needed.
}

local ffa
local zones = {}
local players = {}

-- Load the kill zones for the current map.
local function loadZones()
    local map = get_var(0, '$map')
    zones = config[map]
    return zones and #zones > 0 or nil
end

-- Register callbacks and set up the game state when the script is loaded.
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnStart")
end

-- Initialize the script on game start.
function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}
        ffa = (get_var(0, '$ffa') == '1')

        if loadZones() then
            register_callback(cb['EVENT_TICK'], "OnTick")
            register_callback(cb['EVENT_JOIN'], "OnJoin")
            register_callback(cb['EVENT_LEAVE'], "OnQuit")
            register_callback(cb['EVENT_TEAM_SWITCH'], "OnTeamSwitch")
        else
            unregister_callback(cb['EVENT_TICK'])
            unregister_callback(cb['EVENT_JOIN'])
            unregister_callback(cb['EVENT_LEAVE'])
            unregister_callback(cb['EVENT_TEAM_SWITCH'])
        end
    end
end

-- Handle a player joining the game.
function OnJoin(id)
    players[id] = {
        id = id,
        team = ffa and 'FFA' or get_var(id, '$team'),
        name = get_var(id, '$name')
    }
end

-- Remove player data when they leave the game.
function OnQuit(id)
    players[id] = nil
end

-- Update the player's team when they switch.
function OnTeamSwitch(id)
    local player = players[id]
    if player then
        player.team = get_var(id, '$team')
    end
end

-- Kill the player and broadcast a message when they fail to leave a kill zone.
local function killPlayer(player, zoneName)
    execute_command("kill " .. player.id)
    local message = config.killMessage:gsub("$name", player.name):gsub("$zone", zoneName)
    say_all(message)
    cprint(message, 10)
end

-- Warn the player with a countdown message when they enter a kill zone.
local function warn(player, remaining)
    execute_command('msg_prefix ""')
    local message = config.warningMessage:gsub('%%', remaining)

    -- Clear existing HUD lines to avoid message overlap.
    for _ = 1, 25 do
        rprint(player.id, " ")
    end

    -- Show the warning message.
    rprint(player.id, message)
    execute_command('msg_prefix "' .. config.serverPrefix .. '"')
end

-- Start the timer for a player in a kill zone.
local function startTimer(player, killDelay)
    if not player.timer then
        player.timer = {
            start = os.clock(),
            remaining = killDelay,
        }
    end
end

-- Update the player's kill timer, issuing warnings and killing them when necessary.
local function updateTimer(player, zoneName)
    if player.timer then
        local elapsed = os.clock() - player.timer.start
        if elapsed < player.timer.remaining then
            warn(player, math.floor(player.timer.remaining - elapsed))
        else
            player.timer = nil
            killPlayer(player, zoneName)
        end
    end
end

-- Get the player's current position (supports crouching and vehicles).
local function getPlayerPosition(dyn)
    local x, y, z
    local crouch = read_float(dyn + 0x50C)
    local vehicle = read_dword(dyn + 0x11C)
    local object = get_object_memory(vehicle)

    x, y, z = read_vector3d(dyn + 0x5C)

    if vehicle == 0xFFFFFFFF then
        z = crouch == 0 and z + 0.65 or z + 0.35 * crouch
    elseif object ~= 0 then
        x, y, z = read_vector3d(object + 0x5C)
    end

    return { x = x, y = y, z = z }
end

-- Check if the player is outside the kill zone.
local function isPlayerOutsideZone(playerPosition, zone)
    local maxDistance = zone.radius
    local dx = math.abs(playerPosition.x - zone.x)
    local dy = math.abs(playerPosition.y - zone.y)
    local dz = math.abs(playerPosition.z - zone.z)
    return dx > maxDistance or dy > maxDistance or dz > maxDistance
end

-- Check if a player is in a kill zone and start or update the timer accordingly.
local function checkPlayerZoneAndTimer(player)
    local dyn = get_dynamic_player(player.id)
    if dyn == 0 then
        return
    end
    for _, zone in ipairs(zones) do
        local zonePosition = {
            x = zone[2], y = zone[3], z = zone[4], radius = zone[5]
        }
        local playerPosition = getPlayerPosition(dyn)
        if not isPlayerOutsideZone(playerPosition, zonePosition) then
            startTimer(player, zone[6])
        elseif player.timer then
            player.timer = nil
        end
    end
end

-- Periodically check all players to see if they are in a kill zone.
function OnTick()
    for i = 1, 16 do
        local player = players[i]
        if player and player_present(i) and player_alive(i) then
            checkPlayerZoneAndTimer(player)
            updateTimer(player, zones[1][7]) -- Update with zone name
        end
    end
end

function OnScriptUnload()
    -- No actions needed on unload.
end