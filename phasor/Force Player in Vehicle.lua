--[[
------------------------------------
Description: HPC Force Player in Vehicle, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

Force_Player_In_Vehicle = true
Vehicle_Timer = 15
vehicleTag = nil
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

function LoadTags()
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
end

function OnNewGame(map)
    gametype = readbyte(gametype_base + 0x30, 0x0)
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    LoadTags()
end

function round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

function math.round(input, precision)
    return math.floor(input * (10 ^ precision) + 0.5) / (10 ^ precision)
end

function AssignVehicle(id, count, player)
    local m_objectId = getplayerobjectid(player)
    local m_object = getobject(m_objectId)
    if m_object ~= nil then
        local x, y, z = getobjectcoords(m_objectId)
        if Force_Player_In_Vehicle == false then
            x = x + 2
            z = z + 4
        end
        DetermineVehiclesForPlayer()
        local objid = createobject(gettagid("vehi", vehicleTag), -1, Vehicle_Timer, false, x, y, z)
        if objid ~= nil and objid ~= 0xffffffff then
            if getobject(objid) ~= nil then
                mapid = readdword(getobject(objid), 0)
            end
        end
        if objid ~= nil and Force_Player_In_Vehicle == true then
            entervehicle(player, objid, 0)
        end
    end
    return false
end

function OnPlayerSpawn(player)
    local m_objectId = getplayerobjectid(player)
    local m_object = getobject(m_objectId)
    if m_object ~= nil then
        registertimer(200, "AssignVehicle", player)
    end
end

function DetermineVehiclesForPlayer()
    local r = getrandomnumber(1, 4)
    if map_name == "bloodgulch" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\warthog\\mp_warthog"
            if r <= 2 then
                vehicleTag = "vehicles\\scorpion\\scorpion_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "dangercanyon" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "deathisland" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "hangemhigh" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "icefields" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "infinity" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "sidewinder" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\ghost\\ghost_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\rwarthog\\rwarthog"
            end
        end
    elseif map_name == "timberland" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\ghost\\ghost_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\rwarthog\\rwarthog"
            end
        end
    elseif map_name == "boardingaction" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
        end
    elseif map_name == "gephyrophobia" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\scorpion\\scorpion_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\scorpion\\scorpion_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\banshee\\banshee_mp"
            end
        end
    elseif map_name == "ratrace" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\ghost\\ghost_mp"
        end
    elseif map_name == "beavercreek" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\rwarthog\\rwarthog"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    elseif map_name == "carousel" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\ghost\\ghost_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\rwarthog\\rwarthog"
            end
        elseif readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\ghost\\ghost_mp"
        end
    elseif map_name == "damnation" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            vehicleTag = "vehicles\\banshee\\banshee_mp"
            if r <= 2 then
                vehicleTag = "vehicles\\ghost\\ghost_mp"
            end
        end
    end
end

function writewordsigned(address, offset, word)
    value = tonumber(word)
    if value == nil then
        value = tonumber(word, 16)
    end
    if value and value > 0x7FFF then
        local max = 0xFFFF
        local difference = max - value
        value = -1 - difference
    end
    writeword(address, offset, value)
end

function writedwordsigned(address, offset, dword)
    value = tonumber(dword)
    if value == nil then
        value = tonumber(dword, 16)
    end
    if value and value > 0x7FFFFFFF then
        local max = 0xFFFFFFFF
        local difference = max - value
        value = -1 - difference
    end
    writedword(address, offset, value)
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