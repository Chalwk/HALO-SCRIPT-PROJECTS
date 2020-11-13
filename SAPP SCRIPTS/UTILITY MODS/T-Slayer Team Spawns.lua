--[[
--=====================================================================================================--
Script Name: T-Slayer Team Spawns, for SAPP (PC & CE)
Description: This mod will enforce team spawning on Team-Slayer based game types.

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local spawns = {}

local function Init()
    spawns = { red = { }, blue = { } }
    if (get_var(0, "$gt") ~= "n/a") then
        if (get_var(0, "$gt") == "slayer" and get_var(0, "$ffa") == "0") then
            LoadSpawns()
            register_callback(cb["EVENT_PRESPAWN"], "OnPlayerPreSpawn")
        else
            unregister_callback(cb["EVENT_PRESPAWN"])
        end
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    Init()
end

function OnScriptUnload()
    -- N/A
end

function OnGameStart()
    Init()
end

function OnPlayerPreSpawn(PlayerIndex)
    local player = get_dynamic_player(PlayerIndex)
    if (player ~= 0) then

        local coords
        local team = get_var(PlayerIndex, "$team")
        if (team == "red") and (#spawns.red > 0) then
            coords = spawns.red[math.random(1, #spawns.red)]
        elseif (team == "blue") and (#spawns.blue > 0) then
            coords = spawns.blue[math.random(1, #spawns.blue)]
        end

        local occupied = isOccupied(coords.x, coords.y, coords.z)
        if (not occupied) then
            write_vector3d(player + 0x5C, coords.x, coords.y, coords.z)
        else
            OnPlayerPreSpawn(PlayerIndex)
        end
    end
end

local function getXYZ(DyN)
    local coords, x, y, z = { }
    local VehicleID = read_dword(DyN + 0x11C)
    if (VehicleID ~= 0xFFFFFFFF) then
        local vehicle = get_object_memory(VehicleID)
        x, y, z = read_vector3d(vehicle + 0x5c)
    else
        x, y, z = read_vector3d(DyN + 0x5c)
    end
    coords.x, coords.y, coords.z = x, y, z
    return coords
end

function isOccupied(sx, sy, sz)
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local DyN = get_dynamic_player(i)
            if (DyN ~= 0) then
                local p = getXYZ(DyN)
                local R = GetRadius(sx, sy, sz, p.x, p.y, p.z)
                if (R <= 1) then
                    return true
                end
            end
        end
    end
    return false
end

function GetRadius(X1, Y1, Z1, X2, Y2, Z2)
    return math.sqrt((X1 - X2) ^ 2 + (Y1 - Y2) ^ 2 + (Z1 - Z2) ^ 2)
end

function LoadSpawns()

    local tag_array = read_dword(0x40440000)
    local scenario_tag_index = read_word(0x40440004)
    local scenario_tag = tag_array + scenario_tag_index * 0x20
    local scenario_tag_data = read_dword(scenario_tag + 0x14)

    local starting_location_reflexive = scenario_tag_data + 0x354
    local starting_location_count = read_dword(starting_location_reflexive)
    local starting_location_address = read_dword(starting_location_reflexive + 0x4)

    for i = 0, starting_location_count do
        local starting_location = starting_location_address + 52 * i
        local x, y, z = read_vector3d(starting_location)
        local team = read_word(starting_location + 0x10)

        if (team == 1) then
            spawns.blue[#spawns.blue + 1] = { x = x, y = y, z = z }
        elseif (team == 0) then
            spawns.red[#spawns.red + 1] = { x = x, y = y, z = z }
        end
    end
end
