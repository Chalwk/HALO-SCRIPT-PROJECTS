--[[
------------------------------------
Description: HPC Vehicle Settings (standalone), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function VehicleSettings()
    if Map_Name == "bloodgulch" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            Vehicles_Allowed = "vehicles\\warthog\\mp_warthog | vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp"
            Vehicle_List = "Chain Gun Hogs\nRocket Hogs\nGhosts"
        end
        -- =======================================================================================================================================================================--
    elseif Map_Name == "dangercanyon" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\rwarthog\\rwarthog"
        end
    elseif Map_Name == "deathisland" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
        end
    elseif Map_Name == "hangemhigh" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp | vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "icefields" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee_mp\\banshee_mp", "vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "infinity" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\warthog\\mp_warthog | vehicles\\ghost\\ghost_mp | vehicles\\banshee\\banshee_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
        end
    elseif Map_Name == "sidewinder" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "timberland" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
        end
    elseif Map_Name == "boardingaction" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "gephyrophobia" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\scorpion\\scorpion_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-3" then
            Vehicles_Allowed = "vehicles\\scorpion\\scorpion_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp"
        end
    elseif Map_Name == "ratrace" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "carousel" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\ghost\\ghost_mp | vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "beavercreek" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
        end
    elseif Map_Name == "damnation" then
        if readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
        end
    end
end