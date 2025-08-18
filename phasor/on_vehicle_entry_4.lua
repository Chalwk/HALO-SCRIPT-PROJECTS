--[[
------------------------------------
Description: HPC OnVehicleEntry (Advanced), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
logging = true
function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)

end

function OnScriptUnload()

end

function ScriptLoad()
    logging = true
end

function OnNewGame(map)
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
end

--[[
Warthog:
Seat 0 = Drivers Seat
Seat 1 = Passengers Seat
Seat 2 = Gunners Seat

Rocket Hog:
Seat 0 = Drivers Seat
Seat 1 = Passengers Seat
Seat 2 = Gunners Seat

Ghost, Banshee and Turret:
Seat 0 = Drivers Seat

Scorpion Tank
Seat 0 = Drivers Seat
Seat 1 - 5 = Passengers Seat
]]

-- 		P T S = Print to Server
--      P T P = Print to Player

function OnVehicleEntry(player, veh_id, seat, mapid, relevant)
    local name = getname(player)
    -- Retrieves Player Name
    if mapid == ghost_mapId then
        -- Ghost
        Vehicle_Name = "Ghost"
        PTP_Vehicle_Name = "SR-RAV  GHOST: "
        if seat == (0) then
            -- Drivers Seat
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        end

    elseif mapid == hog_mapId then
        -- // Warthog
        Vehicle_Name = "Warthog"
        PTP_Vehicle_Name = "WARTHOG: "
        if seat == (0) then
            -- Drivers Seat
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        elseif seat == (1) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            -- Gunners Seat
            PTS_seat_name = "Gunners"
            PTP_Seat_Name = "Gunners  Seat"
        end

    elseif mapid == tank_mapId then
        -- // Scorpion Tank
        Vehicle_Name = "Scorpion Tank"
        PTP_Vehicle_Name = "SCORPION TANK: "
        if seat == (0) then
            -- Drivers Seat
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Commanders  Seat"
        elseif seat == (1) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (3) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (4) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        end

    elseif mapid == banshee_mapId then
        -- // Banshee
        Vehicle_Name = "Banshee"
        PTP_Vehicle_Name = "BANSHEE: "
        if seat == (0) then
            -- Pilots Seat
            PTS_seat_name = "Piolts"
            PTP_Seat_Name = "Pilots  Seat"
        end

    elseif mapid == turret_mapId then
        -- // Covenant Turret
        Vehicle_Name = "Covenant Turret"
        PTP_Vehicle_Name = "COVENANT TURRET: "
        if seat == (0) then
            -- Drivers Seat
            PTS_seat_name = "Controllers"
            PTP_Seat_Name = "Controllers  Seat"
        end

    elseif mapid == rhog_mapId then
        -- // Rocket Hog
        Vehicle_Name = "Rocket hog"
        PTP_Vehicle_Name = "ROCKET HOG: "
        if seat == (0) then
            -- Drivers Seat
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        elseif seat == (1) then
            -- Passengers Seat
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            -- Gunners Seat
            PTS_seat_name = "Gunners"
            PTP_Seat_Name = "Gunners  Seat"
        end
    end
    sendconsoletext(player, " " .. tostring(PTP_Vehicle_Name) .. " " .. tostring(PTP_Seat_Name) .. ".")
    hprintf("     V E H I C L E   E N T R Y:\n     " .. tostring(name) .. " entered the " .. tostring(PTS_seat_name) .. " seat of a " .. tostring(Vehicle_Name) .. ".")
    if logging then
        log_msg(1, name .. " entered the " .. tostring(PTS_seat_name) .. " seat of a " .. tostring(Vehicle_Name) .. ".")
    end
    --[[
	local m_playerObjId = getplayerobjectid(player)
	local m_vehicleId = readdword(getobject(m_playerObjId) + 0x11C)
		if m_playerObjId then
			if isinvehicle(player) then
         m_objectId = m_vehicleId
    elseif m_playerObjId then
         m_objectId = m_playerObjId
            end
				if m_objectId then
    local x,y,z = getobjectcoords(m_objectId)
				respond("Coodrinates: X: " .. x .. " Y: " .. y .. " Z: " .. z)
			end
		end
	return true
]]
end