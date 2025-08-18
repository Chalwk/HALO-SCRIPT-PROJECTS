--[[
------------------------------------
Description: HPC Spawn Points V1, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
Red_Spawn_Coords = { }
Blue_Spawn_Coords = { }
team_play = false
---------------------------------------------------------------------------
function GetRequiredVersion()
    return 200
end

function OnScriptLoad(process, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
        map_name = readstring(0x698F21)
        gametype_base = 0x671340
    else
        GAME = "CE"
        map_name = readstring(0x61D151)
        gametype_base = 0x5F5498
    end
    team_play = getteamplay()
    LoadCoords()

end
---------------------------------------------------------------------------
function OnNewGame(map)
    if GAME == "PC" then
        map_name = readstring(0x698F21)
        gametype_base = 0x671340
    elseif GAME == "CE" then
        map_name = readstring(0x61D151)
        gametype_base = 0x5F5498
    end
    team_play = getteamplay()
    LoadCoords()

    if map_name == "sidewinder" then
        red_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
        blue_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
    end
end

function getteamplay()
    if readbyte(gametype_base + 0x34) == 1 then
        return true
    else
        return false
    end
end

function OnPlayerSpawn(player, m_objectId)

    if team_play then
        local team = getteam(player)
        local m_object = getobject(m_objectId)

        if team == 0 then
            local redcoord = RedSpawnPoints()
            if redcoord then
                movobjectcoords(m_objectId, Red_Spawn_Coords[redcoord][1], Red_Spawn_Coords[redcoord][2], Red_Spawn_Coords[redcoord][3])
                local fx, fy, fz = getobjectcoords(red_rot)
                local px, py, pz = getobjectcoords(m_objectId)
                local vx = fx - px
                local vy = fy - py
                local vz = fz - pz
                local magnitude = math.sqrt(vx * vx + vy * vy + vz * vz)
                vx = vx / magnitude
                vy = vy / magnitude
                vz = vz / magnitude
                writefloat(m_object + 0x74, vx)
                writefloat(m_object + 0x78, vy)
                writefloat(m_object + 0x7c, vz)
            end

        elseif team == 1 then
            local blucoord = BlueSpawnPoints()
            if blucoord then
                movobjectcoords(m_objectId, Blue_Spawn_Coords[blucoord][1], Blue_Spawn_Coords[blucoord][2], Blue_Spawn_Coords[blucoord][3])
                local fx, fy, fz = getobjectcoords(blue_rot)
                local px, py, pz = getobjectcoords(m_objectId)
                local vx = fx - px
                local vy = fy - py
                local vz = fz - pz
                local magnitude = math.sqrt(vx * vx + vy * vy + vz * vz)
                vx = vx / magnitude
                vy = vy / magnitude
                vz = vz / magnitude
                writefloat(m_object + 0x74, vx)
                writefloat(m_object + 0x78, vy)
                writefloat(m_object + 0x7c, vz)
            end
        end

    end
end

function RedSpawnPoints(arg)
    local redspawncount = #Red_Spawn_Coords
    if redspawncount > 0 then
        return getrandomnumber(1, redspawncount + 1)
    end
    return nil
end

function BlueSpawnPoints(arg)
    local bluspawncount = #Blue_Spawn_Coords
    if bluspawncount > 0 then
        return getrandomnumber(1, bluspawncount + 1)
    end
    return nil
end

function LoadCoords()
    if map_name == "sidewinder" then
        Red_Spawn_Coords[1] = { -23.225, -35.876, -3.702 }
        Red_Spawn_Coords[2] = { -38.865, -29.467, -3.537 }
        Red_Spawn_Coords[3] = { -40.148, -13.022, -3.526 }
        Red_Spawn_Coords[4] = { -32.959, -21.268, -3.438 }
        Red_Spawn_Coords[5] = { -11.704, -15.451, 0.464 }
        Red_Spawn_Coords[6] = { -11.358, 0.468, -3.482 }
        Red_Spawn_Coords[7] = { -39.048, -12.266, -3.482 }
        Red_Spawn_Coords[8] = { -47.680, -19.125, -3.482 }
        Red_Spawn_Coords[9] = { -20.260, -18.394, -3.016 }
        Red_Spawn_Coords[10] = { -26.170, -28.917, -3.457 }
        Red_Spawn_Coords[11] = { -40.388, -23.141, -3.457 }
        Red_Spawn_Coords[12] = { -24.886, 12.894, -3.615 }
        Red_Spawn_Coords[13] = { -27.733, 26.737, -3.425 }
        Red_Spawn_Coords[14] = { -32.916, 19.477, -1.837 }
        Red_Spawn_Coords[15] = { -38.704, 25.460, -3.527 }
        Red_Spawn_Coords[16] = { -43.871, 29.321, 0.391 }
        --
        Red_Spawn_Coords[17] = { -49.178, 28.624, 0.391 }
        Red_Spawn_Coords[18] = { -42.075, 37.755, 0.391 }
        Red_Spawn_Coords[19] = { -4.920, 39.495, -3.714 }
        Red_Spawn_Coords[20] = { 3.372, 27.836, -3.714 }
        Red_Spawn_Coords[21] = { 33.443, 46.216, -3.576 }
        Red_Spawn_Coords[22] = { 46.014, 27.638, 0.400 }
        Red_Spawn_Coords[23] = { 41.894, 16.970, -3.426 }
        Red_Spawn_Coords[24] = { 49.049, -17.793, -3.554 }
        ---->
        -------------------------------------------------------------
        ---->
        Blue_Spawn_Coords[1] = { -45.860, 39.624, 0.391 }
        Blue_Spawn_Coords[2] = { -39.557, 34.573, 0.391 }
        Blue_Spawn_Coords[3] = { -10.478, 45.313, -3.464 }
        Blue_Spawn_Coords[4] = { -4.082, 31.500, -3.714 }
        Blue_Spawn_Coords[5] = { 39.692, 36.693, 0.400 }
        --
        Blue_Spawn_Coords[6] = { 24.527, -32.343, -3.727 }
        Blue_Spawn_Coords[7] = { 21.464, -30.625, -3.841 }
        Blue_Spawn_Coords[8] = { 26.203, -27.890, -3.658 }
        Blue_Spawn_Coords[9] = { 38.559, -30.418, -3.839 }
        Blue_Spawn_Coords[10] = { 34.344, -15.037, -1.781 }
        Blue_Spawn_Coords[11] = { 31.948, -2.984, -3.170 }
        Blue_Spawn_Coords[12] = { 43.681, -24.345, -3.601 }
        Blue_Spawn_Coords[13] = { 19.631, -26.130, -3.601 }
        Blue_Spawn_Coords[14] = { 36.586, -19.334, -3.366 }
        Blue_Spawn_Coords[15] = { 31.503, 8.041, -3.366 }
        Blue_Spawn_Coords[16] = { 12.535, -12.743, 0.568 }
        Blue_Spawn_Coords[17] = { 9.378, -1.376, 0.317 }
        Blue_Spawn_Coords[18] = { 15.387, -15.838, 0.317 }
        Blue_Spawn_Coords[19] = { 40.880, -2.497, -3.697 }
        Blue_Spawn_Coords[20] = { 35.916, -35.052, -3.697 }
        Blue_Spawn_Coords[21] = { 20.206, -34.240, -3.697 }
        Blue_Spawn_Coords[22] = { 46.123, 23.864, 0.400 }
        Blue_Spawn_Coords[23] = { 47.568, 4.905, -3.426 }
        Blue_Spawn_Coords[24] = { 14.384, 30.278, -3.454 }
    end
end