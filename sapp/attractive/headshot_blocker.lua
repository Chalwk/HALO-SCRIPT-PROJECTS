--[[
=====================================================================================
SCRIPT NAME:      headshot_blocker.lua
DESCRIPTION:      Prevent headshots

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "BlockHeadshots")
end

function BlockHeadshots(Victim, Killer, _, _, HitString, _)
    local k, v = tonumber(Killer), tonumber(Victim)
    if (k > 0 and k ~= v and HitString == "head") then
        return false
    end
end

function OnScriptUnload()
    -- N/A
end