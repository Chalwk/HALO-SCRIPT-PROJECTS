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

-- Rocket Hog on top of Turret Mountain - Overlooking Red Base.
coords = { }
seat = { }
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
        map_name = readstring(0x698F21)
        gametype_base = 0x671340
    else
        GAME = "CE"
        map_name = readstring(0x61D151)
        gametype_base = 0x5F5498
    end
    LoadCoords()
end
function OnNewGame(map)
    if GAME == "PC" then
        map_name = readstring(0x698F21)
        gametype_base = 0x671340
    elseif GAME == "CE" then
        map_name = readstring(0x61D151)
        gametype_base = 0x5F5498
    end
    gamemap = map
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    LoadCoords()
end

function LoadCoords()
    if map_name == "bloodgulch" then
        -- RED BEGIN --		
        coords[1] = { 56.451, -159.135, 20.954 }
        coords[2] = { 84.106, -71.677, 16.636 }

    end
end

function OnClientUpdate(player)
    if gamemap == "bloodgulch" then
        -- Checks to see that the Map matches the script.
        if getplayer(player) then
            -- Resolves Player
            if inSphere(player, coords) == true then
                -- Checks if the player is in the Portal Sphere
                if isplayerinvehicle(player) == true then
                    -- Checks whether the player is in the vehicle or not.
                    local m_vehicleId = getplayervehicleid(player)
                    local m_vehicle = getobject(m_vehicleId)
                    local name = getname(player)
                    if readdword(m_vehicle) == rhog_mapId then
                        -- Checks if the vehicle is a Rocket Hog.
                        if getpassengerplayer(m_vehicle) == player then
                            -- Checks if the player is in the Passengers seat.
                            movobjectcoords(m_vehicleId, 81.653, -119.480, 0.428)
                            -- Moves the passenger to these coordinates on the map.
                            privatesay(player, "* * VEHICLE-TRIGGERED PORTAL * *", false)
                            hprintf("* V T P * " .. name .. "Teleported using VTP at: Rocket Hog on top of Turret Mountain - Overlooking Red Base.")
                            registertimer(1000, "delay_exitvehicle", player)
                            -- registertimer(1000,"delay_exitvehicle",{player,m_vehicleId})							
                        end
                    end
                end
            end
        end
    end
end

function delay_exitvehicle(id, count, player)
    exitvehicle(player)
    return 0
end

--[[

function delay_destroy(id, count, t)
	destroyobject(t[1])
	return 0
end	


function delay_exitvehicle(id, count, t)
	exitvehicle(t[1])
	return 0
end

]]

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

--[[

function checkplayer(player)
        if seat[player] == 1 or seat[player] == 2 or seat[player] == 3  or seat[player] == 4 then resetpassenger(player) end
    seat[player] = nil
end

]]

function checkplayer(player)
    if seat[player] == 1 then
        resetpassenger(player)
    end
    seat[player] = nil
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