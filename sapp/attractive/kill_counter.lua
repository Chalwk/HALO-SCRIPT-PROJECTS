--[[
=====================================================================================
SCRIPT NAME:      kill_counter.lua
DESCRIPTION:      This mod was requested by someone called planetX2 on opencarnage.net.

Copyright (c) 2022-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

local output = "Kill Counter: $kills"

function OnScriptLoad()
    register_callback(cb['EVENT_DIE'], 'OnDeath')
end

function OnDeath(Victim, Killer)

    local killer = tonumber(Killer)
    local victim = tonumber(Victim)

    if (killer > 0 and killer ~= victim) then
        local kills = tonumber(get_var(killer, '$kills'))
        local str = output:gsub('$kills', kills)
        rprint(killer,str)
    end
end

function OnScriptUnload()
    -- N/A
end