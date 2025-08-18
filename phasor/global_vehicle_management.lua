--[[
------------------------------------
Description: HPC Global Vehicle Management, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
-- About:
-- 		* Globally Block/Allow vehicle entry.
-- 		* Configure which vehicles are accessible on a GameType / Map basis.
Vehicle_List = "" -- Do Not Touch
Vehicles_Allowed = "" -- Do Not Touch
Blocked_Vehicles = "" -- Do Not Touch
Vehicle_Block_Message = "Sorry! You're not allowed to use this type of vehicle!\nType \"@vehicles\" for a list of usable vehicles."
function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
    if game == "PC" then
        gametype_base = 0x671340
    elseif game == "CE" then
        gametype_base = 0x5F5498
    end
    LoadTags()
end

function OnVehicleEntry(player, vehiId, seat, mapId, relevant)
    if relevant == true then
        local tagname, tagtype = gettaginfo(mapId)
        if AllowedToEnter(tagname) == false then
            privatesay(player, Vehicle_Block_Message, false)
            -- False to disable the server prefix!
            return false
            -- Block Entry
        elseif AllowedToEnter(tagname) == true then
            return true
            -- Allow Entry
        end
    end
end

-- 1).	Banshee: 			vehicles\\banshee\\banshee_mp
-- 2). 	Ghost: 				vehicles\\ghost\\ghost_mp
-- 3). 	Rocket Hog: 			vehicles\\rwarthog\\rwarthog
-- 4). 	Warthog: 			vehicles\\warthog\\mp_warthog
-- 5). 	Tank: 				vehicles\\scorpion\\scorpion_mp
-- 6). 	Turret: 			vehicles\\c gun turret\\c gun turret_mp
-- 	vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp
function VehicleSettings()
    if Map_Name == "bloodgulch" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            Vehicles_Allowed = "vehicles\\warthog\\mp_warthog | vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp"
            Vehicle_List = "* Chain Gun Hogs\n* Rocket Hogs\n* Ghosts"
        end
    elseif Map_Name == "dangercanyon" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Ghosts\n* Rocket Hogs"
        end
    elseif Map_Name == "deathisland" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Ghosts\n* Rocket Hogs"
        end
    elseif Map_Name == "hangemhigh" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Ghosts\n* Rocket Hogs"
        end
    elseif Map_Name == "icefields" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Rocket Hog\n* Ghost"
        end
    elseif Map_Name == "infinity" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\warthog\\mp_warthog | vehicles\\ghost\\ghost_mp | vehicles\\banshee\\banshee_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp"
            Vehicle_List = "* Chain Gun Hog\n* Ghost\n* Banshee"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Rocket Hog\n* Ghosts"
        end
    elseif Map_Name == "sidewinder" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Rocket Hog\n* Ghosts"
        end
    elseif Map_Name == "timberland" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Rocket Hog\n* Ghosts"
        end
    elseif Map_Name == "boardingaction" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        end
    elseif Map_Name == "gephyrophobia" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\scorpion\\scorpion_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Tank\n* Ghosts"
        elseif readstring(gametype_base, 0x2C) == "owv-3" then
            Vehicles_Allowed = "vehicles\\scorpion\\scorpion_mp | vehicles\\rwarthog\\rwarthog"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Vehicle_List = "* Tank\n* Rocket Hog"
        end
    elseif Map_Name == "ratrace" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            Vehicle_List = "* Ghost"
        end
    elseif Map_Name == "carousel" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            Vehicle_List = "* Ghost"
        elseif readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Ghost\n* Rocket Hog"
        end
    elseif Map_Name == "beavercreek" then
        if readstring(gametype_base, 0x2C) == "owv-1" then
            Vehicles_Allowed = "vehicles\\rwarthog\\rwarthog | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\banshee\\banshee_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\scorpion\\scorpion_mp | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Ghost\n* Rocket Hog"
        end
    elseif Map_Name == "damnation" then
        if readstring(gametype_base, 0x2C) == "owv-2" then
            Vehicles_Allowed = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp"
            Blocked_Vehicles = "vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            Vehicle_List = "* Banshee\n* Ghosts"
        end
    end
end

function AllowedToEnter(tagname)
    local allow = nil
    if string.find(tostring(Vehicles_Allowed), tagname) then
        allow = true
    elseif string.find(tostring(Blocked_Vehicles), tagname) then
        allow = false
    end
    return allow
end

function OnNewGame(map)
    LoadTags()
    Map_Name = tostring(map)
    VehicleSettings()
    gametype = readbyte(gametype_base + 0x30, 0x0)
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
end

function LoadTags()
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
end

function OnServerChat(player, type, message)

    local Message = string.lower(message)
    local t = tokenizestring(Message, " ")
    local count = #t

    if player ~= nil then
        if Message == "@vehicles" then
            privatesay(player, "Current vehicles allowed are: \n" .. tostring(Vehicle_List), false)
            return false
        end
    end
end

function readstring(address, length, endian)
    local char_table = { }
    local string = ""
    local offset = offset or 0x0
    if length == nil then
        if readbyte(address + offset + 1) == 0 and readbyte(address + offset) ~= 0 then
            length = 51000
        else
            length = 256
        end
    end
    for i = 0, length do
        if readbyte(address + (offset + i)) ~= 0 then
            table.insert(char_table, string.char(readbyte(address + (offset + i))))
        elseif i % 2 == 0 and readbyte(address + offset + i) == 0 then
            break
        end
    end
    for k, v in pairs(char_table) do
        if endian == 1 then
            string = v .. string
        else
            string = string .. v
        end
    end
    return string
end