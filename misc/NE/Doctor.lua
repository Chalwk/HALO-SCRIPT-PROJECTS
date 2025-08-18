--[[
=====================================================================================
SCRIPT NAME:      doctor_heal.lua
DESCRIPTION:      On-demand player healing system with configurable options.

                  Command:
                  /heal - Restores health (configurable amount)

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

--=====================================
-- CONFIGURATION
--=====================================
local dr_command        = "dr"       -- Custom command to call a doctor
local increment         = 0.1016     -- Health regen increment per tick
local permission_level  = -1         -- Minimum permission level (-1 = all players)

local messages = {
    "Health is regenerating...",           -- [1]
    "You already have full health!",       -- [2]
    "You do not have permission to execute that command!", -- [3]
    "Please wait until you respawn!"        -- [4]
}

api_version = "1.12.0.0"

--=====================================
-- PERFORMANCE CACHES
--=====================================
local lower           = string.lower
local gmatch          = string.gmatch
local tonumber        = tonumber
local read_float      = read_float
local write_float     = write_float
local player_alive    = player_alive
local get_var         = get_var
local rprint          = rprint
local get_dynamic_player = get_dynamic_player
local register_callback = register_callback
local cb              = cb
local timer           = timer

--=====================================
-- HELPERS
--=====================================
local function StrSplit(str)
    local args = {}
    for param in gmatch(str, "([^%s]+)") do
        args[#args+1] = lower(param)
    end
    return args
end

local function GetHealth(dyn)
    return read_float(dyn + 0xE0)
end

function Regen(id)
    if player_alive(id) then
        local dyn = get_dynamic_player(id)
        local health = GetHealth(dyn)
        if health < 1 then
            local newHealth = health + increment
            write_float(dyn + 0xE0, (newHealth > 1) and 1 or newHealth)
        else
            return false
        end
    end
    return true
end

function OnCommand(id, command)
    local args = StrSplit(command)
    if args[1] == dr_command then
        if tonumber(get_var(id, "$lvl")) >= permission_level then
            if player_alive(id) then
                local dyn = get_dynamic_player(id)
                local health = GetHealth(dyn)
                if health >= 1 then
                    rprint(id, messages[2])
                else
                    rprint(id, messages[1])
                    timer(1000, "Regen", id)
                end
            else
                rprint(id, messages[4])
            end
        else
            rprint(id, messages[3])
        end
        return false
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
end

function OnScriptUnload() end