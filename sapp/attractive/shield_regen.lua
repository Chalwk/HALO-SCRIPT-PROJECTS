--[[
=====================================================================================
SCRIPT NAME:      shield_regen.lua
DESCRIPTION:      As soon as you receive damage, your shields will immediately start regenerating.

Copyright (c) 2022-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]


api_version = "1.12.0.0"

-- Time until shields begin regenerating (in ticks) - 1/30th tick = 1 second
-- 0 = instant
local delay = 0

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local dyn = get_dynamic_player(i)
            if (dyn ~= 0 and read_float(dyn + 0xE4) < 1) then
                write_word(dyn + 0x104, delay)
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end
