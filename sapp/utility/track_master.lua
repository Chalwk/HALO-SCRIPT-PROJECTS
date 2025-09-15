--[[
===============================================================================
SCRIPT NAME:      track_master.lua
DESCRIPTION:      Advanced race tracking and leaderboard system.
                  - Tracks individual lap times for each player in real-time
                  - Records personal bests, map records, and global records
                  - Computes average lap times and total laps per player
                  - Maintains persistent JSON storage for all-time stats
                  - Provides in-game commands for retrieving stats, top 5 best laps,
                    and current race rankings
                  - Announces personal bests and map record achievements automatically
                  - Supports both FFA and Team race types

COMMANDS:

    /stats
        - Shows your stats on the current map
    /stats <player id|name>
        - Shows the specified player's stats on the current map
    /stats <map name>
        - Shows your stats on the specified map
    /stats <player id|name> <map name>
        - Shows the specified player's stats on the specified map

    /top5 <global|map> [map name]
        - global -> Shows top 5 all-time global best laps
        - map    -> Shows top 5 all-time best laps on the specified map (or current map if omitted)

    /current
        - Shows current race rankings, including laps and best lap times

LAST UPDATED:     16/9/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = '1.12.0.0'

-- Configuration -------------------------------------------
local CONFIG = {
    STATS_FILE = "race_stats.json",       -- File to store all-time stats
    TEXT_EXPORT_FILE = "lap_records.txt", -- File to export lap records to

    STATS_COMMAND = "stats",              -- Command to display all-time stats
    TOP5_COMMAND = "top5",                -- Command to display top 5 best laps
    CURRENT_COMMAND = "current",          -- Command to display current race rankings

    EXPORT_LAP_RECORDS = true,            -- Export lap records to lap_records.txt
    MIN_LAP_TIME = 10.0,                  -- Minimum reasonable lap time in seconds

    -- Configurable messages
    MESSAGES = {
        NEW_MAP_RECORD = "New map record by %s: %s!",
        PERSONAL_BEST = "New personal best for %s: %s",
        CURRENT_GAME_BEST = "Current best on %s: %s (%s)",
        ALL_TIME_BEST = "All-time best on %s: %s (%s)",
        NO_LAPS = "No laps completed this game.",
        NO_RECORD = "No all-time record for this map yet.",
        NO_STATS = "No stats recorded for this map yet.",

        STATS_GLOBAL = "Global: Best %s | Avg %s",
        STATS_MAP = "%s: Best %s | Avg %s",
        STATS_NO_MAP = "%s: No stats yet",

        TOP5_GLOBAL_HEADER = "All-Time Global Best Laps:",
        TOP5_MAP_HEADER = "All-Time Best Laps on %s:",
        TOP5_ENTRY = "%d. %s - %s",
        TOP5_NO_RECORDS = "No records yet for %s",

        CURRENT_HEADER = "Current Race Rankings:",
        CURRENT_ENTRY = "%d. %s - Laps: %d, Best: %s"
    }
}
-- Config ends ---------------------------------------------

local io_open = io.open

local math_floor, math_huge = math.floor, math.huge
local table_insert, table_sort, table_concat = table.insert, table.sort, table.concat
local string_format = string.format

local stats_file, txt_export_file

local get_var, player_present, register_callback, say_all, rprint =
    get_var, player_present, register_callback, say_all, rprint

local get_dynamic_player, get_player, player_alive, read_dword, read_word =
    get_dynamic_player, get_player, player_alive, read_dword, read_word

local json = loadfile('json.lua')()
local tick_rate = 1 / 30

local players, previous_time = {}, {}

local all_time_stats = {
    maps = {},
    global = {
        best_lap = { time = math_huge, player = "", map = "" },
        players = {}
    }
}

local current_game_stats = {
    race_type = "",
    map = "",
    best_lap = { time = math_huge, player = "" },
    rankings = {}
}

local function formatMessage(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

local function parseArgs(input, delimiter)
    local result = {}
    for substring in input:gmatch("([^" .. delimiter .. "]+)") do
        result[#result + 1] = substring
    end
    return result
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
    file:write(json:encode(data))
    file:close()
    return true
end

local function exportLapRecords(path, stats)
    local lines, maps = {}, {}

    for map in pairs(stats.maps) do table_insert(maps, map) end

    table_sort(maps, function(a, b) return a:lower() < b:lower() end)

    for _, map in ipairs(maps) do
        local data = stats.maps[map]
        if data.best_lap and data.best_lap.time < math_huge then
            local line = string_format("%s, %s, %s", map, data.best_lap.time, data.best_lap.player)
            table_insert(lines, line)
        end
    end

    local file = io_open(path, "w")
    if file then
        file:write(table_concat(lines, "\n"))
        file:close()
    end
end

local function saveStats()
    writeJSON(stats_file, all_time_stats)
    if CONFIG.EXPORT_LAP_RECORDS then
        exportLapRecords(txt_export_file, all_time_stats)
    end
end

local function inVehicleAsDriver(id)
    local dyn_player = get_dynamic_player(id)
    if not player_alive(id) or dyn_player == 0 then return false end

    local vehicle_id = read_dword(dyn_player + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return false end

    local vehicle_object = get_object_memory(vehicle_id)
    if vehicle_object == 0 then return false end

    return read_word(dyn_player + 0x2F0) == 0
end

local function validateLapTime(lap_time)
    return lap_time >= CONFIG.MIN_LAP_TIME
end

local function safeReadWord(address)
    if address == 0 then return 0 end
    return read_word(address)
end

local function updateStats(stats, lapTime)
    if lapTime < stats.best_lap_seconds then
        stats.best_lap_seconds = lapTime
    end
    local total_time = (stats.avg_lap_seconds or 0) * ((stats.laps or 0)) + lapTime
    stats.laps = (stats.laps or 0) + 1
    stats.avg_lap_seconds = total_time / stats.laps
end

local function updatePlayerStats(player, lapTime)
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

local function processLapTime(player, lap_time)
    player.laps = player.laps + 1
    player.previous_time = lap_time
    table_insert(player.lapTimes, lap_time)
    updatePlayerStats(player, lap_time)
end

local function shouldProcessPlayer(id)
    return player_present(id) and player_alive(id) and
        get_player(id) ~= 0 and get_dynamic_player(id) ~= 0 and
        inVehicleAsDriver(id)
end

function OnTick()
    for id, player in pairs(players) do
        if not shouldProcessPlayer(id) then goto continue end

        local static_player = get_player(id)
        local lap_ticks = safeReadWord(static_player + 0xC4)
        local lap_time = roundToHundredths(lap_ticks * tick_rate)

        if lap_time > 0 and lap_time ~= previous_time[id] and validateLapTime(lap_time) then
            processLapTime(player, lap_time)
        end

        previous_time[id] = lap_time
        ::continue::
    end
end

function OnStart()
    if get_var(0, '$gt') ~= 'race' then return end

    local current_map = get_var(0, "$map")
    local is_ffa = get_var(0, '$ffa') == '1'

    current_game_stats = {
        race_type = is_ffa and 'FFA' or 'Team',
        map = current_map,
        best_lap = { time = math_huge, player = "" },
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
    saveStats()

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
        best_lap = math_huge,
        previous_time = 0,
        lapTimes = {},
    }
    previous_time[id] = 0
end

function OnQuit(id)
    local player = players[id]
    if player then
        players[id] = nil
    end
end

function OnCommand(id, command)
    if id == 0 then return true end

    local args = parseArgs(command, " ")
    if #args == 0 then return end

    local cmd = args[1]:lower()
    local arg_map = args[2]
    local map = arg_map or current_game_stats.map

    if cmd == CONFIG.STATS_COMMAND then
        local target_player

        if #args == 1 then
            -- /stats -> self, current map
            target_player = get_var(id, "$name")
            map = current_game_stats.map
        elseif #args == 2 then
            local arg = args[2]
            local pid = tonumber(arg)

            if pid then
                -- Argument is numeric -> check if player is present
                if player_present(pid) then
                    target_player = get_var(pid, "$name")
                else
                    rprint(id, "Player #" .. pid .. " is not online.")
                    return false
                end
                map = current_game_stats.map
            elseif all_time_stats.maps[arg] then
                -- Argument matches a map -> self, that map
                target_player = get_var(id, "$name")
                map = arg
            else
                -- Treat as player name -> that player, current map
                target_player = arg
                map = current_game_stats.map
            end
        elseif #args == 3 then
            local arg = args[2]
            local pid = tonumber(arg)

            if pid then
                if player_present(pid) then
                    target_player = get_var(pid, "$name")
                else
                    rprint(id, "Player #" .. pid .. " is not online.")
                    return false
                end
            else
                target_player = arg
            end

            map = args[3]
        else
            rprint(id, "Syntax error: /stats [player id|name|map] [optional map name]")
            return false
        end

        local global_stats = all_time_stats.global.players[target_player]
        local map_stats = all_time_stats.maps[map] and all_time_stats.maps[map].players[target_player]

        if global_stats then
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_GLOBAL,
                formatTime(global_stats.best_lap_seconds),
                formatTime(global_stats.avg_lap_seconds)))
        else
            rprint(id, "No global stats recorded for " .. target_player)
        end

        if map_stats then
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_MAP,
                map,
                formatTime(map_stats.best_lap_seconds),
                formatTime(map_stats.avg_lap_seconds)))
        else
            rprint(id, formatMessage(CONFIG.MESSAGES.STATS_NO_MAP, map))
        end

        return false
    end

    if cmd == CONFIG.TOP5_COMMAND then
        if #args < 2 or #args > 3 then
            rprint(id, "Syntax error: /top5 <global|map> [optional map name]")
            return false
        end

        local scope = args[2]:lower() -- "global" or "map"
        map = args[3] or current_game_stats.map

        if scope == "global" then
            rprint(id, CONFIG.MESSAGES.TOP5_GLOBAL_HEADER)
            local global_players = {}
            for pname, stats in pairs(all_time_stats.global.players) do
                table_insert(global_players, { name = pname, best_lap = stats.best_lap_seconds })
            end
            table_sort(global_players, function(a, b) return a.best_lap < b.best_lap end)
            for i = 1, math.min(5, #global_players) do
                rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_ENTRY, i, global_players[i].name,
                    formatTime(global_players[i].best_lap)))
            end
        elseif scope == "map" then
            if all_time_stats.maps[map] then
                rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_MAP_HEADER, map))
                local map_players = {}
                for pname, stats in pairs(all_time_stats.maps[map].players) do
                    table_insert(map_players, { name = pname, best_lap = stats.best_lap_seconds })
                end
                table_sort(map_players, function(a, b) return a.best_lap < b.best_lap end)
                for i = 1, math.min(5, #map_players) do
                    rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_ENTRY, i, map_players[i].name,
                        formatTime(map_players[i].best_lap)))
                end
            else
                rprint(id, formatMessage(CONFIG.MESSAGES.TOP5_NO_RECORDS, map))
            end
        else
            rprint(id, "Syntax error: /top5 <global|map> [optional map name]")
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
    txt_export_file = config_path .. "\\sapp\\" .. CONFIG.TEXT_EXPORT_FILE

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    OnStart()
end

function OnScriptUnload()
    saveStats()
end
