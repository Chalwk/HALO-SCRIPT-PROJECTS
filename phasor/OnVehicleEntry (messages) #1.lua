--[[
------------------------------------
Script Name: HPC OnVehicleEntry Messages, SAPP
    - Implementing API version: 1.10.0.0

Description: This script will print Vehicle Names & Seat position On vehicle Entry

Copyright (c) 2016 Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE

* IGN: Chalwk
-----------------------------------
]]-- 

api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb['EVENT_VEHICLE_ENTER'], "OnVehicleEnter")
end

function OnScriptUnload()
end

function OnVehicleEnter(PlayerIndex, Seat)
    local PlayerObj = get_dynamic_player(PlayerIndex)
    local VehicleObj = get_object_memory(read_dword(PlayerObj + 0x11c))
    local MetaIndex = read_dword(VehicleObj)

    if MetaIndex == 0xE3D40260 then
        Vehicle_Name = "Warthog"
        if Seat == "0" then
            Seat_Position = "Drivers Seat"
        elseif Seat == "1" then
            Seat_Position = "Passengers Seat"
        elseif Seat == "2" then
            Seat_Position = "Gunners Seat"
        end
    end

    if MetaIndex == 0xE5050391 then
        Vehicle_Name = "Rocket Hog"
        if Seat == "0" then
            Seat_Position = "Drivers Seat"
        elseif Seat == "1" then
            Seat_Position = "Passengers Seat"
        elseif Seat == "2" then
            Seat_Position = "Gunners Seat"
        end
    end

    if MetaIndex == 0xE45702E3 then
        Vehicle_Name = "Scorpion Tank"
        if Seat == "0" then
            Seat_Position = "Drivers Seat"
        elseif Seat == "1" then
            Seat_Position = "Passengers Seat"
        elseif Seat == "2" then
            Seat_Position = "Passengers Seat"
        elseif Seat == "3" then
            Seat_Position = "Passengers Seat"
        elseif Seat == "4" then
            Seat_Position = "Passengers Seat"
        end
    end

    if MetaIndex == 0xE4B70343 then
        Vehicle_Name = "Ghost"
        if Seat == "0" then
            Seat_Position = "Drivers Seat"
        end
    end

    if MetaIndex == 0xE54003CC then
        Vehicle_Name = "Banshee"
        if Seat == "0" then
            Seat_Position = "Drivers Seat"
        end
    end
    cprint("Vehicle Name: " .. tostring(Vehicle_Name) .. " - " .. tostring(Seat_Position))
end

function OnError(Message)
    print(debug.traceback())
end
