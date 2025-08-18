--[[
--=====================================================================================================--
Script Name: Auto-Lead, for SAPP (PC & CE)
Description: This script automates the process of managing SAPP's no-lead feature based on specified
             map and game type configurations. The script enables or disables the no-lead feature for
             individual game types within each map, allowing for flexible and customizable control over
             gameplay mechanics. By configuring a settings table with desired map and game type combinations,
             the script provides an efficient way to optimize and tailor the gaming experience for various scenarios.
            
Copyright (c) 2019-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

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