--[[
--=====================================================================================================--
Script Name: Give Passenger Weapon, for SAPP (PC & CE)
Description: Assigns a custom weapon when someone enters the passengers seat of a vehicle

* Requested by "mdc81" on opencarnage.net

UNFORTUNATELY, THIS MOD DOES NOT WORK! DO NOT USE.

Copyright (c) 2016-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]

--[[
    -- valid weapon tags
    "weapons\\assault rifle\\assault rifle"
    "weapons\\ball\\ball"
    "weapons\\flag\\flag"
    "weapons\\flamethrower\\flamethrower"
    "weapons\\needler\\mp_needler"
    "weapons\\pistol\\pistol"
    "weapons\\plasma pistol\\plasma pistol"
    "weapons\\plasma rifle\\plasma rifle"
    "weapons\\plasma_cannon\\plasma_cannon"
    "weapons\\rocket launcher\\rocket launcher"
    "weapons\\shotgun\\shotgun"
    "weapons\\sniper rifle\\sniper rifle"
]]

api_version = '1.12.0.0'

local vehicles = {
    ["vehicles\\warthog\\mp_warthog"] = "weapons\\sniper rifle\\sniper rifle",
    ['vehicles\\rwarthog\\rwarthog'] = 'weapons\\rocket launcher\\rocket launcher',
    ["vehicles\\scorpion\\scorpion_mp"] = "weapons\\plasma_cannon\\plasma_cannon",
}

function OnScriptLoad()
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnVehicleEntry')
end

local function GetObjectName(object)
    return read_string(read_dword(read_word(object) * 32 + 0x40440038))
end

local function GetWeapon(object)
    return vehicles[GetObjectName(object)]
end

function OnVehicleEntry(Ply)
    local dyn = get_dynamic_player(Ply)
    if dyn ~= 0 then
        local vehicle = read_dword(dyn + 0x11C)
        local object = get_object_memory(vehicle)
        if object ~= 0 then
            local weapon = GetWeapon(object)
            if weapon and read_word(dyn + 0x2F0) == 1 then
                assign_weapon(spawn_object('weap', weapon, 0, 0, 0), Ply)
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end