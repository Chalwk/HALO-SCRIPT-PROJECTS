--[[
=====================================================================================
SCRIPT NAME:      auto_lead.lua
DESCRIPTION:      Dynamic projectile lead control system that:
                  - Automates SAPP's no-lead feature per map/gametype
                  - Customizable configuration table:
                    * Map-specific settings
                    * Gametype-specific overrides
                  - Real-time adjustment during:
                    * Map rotations
                    * Gametype changes
                  - Supports all standard Halo projectile types

Copyright (c) 2019-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

-- Configure settings with a map-gametype structure:
-- ["mapName"] = {
--   ["gametype"] = noLeadSetting,
--   ...
-- }
--   ... repeat for each map

local settings = {
    ["example_map"] = { ["gametype_name_here"] = 1, ["another_gametype"] = 1 },
    ["beavercreek"] = { },
    ["bloodgulch"] = { },
    ["boardingaction"] = { },
    ["carousel"] = { },
    ["dangercanyon"] = { },
    ["deathisland"] = { },
    ["gephyrophobia"] = { },
    ["icefields"] = { },
    ["infinity"] = { },
    ["sidewinder"] = { },
    ["timberland"] = { },
    ["hangemhigh"] = { },
    ["ratrace"] = { },
    ["damnation"] = { },
    ["putput"] = { },
    ["prisoner"] = { },
    ["wizard"] = { },
}

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if (get_var(0, "$gt") ~= "n/a") then
        timer(1000, "SetLead")
    end
end

function SetLead()
    local map = get_var(0, "$map")
    local mode = get_var(0, "$mode")
    if settings[map] and settings[map][mode] then
        execute_command("no_lead " .. tostring(settings[map][mode]))
    end
end

function OnScriptUnload()

end