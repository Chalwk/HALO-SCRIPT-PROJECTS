--[[
--======================================================================================================--
Script Name: HLN Damage Prevention (v1.2), for SAPP (PC & CE)
	* Lone-drivers from receiving damage or inflicting damage
	* Walkers from inflicting damage to anyone
	* Any vehicle occupant from inflicting damage on walkers
		
	
Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

api_version = "1.12.0.0"
local seat = {}

function OnScriptLoad()
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")
    register_callback(cb['EVENT_VEHICLE_ENTER'], "OnVehicleEntry")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerConnect")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerDisconnect")
    register_callback(cb['EVENT_TICK'], "OnTick")

    if (get_var(0, "$gt") ~= "n/a") then
        seat = {}
        for i = 1, 16 do
            if player_present(i) then
                execute_command("kill " .. i)
            end
        end
    end
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) then
            if (not InVehicle(i) and seat[i] ~= nil) then
                seat[i] = 0
            end
        end
    end
end

function OnPlayerConnect(PlayerIndex)
    seat[PlayerIndex] = 0
end

function OnPlayerDisconnect(PlayerIndex)
    seat[PlayerIndex] = 0
end

function OnVehicleEntry(PlayerIndex, Seat)
    if player_alive(PlayerIndex) then
        local current_seat = GetSeat(PlayerIndex)
        if (current_seat ~= nil) then
            if (seat[PlayerIndex] ~= current_seat) then
                seat[PlayerIndex] = "0-2"
            end
        end
    end
end

function OnDamageApplication(VictimIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    if (tonumber(CauserIndex) > 0 and VictimIndex ~= CauserIndex) then

        -- Walker vs Walker
        if not InVehicle(CauserIndex) then
            return false

            -- Walker vs Vehicle Occupant
        elseif not InVehicle(CauserIndex) and InVehicle(VictimIndex) then
            return false

            -- Vehicle Occupant vs Walker
        elseif InVehicle(CauserIndex) and not InVehicle(VictimIndex) then
            return false

            -- Driver/Gunner vs Vehicle Occupant
        elseif InVehicle(CauserIndex) and InVehicle(VictimIndex) then

            if (seat[CauserIndex] == "0-2") then

                -- Victim is LONE Driver (no gunner/passenger)
                if (GetOccupantCount(VictimIndex) == 1) then
                    local current_seat = GetSeat(VictimIndex)
                    if (current_seat ~= nil) then
                        if (current_seat == 0) then
                            return false
                        end
                    end
                end
            end
        end
    end
end

function InVehicle(PlayerIndex)
    if player_alive(PlayerIndex) then
        local player_object = get_dynamic_player(PlayerIndex)
        if (player_object ~= 0) then
            local VehicleID = read_dword(player_object + 0x11C)
            if (VehicleID == 0xFFFFFFFF) then
                return false
            else
                return true
            end
        end
    end
    return false
end

function GetSeat(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        local VehicleID = read_dword(player_object + 0x11C)
        if (VehicleID ~= 0xFFFFFFFF) then
            return read_word(player_object + 0x2F0)
        end
    end
    return nil
end

function GetOccupantCount(PlayerIndex)
    local count = 1

    local player_object1 = get_dynamic_player(PlayerIndex)
    local P1_VID = read_dword(player_object1 + 0x11C)
    local P1_VObjectMemory = get_object_memory(P1_VID)

    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            if (i ~= PlayerIndex) then
                local player_object2 = get_dynamic_player(i)
                local P2_VID = read_dword(player_object2 + 0x11C)
                if (P2_VID ~= 0xFFFFFFFF) then
                    local P2_VObjectMemory = get_object_memory(P2_VID)
                    if (P1_VObjectMemory == P2_VObjectMemory) then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count
end

function Reset(PlayerIndex)
    seat[PlayerIndex] = 0
end
