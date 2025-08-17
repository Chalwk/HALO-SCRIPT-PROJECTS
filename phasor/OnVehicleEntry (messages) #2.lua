--[[
------------------------------------
Description: HPC OnVehicleEntry #2 (Advanced), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
Script Version: 3.5
-----------------------------------
]]--
-------------------------------------------------------
function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)

end

function OnScriptUnload()

end
-------------------------------------------------------

function OnNewGame(map)
    ghost_mapId = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    rhog_mapId = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    hog_mapId = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    banshee_mapId = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_mapId = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    tank_mapId = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
end
----------------------------------------------------------------------------------------

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
Seat 1 - 4 = Passengers Seat
]]

function OnVehicleEntry(player, veh_id, seat, mapid, relevant)
    local name = getname(player)
    if mapid == ghost_mapId then
        -- // Ghost
        PTC_Vehicle_Name = "SR-RAV  GHOST: "
        if seat == (0) then
            PTP_Vehicle_Name = "(1) Drivers  Seat"
        end

    elseif mapid == hog_mapId then
        -- // Warthog
        PTP_Vehicle_Name = "WARTHOG: "
        if seat == (0) then
            PTP_Vehicle_Name = "Drivers  Seat | (1)"
        elseif seat == (1) then
            PTP_Vehicle_Name = "Passengers  Seat | (2)"
        elseif seat == (2) then
            PTP_Vehicle_Name = "Gunners  Seat | (3)"
        end

    elseif mapid == tank_mapId then
        -- // Scorpion Tank
        PTP_Vehicle_Name = "SCORPION TANK: "
        if seat == (0) then
            PTP_Vehicle_Name = "Commanders  Seat | (1)"
        elseif seat == (1) then
            PTP_Vehicle_Name = "Passengers  Seat | (2)"
        elseif seat == (2) then
            PTP_Vehicle_Name = "Passengers  Seat | (3)"
        elseif seat == (3) then
            PTP_Vehicle_Name = "Passengers  Seat | (4)"
        elseif seat == (4) then
            PTP_Vehicle_Name = "Passengers  Seat | (5)"
        end

    elseif mapid == banshee_mapId then
        -- // Banshee
        PTP_Vehicle_Name = "BANSHEE: "
        if seat == (0) then
            PTP_Vehicle_Name = "Pilots  Seat | (1)"
        end

    elseif mapid == turret_mapId then
        -- Covenant Turret
        PTP_Vehicle_Name = "COVENANT TURRET: "
        if seat == (0) then
            PTP_Vehicle_Name = "Controllers  Seat | (1)"
        end

    elseif mapid == rhog_mapId then
        -- Rocket Hog
        PTP_Vehicle_Name = "ROCKET HOG: "
        if seat == (0) then
            PTP_Vehicle_Name = "Drivers  Seat | (1)"
        elseif seat == (1) then
            PTP_Vehicle_Name = "Passengers  Seat | (1)"
        elseif seat == (2) then
            PTP_Vehicle_Name = "Gunners  Seat | (1)"
        end
    end
    sendconsoletext(player, " " .. tostring(PTP_Vehicle_Name) .. " " .. tostring(PTP_Vehicle_Name) .. ".")
end