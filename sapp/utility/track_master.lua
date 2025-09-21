--[[
===============================================================================
SCRIPT NAME:      track_master.lua
DESCRIPTION:      Advanced racing tracker and leaderboard system for Halo SAPP.
FEATURES:         - Tracks player lap times and validates laps (minimum time + driver seat)
                  - Records personal bests per player and all-time map records
                  - Maintains detailed per-map player statistics:
                      * laps completed
                      * best lap
                      * average lap
                  - Calculates global rankings across all maps using a weighted point system:
                      * MAP_RECORD_WEIGHT: points awarded for holding a map record
                      * GLOBAL_RECORD_WEIGHT: bonus points for holding the global best lap
                      * PERFORMANCE_WEIGHT: points for performance relative to the map record
                      * TOP_FINISH_THRESHOLD: counts near-record laps as top finishes
                      * Participation penalty: players with few maps played may have adjusted points
                      * Tiebreakers: map records > global record > top finishes
                  - Announces in-game:
                      * New personal bests
                      * New map records
                  - Provides in-game commands:
                      * stats          - Show your personal best on current map
                      * top            - Display top N all-time laps for current map
                      * global         - Display top overall players across all maps
                  - Exports lap records to JSON and optional text file
                  - Automatic saving and exporting on game end or script unload
                  - Configurable options:
                      * top list size
                      * minimum lap time
                      * export files
                      * driver-only laps
                      * final leaderboard display

LAST UPDATED:     21/9/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Configuration -------------------------------------------
local CONFIG = {
    -- File names (in the SAPP config directory):
    STATS_FILE = "race_stats.json",
    TEXT_EXPORT_FILE = "lap_records.txt",

    -- Commands:
    STATS_COMMAND = "stats",       -- Command to show player's personal best lap (current map)
    MAP_TOP_COMMAND = "top",       -- Command to show top 5 global best laps (current map)
    GLOBAL_TOP_COMMAND = "global", -- Command to show top 5 overall players (all maps)

    -- Settings:
    LIST_SIZE = 5,             -- Number of top laps to display (applies to top command and game end)
    MIN_LAP_TIME = 10.0,       -- Minimum valid lap time in seconds
    EXPORT_LAP_RECORDS = true, -- Export lap records to a text file
    DRIVER_REQUIRED = true,    -- Only count laps if the player is the driver of the vehicle
    SHOW_FINAL_TOP = true,     -- Show top results on game end
    TOP_FINAL_GLOBAL = true,   -- Show global or current map results at game end (requires SHOW_FINAL_TOP = true)
    MSG_PREFIX = "**SAPP**",   -- Some functions temporarily change the message msg_prefix; this restores it.

    -- Scoring weights
    MAP_RECORD_WEIGHT = 200,    -- Points for holding a map record
    GLOBAL_RECORD_WEIGHT = 300, -- Bonus points for holding the global best lap
    PERFORMANCE_WEIGHT = 50,    -- Max points for performance relative to record
    TOP_FINISH_THRESHOLD = 0.95 -- Ratio threshold for counting top finishes
}
-- Config ends ---------------------------------------------

api_version = '1.12.0.0'

local io_open = io.open
local string_format = string.format
local math_floor, math_huge, math_min = math.floor, math.huge, math.min
local table_insert, table_sort, table_concat = table.insert, table.sort, table.concat

local stats_file, txt_export_file
local get_var, player_present, register_callback, say_all, rprint =
    get_var, player_present, register_callback, say_all, rprint
local get_dynamic_player, get_player, player_alive, read_dword, read_word =
    get_dynamic_player, get_player, player_alive, read_dword, read_word

local json = loadfile('json.lua')()
local players, stats = {}, {}
local current_map, tick_rate = "", 1 / 30
local global_best_lap = { time = math_huge, player = "", map = "" }

local function formatMessage(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

local function sendPublic(message)
    execute_command('msg_prefix ""')
    say_all(message)
    execute_command('msg_prefix "' .. CONFIG.MSG_PREFIX .. '"')
end

local function roundToHundredths(num)
    return math_floor(num * 100 + 0.5) / 100
end

local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

local function formatTime(lap_time)
    if lap_time == 0 or lap_time == math_huge then return "00:00.000" end
    local total_hundredths = math_floor(lap_time * 100 + 0.5)
    local minutes = math_floor(total_hundredths / 6000)
    local remaining_hundredths = total_hundredths % 6000
    local secs = math_floor(remaining_hundredths / 100)
    local hundredths = remaining_hundredths % 100
    return string_format("%02d:%02d.%03d", minutes, secs, hundredths)
end

local function readJSON(default)
    local file = io_open(stats_file, "r")
    if not file then return default end
    local content = file:read("*a")
    file:close()
    if content == "" then return default end
    local success, data = pcall(json.decode, json, content)

    -- Load global best lap if available
    if success and data.global_best then
        global_best_lap = data.global_best
    end

    return success and data or default
end

local function writeJSON()
    -- Include global best lap in saved data
    stats.global_best = global_best_lap

    local file = io_open(stats_file, "w")
    if not file then return false end
    file:write(json:encode(stats))
    file:close()
    return true
end

local function exportLapRecords()
    local lines, maps = {}, {}

    for map in pairs(stats) do
        if map ~= "global_best" then -- Skip the global best entry
            table_insert(maps, map)
        end
    end
    table_sort(maps, function(a, b) return a:lower() < b:lower() end)

    for _, map in ipairs(maps) do
        local data = stats[map]
        if data.current_best and data.current_best.time < math_huge then
            local line = string_format("%s, %s, %s", map, data.current_best.time, data.current_best.player)
            table_insert(lines, line)
        end
    end

    -- Add global best lap to export
    if global_best_lap.time < math_huge then
        local line = string_format("GLOBAL_BEST, %s, %s (%s)", global_best_lap.time,
            global_best_lap.player, global_best_lap.map)
        table_insert(lines, line)
    end

    local file = io_open(txt_export_file, "w")
    if file then
        file:write(table_concat(lines, "\n"))
        file:close()
    end
end

local function saveStats()
    writeJSON()
    if CONFIG.EXPORT_LAP_RECORDS then
        exportLapRecords()
    end
end

local function considerOccupant(id)
    if not CONFIG.DRIVER_REQUIRED then return true end

    local dyn_player = get_dynamic_player(id)
    if not player_alive(id) or dyn_player == 0 then return false end

    local vehicle_id = read_dword(dyn_player + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return false end

    local vehicle_object = get_object_memory(vehicle_id)
    if vehicle_object == 0 then return false end

    return read_word(dyn_player + 0x2F0) == 0 -- driver seat
end

local function getLapTicks(address)
    if address == 0 then return 0 end
    return read_word(address)
end

local function updatePlayerStats(player, lapTime)
    local name = player.name
    local map_stats = stats[current_map] or { current_best = { time = math_huge, player = "" }, players = {} }

    local is_personal_best = false
    local is_map_record = false
    --local is_global_record = false

    local lap_count = tonumber(get_var(player.id, '$score'))

    -- Personal best
    if lapTime < (player.best_lap or math_huge) then
        player.best_lap = lapTime
        is_personal_best = true
    end

    -- Map best
    if lapTime < map_stats.current_best.time then
        map_stats.current_best = { time = lapTime, player = name }
        is_map_record = true

        -- Check for global best
        if lapTime < global_best_lap.time then
            global_best_lap = { time = lapTime, player = name, map = current_map }
            --is_global_record = true
        end
    end

    -- Player stats for this map
    local player_stats = map_stats.players[name]
    if not player_stats then
        player_stats = { best = lapTime, laps = lap_count, average = lapTime }
        map_stats.players[name] = player_stats
    else
        -- Update lap count from the game's score system
        player_stats.laps = lap_count
        player_stats.best = math_min(player_stats.best, lapTime)
        player_stats.average = ((player_stats.average * (lap_count - 1)) + lapTime) / lap_count
    end

    stats[current_map] = map_stats

    -- Announce
    --if is_global_record then
    --sendPublic(formatMessage("NEW GLOBAL RECORD by %s: %s on %s!", name, formatTime(lapTime), current_map))
    if is_map_record then
        sendPublic(formatMessage("New map record by %s: %s!", name, formatTime(lapTime)))
    elseif is_personal_best then
        sendPublic(formatMessage("New personal best for %s: %s", name, formatTime(lapTime)))
    end
end

local function parseArgs(input)
    local result = {}
    for substring in input:gmatch("([^%s]+)") do
        result[#result + 1] = substring
    end
    return result
end

local function showTopPlayers(id)
    local send = id and function(msg) rprint(id, msg) end or sendPublic
    local map_data = stats[current_map]
    local map_best_laps = {}

    if not map_data then
        send("No records for this map yet.")
        goto continue
    end

    send("Top players for " .. current_map .. ":")
    for player_name, player_stats in pairs(map_data.players) do
        table_insert(map_best_laps, {
            name = player_name,
            best_lap = player_stats.best
        })
    end

    table.sort(map_best_laps, function(a, b) return a.best_lap < b.best_lap end)

    for i = 1, math_min(CONFIG.LIST_SIZE, #map_best_laps) do
        local entry = map_best_laps[i]
        send(string.format("%d. %s - %s", i, entry.name, formatTime(entry.best_lap)))
    end

    ::continue::
end

local function getTopOverallPlayers(n)
    local player_totals = {}

    -- Calculate scores for each player across all maps
    for map_name, map_data in pairs(stats) do
        if map_name ~= "global_best" and map_data.players then -- Skip global best entry
            for player_name, player_stats in pairs(map_data.players) do
                if not player_totals[player_name] then
                    player_totals[player_name] = {
                        points = 0,
                        map_records = 0,
                        top_finishes = 0,
                        maps_played = 0,
                        has_global_record = false
                    }
                end

                local player = player_totals[player_name]
                player.maps_played = player.maps_played + 1

                -- Award points for map record (if held)
                if map_data.current_best and map_data.current_best.player == player_name then
                    player.points = player.points + CONFIG.MAP_RECORD_WEIGHT
                    player.map_records = player.map_records + 1
                end

                -- Award bonus for global record
                if global_best_lap.player == player_name then
                    player.points = player.points + CONFIG.GLOBAL_RECORD_WEIGHT
                    player.has_global_record = true
                end

                -- Award points based on performance relative to map record
                if map_data.current_best then
                    local ratio = map_data.current_best.time / player_stats.best
                    local performance_points = math.floor(ratio * CONFIG.PERFORMANCE_WEIGHT)
                    player.points = player.points + performance_points

                    -- Count top finishes (within threshold of record)
                    if ratio >= CONFIG.TOP_FINISH_THRESHOLD then
                        player.top_finishes = player.top_finishes + 1
                    end
                end
            end
        end
    end

    -- Convert to sortable array, excluding players with no map records
    local players_array = {}
    for name, data in pairs(player_totals) do
        -- Only include players who have at least one map record
        if data.map_records > 0 then
            -- Apply penalty for players with few maps played
            local participation_penalty = data.maps_played < 3 and 0.5 or 1
            data.adjusted_points = data.points * participation_penalty

            table.insert(players_array, {
                name = name,
                points = data.adjusted_points,
                map_records = data.map_records,
                top_finishes = data.top_finishes,
                maps_played = data.maps_played,
                has_global_record = data.has_global_record
            })
        end
    end

    -- Sort by points (descending)
    table.sort(players_array, function(a, b)
        if a.points == b.points then
            -- Tiebreaker: more map records
            if a.map_records == b.map_records then
                -- Second tiebreaker: global record holder
                if a.has_global_record ~= b.has_global_record then
                    return a.has_global_record
                end
                -- Third tiebreaker: more top finishes
                return a.top_finishes > b.top_finishes
            end
            return a.map_records > b.map_records
        end
        return a.points > b.points
    end)

    -- Return top n players
    local result = {}
    for i = 1, math.min(n, #players_array) do
        table.insert(result, players_array[i])
    end

    return result
end

local function showGlobalStats(id, n)
    local top_players = getTopOverallPlayers(n)
    local send = id and function(msg) rprint(id, msg) end or sendPublic

    if #top_players == 0 then
        send("No records yet.")
        goto continue
    end

    send("Top overall players:")
    for i, player in ipairs(top_players) do
        local global_indicator = player.has_global_record and " [GLOBAL RECORD]" or ""
        send(string.format("%d. %s%s [%dpts]",
            i, player.name, global_indicator, player.points))
    end

    ::continue::
end

function OnScore(id)
    if not considerOccupant(id) then goto continue end

    local player = players[id]
    if not player or not player_alive(id) then goto continue end

    local static_player = get_player(id)
    local lap_ticks = getLapTicks(static_player + 0xC4)
    local lap_time = roundToHundredths(lap_ticks * tick_rate)

    if lap_time >= CONFIG.MIN_LAP_TIME then
        updatePlayerStats(player, lap_time)
    end

    ::continue::
end

function OnStart()
    if get_var(0, '$gt') ~= 'race' then return end
    current_map = get_var(0, "$map")
    players = {}
    stats = readJSON(stats)

    for i = 1, 16 do
        if player_present(i) then OnJoin(i) end
    end
end

function OnEnd()
    saveStats()
    if not CONFIG.SHOW_FINAL_TOP then return end
    if not CONFIG.TOP_FINAL_GLOBAL then
        showTopPlayers() -- show top for current map only
        return
    end
    showGlobalStats(nil, CONFIG.LIST_SIZE) -- show top overall players (all maps)
end

function OnJoin(id)
    players[id] = {
        id = id,
        name = get_var(id, "$name"),
        previous_time = 0,
        best_lap = math_huge
    }
end

function OnQuit(id)
    players[id] = nil
end

function OnCommand(id, command)
    if id == 0 then return true end

    local args = parseArgs(command)
    if #args == 0 then return false end

    if args[1] == CONFIG.MAP_TOP_COMMAND then
        showTopPlayers(id)
        return false
    elseif args[1] == CONFIG.STATS_COMMAND then
        local map_data = stats[current_map]
        if map_data and map_data.players and map_data.players[players[id].name] then
            local best = map_data.players[players[id].name].best
            rprint(id, string_format("Your best lap on %s: %s", current_map, formatTime(best)))
        else
            rprint(id, "You have no recorded laps on this map yet.")
        end
        return false
    elseif args[1] == CONFIG.GLOBAL_TOP_COMMAND then
        local count = tonumber(args[2]) or CONFIG.LIST_SIZE
        if count < 1 then count = CONFIG.LIST_SIZE end
        showGlobalStats(id, count)
        return false
    end
end

function OnScriptLoad()
    local config_path = getConfigPath()
    stats_file = config_path .. "\\sapp\\" .. CONFIG.STATS_FILE
    txt_export_file = config_path .. "\\sapp\\" .. CONFIG.TEXT_EXPORT_FILE

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_SCORE'], 'OnScore')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    OnStart()
end

function OnScriptUnload()
    saveStats()
end
