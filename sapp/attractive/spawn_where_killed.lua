--[[
--=====================================================================================================--
Script Name: Spawn where killed, for SAPP (PC & CE)
Description: You will spawn where you died.

Copyright (c) 2016-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local loc = {}

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_DIE'], "OnDeath")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_PRESPAWN'], "OnPreSpawn")
end

local function GetXYZ(player)

    local x, y, z
    local dyn = get_dynamic_player(player)
    if (dyn ~= 0) then
        local vehicle = read_dword(dyn + 0x11C)
        local object = get_object_memory(vehicle)
        if (vehicle == 0xFFFFFFFF) then
            x, y, z = read_vector3d(dyn + 0x5C)
        elseif (object ~= 0) then
            x, y, z = read_vector3d(object + 0x5C)
        end
    end

    return x, y, z
end

function OnDeath(Victim, Killer)

    local victim = tonumber(Victim)
    local killer = tonumber(Killer)

    if (killer > 0) then
        local x, y, z = GetXYZ(victim)
        loc[victim] = { x, y, z }
    end
end

function OnPreSpawn(p)
    local dyn = get_dynamic_player(p)
    if (dyn ~= 0 and loc[p]) then

        local x = loc[p][1]
        local y = loc[p][2]
        local z = loc[p][3]

        write_vector3d(dyn + 0x5C, x, y, z)
        OnQuit(p)
    end
end

function OnQuit(p)
    loc[p] = nil
end

function OnScriptUnload()
    -- N/A
end