--[[
------------------------------------
Description: HPC Player Spawn System (Advanced), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
Script Version: 2.5
-----------------------------------
]]--

Red_Spawn_Coords = { }
Blue_Spawn_Coords = { }
Team_Play = true
math.randomseed(os.time())
RANDOM_NUMBER = math.random

function math.random(low, high)
    low = tonumber(low) or raiseerror("Bad argument #1 to 'math.random' (number expected, got " .. tostring(type(low)) .. ")")
    high = tonumber(high) or raiseerror("Bad argument #2 to 'math.random' (number expected, got " .. tostring(type(high)) .. ")")
    RANDOM_NUMBER(low, high)
    RANDOM_NUMBER(low, high)
    RANDOM_NUMBER(low, high)
    RANDOM_NUMBER(low, high)
    RANDOM_NUMBER(low, high)
    RANDOM_NUMBER(high, low)
    RANDOM_NUMBER(high, low)
    RANDOM_NUMBER(high, low)
    RANDOM_NUMBER(high, low)
    RANDOM_NUMBER(high, low)
    return RANDOM_NUMBER(low, high), RANDOM_NUMBER(high, low)
end

function GetRequiredVersion()
    return
    200
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
    Team_Play = GetTeamPlay()
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
    Team_Play = GetTeamPlay()
    LoadCoords()
    if map_name == "bloodgulch" then
        red_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
        blue_rot = createobject(gettagid("scen", "scenery\\flag_base\\flag_base"), 0, 0, false, 60.987, -121.606, 0.274)
    end
end

function GetTeamPlay()
    if readbyte(gametype_base + 0x34) == 1 then
        return true
    else
        return false
    end
end

function OnPlayerSpawn(player, m_objectId)

    if Team_Play then
        local team = getteam(player)
        local m_object = getobject(m_objectId)

        if team == 0 then
            local RedCoordinates = RedSpawnSystem()
            if RedCoordinates then
                movobjectcoords(m_objectId, Red_Spawn_Coords[RedCoordinates][1], Red_Spawn_Coords[RedCoordinates][2], Red_Spawn_Coords[RedCoordinates][3])
                local name = getname(player)
                hprintf(name .. " has spawned!")
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
            local BlueCoordinates = BlueSpawnSystem()
            if BlueCoordinates then
                movobjectcoords(m_objectId, Blue_Spawn_Coords[BlueCoordinates][1], Blue_Spawn_Coords[BlueCoordinates][2], Blue_Spawn_Coords[BlueCoordinates][3])
                local name = getname(player)
                hprintf("")
                hprintf(name .. " has spawned!")
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

function RedSpawnSystem(arg)
    local redspawncount = #Red_Spawn_Coords
    if redspawncount > 0 then
        return getrandomnumber(1, redspawncount + 1)
    end
    return nil
end

function BlueSpawnSystem(arg)
    local bluspawncount = #Blue_Spawn_Coords
    if bluspawncount > 0 then
        return getrandomnumber(1, bluspawncount + 1)
    end
    return nil
end

function LoadCoords()
    if map_name == "bloodgulch" then
        -- RED BEGIN --
        Red_Spawn_Coords[1] = { 68.911, -173.686, 1.755 }
        Red_Spawn_Coords[2] = { 61.482, -164.685, 5.158 }
        Red_Spawn_Coords[3] = { 62.186, -160.847, 5.757 }
        Red_Spawn_Coords[4] = { 99.338, -157.363, 1.705 }
        Red_Spawn_Coords[5] = { 101.234, -159.579, 0.274 }
        Red_Spawn_Coords[6] = { 110.923, -142.052, 0.247 }
        Red_Spawn_Coords[7] = { 111.388, -141.550, 0.267 }
        Red_Spawn_Coords[8] = { 112.300, -140.159, 0.287 }
        Red_Spawn_Coords[9] = { 115.723, -134.220, 1.340 }
        Red_Spawn_Coords[10] = { 117.031, -127.629, 1.656 }
        Red_Spawn_Coords[11] = { 116.680, -126.634, 1.658 }
        Red_Spawn_Coords[12] = { 112.550, -127.203, 1.905 }
        Red_Spawn_Coords[13] = { 105.026, -162.209, 0.022 }
        Red_Spawn_Coords[14] = { 96.887, -165.438, 0.136 }
        Red_Spawn_Coords[15] = { 94.146, -165.385, 0.132 }
        Red_Spawn_Coords[16] = { 95.551, -168.620, 0.200 }
        Red_Spawn_Coords[17] = { 92.484, -169.559, 0.128 }
        Red_Spawn_Coords[18] = { 85.690, -159.979, 0.130 }
        Red_Spawn_Coords[19] = { 89.481, -153.501, 0.291 }
        Red_Spawn_Coords[20] = { 92.497, -149.394, 0.507 }
        Red_Spawn_Coords[21] = { 81.449, -149.635, 0.069 }
        Red_Spawn_Coords[22] = { 82.504, -145.652, 0.140 }
        Red_Spawn_Coords[23] = { 96.832, -164.032, 1.722 }
        Red_Spawn_Coords[24] = { 105.292, -173.656, 0.159 }
        Red_Spawn_Coords[25] = { 110.137, -173.322, 0.616 }
        Red_Spawn_Coords[26] = { 92.223, -161.893, -0.278 }
        Red_Spawn_Coords[27] = { 92.266, -157.129, -0.267 }
        Red_Spawn_Coords[28] = { 97.644, -157.279, -0.238 }
        Red_Spawn_Coords[29] = { 111.451, -177.511, 1.010 }
        Red_Spawn_Coords[30] = { 96.534, -175.199, 1.064 }
        Red_Spawn_Coords[31] = { 94.880, -159.475, -0.263 }
        Red_Spawn_Coords[32] = { 96.609, -160.162, -0.263 }
        Red_Spawn_Coords[33] = { 81.399, -147.391, 0.140 }
        Red_Spawn_Coords[34] = { 86.402, -159.027, 0.140 }
        Red_Spawn_Coords[35] = { 64.386, -157.993, 3.352 }
        Red_Spawn_Coords[36] = { 115.437, -130.253, 1.720 }
        Red_Spawn_Coords[37] = { 95.503, -164.974, 0.136 }
        Red_Spawn_Coords[38] = { 95.591, -153.745, 0.136 }
        Red_Spawn_Coords[39] = { 91.993, -159.543, 1.500 }
        Red_Spawn_Coords[40] = { 113.828, -178.777, 1.960 }
        Red_Spawn_Coords[41] = { 99.122, -159.539, 1.500 }
        Red_Spawn_Coords[42] = { 114.112, -177.953, 2.266 }
        Red_Spawn_Coords[43] = { 111.272, -135.343, 0.688 }
        Red_Spawn_Coords[44] = { 61.763, -159.021, 5.779 }
        Red_Spawn_Coords[45] = { 57.518, -178.940, 7.044 }
        Red_Spawn_Coords[46] = { 69.190, -171.407, 1.648 }
        Red_Spawn_Coords[47] = { 62.670, -171.012, 4.363 }
        Red_Spawn_Coords[48] = { 92.453, -157.702, 1.947 }
        Red_Spawn_Coords[49] = { 98.630, -160.817, 1.947 }
        Red_Spawn_Coords[50] = { 94.185, -159.227, 0.037 }
        Red_Spawn_Coords[51] = { 93.408, -157.250, -0.005 }
        Red_Spawn_Coords[52] = { 95.739, -162.009, -0.005 }
        Red_Spawn_Coords[53] = { 93.452, -162.077, -0.116 }
        Red_Spawn_Coords[54] = { 127.112, -177.000, 5.584 }
        Red_Spawn_Coords[55] = { 121.313, -173.051, 4.677 }
        Red_Spawn_Coords[56] = { 122.515, -176.343, 4.897 }
        Red_Spawn_Coords[57] = { 111.626, -177.714, 1.522 }
        Red_Spawn_Coords[58] = { 86.049, -145.975, 0.571 }
        Red_Spawn_Coords[59] = { 95.629, -154.604, 0.393 }
        Red_Spawn_Coords[60] = { 100.090, -160.488, 2.001 }
        Red_Spawn_Coords[61] = { 91.365, -161.792, 2.001 }
        Red_Spawn_Coords[62] = { 62.023, -152.916, 6.572 }
        -- RED END --
        ------------------------------------------------
        -- BLUE BEGIN --
        ------------------------------------------------
        Blue_Spawn_Coords[1] = { 43.287, -81.040, -0.281 }
        Blue_Spawn_Coords[2] = { 36.800, -81.308, -0.236 }
        Blue_Spawn_Coords[3] = { 36.986, -80.922, -0.225 }
        Blue_Spawn_Coords[4] = { 36.898, -76.983, -0.273 }
        Blue_Spawn_Coords[5] = { 37.750, -75.052, 1.707 }
        Blue_Spawn_Coords[6] = { 38.906, -82.419, 1.704 }
        Blue_Spawn_Coords[7] = { 42.626, -81.540, 1.705 }
        Blue_Spawn_Coords[8] = { 41.271, -73.382, 0.181 }
        Blue_Spawn_Coords[9] = { 35.452, -73.561, 0.106 }
        Blue_Spawn_Coords[10] = { 34.469, -79.704, 0.189 }
        Blue_Spawn_Coords[11] = { 27.835, -71.899, 0.787 }
        Blue_Spawn_Coords[12] = { 32.593, -65.859, 0.367 }
        Blue_Spawn_Coords[13] = { 37.429, -68.108, 0.261 }
        Blue_Spawn_Coords[14] = { 42.910, -67.763, 0.516 }
        Blue_Spawn_Coords[15] = { 50.962, -58.397, 2.221 }
        Blue_Spawn_Coords[16] = { 57.520, -65.796, 1.233 }
        Blue_Spawn_Coords[17] = { 61.292, -65.713, 1.693 }
        Blue_Spawn_Coords[18] = { 64.009, -70.653, 1.475 }
        Blue_Spawn_Coords[19] = { 72.525, -69.816, 2.813 }
        Blue_Spawn_Coords[20] = { 62.707, -85.545, 0.555 }
        Blue_Spawn_Coords[21] = { 60.925, -90.120, 0.244 }
        Blue_Spawn_Coords[22] = { 78.354, -75.814, 5.709 }
        Blue_Spawn_Coords[23] = { 77.552, -76.873, 5.709 }
        Blue_Spawn_Coords[24] = { 74.648, -78.345, 5.781 }
        Blue_Spawn_Coords[25] = { 71.998, -81.668, 5.774 }
        Blue_Spawn_Coords[26] = { 72.124, -85.783, 5.774 }
        Blue_Spawn_Coords[27] = { 71.091, -74.340, 2.911 }
        Blue_Spawn_Coords[28] = { 37.710, -62.552, 0.959 }
        Blue_Spawn_Coords[29] = { 40.275, -74.367, 0.069 }
        Blue_Spawn_Coords[30] = { 38.151, -96.135, -0.166 }
        Blue_Spawn_Coords[31] = { 38.596, -89.610, 0.035 }
        Blue_Spawn_Coords[32] = { 41.529, -93.910, -0.001 }
        Blue_Spawn_Coords[33] = { 41.102, -90.282, 0.175 }
        Blue_Spawn_Coords[34] = { 50.480, -86.173, 0.111 }
        Blue_Spawn_Coords[35] = { 51.905, -76.423, 0.084 }
        Blue_Spawn_Coords[36] = { 34.664, -76.831, 0.106 }
        Blue_Spawn_Coords[37] = { 36.424, -79.102, 1.386 }
        Blue_Spawn_Coords[38] = { 43.635, -79.049, 1.386 }
        Blue_Spawn_Coords[39] = { 58.582, -60.901, 1.618 }
        Blue_Spawn_Coords[40] = { 69.483, -81.918, 3.141 }
        Blue_Spawn_Coords[41] = { 25.136, -110.203, 4.011 }
        Blue_Spawn_Coords[42] = { 23.677, -109.210, 3.086 }
        Blue_Spawn_Coords[43] = { 20.775, -105.150, 2.761 }
        Blue_Spawn_Coords[44] = { 20.458, -59.032, 4.451 }
        Blue_Spawn_Coords[45] = { 18.732, -88.286, 3.221 }
        Blue_Spawn_Coords[46] = { 69.989, -87.444, 6.014 }
        Blue_Spawn_Coords[47] = { 71.085, -85.347, 5.805 }
        Blue_Spawn_Coords[48] = { 79.079, -74.792, 5.987 }
        Blue_Spawn_Coords[49] = { 77.354, -76.058, 5.945 }
        Blue_Spawn_Coords[50] = { 78.472, -65.242, 5.097 }
        Blue_Spawn_Coords[51] = { 72.477, -73.864, 3.085 }
        Blue_Spawn_Coords[52] = { 67.212, -74.535, 1.752 }
        Blue_Spawn_Coords[53] = { 40.715, -95.787, 0.028 }
        Blue_Spawn_Coords[54] = { 42.199, -89.734, 0.456 }
        Blue_Spawn_Coords[55] = { 54.379, -68.383, 0.985 }
        Blue_Spawn_Coords[56] = { 42.408, -73.025, 0.410 }
        Blue_Spawn_Coords[57] = { 28.002, -70.736, 0.696 }
        Blue_Spawn_Coords[58] = { 40.251, -74.630, 0.254 }
        Blue_Spawn_Coords[59] = { 41.456, -76.711, -0.088 }
        Blue_Spawn_Coords[60] = { 38.170, -76.573, -0.088 }
        Blue_Spawn_Coords[61] = { 20.417, -98.679, 2.358 }
        Blue_Spawn_Coords[62] = { 20.149, -106.627, 2.881 }
    end
end