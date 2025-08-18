--[[
=====================================================================================
SCRIPT NAME:      swat.lua
DESCRIPTION:      An extremely simple adaptation of 'swat' from Halo Reach.

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]


api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')
end

function OnDamage(victim, killer, _, damage, hitString)
    if (killer > 0 and victim ~= killer) then
        if (hitString == 'head') then
            return true, damage * 1000
        else
            return false
        end
    end
end