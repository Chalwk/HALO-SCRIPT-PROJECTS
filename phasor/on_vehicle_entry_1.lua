--[[
------------------------------------
Description: HPC OnVehicleEntry #3 (Advanced), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
Script Version: 3.5
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

function OnNewGame(map)
    Ghost_MapID = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    Hog_MapID = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    Tank_MapID = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    Banshee_MapID = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    Turret_MapID = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    RHog_MapID = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
end

function OnVehicleEntry(player, vehiId, seat, mapId, relevant)
    local name = getname(player)
    if mapId == Ghost_MapID then
        Vehicle_Name = "Ghost"
        PTP_Vehicle_Name = "GHOST: "
        if seat == (0) then
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        end
    end

    if mapId == Hog_MapID then
        Vehicle_Name = "Warthog (Chain Gun Hog)"
        PTP_Vehicle_Name = "WARTHOG: "
        if seat == (0) then
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        elseif seat == (1) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            PTS_seat_name = "Gunners"
            PTP_Seat_Name = "Gunners  Seat"
        end
    end

    if mapId == Tank_MapID then
        Vehicle_Name = "Scorpion Tank"
        PTP_Vehicle_Name = "SCORPION TANK: "
        if seat == (0) then
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Commanders  Seat"
        elseif seat == (1) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (3) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (4) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        end
    end

    if mapId == Banshee_MapID then
        Vehicle_Name = "Banshee"
        PTP_Vehicle_Name = "BANSHEE: "
        if seat == (0) then
            PTS_seat_name = "Piolts"
            PTP_Seat_Name = "Pilots  Seat"
        end
    end

    if mapId == Turret_MapID then
        Vehicle_Name = "Covenant Turret"
        PTP_Vehicle_Name = "TURRET: "
        if seat == (0) then
            PTS_seat_name = "Controllers"
            PTP_Seat_Name = "Controllers  Seat"
        end
    end

    if mapId == RHog_MapID then
        Vehicle_Name = "Rocket hog"
        PTP_Vehicle_Name = "ROCKET HOG: "
        if seat == (0) then
            PTS_seat_name = "Drivers"
            PTP_Seat_Name = "Drivers  Seat"
        elseif seat == (1) then
            PTS_seat_name = "Passengers"
            PTP_Seat_Name = "Passengers  Seat"
        elseif seat == (2) then
            PTS_seat_name = "Gunners"
            PTP_Seat_Name = "Gunners  Seat"
        end
    end
    sendconsoletext(player, " " .. tostring(PTP_Vehicle_Name) .. " " .. tostring(PTP_Seat_Name) .. ".")
    hprintf("     V E H I C L E   E N T R Y:\n     " .. tostring(name) .. " entered the " .. tostring(PTS_seat_name) .. " seat of a " .. tostring(Vehicle_Name) .. ".")
    if logging then
        log_msg(1, name .. " entered the " .. tostring(PTS_seat_name) .. " seat of a " .. tostring(Vehicle_Name) .. ".")
    end
end