--[[
--======================================================================================================--
Script Name: Anti-Portal-Camping (v1.0), for SAPP (PC & CE)
Description: Prevent players from camping portals.

Players will be considered portal camping if they are within 3.5 world units
of any portal. They will be warned to move away after 5 seconds and killed after 10.

* Made specifically for AG Clan (http://agclan1.proboards.com/)

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

-- Configuration Starts --
local time_until_kill = 10 -- in seconds
-- Players will be warned (time_until_kill/2) seconds after entering (trigger_distance)
local warning_message = "Warning. You will be killed in %seconds% seconds for portal-camping. Move away!"
-- To output the players name, use the custom variable: "%name%
local on_kill_message = "%name%, You were killed for Portal Camping."
local trigger_distance = 3.5 -- world units
local portals = {
    -- Set "enabled" to false to disable individual maps.
    ["beavercreek"] = {
        enabled = true,
        -- Portal 1 Coordinates: X,Y,Z
        { 31.526, 13.809, -0.216 },
        -- Portal 2 Coordinates: X,Y,Z
        { -3.347, 13.679, -0.216 }
    },
    ["bloodgulch"] = {
        enabled = true,
        { 82.828, -114.527, 0.702 },
        { 43.795, -126.231, 0.241 },
        { 95.584, -155.452, 1.807 },
        { 40.057, -82.916, 1.815 }
    },
    ["boardingaction"] = {
        enabled = true,
        { -2.576, 8.905, 5.219 },
        { -1.042, -8.182, 5.219 },
        { 1.952, -8.453, -4.778 },
        { 1.904, 9.036, -4.778 },
        { 18.125, 8.433, -4.778 },
        { 18.124, -9.037, -4.778 },
        { 22.608, -8.883, 5.219 },
        { 21.156, 8.195, 5.219 }
    },
    ["carousel"] = {
        enabled = true,
        { -0.016, 10.579, -0.855 },
        { -0.003, -11.537, -0.856 },
        { 8.031, 7.995, -3.349 },
        { -8.136, -8.111, -3.349 }
    },
    ["chillout"] = {
        enabled = true,
        { 11.173, 8.019, 0.001 },
        { 1.461, -4.204, 0.001 },
        { -4.811, 7.962, 0.502 },
        { -3.699, -0.415, 2.785 },
        { 7.278, 0.901, 2.382 },
        { 12.152, 2.636, 3.536 }
    },
    ["longest"] = { -- there are no portals on this map by default
        enabled = false,
        {}
    },
    ["dangercanyon"] = {
        enabled = true,
        { -0.473, 57.500, 0.500 },
        { -0.043, 45.401, -8.365 }
    },
    ["deathisland"] = {
        enabled = true,
        { 24.375, 13.309, 8.295 },
        { 24.407, 18.669, 8.295 },
        { 25.656, 16.048, 21.191 },
        { -21.338, -6.919, 22.686 },
        { -21.085, -9.671, 9.677 },
        { -21.009, -4.404, 9.678 },
        { -68.695, 17.713, 15.313 },
        { 46.747, -35.916, 13.993 }
    },
    ["gephyrophobia"] = {
        enabled = true,
        { 24.885, 7.990, -16.628 },
        { 28.589, 7.984, -16.628 },
        { 28.682, -152.535, -16.611 },
        { 24.975, -152.534, -16.611 },
        { -28.897, -107.227, -1.254 },
        { -25.464, -27.669, -1.254 },
        { 75.811, -38.150, -1.061 },
        { 75.810, -112.774, -1.061 }
    },
    ["icefields"] = {
        enabled = true,
        { 24.850, -36.958, 2.500 },
        { -77.864, 101.300, 2.500 },
        { -26.023, 40.575, 4.200 },
        { -26.020, 24.415, 4.200 },
        { -50.430, 41.690, 0.681 },
        { -1.240, 23.425, 0.682 },
        { -8.035, 17.422, 8.665 },
        { -43.600, 47.621, 8.663 }
    },
    ["infinity"] = {
        enabled = true,
        { 13.596, 6.135, 16.580 },
        { -13.921, 6.056, 18.380 },
        { -15.351, -46.685, 21.871 },
        { 18.856, -44.630, 21.871 },
        { 18.885, -81.463, 21.937 },
        { -15.379, -78.837, 21.871 },
        { 16.917, -124.849, 15.985 },
        { -13.242, -122.783, 18.953 }
    },
    ["sidewinder"] = {
        enabled = true,
        { 32.012, -38.224, 0.559 },
        { 51.926, 22.868, 0.159 },
        { 41.180, 46.002, 0.159 },
        { -41.281, 46.157, 0.159 },
        { -52.284, 22.646, 0.159 },
        { -33.670, -34.183, 0.559 }
    },
    ["timberland"] = { -- there are no portals on this map by default
        enabled = false,
        {}
    },
    ["hangemhigh"] = { -- there are no portals on this map by default
        enabled = false,
        {}
    },
    ["ratrace"] = {
        enabled = true,
        { -4.878, -16.255, -2.118 },
        { 8.945, -26.794, -3.611 },
        { 22.394, -5.786, -2.115 },
        { 8.383, -8.004, 0.223 }
    },
    ["damnation"] = {
        enabled = true,
        { -0.608, 8.530, 8.201 },
        { -1.899, 9.001, 1.201 }
    },
    ["putput"] = {
        enabled = true,
        { 33.898, -14.268, 0.903 },
        { 28.561, -9.237, 0.903 },
        { 28.653, -32.667, 1.001 },
        { 31.761, -22.771, 1.001 },
        { 26.232, -28.212, 0.001 },
        { 19.735, -4.618, 1.703 },
        { 12.761, -4.540, 0.103 },
        { 12.739, -8.262, 0.904 },
        { 10.968, -20.362, 0.001 },
        { 16.204, -17.400, 0.001 },
        { 13.504, -24.423, 0.001 },
        { 18.962, -20.393, 0.501 },
        { 17.784, -34.447, 0.904 },
        { 9.402, -34.357, 0.903 },
        { 13.600, -30.380, 2.829 },
        { 1.376, -2.851, 0.904 },
        { -3.115, -9.125, 0.903 },
        { -7.488, -2.784, 0.903 },
        { -8.403, -2.806, 2.203 },
        { -3.084, -15.752, 0.904 },
        { -7.533, -20.202, 0.903 },
        { -3.117, -24.660, 0.903 },
        { 1.359, -20.244, 0.904 },
        { -7.206, -34.540, 3.403 },
        { -2.362, -30.562, 2.303 },
        { 1.014, -34.616, 0.903 },
        { -14.380, -18.413, 2.303 },
        { -14.353, -22.101, 2.303 },
        { -15.750, -16.776, 0.903 },
        { -15.718, -23.706, 0.903 }
    },
    ["prisoner"] = { -- there are no portals on this map by default
        enabled = false,
        {}
    },
    ["wizard"] = {
        enabled = true,
        { -0.003, -11.497, -4.499 },
        { -12.057, 0.006, -4.416 },
        { 0.010, 11.439, -4.499 },
        { 012.020, -0.051, -4.416 }
    },
}
-- Configuration Ends --

-- Do not touch below this point (unless you know what you are doing)
local players, game_over, loc = {}
local delta_time = 1 / 30
local floor, gsub = math.floor, string.gsub

api_version = "1.12.0.0"
function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb["EVENT_SPAWN"], "OnPlayerSpawn")

    if get_var(0, "$gt") ~= "n/a" then
        game_over, loc = false, portals[get_var(0, "$map")]
        for i = 1, 16 do
            if player_present(i) then
                InitPlayer(i, false)
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end

function OnGameStart()
    game_over, loc = false, portals[get_var(0, "$map")]
end

function OnGameEnd()
    game_over = true
end

function OnPlayerConnect(PlayerIndex)
    InitPlayer(PlayerIndex, false)
end

function OnPlayerDisconnect(PlayerIndex)
    InitPlayer(PlayerIndex, true)
end

function OnPlayerSpawn(PlayerIndex)
    InitPlayer(PlayerIndex, false)
end


-- This function called every 1/30th second
function OnTick()
    if (not game_over) and (loc) then
        if (loc.enabled) then
            for i, player in pairs(players) do
                if (i) then
                    if player_present(i) and player_alive(i) then

                        local dynamic_player = get_dynamic_player(i)
                        if (dynamic_player ~= 0) then

                            local coords = getXYZ(dynamic_player)
                            if (coords) then
                                local x1, y1, z1 = coords.x, coords.y, coords.z
                                local count = 0
                                for j = 1, #loc do
                                    local x2, y2, z2 = loc[j][1], loc[j][2], loc[j][3]
                                    if CheckCoordinates(x1, y1, z1, x2, y2, z2) then
                                        count = count + 1
                                        if (player.init) then
                                            player.timer = player.timer + delta_time
                                            if (player.timer >= time_until_kill / 2) and (player.timer < time_until_kill) then
                                                cls(i, 25)
                                                local time_remaining = floor((time_until_kill - player.timer) + 1)
                                                local msg = gsub(warning_message, "%%seconds%%", time_remaining)
                                                rprint(i, msg)
                                            elseif (player.timer > time_until_kill) then
                                                cls(i, 25)
                                                player.init = false
                                                local name = get_var(i, "$name")
                                                local msg = gsub(on_kill_message, "%%name%%", name)
                                                rprint(i, msg)
                                                execute_command("kill " .. i)
                                            end
                                        end
                                    end
                                end
                                if (count == 0) then
                                    player.timer = 0
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function InitPlayer(PlayerIndex, Reset)
    if (not Reset) then
        players[PlayerIndex] = { timer = 0, init = true }
    else
        players[PlayerIndex] = {}
    end
end

function getXYZ(PlayerObject)
    local coords, x, y, z = {}
    local VehicleID = read_dword(PlayerObject + 0x11C)
    if (VehicleID == 0xFFFFFFFF) then
        coords.invehicle = false
        x, y, z = read_vector3d(PlayerObject + 0x5c)
    else
        coords.invehicle = true
        x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
    end
    coords.x, coords.y, coords.z = x, y, z
    return coords
end

function CheckCoordinates(pX, pY, pZ, x, y, z)
    local distance = math.sqrt((pX - x) ^ 2 + (pY - y) ^ 2 + (pZ - z) ^ 2)
    if (distance <= trigger_distance) then
        return distance
    end
end

function cls(PlayerIndex, count)
    count = count or 25
    for _ = 1, count do
        rprint(PlayerIndex, " ")
    end
end