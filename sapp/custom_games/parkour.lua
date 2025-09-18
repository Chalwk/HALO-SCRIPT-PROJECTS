--[[
=====================================================================================
SCRIPT NAME:      parkour.lua
DESCRIPTION:      Halo SAPP/Lua parkour plugin.
                  - Allows players to run custom parkour courses on maps.
                  - Tracks checkpoints, start/finish lines, and player progression.
                  - Supports in-order or free checkpoint completion.
                  - Records player statistics (best times, averages, completions) globally and per map.
                  - Provides commands for teleporting to checkpoints, resetting runs, and viewing leaderboards.
                  - Handles respawning at checkpoints, death limits, and course restarts.
                  - Includes optional visual aids (flags and oddball markers) for starts, finishes, and checkpoints.
                  - Fully configurable per map via the CONFIG table.

REQUIREMENTS:     Install to the same directory as sapp.dll
                  - Lua JSON Parser:  http://regex.info/blog/lua/json

Copyright (c) 2023-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG start -----------------------------------------------------------
local CONFIG = {
    DATABASE_FILE = './parkour_results.json',

    -- Format: {internal_command = {table_of_aliases, permission_level}}
    -- -1 = public, 1-4 = admin
    COMMANDS = {
        checkpoint = { { "cp" }, 4 },             -- teleport to checkpoint
        getposition = { { "getrot" }, 4 },        -- get position + yaw
        checkpointreset = { { "reset" }, -1 },    -- reset to last checkpoint
        runreset = { { "runreset" }, -1 },        -- full run reset to start
        hardreset = { { "hardreset" }, -1 },      -- hard reset
        statistics = { { "stats", "top5" }, -1 }, -- show personal stats
        leaderboard = { { "leaderboard" }, -1 },  -- show leaderboard
        rankings = { { "current" }, -1 },         -- show current game rankings
    },

    MAPS = {
        ['EV_jump'] = {
            --
            -- Set to true to enable flag spawning:
            -- Flag poles are a visual representation of the start/finish lines:
            -- Players need to cross a line to start or finish the course.
            -- Default: true
            --
            spawn_flags = true,
            --
            -- Set to true to enable checkpoint markers:
            -- Checkpoint markers are small markers that show the location of each checkpoint.
            -- Default: true
            --
            spawn_checkpoint_markers = true,
            --
            -- If you die this many times, you will have to restart the course:
            -- Default: 10
            --
            restart_after = 10,
            --
            -- Set the respawn time (in seconds):
            -- Default: 3
            --
            respawn_time = 0, -- set to 'nil' to disable
            --
            -- Set the running speed:
            -- Default: 1.4
            --
            running_speed = 1.4,
            --
            -- Starting line (straight line between the two points):
            start = {
                -- Point A (line marker)
                -0.80, -9.93, .30,

                -- Point B (line marker)
                0.30, -9.93, 0.30,

                -- Spawn position + yaw (x,y,z,radians):
                spawn = { -0.36, -10.01, 0.30, 1.5639 } -- facing north
            },
            --
            -- Finish line (straight line between the two points):
            -- 3x 32-bit floating point numbers.
            finish = {
                -- Point A (3x 32-bit floating point numbers):
                50.19, 259.27, -18.62,

                -- Point B (3x 32-bit floating point numbers):
                52.79, 259.27, -18.62
            },
            --
            -- Checkpoints Settings:
            in_order = true,
            -- Format: {x, y, z, yaw}
            --
            checkpoints = {
                { 0.11,   11.76,  0.00,  2.4748 },
                { -10.31, 45.01,  0.00,  1.5598 },
                { -7.40,  63.75,  1.00,  1.5754 },
                { 10.31,  104.63, -6.62, 0.3510 },
                { 29.79,  125.52, -6.62, -0.0156 },
                { 27.85,  129.02, 0.28,  4.7079 },
                { 40.87,  129.02, 2.78,  3.1339 },
                { 27.70,  134.74, 5.23,  -0.0000 },
                { 39.51,  137.21, 2.78,  1.5210 },
                { 51.53,  198.75, 5.36,  2.1197 }
            }
        }

        -- more maps here:
    }
}
-- CONFIG end --------------------------------------------------------------

api_version = '1.12.0.0'

local json = loadfile('json.lua')()

local os_time = os.time
local math_floor, math_huge, math_sqrt = math.floor, math.huge, math.sqrt
local table_insert, table_sort = table.insert, table.sort
local string_format = string.format

local get_var, player_present, register_callback, say_all, rprint =
    get_var, player_present, register_callback, say_all, rprint

local get_dynamic_player, get_player, player_alive, read_dword =
    get_dynamic_player, get_player, player_alive, read_dword

local base_tag_table = 0x40440000
local tag_entry_size, tag_data_offset, bit_check_offset, bit_index = 0x20, 0x14, 0x308, 3

local function formatMessage(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

local function atan2(y, x)
    return math.atan(y / x) + ((x < 0) and math.pi or 0)
end

local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

local function formatTime(seconds)
    if seconds == 0 or seconds == math_huge then return "00:00.00" end

    local total_hundredths = math_floor(seconds * 100 + 0.5)
    local minutes = math_floor(total_hundredths / 6000)
    local remaining_hundredths = total_hundredths % 6000
    local secs = math_floor(remaining_hundredths / 100)
    local hundredths = remaining_hundredths % 100

    return string_format("%02d:%02d.%02d", minutes, secs, hundredths)
end

local function readJSON(file_path, default)
    local file = io.open(file_path, "r")
    if not file then return default end
    local content = file:read("*a")
    file:close()
    if content == "" then return default end
    local success, data = pcall(json.decode, json, content)
    return success and data or default
end

local function writeJSON(file_path, data)
    local file = io.open(file_path, "w")
    if not file then return false end
    file:write(json:encode(data))
    file:close()
    return true
end

-- Parkour-specific code
local map_cfg
local game_over
local stats_file
local players = {}
local oddballs = {}
local alias_to_command = {}
local all_time_stats = {
    maps = {},
    global = {
        best_time = { time = math_huge, player = "", map = "" },
        players = {}
    }
}

local current_game_stats = {
    map = "",
    best_time = { time = math_huge, player = "" },
    rankings = {}
}

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_DIE']] = 'OnDeath',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_SPAWN']] = 'OnSpawn',
    [cb['EVENT_GAME_END']] = 'OnEnd',
    [cb['EVENT_COMMAND']] = 'OnCommand',
    [cb['EVENT_PRESPAWN']] = 'OnPreSpawn'
}

local function registerCallbacks(enable)
    for event, callback in pairs(sapp_events) do
        if enable then
            register_callback(event, callback)
        else
            unregister_callback(event)
        end
    end
end

local function getFlagAndOddballData()
    local tag_array = read_dword(base_tag_table)
    local tag_count = read_dword(base_tag_table + 0xC)

    local flag_id, flag_name
    local oddball_id, oddball_name

    for i = 0, tag_count - 1 do
        local tag = tag_array + tag_entry_size * i
        local tag_class = read_dword(tag)
        if tag_class == 0x77656170 then
            local tag_data = read_dword(tag + tag_data_offset)
            if read_bit(tag_data + bit_check_offset, bit_index) == 1 then
                local item_type = read_byte(tag_data + 2)
                local meta_id = read_dword(tag + 0xC)
                local tag_name = read_string(read_dword(tag + 0x10))
                if item_type == 0 and not flag_id then
                    flag_id, flag_name = meta_id, tag_name
                elseif item_type == 4 and not oddball_id then
                    oddball_id, oddball_name = meta_id, tag_name
                end
            end
        end
    end

    return flag_id, flag_name, oddball_id, oddball_name
end

local function getPos(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    return x, y, z + 0.65 - (0.3 * crouch)
end

local function setRespawnTime(id)
    if not map_cfg.respawn_time then return end
    local player = get_player(id)
    if player ~= 0 then
        write_dword(player + 0x2C, map_cfg.respawn_time)
    end
end

local function spawnObject(x, y, z, meta_id)
    return spawn_object('', '', x, y, z, 0, meta_id)
end

local function validatePlayer(id)
    local dyn_player = get_dynamic_player(id)
    return player_present(id) and player_alive(id) and dyn_player ~= 0
end

local function hasCommandPermission(id, cmd)
    local command_data = alias_to_command[cmd]
    if not command_data then
        rprint(id, "Unknown command")
        return false
    end

    local level_required = command_data.level
    local player_level = tonumber(get_var(id, "$lvl"))

    if player_level >= level_required then return true end
    rprint(id, "You do not have permission to use this command")
    return false
end

local function distance(x1, y1, z1, x2, y2, z2)
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
    return math_sqrt(dx * dx + dy * dy + dz * dz)
end

local function isNearPoint(px, py, pz, point, radius)
    return distance(px, py, pz, point[1], point[2], point[3]) <= radius
end

-- Improved line crossing detection
local function isCrossingLine(px, py, pz, lineA, lineB, prevPos)
    if not prevPos then return false end

    -- Extract line points
    local Ax, Ay, Az = lineA[1], lineA[2], lineA[3]
    local Bx, By, Bz = lineB[1], lineB[2], lineB[3]

    -- Calculate line vector
    local Lx, Ly, Lz = Bx - Ax, By - Ay, Bz - Az

    -- Calculate vector from line point A to current position
    local Vx, Vy, Vz = px - Ax, py - Ay, pz - Az

    -- Calculate vector from line point A to previous position
    local Px, Py, Pz = prevPos[1] - Ax, prevPos[2] - Ay, prevPos[3] - Az

    -- Calculate cross products
    local crossCurrent = {
        x = Ly * Vz - Lz * Vy,
        y = Lz * Vx - Lx * Vz,
        z = Lx * Vy - Ly * Vx
    }

    local crossPrevious = {
        x = Ly * Pz - Lz * Py,
        y = Lz * Px - Lx * Pz,
        z = Lx * Py - Ly * Px
    }

    -- Check if the signs of the Z components are different
    -- This indicates the player crossed the line
    if crossCurrent.z * crossPrevious.z < 0 then
        -- Additional check to ensure the crossing is within the line segment
        -- Project the current position onto the line
        local t = ((px - Ax) * Lx + (py - Ay) * Ly + (pz - Az) * Lz) / (Lx * Lx + Ly * Ly + Lz * Lz)

        -- If t is between 0 and 1, the crossing point is within the line segment
        if t >= 0 and t <= 1 then
            return true
        end
    end

    return false
end

local function updateStats(stats, completionTime)
    if completionTime < stats.best_time_seconds then
        stats.best_time_seconds = completionTime
    end
    local total_time = (stats.avg_time_seconds or 0) * ((stats.completions or 0)) + completionTime
    stats.completions = (stats.completions or 0) + 1
    stats.avg_time_seconds = total_time / stats.completions
end

local function updatePlayerStats(player, completionTime)
    local name, map = player.name, current_game_stats.map
    local map_stats = all_time_stats.maps[map] or {
        best_time = { time = math_huge, player = "" },
        players = {},
    }
    local global_stats = all_time_stats.global

    local is_personal_best = false
    local is_map_record = false

    -- Check for personal best
    if completionTime < player.best_time then
        player.best_time = completionTime
        is_personal_best = true
    end

    -- Check for map record
    if completionTime < map_stats.best_time.time then
        map_stats.best_time = { time = completionTime, player = name }
        is_map_record = true
    end

    -- Check for global record
    if completionTime < global_stats.best_time.time then
        global_stats.best_time = { time = completionTime, player = name, map = map }
    end

    -- Initialize player statistics if not present
    all_time_stats.maps[map] = map_stats
    if not global_stats.players[name] then
        global_stats.players[name] = {
            best_time_seconds = completionTime,
            completions = 1,
            avg_time_seconds = completionTime
        }
    end
    if not map_stats.players[name] then
        map_stats.players[name] = {
            best_time_seconds = completionTime,
            completions = 1,
            avg_time_seconds = completionTime
        }
    end

    -- Update statistics
    updateStats(global_stats.players[name], completionTime)
    updateStats(map_stats.players[name], completionTime)

    -- Announce achievements
    if is_map_record then
        say_all(formatMessage("New map record by %s: %s!", name, formatTime(completionTime)))
    elseif is_personal_best then
        say_all(formatMessage("New personal best for %s: %s", name, formatTime(completionTime)))
    end

    -- Update current game rankings
    current_game_stats.rankings = {}
    for _, p in pairs(players) do
        if p.completions > 0 then
            table_insert(current_game_stats.rankings,
                { name = p.name, completions = p.completions, best_time = p.best_time })
        end
    end
    table_sort(current_game_stats.rankings, function(a, b)
        return a.completions > b.completions or (a.completions == b.completions and a.best_time < b.best_time)
    end)
end

local function saveStats()
    writeJSON(stats_file, all_time_stats)
end

local function loadStats()
    all_time_stats = readJSON(stats_file, all_time_stats)
end

function OnScriptLoad()
    for command_name, data in pairs(CONFIG.COMMANDS) do
        local aliases = data[1]
        local permission_level = data[2]
        for _, alias in ipairs(aliases) do
            alias_to_command[alias] = { command = command_name, level = permission_level }
        end
    end
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    local config_path = getConfigPath()
    stats_file = config_path .. "\\sapp\\" .. CONFIG.DATABASE_FILE

    loadStats()
    OnStart() -- in case the script is loaded mid-game
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    local map = get_var(0, '$map')
    local cfg = CONFIG.MAPS[map]
    if not cfg then
        registerCallbacks(false)
        return
    end

    local flag_id, flag_name, oddball_id, oddball_name = getFlagAndOddballData()
    if cfg.spawn_flags and flag_id then
        execute_command("disable_object '" .. flag_name .. "'")
        spawnObject(cfg.start[1], cfg.start[2], cfg.start[3], flag_id)
        spawnObject(cfg.start[4], cfg.start[5], cfg.start[6], flag_id)
        spawnObject(cfg.finish[1], cfg.finish[2], cfg.finish[3], flag_id)
        spawnObject(cfg.finish[4], cfg.finish[5], cfg.finish[6], flag_id)
    end

    if cfg.spawn_checkpoint_markers and oddball_id then
        for _, checkpoint in ipairs(cfg.checkpoints) do
            local x, y, z = checkpoint[1], checkpoint[2], checkpoint[3]
            local oddball = spawnObject(x, y, z, oddball_id)
            oddballs[oddball] = { x = x, y = y, z = z }
        end
        execute_command("disable_object '" .. oddball_name .. "'")
    end

    map_cfg = cfg
    game_over = false
    current_game_stats.map = map
    current_game_stats.best_time = { time = math_huge, player = "" }
    current_game_stats.rankings = {}

    players = {}
    for i = 1, 16 do
        if player_present(i) then OnJoin(i) end
    end

    registerCallbacks(true)
end

function OnEnd()
    game_over = true
    saveStats()
end

function OnJoin(id)
    players[id] = {
        id = id,
        name = get_var(id, '$name'),
        started = false,
        finished = false,
        start_time = 0,
        completion_time = 0,
        best_time = math_huge,
        completions = 0,
        deaths = 0,
        checkpoint_index = 0,
        current_checkpoint = nil,
        prev_tick_pos = nil -- Added for line crossing detection
    }
end

function OnQuit(id)
    players[id] = nil
end

function OnPreSpawn(id)
    local player = players[id]
    if not player or not player.spawn_target then return end

    local dyn = get_dynamic_player(id)
    if dyn == 0 then return end

    local x, y, z, r = unpack(player.spawn_target)

    -- Set position
    write_vector3d(dyn + 0x5C, x, y, z)

    -- Apply rotation if defined
    if r then
        write_vector3d(dyn + 0x74, math.cos(r), math.sin(r), 0)
    end

    -- Clear spawn target so we don't teleport again
    player.spawn_target = nil
end

function OnSpawn(id)
    execute_command("s " .. id .. " " .. map_cfg.running_speed)
end

function OnDeath(id)
    local player = players[id]
    if not player or not player.started then return end

    player.deaths = player.deaths + 1

    -- Always respawn at last checkpoint if available
    if player.current_checkpoint then
        player.spawn_target = {
            player.current_checkpoint[1],
            player.current_checkpoint[2],
            player.current_checkpoint[3],
            player.current_checkpoint[4]
        }
    else
        -- Default to starting spawn location
        player.spawn_target = {
            map_cfg.start.spawn[1],
            map_cfg.start.spawn[2],
            map_cfg.start.spawn[3],
            map_cfg.start.spawn[4]
        }
    end

    -- Restart course if too many deaths
    if player.deaths >= map_cfg.restart_after then
        player.started = false
        player.finished = false
        player.checkpoint_index = 0
        player.deaths = 0
        rprint(id, "You've died too many times! Restarting the course...")
    end

    setRespawnTime(id)
end

local function anchorOddballs()
    if not map_cfg.spawn_checkpoint_markers then return end
    for object_id, pos in pairs(oddballs) do
        local object = get_object_memory(object_id)
        if object == 0 then goto continue end

        -- update position, velocity, yaw, pitch and roll
        write_vector3d(object + 0x5C, pos.x, pos.y, pos.z)
        write_float(object + 0x68, 0) -- x vel
        write_float(object + 0x6C, 0) -- y vel
        write_float(object + 0x70, 0) -- z vel
        write_float(object + 0x90, 0) -- yaw
        write_float(object + 0x8C, 0) -- pitch
        write_float(object + 0x94, 0) -- roll

        ::continue::
    end
end

function OnTick()
    if game_over then return end

    anchorOddballs()
    local now = os_time()

    for id, player in pairs(players) do
        local dyn_player = get_dynamic_player(id)
        if not validatePlayer(id) or not dyn_player then goto continue end

        local x, y, z = getPos(dyn_player)
        if not x then goto continue end

        -- Store previous position for line crossing detection
        local prev_tick_pos = player.prev_tick_pos
        player.prev_tick_pos = { x, y, z }

        -- Skip if we don't have a previous position
        if not prev_tick_pos then goto continue end

        -- Check if player is crossing the start line
        if not player.started and isCrossingLine(x, y, z,
                { map_cfg.start[1], map_cfg.start[2], map_cfg.start[3] },
                { map_cfg.start[4], map_cfg.start[5], map_cfg.start[6] },
                prev_tick_pos) then
            player.started = true
            player.finished = false
            player.start_time = now
            player.checkpoint_index = 0
            player.deaths = 0
            rprint(id, "Course started! Good luck!")
        end

        -- Check if player is crossing the finish line
        if player.started and not player.finished and isCrossingLine(x, y, z,
                { map_cfg.finish[1], map_cfg.finish[2], map_cfg.finish[3] },
                { map_cfg.finish[4], map_cfg.finish[5], map_cfg.finish[6] },
                prev_tick_pos) then
            -- Make sure all checkpoints were passed
            if player.checkpoint_index >= #map_cfg.checkpoints then
                player.finished = true
                player.completion_time = now - player.start_time
                player.completions = player.completions + 1

                -- Update stats
                updatePlayerStats(player, player.completion_time)

                rprint(id, "Course completed in " .. formatTime(player.completion_time) .. "!")
            else
                rprint(id,
                    "You missed some checkpoints! (" .. player.checkpoint_index .. "/" .. #map_cfg.checkpoints .. ")")
            end
        end

        -- Check if player is near a checkpoint
        if player.started and not player.finished then
            for i, checkpoint in ipairs(map_cfg.checkpoints) do
                -- determine whether this checkpoint is eligible to be claimed
                local can_claim = false
                if map_cfg.in_order then
                    -- must be exactly the next checkpoint in sequence
                    can_claim = (i == player.checkpoint_index + 1)
                else
                    -- allow any checkpoint higher than current
                    can_claim = (i > player.checkpoint_index)
                end

                if can_claim and isNearPoint(x, y, z, checkpoint, 1.0) then
                    player.checkpoint_index = i

                    local elapsed = now - player.start_time
                    rprint(id, string_format(
                        "Checkpoint %d/%d reached! Total time: %s",
                        i, #map_cfg.checkpoints,
                        formatTime(elapsed)
                    ))

                    -- Update previous position for respawning
                    player.current_checkpoint = { checkpoint[1], checkpoint[2], checkpoint[3], checkpoint[4] }
                    break
                end
            end
        end

        ::continue::
    end
end

local function parseArgs(input)
    local result = {}
    for substring in input:gmatch("([^%s]+)") do
        result[#result + 1] = substring
    end
    return result
end

function OnCommand(id, command)
    if id == 0 then return true end

    local args = parseArgs(command)
    if #args == 0 then return false end

    local command_data = alias_to_command[args[1]]
    if not command_data then return true end -- allow all other commands
    if not hasCommandPermission(id, args[1]) then return false end

    local cmd = command_data.command

    if cmd == "checkpoint" then
        local player = players[id]
        if not player then return false end

        local index = tonumber(args[2])
        if not index then
            rprint(id, "Usage: /cp <checkpoint number>")
            return false
        end

        local checkpoint = map_cfg.checkpoints[index]
        if not checkpoint then
            rprint(id, "Invalid checkpoint number! Max is " .. #map_cfg.checkpoints)
            return false
        end

        local dyn = get_dynamic_player(id)
        if dyn == 0 then
            rprint(id, "You must be alive to teleport.")
            return false
        end

        -- Move player instantly
        write_vector3d(dyn + 0x5C, checkpoint[1], checkpoint[2], checkpoint[3])

        -- Update player's checkpoint tracking so respawn and UI are consistent
        player.checkpoint_index = index
        player.current_checkpoint = { checkpoint[1], checkpoint[2], checkpoint[3], checkpoint[4] }

        rprint(id, "Teleported to checkpoint " .. index .. "!")
        return false
    end

    if cmd == "checkpointreset" then
        local player = players[id]
        if not player or not player.started then
            rprint(id, "You haven't started the course yet!")
            return false
        end

        if player.current_checkpoint then
            player.spawn_target = {
                player.current_checkpoint[1],
                player.current_checkpoint[2],
                player.current_checkpoint[3],
                player.current_checkpoint[4]
            }
            execute_command("kill " .. id)
            rprint(id, "Respawning at last checkpoint...")
        else
            rprint(id, "No checkpoint reached yet! Use /treset to restart.")
        end
        return false
    end

    if cmd == "runreset" then
        local player = players[id]
        if not player then return false end

        player.spawn_target = {
            map_cfg.start.spawn[1],
            map_cfg.start.spawn[2],
            map_cfg.start.spawn[3],
            map_cfg.start.spawn[4]
        }
        execute_command("kill " .. id)
        rprint(id, "Respawning at the beginning...")
        return false
    end

    if cmd == "hardreset" then
        local player = players[id]
        if not player then return false end

        -- Reset all current run stats:
        player.started = false
        player.finished = false
        player.start_time = 0
        player.completion_time = 0
        player.checkpoint_index = 0
        player.current_checkpoint = nil
        player.deaths = 0

        -- Respawn at start line:
        player.spawn_target = {
            map_cfg.start.spawn[1],
            map_cfg.start.spawn[2],
            map_cfg.start.spawn[3],
            map_cfg.start.spawn[4]
        }
        execute_command("kill " .. id)

        rprint(id, "Your stats have been reset. Back to the start line!")
        return false
    end

    if cmd == "getposition" then
        local dyn = get_dynamic_player(id)
        if dyn == 0 then
            rprint(id, "You must be spawned to use this command.")
            return false
        end

        local x, y, z = read_vector3d(dyn + 0x5C)
        local cam_x = read_float(dyn + 0x230)
        local cam_y = read_float(dyn + 0x234)
        local yaw = atan2(cam_y, cam_x)
        local out = string.format("Position: %.2f, %.2f, %.2f, %.4f", x, y, z, yaw)
        rprint(id, out); cprint(out)
        return false
    end

    if cmd == "statistics" then
        local player = players[id]
        if not player then return false end

        local name = player.name
        local map = current_game_stats.map
        local global_stats = all_time_stats.global.players[name]
        local map_stats = all_time_stats.maps[map] and all_time_stats.maps[map].players[name]

        if global_stats then
            rprint(id, formatMessage("Global: Best %s | Avg %s | Completions: %d",
                formatTime(global_stats.best_time_seconds),
                formatTime(global_stats.avg_time_seconds),
                global_stats.completions))
        else
            rprint(id, "No global stats recorded for " .. name)
        end

        if map_stats then
            rprint(id, formatMessage("%s: Best %s | Avg %s | Completions: %d",
                map,
                formatTime(map_stats.best_time_seconds),
                formatTime(map_stats.avg_time_seconds),
                map_stats.completions))
        else
            rprint(id, formatMessage("%s: No stats yet", map))
        end

        return false
    end

    if cmd == "leaderboard" then
        local map = current_game_stats.map
        if all_time_stats.maps[map] then
            rprint(id, formatMessage("All-Time Best Times on %s:", map))
            local map_players = {}
            for pname, stats in pairs(all_time_stats.maps[map].players) do
                table_insert(map_players, { name = pname, best_time = stats.best_time_seconds })
            end
            table_sort(map_players, function(a, b) return a.best_time < b.best_time end)
            for i = 1, math.min(5, #map_players) do
                rprint(id, formatMessage("%d. %s - %s", i, map_players[i].name,
                    formatTime(map_players[i].best_time)))
            end
        else
            rprint(id, formatMessage("No records yet for %s", map))
        end
        return false
    end

    if cmd == "rankings" then
        rprint(id, "Current Parkour Rankings:")
        for i, player in ipairs(current_game_stats.rankings) do
            rprint(id, formatMessage("%d. %s - Completions: %d, Best: %s",
                i, player.name, player.completions, formatTime(player.best_time)))
        end
        return false
    end
end

function OnScriptUnload()
    saveStats()
end
