--[[
------------------------------------
Description: HPC Vehicle Triggered Portals (OWV Server), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
Script Version: 2.5
-----------------------------------
]]--

seat = { }
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnNewGame(map)
    gamemap = map
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    overshield_tag_id = gettagid("eqip", "powerups\\over shield")
end

function OnClientUpdate(player)
    if gamemap == "ladrangvalley" or gamemap == "bloodgulch" then
        if getplayer(player) then
            if inSphere(player, 84.106, -71.677, 16.636, 3.00) == true then
                if isplayerinvehicle(player) == true then
                    if seat[player] == 1 then
                        local m_vehicleId = getplayervehicleid(player)
                        local m_vehicle = getobject(m_vehicleId)
                        local name = getname(player)
                        if readdword(m_vehicle) == rhog_mapId then
                            if getpassengerplayer(m_vehicle) == player then
                                movobjectcoords(m_vehicleId, 55.223, -132.877, 1.142)
                                privatesay(player, "* * VEHICLE-TRIGGERED PORTAL * *", false)
                                hprintf("V T P  -  " .. name .. " Teleported using VTP at: Behind Blue Base (Above the Banshee)")
                                registertimer(1000, "delay_exitvehicle", player)
                                registertimer(1000, "GiveOS", player)
                            end
                        end
                    end
                end
            end
        end
    end
end

function GiveOS(id, count, player)
    if count == (2) then
        local m_playerObjId = getplayerobjectid(player)
        if m_playerObjId then
            local m_object = getobject(m_playerObjId)
            if m_object then
                local x, y, z = getobjectcoords(m_playerObjId)
                local os = createobject(overshield_tag_id, 0, 0, false, x, y, z + 0.5)
            end
        end
    end
    return true
end

function delay_exitvehicle(id, count, player)
    exitvehicle(player)
    return 0
end

function inSphere(player, x, y, z, radius)
    if getplayer(player) then
        local obj_x = readfloat(getplayer(player) + 0xF8)
        local obj_y = readfloat(getplayer(player) + 0xFC)
        local obj_z = readfloat(getplayer(player) + 0x100)
        local x_diff = x - obj_x
        local y_diff = y - obj_y
        local z_diff = z - obj_z
        local dist_from_center = math.sqrt(x_diff ^ 2 + y_diff ^ 2 + z_diff ^ 2)
        if dist_from_center <= radius then
            return true
        end
    end
    return false
end

function isplayerinvehicle(player)
    local m_object = getobject(getplayerobjectid(player))
    if m_object ~= nil then
        local m_vehicleId = readdword(m_object + 0x11C)
        if m_vehicleId == 0xFFFFFFFF then
            return false
        else
            return true
        end
    end
end

function OnPlayerLeave(player)
    checkplayer(player)
end

function OnPlayerKill(killer, victim, mode)
    if victim then
        checkplayer(victim)
    end
end

function OnVehicleEntry(player, m_vehicleId, seat_number, mapId, voluntary)
    if seat_number == 1 then
        registertimer(0, "assignpassenger", { getplayerobjectid(player), getobject(m_vehicleId) })
    end
    seat[player] = seat_number
    return nil
end

function OnVehicleEject(player, voluntary)
    checkplayer(player)
    return nil
end

function assignpassenger(id, count, arg)
    writedword(arg[2] + 0x32C, arg[1])
    return false
end

function checkplayer(player)
    if isinvehicle(player) then
        if seat[player] == 1 then
            resetpassenger(player)
        end
        seat[player] = nil
    end
end

function getpassengerobjid(m_vehicle)
    return readdword(m_vehicle + 0x32C)
end

function getpassengerplayer(m_vehicle)
    local obj_id = getpassengerobjid(m_vehicle)
    if obj_id ~= 0xFFFFFFFF then
        return objectidtoplayer(obj_id)
    end
end

function getplayervehicleid(player)
    local obj_id = getplayerobjectid(player)
    if obj_id then
        return readdword(getobject(obj_id) + 0x11C)
    end
end

function resetpassenger(player)
    writedword(getobject(getplayervehicleid(player)) + 0x32C, 0xFFFFFFFF)
end