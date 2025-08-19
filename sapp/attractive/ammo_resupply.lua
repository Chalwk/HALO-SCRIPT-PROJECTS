--[[
=====================================================================================
SCRIPT NAME:      ammo_resupply.lua
DESCRIPTION:      Adds a configurable '/res' command that allows players to:
                  - Replenish ammo, grenades, and battery
                  - Customizable resupply amounts
                  - Permission level restriction
                  - Cooldown timer between uses

                  Server operators can configure all aspects of the resupply.

Copyright (c) 2019-2024 Jericho Crosby
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]
-- Configuration table for the resupply script
local config = {

    -- Command to trigger the resupply
    command = 'res',

    -- Permission level required to use the command (-1 means no restriction)
    -- Default: -1
    permission_level = -1,

    -- Amount of ammo to resupply
    -- Default: 200
    ammo = 200,

    -- Amount of magazine to resupply
    -- Default: 500
    mag = 500,

    -- Number of frag grenades to resupply
    -- Default: 4
    frags = 4,

    -- Number of plasma grenades to resupply
    -- Default: 4
    plasmas = 4,

    -- Battery percentage to resupply
    -- Default: 100%
    battery = 100,

    -- Output message to display after resupply
    output = '[RESUPPLY] +200 ammo, +500 mag, +4 frags, +4 plasmas, +100% battery',

    -- Cooldown period in seconds before the command can be used again
    -- Default: 30 seconds
    cooldown = 30
}

-- SAPP Lua API Version
api_version = '1.12.0.0'

-- State variables
local last_resupply = {}

-- Function to check if a player has the required permission level
local function hasPermission(player_id)
    local level = tonumber(get_var(player_id, '$lvl'))
    return level >= config.permission_level
end

-- Function to handle the resupply command
local function handleResupplyCommand(player_id)
    local now = os.time()

    if config.cooldown > 0 and last_resupply[player_id] and now < last_resupply[player_id] + config.cooldown then
        local wait_time = math.floor(last_resupply[player_id] + config.cooldown - now)
        rprint(player_id, 'You must wait ' .. wait_time .. ' more seconds before resupplying.')
        return
    end

    last_resupply[player_id] = now

    -- Update ammo
    execute_command('ammo ' .. player_id .. ' ' .. config.ammo .. ' 5')
    execute_command('mag ' .. player_id .. ' ' .. config.mag .. ' 5')
    execute_command('battery ' .. player_id .. ' ' .. config.battery .. ' 5')

    -- Update grenades
    execute_command('nades ' .. player_id .. ' ' .. config.frags .. ' 1')
    execute_command('nades ' .. player_id .. ' ' .. config.plasmas .. ' 2')

    rprint(player_id, config.output)
end

-- Event handler for command execution
function OnCommand(player_id, command)
    if command:sub(1, #config.command):lower() == config.command then
        if hasPermission(player_id) then
            handleResupplyCommand(player_id)
        else
            rprint(player_id, 'Insufficient Permission')
        end
        return false
    end
end

-- Event handler for script load
function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
end

-- Event handler for script unload
function OnScriptUnload()
    -- No cleanup required
end