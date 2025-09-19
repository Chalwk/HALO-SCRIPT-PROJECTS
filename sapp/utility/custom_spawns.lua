--[[
=====================================================================================
SCRIPT NAME:      custom_spawns.lua
DESCRIPTION:      Provides custom spawn point handling for players based on map and team.
                  - Supports team-based and free-for-all game modes.
                  - Caches map-specific spawn points to optimize performance.
                  - Prevents players from spawning on occupied points.
                  - Actively monitors and clears abandoned spawn points.
                  - Retries spawn placement if no valid point is available.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG start ----------------------------------------------------------
local MAPS = {

    -- Format: map_name = { team_name = { {x, y, z, rotation}, ... }, ... }

    ['training_jump'] = {
        red = {
            { -0.77, -39.56, 0.00, 1.3374 },
            { -0.77, -39.26, 0.00, 1.4720 },
            { -0.77, -38.95, 0.00, 1.4681 },
            { -0.77, -38.53, 0.00, 1.4739 },
            { -0.77, -38.09, 0.00, -0.4819 },
            { -0.26, -38.00, 0.00, -0.1153 },
            { 0.26,  -38.06, 0.00, 4.4947 },
            { 0.68,  -37.97, 0.00, 4.0404 },
            { 0.75,  -38.52, 0.00, 3.9410 },
            { 0.80,  -39.03, 0.00, 3.0752 },
            { 0.48,  -39.28, 0.00, 3.0362 },
            { -0.04, -39.30, 0.00, 1.6244 },
            { -0.50, -38.94, 0.00, 1.4333 },
            { 0.11,  -38.59, 0.00, 1.4859 },
            { -0.58, -38.30, 0.00, 1.5600 },
            { 0.52,  -38.76, 0.00, 2.2445 },
            { -0.01, -39.27, 0.00, 1.5269 },
        },
        blue = {

        },
    },
    -- Add more maps here following the same format
}
-- CONFIG end ------------------------------------------------------------

api_version = '1.12.0.0'

local table_insert, table_remove = table.insert, table.remove
local math_random, math_sqrt, math_cos, math_sin = math.random, math.sqrt, math.cos, math.sin

local pairs, ipairs = pairs, ipairs
local get_var, player_alive = get_var, player_alive
local read_dword, read_float = read_dword, read_float
local read_vector3d, write_vector3d = read_vector3d, write_vector3d
local get_dynamic_player, get_object_memory = get_dynamic_player, get_object_memory

local spawns = {}        -- Cached spawn points per map
local active_spawns = {} -- Currently occupied spawn points
local current_map = nil  -- Current map name
local is_ffa = false     -- Free-for-all mode flag

-- Teleports player to specified coordinates and rotation
local function teleportPlayer(dyn_player, x, y, z, r)
    write_vector3d(dyn_player + 0x5C, x, y, z)
    write_vector3d(dyn_player + 0x74, math_cos(r), math_sin(r), 0)
end

-- Gets player's current position
local function getPos(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    else
        return nil
    end

    return x, y, z + 0.65 - (0.3 * crouch)
end

-- Caches spawn points for current map
local function cacheSpawns()
    current_map = get_var(0, '$map')
    is_ffa = get_var(0, '$ffa') == '1'

    if not spawns[current_map] then
        spawns[current_map] = {}
        local map_data = MAPS[current_map]

        if map_data then
            -- Combine teams for FFA, keep separate for team games
            if is_ffa then
                for _, team_spawns in pairs(map_data) do
                    for _, spawn in ipairs(team_spawns) do
                        table.insert(spawns[current_map], spawn)
                    end
                end
            else
                spawns[current_map] = map_data
            end
        end
    end
end

-- Gets available spawn point for player
local function getSpawnPoint(team)
    if not spawns[current_map] then return nil end

    local available_spawns = {}

    if is_ffa then
        available_spawns = spawns[current_map]
    else
        available_spawns = spawns[current_map][team] or {}
    end

    -- Filter out active spawns
    local valid_spawns = {}
    for _, spawn in ipairs(available_spawns) do
        local is_occupied = false
        for _, active in pairs(active_spawns) do
            if active[1] == spawn[1] and active[2] == spawn[2] and active[3] == spawn[3] then
                is_occupied = true
                break
            end
        end

        if not is_occupied then
            table_insert(valid_spawns, spawn)
        end
    end

    return #valid_spawns > 0 and valid_spawns[math_random(#valid_spawns)] or nil
end

-- Attempts to spawn a player at a custom point.
-- Returns true if successful, false otherwise.
local function trySpawn(id)
    local dyn_player = get_dynamic_player(id)
    if dyn_player == 0 then return false end

    local team = get_var(id, '$team')
    local spawn_point = getSpawnPoint(team)

    if spawn_point then
        local x, y, z, r = spawn_point[1], spawn_point[2], spawn_point[3], spawn_point[4]
        table_insert(active_spawns, { x, y, z, id })
        teleportPlayer(dyn_player, x, y, z, r)
        return true
    end

    return false
end

function OnPreSpawn(id)
    if not trySpawn(id) then
        -- No spawn available, retry every second
        timer(1000, "RetrySpawn", id)
    end
end

-- Clears abandoned spawn points
function CheckSpawns()
    for i = #active_spawns, 1, -1 do
        local spawn = active_spawns[i]
        local player_id = spawn[4]

        if not player_alive(player_id) then
            table_remove(active_spawns, i)
        else
            local dyn_player = get_dynamic_player(player_id)
            if dyn_player ~= 0 then
                local x, y, z = getPos(dyn_player)
                if x then
                    -- Calculate distance from spawn point
                    local dx = spawn[1] - x
                    local dy = spawn[2] - y
                    local dz = spawn[3] - z
                    local distance = math_sqrt(dx * dx + dy * dy + dz * dz)

                    -- Clear if player moved away
                    if distance > 1.0 then
                        table_remove(active_spawns, i)
                    end
                end
            end
        end
    end

    return true
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_PRESPAWN'], 'OnPreSpawn')
    OnStart() -- just in case the script is loaded mid-game
end

function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        cacheSpawns()
        active_spawns = {}
        timer(1000, "CheckSpawns")
    end
end

function RetrySpawn(id) return not trySpawn(id) end

function OnEnd() active_spawns = {} end

function OnScriptUnload() end
