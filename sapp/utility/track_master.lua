--[[
===============================================================================
SCRIPT NAME:      track_master.lua
DESCRIPTION:      Advanced race tracking and leaderboard system.
                  - Tracks individual lap times for each player in real-time
                  - Records personal bests, map records, and global records
                  - Computes average lap times and total laps per player
                  - Maintains persistent JSON storage for all-time and current-game stats
                  - Provides in-game commands for retrieving stats, top 5 best laps,
                    and current race rankings
                  - Announces personal bests and map record achievements automatically
                  - Supports both FFA and Team race types

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = '1.12.0.0'

-- Configuration -------------------------------------------
local CONFIG = {
    STATS_FILE = "race_stats.json",
    CURRENT_GAME_STATS_FILE = "current_race_stats.json",
    STATS_COMMAND = "stats",
    TOP5_COMMAND = "top5",
    CURRENT_COMMAND = "current",

    -- Configurable messages
    MESSAGES = {
        NEW_MAP_RECORD = "%s set a new map record with %s!",
        PERSONAL_BEST = "%s beat their personal best with %s!",
        CURRENT_GAME_BEST = "Current Game Best on %s: %s by %s",
        ALL_TIME_BEST = "All-Time Best on %s: %s by %s",
        NO_LAPS = "No laps completed this game.",
        NO_RECORD = "No all-time record for this map yet.",
        NO_STATS = "No stats recorded for this map yet.",

        STATS_GLOBAL_HEADER = "Global Stats:",
        STATS_BEST_LAP = "Best Lap: %s",
        STATS_AVG_LAP = "Average Lap: %s",
        STATS_MAP_HEADER = "Stats for %s:",
        STATS_NO_MAP_STATS = "No statistics recorded yet for %s",

        TOP5_GLOBAL_HEADER = "All-Time Global Best Laps:",
        TOP5_MAP_HEADER = "All-Time Best Laps on %s:",
        TOP5_ENTRY = "%d. %s - %s",
        TOP5_NO_RECORDS = "No records yet for %s",

        CURRENT_HEADER = "Current Race Rankings:",
        CURRENT_ENTRY = "%d. %s - Laps: %d, Best: %s"
    }
}
-- Config ends ---------------------------------------------

local json = loadfile('json.lua')()
local players, previous_time = {}, {}
local all_time_stats = {
    maps = {},
    global = {
        best_lap = { time = math.huge, player = "", map = "" },
        players = {}
    }
}
local current_game_stats = {
    race_type = "",
    map = "",
    best_lap = { time = math.huge, player = "" },
    rankings = {}
}

local io_open = io.open
local stats_file, current_game_stats_file
local math_floor, math_huge = math.floor, math.huge
local table_insert, table_sort = table.insert, table.sort
local string_format, string_match = string.format, string.match
local get_var, player_present, register_callback, say_all, rprint =
    get_var, player_present, register_callback, say_all, rprint
local get_dynamic_player, get_player, player_alive, read_dword, read_word =
    get_dynamic_player, get_player, player_alive, read_dword, read_word

local function formatMessage(message, ...)
    if select('#', ...) > 0 then
        return message:format(...)
    end
    return message
end

local function roundToHundredths(num)
    return math_floor(num * 100 + 0.5) / 100
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
    local file = io_open(file_path, "r")
    if not file then return default end
    local content = file:read("*a")
    file:close()
    if content == "" then return default end
    local success, data = pcall(json.decode, json, content)
    return success and data or default
end

local function writeJSON(file_path, data)
    local file = io_open(file_path, "w")
    if not file then return false end
    file:write(json:encode_pretty(data))
    file:close()
    return true
end

local function inVehicleAsDriver(playerId)
    local dyn_player = get_dynamic_player(playerId)
    if not player_alive(playerId) or dyn_player == 0 then return false end

    local vehicle_id = read_dword(dyn_player + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return false end

    local vehicle_object = get_object_memory(vehicle_id)
    if vehicle_object == 0 then return false end

    return read_word(dyn_player + 0x2F0) == 0
end

local function updateStats(stats, lapTime)
    if lapTime < stats.best_lap_seconds then
        stats.best_lap_seconds = lapTime
    end
    local total_time = (stats.avg_lap_seconds or 0) * ((stats.laps or 0)) + lapTime
    stats.laps = (stats.laps or 0) + 1
    stats.avg_lap_seconds = total_time / stats.laps
end

local function updatePlayerStats(id, lapTime)
    local player = players[id]
    if not player then return end
    local name, map = player.name, current_game_stats.map
    local map_stats = all_time_stats.maps[map] or {
        best_lap = { time = math_huge, player = "" },
        players = {},
    }
    local global_stats = all_time_stats.global

    local is_personal_best = false
    local is_map_record = false

    -- Check for personal best
    if lapTime < player.best_lap then
        player.best_lap = lapTime
        is_personal_best = true
    end

    -- Check for map record
    if lapTime < map_stats.best_lap.time then
        map_stats.best_lap = { time = lapTime, player = name }
        is_map_record = true
    end

    -- Check for global record
    if lapTime < global_stats.best_lap.time then
        global_stats.best_lap = { time = lapTime, player = name, map = map }
    end

    -- Initialize player statistics if not present
    all_time_stats.maps[map] = map_stats
    if not global_stats.players[name] then
        global_stats.players[name] = { best_lap_seconds = lapTime, laps = 1, avg_lap_seconds = lapTime }
    end
    if not map_stats.players[name] then
        map_stats.players[name] = { best_lap_seconds = lapTime, laps = 1, avg_lap_seconds = lapTime }
    end

    -- Update statistics
    updateStats(global_stats.players[name], lapTime)
    updateStats(map_stats.players[name], lapTime)

    -- Announce achievements
    if is_map_record then
        say_all(formatMessage(CONFIG.MESSAGES.NEW_MAP_RECORD, name, formatTime(lapTime)))
    elseif is_personal_best then
        say_all(formatMessage(CONFIG.MESSAGES.PERSONAL_BEST, name, formatTime(lapTime)))
    end

    -- Update current game rankings
    current_game_stats.rankings = {}
    for _, p in pairs(players) do
        if p.laps > 0 then
            table_insert(current_game_stats.rankings, { name = p.name, laps = p.laps, best_lap = p.best_lap })
        end
    end
    table_sort(current_game_stats.rankings, function(a, b)
        return a.laps > b.laps or (a.laps == b.laps and a.best_lap < b.best_lap)
    end)
end

function OnTick()
    for id, player in pairs(players) do
        if player_present(id) and player_alive(id) then
            local static_player = get_player(id)
            local dyn_player = get_dynamic_player(id)
            if static_player ~= 0 and dyn_player ~= 0 then
                if not inVehicleAsDriver(id) then goto continue end

                local lap_ticks = read_word(static_player + 0xC4)
                local lap_time = roundToHundredths(lap_ticks / 30)

                if lap_time > 0 and lap_time ~= previous_time[id] then
                    player.laps = player.laps + 1
                    player.previous_time = lap_time
                    table_insert(player.lapTimes, lap_time)
                    updatePlayerStats(id, lap_time)
                end

                previous_time[id] = lap_time
            end
        end
        ::continue::
    end
end

function OnStart()
    if get_var(0, '$gt') ~= 'race' then return end
    current_game_stats = {
        race_type = get_var(0, '$ffa') == '1' and 'FFA' or 'Team',
        map = get_var(0, "$map"),
        best_lap = { time = math.huge, player = "" },
        rankings = {}
    }
    players, previous_time = {}, {}
    all_time_stats = readJSON(stats_file, all_time_stats)
    for i = 1, 16 do
        if player_present(i) then OnJoin(i) end
        previous_time[i] = 0
    end
end

function OnEnd()
    writeJSON(stats_file, all_time_stats)
    writeJSON(current_game_stats_file, current_game_stats)

    local map = current_game_stats.map
    local map_stats = all_time_stats.maps[map]

    if map_stats then
        -- Find current game best lap
        local current_best = { time = math_huge, player = "" }
        for _, p in pairs(players) do
            if p.best_lap < current_best.time then
                current_best.time = p.best_lap
                current_best.player = p.name
            end
        end

        -- Announce results
        if current_best.time < math_huge then
            say_all(formatMessage(CONFIG.MESSAGES.CURRENT_GAME_BEST, map, formatTime(current_best.time),
                current_best.player))
        else
            say_all(CONFIG.MESSAGES.NO_LAPS)
        end

        if map_stats.best_lap.time < math_huge then
            say_all(formatMessage(CONFIG.MESSAGES.ALL_TIME_BEST, map, formatTime(map_stats.best_lap.time),
                map_stats.best_lap.player))
        else
            say_all(CONFIG.MESSAGES.NO_RECORD)
        end
    else
        say_all(CONFIG.MESSAGES.NO_STATS)
    end
end

function OnJoin(id)
    players[id] = {
        name = get_var(id, "$name"),
        laps = 0,
        best_lap = math.huge,
        previous_time = 0,
        lapTimes = {},
    }
    previous_time[id] = 0
end

function OnQuit(id)
    players[id] = nil
end

function OnCommand(id, command)
    if id == 0 then return true end

    local cmd = string_match(command, "^%s*(%S+)") or ""
    cmd = cmd:lower()

    if cmd == CONFIG.STATS_COMMAND then
        local name, map = get_var(id, "$name"), current_game_stats.map
        local global_stats = all_time_stats.global.players[name]
        local map_stats = all_time_stats.maps[map] and all_time_stats.maps[map].players[name]

        if global_stats then
            rprint(id, CONFIG.MESSAGES.STATS_GLOBAL_HEADER)
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_BEST_LAP, formatTime(global_stats.best_lap_seconds)))
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_AVG_LAP, formatTime(global_stats.avg_lap_seconds)))
            rprint(id, " ")
        end

        if map_stats then
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_MAP_HEADER, map))
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_BEST_LAP, formatTime(map_stats.best_lap_seconds)))
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_AVG_LAP, formatTime(map_stats.avg_lap_seconds)))
        else
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_NO_MAP_STATS, map))
        end
        return false
    end

    if cmd == CONFIG.TOP5_COMMAND then
        local map = current_game_stats.map

        rprint(id, CONFIG.MESSAGES.TOP5_GLOBAL_HEADER)
        local global_players = {}
        for name, stats in pairs(all_time_stats.global.players) do
            table_insert(global_players, { name = name, best_lap = stats.best_lap_seconds })
        end
        table_sort(global_players, function(a, b) return a.best_lap < b.best_lap end)
        for i = 1, math.min(5, #global_players) do
            rprint(id,
                formatMessage(CONFIG.MESSAGES.TOP5_ENTRY, i, global_players[i].name,
                    formatTime(global_players[i].best_lap)))
        end
        rprint(id, " ")

        if all_time_stats.maps[map] then
            rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_MAP_HEADER, map))
            local map_players = {}
            for name, stats in pairs(all_time_stats.maps[map].players) do
                table_insert(map_players, { name = name, best_lap = stats.best_lap_seconds })
            end
            table_sort(map_players, function(a, b) return a.best_lap < b.best_lap end)
            for i = 1, math.min(5, #map_players) do
                rprint(id,
                    formatMessage(CONFIG.MESSAGES.TOP5_ENTRY, i, map_players[i].name, formatTime(map_players[i].best_lap)))
            end
        else
            rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_NO_RECORDS, map))
        end
        return false
    end

    if cmd == CONFIG.CURRENT_COMMAND then
        rprint(id, CONFIG.MESSAGES.CURRENT_HEADER)
        for i, player in ipairs(current_game_stats.rankings) do
            rprint(id,
                formatMessage(CONFIG.MESSAGES.CURRENT_ENTRY, i, player.name, player.laps, formatTime(player.best_lap)))
        end
        return false
    end
end

function OnScriptLoad()
    local config_path = getConfigPath()
    stats_file = config_path .. "\\sapp\\" .. CONFIG.STATS_FILE
    current_game_stats_file = config_path .. "\\sapp\\" .. CONFIG.CURRENT_GAME_STATS_FILE

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    OnStart()
end

function OnScriptUnload()
    writeJSON(stats_file, all_time_stats)
    writeJSON(current_game_stats_file, current_game_stats)
end