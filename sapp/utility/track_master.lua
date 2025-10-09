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
                      * New personal bests + New map records
                  - Provides in-game commands:
                      * /stats [player|all]     - Show personal stats for current player, specific player, or all online players
                      * /top [page]             - Display paginated top laps for current map (default page size: 10)
                      * /global [page]          - Display paginated top overall players across all maps (default page size: 10)
                  - Exports lap records to JSON and optional text file
                  - Automatic saving and exporting on game end or script unload
                  - Configurable options:
                      * pagination sizes
                      * minimum lap time
                      * export files
                      * driver-only laps
                      * final leaderboard display (map or global)

COMMAND SYNTAX:
    /stats                    - Show your personal stats on current map
    /stats [player_name]      - Show stats for specific player on current map
    /stats [player_id]        - Show stats for player by ID on current map
    /stats all                - Show stats for all online players on current map
    /top                      - Show first page of top laps for current map
    /top [page_number]        - Show specific page of top laps for current map
    /global                   - Show first page of top overall players
    /global [page_number]     - Show specific page of top overall players

SCORING SYSTEM:
    Global rankings are calculated using a weighted system:
    - Map Record: +200 points per map record held
    - Global Record: +300 bonus points for overall best lap
    - Performance: Up to +50 points based on lap time relative to map record
    - Top Finishes: Laps within 95% of record time count as top finishes (tiebreaker)
    - Participation: Players with fewer than 3 maps played get 50% point penalty

REQUIREMENTS:     Install to the same directory as sapp.dll
                  - Lua JSON Parser:  http://regex.info/blog/lua/json

LAST UPDATED:     9/10/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Config start ---------------------------------------------
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
    TOP_FINAL_GLOBAL = false,  -- true = GLOBAL map results | false = CURRENT map results | This setting requires SHOW_FINAL_TOP = true
    MSG_PREFIX = "**SAPP**",   -- Some functions temporarily change the message msg_prefix; this restores it.

    -- Pagination settings
    TOP_PAGE_SIZE = 10,    -- Default results per page for /top command
    GLOBAL_PAGE_SIZE = 10, -- Default results per page for /global command

    -- Scoring weights
    MAP_RECORD_WEIGHT = 200,    -- Points for holding a map record
    GLOBAL_RECORD_WEIGHT = 300, -- Bonus points for holding the global best lap
    PERFORMANCE_WEIGHT = 50,    -- Max points for performance relative to record
    TOP_FINISH_THRESHOLD = 0.95 -- Ratio threshold for counting top finishes
}
-- Config ends ---------------------------------------------

api_version = '1.12.0.0'

local io_open = io.open
local tonumber, pcall, pairs, ipairs, select = tonumber, pcall, pairs, ipairs, select
local table_insert, table_sort, table_concat = table.insert, table.sort, table.concat
local math_floor, math_huge, math_min, math_ceil, math_abs = math.floor, math.huge, math.min, math.ceil, math.abs

local get_object_memory, get_dynamic_player = get_object_memory, get_dynamic_player
local get_var, player_present, say_all, rprint = get_var, player_present, say_all, rprint
local get_player, player_alive, read_dword, read_word = get_player, player_alive, read_dword, read_word

local players, stats = {}, {}
local stats_file, txt_export_file
local json = loadfile('json.lua')()
local current_map, tick_rate = "", 1 / 30
local global_best_lap = { time = math_huge, player = "", map = "" }

local function fmt(str, ...)
    return select('#', ...) > 0 and str:format(...) or str
end

local function sendPublic(str)
    execute_command('msg_prefix ""')
    say_all(str)
    execute_command('msg_prefix "' .. CONFIG.MSG_PREFIX .. '"')
end

local function roundToHundredths(num)
    return math_floor(num * 100 + 0.5) / 100
end

local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

local function fmtTime(lap_time)
    if lap_time == 0 or lap_time == math_huge then return "00:00.000" end
    local total_hundredths = math_floor(lap_time * 100 + 0.5)
    local minutes = math_floor(total_hundredths / 6000)
    local remaining_hundredths = total_hundredths % 6000
    local secs = math_floor(remaining_hundredths / 100)
    local hundredths = remaining_hundredths % 100
    return fmt("%02d:%02d.%03d", minutes, secs, hundredths)
end

local function fmtTimeDifference(diff)
    local sign = diff >= 0 and "+" or "-"
    local abs_diff = math_abs(diff)
    local total_hundredths = math_floor(abs_diff * 100 + 0.5)
    local minutes = math_floor(total_hundredths / 6000)
    local remaining_hundredths = total_hundredths % 6000
    local secs = math_floor(remaining_hundredths / 100)
    local hundredths = remaining_hundredths % 100
    return fmt("%s%02d:%02d.%03d", sign, minutes, secs, hundredths)
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
            local line = fmt("%s, %s, %s", map, data.current_best.time, data.current_best.player)
            table_insert(lines, line)
        end
    end

    -- Add global best lap to export
    if global_best_lap.time < math_huge then
        local line = fmt("GLOBAL_BEST, %s, %s (%s)", global_best_lap.time,
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
    if is_map_record then
        sendPublic(fmt("NEW MAP RECORD: [%s - %s]", name, fmtTime(lapTime)))
    elseif is_personal_best then
        sendPublic(fmt("NEW PERSONAL BEST: [%s - %s]", name, fmtTime(lapTime)))
    else
        local best_time = player.best_lap
        local difference = lapTime - best_time
        rprint(player.id,
            fmt("Lap completed: %s (Best: %s | +%s)",
                fmtTime(lapTime),
                fmtTime(best_time),
                fmtTimeDifference(difference)))
    end
end

local function parseArgs(input)
    local result = {}
    for substring in input:gmatch("([^%s]+)") do
        result[#result + 1] = substring
    end
    return result
end

local function showTopPlayers(id, page)
    local send = id and function(msg) rprint(id, msg) end or sendPublic
    local map_data = stats[current_map]
    local map_best_laps = {}

    if not map_data then
        send("No records for this map yet")
        return
    end

    -- Collect all player best laps
    for player_name, player_stats in pairs(map_data.players) do
        table_insert(map_best_laps, {
            name = player_name,
            best_lap = player_stats.best
        })
    end

    if #map_best_laps == 0 then
        send("No records for this map yet")
        return
    end

    -- Sort by best lap time
    table_sort(map_best_laps, function(a, b) return a.best_lap < b.best_lap end)

    -- Pagination logic
    local page_size = CONFIG.TOP_PAGE_SIZE
    local total_entries = #map_best_laps
    local total_pages = math_ceil(total_entries / page_size)

    page = page or 1
    if page < 1 then page = 1 end
    if page > total_pages then page = total_pages end

    local start_index = (page - 1) * page_size + 1
    local end_index = math_min(start_index + page_size - 1, total_entries)

    -- Display results
    send(fmt("Top players for %s [Page %d/%d]:", current_map, page, total_pages))

    for i = start_index, end_index do
        local entry = map_best_laps[i]
        send(fmt("%d. %s - %s", i, entry.name, fmtTime(entry.best_lap)))
    end

    if total_pages > 1 then
        send(fmt("Use '/top %d' for next page", page + 1))
    end
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
                        maps_played = 0
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
                end

                -- Award points based on performance relative to map record
                if map_data.current_best then
                    local ratio = map_data.current_best.time / player_stats.best
                    local performance_points = math_floor(ratio * CONFIG.PERFORMANCE_WEIGHT)
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

            table_insert(players_array, {
                name = name,
                points = data.adjusted_points,
                map_records = data.map_records,
                top_finishes = data.top_finishes,
                maps_played = data.maps_played
            })
        end
    end

    -- Sort by points (descending)
    table_sort(players_array, function(a, b)
        if a.points == b.points then
            -- Tiebreaker: more map records
            if a.map_records == b.map_records then
                -- Second tiebreaker: more top finishes
                return a.top_finishes > b.top_finishes
            end
            return a.map_records > b.map_records
        end
        return a.points > b.points
    end)

    -- Return top n players
    local result = {}
    for i = 1, math_min(n, #players_array) do
        table_insert(result, players_array[i])
    end

    return result
end

local function showGlobalStats(id, page, page_size)
    local send = id and function(msg) rprint(id, msg) end or sendPublic

    -- Get all players (not limited by page size yet)
    local all_players = getTopOverallPlayers(10000) -- Large number to get all players

    if #all_players == 0 then
        send("No records yet")
        return
    end

    -- Pagination logic
    page_size = page_size or CONFIG.GLOBAL_PAGE_SIZE
    local total_entries = #all_players
    local total_pages = math_ceil(total_entries / page_size)

    page = page or 1
    if page < 1 then page = 1 end
    if page > total_pages then page = total_pages end

    local start_index = (page - 1) * page_size + 1
    local end_index = math_min(start_index + page_size - 1, total_entries)

    -- Display results
    send(fmt("Top players [Page %d/%d]:", page, total_pages))

    for i = start_index, end_index do
        local player = all_players[i]
        send(fmt("%d. %s [%d pts]", i, player.name, player.points))
    end

    if total_pages > 1 then
        send(fmt("Use '/global %d' for next page", page + 1))
    end
end

local function showPlayerStats(id, target)
    local send = function(msg) rprint(id, msg) end
    local map_data = stats[current_map]

    if not map_data or not map_data.players then
        send("No records for this map yet")
        return
    end

    if target == "all" then
        -- Show stats for all online players
        for pid, player_data in pairs(players) do
            if player_present(pid) then
                local player_name = player_data.name
                local player_stats = map_data.players[player_name]
                if player_stats then
                    send(fmt("%s: Best [%s], Avg [%s]",
                        player_name,
                        fmtTime(player_stats.best),
                        fmtTime(player_stats.average)))
                else
                    send(fmt("%s: No laps recorded", player_name))
                end
            end
        end
    else
        -- Show stats for specific player
        local target_id = tonumber(target)
        local player_name

        if target_id and player_present(target_id) then
            player_name = get_var(target_id, "$name")
        else
            -- Assume it's a player name
            player_name = target
        end

        local player_stats = map_data.players[player_name]
        if player_stats then
            send(fmt("%s: Best [%s], Avg [%s]",
                player_name,
                fmtTime(player_stats.best),
                fmtTime(player_stats.average)))
        else
            send(fmt("No records found for %s on %s", player_name, current_map))
        end
    end
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
    showGlobalStats(nil, 1, CONFIG.LIST_SIZE) -- show top overall players (all maps)
end

function OnJoin(id)
    local player_name = get_var(id, "$name")
    local best_lap = math_huge
    if stats[current_map] and stats[current_map].players and stats[current_map].players[player_name] then
        best_lap = stats[current_map].players[player_name].best
    end
    players[id] = {
        id = id,
        name = player_name,
        previous_time = 0,
        best_lap = best_lap
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
        local page = tonumber(args[2]) or 1
        showTopPlayers(id, page)
        return false
    elseif args[1] == CONFIG.STATS_COMMAND then
        local target = args[2] or tostring(id)
        showPlayerStats(id, target)
        return false
    elseif args[1] == CONFIG.GLOBAL_TOP_COMMAND then
        local page = tonumber(args[2]) or 1
        showGlobalStats(id, page)
        return false
    end
end

function OnScriptLoad()
    local config_path = getConfigPath()
    stats_file = config_path .. "\\sapp\\" .. CONFIG.STATS_FILE
    txt_export_file = config_path .. "\\sapp\\" .. CONFIG.TEXT_EXPORT_FILE

    stats = readJSON(stats)

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
