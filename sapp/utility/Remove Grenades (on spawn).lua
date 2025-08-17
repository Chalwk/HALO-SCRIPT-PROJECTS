--[[
--=====================================================================================================--
Script Name: Disable Grenades, for SAPP (PC & CE)
Description: This script will remove nades (after spawning), on per game mode basis.
             Note: This does not prevent players from picking them up.

Copyright (c) 2020-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local modes = {

    --
    -- Simply list all of the game modes you want this script to disable grenades on.
    -- [MODE NAME] = ENABLED/DISABLED (true/false)
    --

    ["FFA Swat"] = true,
    ["put game mode here"] = true,
}

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then

        local mode = get_var(0, "$mode")
        if (modes[mode]) then
            register_callback(cb["EVENT_SPAWN"], "OnSpawn")
            cprint('Disabling grenades', 10)
            return true
        end
        unregister_callback(cb["EVENT_SPAWN"])
    end
end

function OnSpawn(Ply)
    execute_command('nades ' .. Ply .. ' 0')
end