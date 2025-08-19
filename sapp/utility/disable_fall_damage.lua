--[[
===============================================================================
SCRIPT NAME:      disable_fall_damage.lua
DESCRIPTION:      Disables fall damage on configured maps by enabling jetpack
                  - Prevents player deaths from falls
                  - Map/gametype specific configuration
                  - Automatic activation

FEATURES:
                  - Simple configuration for any map
                  - Gametype-specific control
                  - Jetpack-based fall prevention

CONFIGURATION:    Edit the maps table to:
                  - Add maps where fall damage should be disabled
                  - Specify gametypes per map
                  - Set values to true to activate

Copyright (c) 2020 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = "1.12.0.0"

local maps = {
    ["putput"] = { ["game_mode_here"] = true },
    ["wizard"] = { ["game_mode_here"] = true },
    ["longest"] = { ["game_mode_here"] = true },
    ["ratrace"] = { ["game_mode_here"] = true },
    ["carousel"] = { ["game_mode_here"] = true },
    ["infinity"] = { ["game_mode_here"] = true },
    ["chillout"] = { ["game_mode_here"] = true },
    ["prisoner"] = { ["game_mode_here"] = true },
    ["damnation"] = { ["game_mode_here"] = true },
    ["icefields"] = { ["game_mode_here"] = true },
    ["bloodgulch"] = { ["game_mode_here"] = true },
    ["hangemhigh"] = { ["game_mode_here"] = true },
    ["sidewinder"] = { ["game_mode_here"] = true },
    ["timberland"] = { ["game_mode_here"] = true },
    ["beavercreek"] = { ["LNZ-GUN-GAME"] = true },
    ["deathisland"] = { ["game_mode_here"] = true },
    ["dangercanyon"] = { ["game_mode_here"] = true },
    ["gephyrophobia"] = { ["game_mode_here"] = true },
    ["boardingaction"] = { ["game_mode_here"] = true },
}

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

function OnStart()
    if (get_var(0, "$gt") ~= "n/a") then

        execute_command("cheat_jetpack false")

        local map = get_var(0, "$map")
        local mode = get_var(0, "$mode")

        if (maps[map] and maps[map][mode]) then
            execute_command("cheat_jetpack true")
        end
    end
end

function OnScriptUnload()
    -- N/A
end