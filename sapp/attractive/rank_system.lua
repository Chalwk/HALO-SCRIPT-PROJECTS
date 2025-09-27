--[[
=====================================================================================
SCRIPT NAME:      rank_system.lua
DESCRIPTION:      Advanced player ranking and progression system that tracks
                  player statistics, awards credits for in-game actions, and
                  implements a multi-tier ranking system with grade progression.

FEATURES:
                 - Comprehensive rank progression system with multiple grades per rank
                 - Real-time credit rewards/penalties for various combat actions and events
                 - Persistent player statistics storage using JSON database
                 - Admin commands for rank management and player tracking
                 - Leaderboard system with KDR-based scoring
                 - Optimized performance with precomputed data structures

RANK SYSTEM DETAILS:
                 - Players progress through ranks by earning credits from kills and special events
                 - Each rank contains multiple grades that must be achieved before advancing
                 - Credit rewards are awarded for: headshots, revenge kills, multi-kills, sprees,
                   vehicle kills, weapon-specific kills, and various combat scenarios
                 - Penalties are applied for: suicides, betrayals, environmental deaths

CREDIT EVENTS:
                 - Combat Actions: Headshots, revenge, avenge, reload kills, close calls
                 - Kill Streaks: Spree bonuses at 5,10,15... kills and multi-kill chains
                 - Special Events: First blood, killed from the grave, vehicle squashes
                 - Weapon Specific: Different credit values per weapon type and damage source
                 - Penalties: Suicide, betrayal, falling, distance deaths

COMMANDS:
                 - rank [player_id]    - Check your or another player's rank and statistics
                 - ranks               - List all available ranks and their credit thresholds
                 - top [limit]         - Display leaderboard with top players by composite score
                 - setrank <id> <rank> <grade> - Admin command to set player rank (level 4 only)

DATA PERSISTENCE:
                 - Player stats automatically saved to 'sapp/ranks.json'
                 - Configurable save triggers: game end, player quit, script unload
                 - Survives server restarts and maintains player progression

CONFIGURATION:
                All aspects customizable via CONFIG table:
                 - Rank names and grade thresholds
                 - Credit values for all damage types and events
                 - Command permissions and currency symbol
                 - Database save timing and event triggers

REQUIREMENTS:   Install to the same directory as sapp.dll
                 - Lua JSON Parser: http://regex.info/blog/lua/json
                 - This scirpt ONLY works on maps with stock tag addresses

LAST UPDATED:     28/9/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

--CONFIG start ------------------------------------------------------

local CONFIG = {

    -- When to save player stats to database
    UPDATE = { ['game_end'] = true, ['player_quit'] = false, ['script_unload'] = true },

    -- Symbol displayed in credit messages
    SYMBOL = 'cR',

    -- Commands and required permission levels (-1 = all players, 1-4 = admin levels)
    COMMANDS = {
        { 'rank',    -1 }, -- Check your or another player's rank
        { 'ranks',   -1 }, -- List all available ranks
        { 'top',     -1 }, -- Show leaderboard
        { 'setrank', 4 },  -- Admin command to set player rank (level 4 only)
    },

    -- Rank definitions: { "Rank Name", { grade1_threshold, grade2_threshold, ... } }
    -- Players progress through grades within each rank before advancing to next rank
    RANKS = {
        { "Recruit",          { [1] = 0 } },
        { "Apprentice",       { [1] = 3000, [2] = 6000 } },
        { "Private",          { [1] = 9000, [2] = 12000 } },
        { "Corporal",         { [1] = 13000, [2] = 14000 } },
        { "Sergeant",         { [1] = 15000, [2] = 16000, [3] = 17000, [4] = 18000 } },
        { "Gunnery Sergeant", { [1] = 19000, [2] = 20000, [3] = 21000, [4] = 22000 } },
        { "Lieutenant",       { [1] = 23000, [2] = 24000, [3] = 25000, [4] = 26000 } },
        { "Captain",          { [1] = 27000, [2] = 28000, [3] = 29000, [4] = 30000 } },
        { "Major",            { [1] = 31000, [2] = 32000, [3] = 33000, [4] = 34000 } },
        { "Commander",        { [1] = 35000, [2] = 36000, [3] = 37000, [4] = 38000 } },
        { "Colonel",          { [1] = 39000, [2] = 40000, [3] = 41000, [4] = 42000 } },
        { "Brigadier",        { [1] = 43000, [2] = 44000, [3] = 45000, [4] = 46000 } },
        { "General",          { [1] = 47000, [2] = 48000, [3] = 49000, [4] = 50000 } }
    },

    -- Credit rewards/penalties for in-game events
    CREDITS = {

        -- Bonus Events: { credit_amount, "display_message" } - %s will be replaced with currency symbol

        -- Bonus Events
        head_shot             = { 1, '+1 %s (Headshot)' },          -- Headshot bonus
        revenge               = { 1, '+1 %s (Revenge)' },           -- Revenge bonus (killed someone who recently killed you)
        avenge                = { 1, '+1 %s (Avenge)' },            -- Avenge bonus (killed someone who recently killed a teammate)
        reload_this           = { 1, '+1 %s (Reload This!)' },      -- Kill a player while they are reloading
        close_call            = { 2, '+2 %s (Close Call)' },        -- Shield fully depleted + health <= 30%
        server                = { 0, '+0 %s (Server)' },
        guardians             = { -5, '-5 %s (Guardians)' },        -- Killed by guardians (both players die at the same time)
        suicide               = { -10, '-10 %s (Suicide)' },
        betrayal              = { -15, '-15 %s (Betrayal)' },       -- Team kill in non-FFA
        killed_from_the_grave = { 5, '+5 %s (Killed From Grave)' }, -- Kill after dying
        first_blood           = { 30, '+30 %s (First Blood)' },     -- First kill of the match

        -- Consecutive spree kills: triggered at specific kill counts
        spree                 = {
            [5] = { 5, '+5 %s (Spree)' },
            [10] = { 10, '+10 %s (Spree)' },
            [15] = { 15, '+15 %s (Spree)' },
            [20] = { 20, '+20 %s (Spree)' },
            [25] = { 25, '+25 %s (Spree)' },
            [30] = { 30, '+30 %s (Spree)' },
            [35] = { 35, '+35 %s (Spree)' },
            [40] = { 40, '+40 %s (Spree)' },
            [45] = { 45, '+45 %s (Spree)' },
            [50] = { 50, '+50 %s (Spree)' },
        },

        -- Multi-kill: rapid consecutive kills without dying
        multi_kill            = {
            [2] = { 8, '+8 %s (multi-kill)' },
            [3] = { 10, '+10 %s (multi-kill)' },
            [4] = { 12, '+12 %s (multi-kill)' },
            [5] = { 14, '+14 %s (multi-kill)' },
            [6] = { 16, '+16 %s (multi-kill)' },
            [7] = { 18, '+18 %s (multi-kill)' },
            [8] = { 20, '+20 %s (multi-kill)' },
            [9] = { 23, '+23 %s (multi-kill)' },
            [10] = { 25, '+25 %s (multi-kill)' },
        },

        -- Damage Events: Credit rewards based on damage source
        damage_tags           = {

            -- Distance/Falling: Environmental damage types
            falling   = { -3, '-3 %s (Fall)' },
            distance  = { -3, '-3 %s (Distance)' },

            -- Vehicle collision: Reference to tag for collision damage
            collision = 'globals\\vehicle_collision',

            -- Vehicle squash rewards: { vehicle_tag_path, { credit_amount, "display_message" } }
            vehicles  = {
                ['vehicles\\ghost\\ghost_mp']               = { 5, '+5 %s (GHOST)' },
                ['vehicles\\rwarthog\\rwarthog']            = { 6, '+6 %s (R-Hog)' },
                ['vehicles\\warthog\\mp_warthog']           = { 7, '+7 %s (Warthog)' },
                ['vehicles\\banshee\\banshee_mp']           = { 8, '+8 %s (Banshee)' },
                ['vehicles\\scorpion\\scorpion_mp']         = { 10, '+10 %s (Tank)' },
                ['vehicles\\c gun turret\\c gun turret_mp'] = { 1000, '+1000 %s (Turret)' }
            },

            --------
            -- Weapon damage rewards: { damage_tag_path, credit_amount, "display_message" }
            --------

            -- Vehicles Damage
            { 'vehicles\\ghost\\ghost bolt',                              7,  '+7 %s (Ghost)' },
            { 'vehicles\\scorpion\\bullet',                               6,  '+6 %s (Tank)' },
            { 'vehicles\\warthog\\bullet',                                6,  '+6 %s (Warthog)' },
            { 'vehicles\\c gun turret\\mp bolt',                          7,  '+7 %s (Turret)' },
            { 'vehicles\\banshee\\banshee bolt',                          7,  '+7 %s (Banshee)' },
            { 'vehicles\\scorpion\\shell explosion',                      10, '+10 %s (Tank Shell)' },
            { 'vehicles\\banshee\\mp_fuel rod explosion',                 10, '+10 %s (Fuel Rod)' },

            -- Weapons Damage
            { 'weapons\\pistol\\bullet',                                  5,  '+5 %s (Pistol)' },
            { 'weapons\\shotgun\\pellet',                                 6,  '+6 %s (Shotgun)' },
            { 'weapons\\plasma rifle\\bolt',                              4,  '+4 %s (Plasma Rifle)' },
            { 'weapons\\needler\\explosion',                              8,  '+8 %s (Needler)' },
            { 'weapons\\plasma pistol\\bolt',                             4,  '+4 %s (Plasma Pistol)' },
            { 'weapons\\assault rifle\\bullet',                           5,  '+5 %s (Assault Rifle)' },
            { 'weapons\\needler\\impact damage',                          4,  '+4 %s (Needler)' },
            { 'weapons\\flamethrower\\explosion',                         5,  '+5 %s (Flamethrower)' },
            { 'weapons\\flamethrower\\burning',                           5,  '+5 %s (Flamethrower)' },
            { 'weapons\\flamethrower\\impact damage',                     5,  '+5 %s (Flamethrower)' },
            { 'weapons\\rocket launcher\\explosion',                      8,  '+8 %s (Rocket Launcher)' },
            { 'weapons\\needler\\detonation damage',                      3,  '+3 %s (Needler)' },
            { 'weapons\\plasma rifle\\charged bolt',                      4,  '+4 %s (Plasma Rifle)' },
            { 'weapons\\sniper rifle\\sniper bullet',                     6,  '+6 %s (Sniper Rifle)' },
            { 'weapons\\plasma_cannon\\effects\\plasma_cannon_explosion', 8,  '+8 %s (Plasma Cannon)' },
            { 'weapons\\frag grenade\\explosion',                         8,  '+8 %s (Frag)' },
            { 'weapons\\plasma grenade\\attached',                        7,  '+7 %s (Plasma Grenade)' },
            { 'weapons\\plasma grenade\\explosion',                       5,  '+5 %s (Plasma Grenade)' },

            -- Melee
            { 'weapons\\flag\\melee',                                     5,  '+5 %s (Flag)' },
            { 'weapons\\ball\\melee',                                     5,  '+5 %s (Ball)' },
            { 'weapons\\pistol\\melee',                                   4,  '+4 %s (Pistol)' },
            { 'weapons\\needler\\melee',                                  4,  '+4 %s (Needler)' },
            { 'weapons\\shotgun\\melee',                                  5,  '+5 %s (Shotgun)' },
            { 'weapons\\flamethrower\\melee',                             5,  '+5 %s (Flamethrower)' },
            { 'weapons\\sniper rifle\\melee',                             5,  '+5 %s (Sniper Rifle)' },
            { 'weapons\\plasma rifle\\melee',                             4,  '+4 %s (Plasma Rifle)' },
            { 'weapons\\plasma pistol\\melee',                            4,  '+4 %s (Plasma Pistol)' },
            { 'weapons\\assault rifle\\melee',                            4,  '+4 %s (Assault Rifle)' },
            { 'weapons\\rocket launcher\\melee',                          10, '+10 %s (Rocket Launcher)' },
            { 'weapons\\plasma_cannon\\effects\\plasma_cannon_melee',     10, '+10 %s (Plasma Cannon)' },
        }
    }
}

-------------------------------------------------------------------
--CONFIG end ------------------------------------------------------
-------------------------------------------------------------------

api_version = '1.12.0.0'

-- Precomputed data structures for optimization
local RANK_LOOKUP = {}
local GRADE_THRESHOLDS = {}
local SORTED_THRESHOLDS = {}
local COMMAND_LOOKUP = {}

local stats_db = {} -- Persistent stats database
local db_directory, json

local players = {}
local damage_meta_ids = {}
local collision_meta_id = nil
local vehicle_meta_ids = {}
local ffa, falling, distance, first_blood

local io_open = io.open
local pcall = pcall
local ipairs = ipairs
local pairs = pairs
local type = type
local table_sort = table.sort
local tonumber, tostring, string_format = tonumber, tostring, string.format
local math_floor, math_min = math.floor, math.min

local get_var = get_var
local read_dword = read_dword
local read_byte = read_byte
local read_float = read_float
local read_word = read_word
local get_dynamic_player = get_dynamic_player
local get_object_memory = get_object_memory
local get_player = get_player
local player_alive = player_alive
local player_present = player_present
local lookup_tag = lookup_tag
local cprint, rprint = cprint, rprint

local function loadStatsDB()
    local f = io_open(db_directory, 'r')
    if not f then
        stats_db = {}
        return true
    end

    local content = f:read('*a')
    f:close()

    if content and content ~= '' then
        local success, result = pcall(function()
            return json:decode(content)
        end)
        if success and result then
            stats_db = result
            return true
        else
            print("Error parsing stats database: " .. tostring(result))
            stats_db = {}
            return false
        end
    else
        stats_db = {}
        return true
    end
end

local function saveStatsDB()
    local f, err = io.open(db_directory, 'w')
    if not f then
        print("Error opening stats database for writing: " .. err)
        return false
    end

    local success, json_str = pcall(function()
        return json:encode(stats_db)
    end)

    if not success then
        print("Error encoding stats database: " .. tostring(json_str))
        f:close()
        return false
    end

    f:write(json_str)
    f:close()
    return true
end

local function hasPermission(id, required_level)
    if id == 0 then return true end
    return tonumber(get_var(id, '$lvl')) >= required_level
end

local function send(id, msg)
    if id == 0 then return cprint(msg) end
    rprint(id, msg)
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function getVehicleObjectID(killer_id)
    local dyn_player = get_dynamic_player(killer_id)
    if dyn_player == 0 then return nil end

    local vehicle_id = read_dword(dyn_player + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return nil end

    local vehicle_object = get_object_memory(vehicle_id)
    if vehicle_object == 0 then return nil end

    return read_dword(vehicle_object)
end

local function parseArgs(input)
    local result = {}
    for substring in input:gmatch("([^%s]+)") do
        result[#result + 1] = substring
    end
    return result
end

local function calculateKDR(kills, deaths)
    if deaths == 0 then return kills > 0 and kills or 0 end
    return kills / deaths
end

local function getPlayerScore(stats)
    local rank_index = RANK_LOOKUP[stats.rank] or 0
    local rank_score = rank_index * 100000
    local grade_score = stats.grade or 1
    local credit_score = stats.credits or 0
    local kdr_score = calculateKDR(stats.kills or 0, stats.deaths or 0) * 1000

    return rank_score + grade_score * 10000 + credit_score + kdr_score
end

local function initializePlayer(id)
    local name = get_var(id, '$name')

    if not stats_db[name] then
        local default_rank = CONFIG.RANKS[1]
        stats_db[name] = {
            rank = default_rank[1],
            grade = 1,
            credits = default_rank[2][1],
            kills = 0,
            deaths = 0,
        }
    end

    return {
        name = name,
        team = get_var(id, '$team'),
        id = id,
        last_damage = nil,
        headshot = nil,
        last_killer = nil,
        switched = false,
        stats = stats_db[name]
    }
end

local function updatePlayerRank(player)
    local old_rank = player.stats.rank
    local old_grade = player.stats.grade
    local credits = player.stats.credits

    -- Binary search for the appropriate threshold
    local low, high = 1, #SORTED_THRESHOLDS
    local best_match = nil

    while low <= high do
        local mid = math_floor((low + high) / 2)
        local threshold = SORTED_THRESHOLDS[mid]

        if credits >= threshold then
            best_match = GRADE_THRESHOLDS[threshold]
            low = mid + 1 -- Look for higher threshold
        else
            high = mid - 1
        end
    end

    local new_rank, new_grade
    if best_match then
        new_rank = best_match[3]
        new_grade = best_match[2]
    else
        -- Default to first rank
        new_rank = CONFIG.RANKS[1][1]
        new_grade = 1
    end

    -- Only update if changed
    if old_rank ~= new_rank or old_grade ~= new_grade then
        player.stats.rank = new_rank
        player.stats.grade = new_grade

        local old_index = RANK_LOOKUP[old_rank] or 0
        local new_index = RANK_LOOKUP[new_rank]

        if new_index > old_index or (new_index == old_index and new_grade > old_grade) then
            send(player.id, string_format("Rank Up: %s Grade %d", new_rank, new_grade))
        else
            send(player.id, string_format("Rank Down: %s Grade %d", new_rank, new_grade))
        end
    end
end

local function awardCredits(player, amount, label)
    if not player or amount == 0 then return end

    player.stats.credits = player.stats.credits + amount
    updatePlayerRank(player)

    local formatted_label = string_format(label, CONFIG.SYMBOL)
    send(player.id, formatted_label)
end

local function initializeDamageSystem()
    damage_meta_ids, vehicle_meta_ids, collision_meta_id = {}, {}, nil

    -- Single pass initialization
    for _, tag_data in ipairs(CONFIG.CREDITS.damage_tags) do
        if type(tag_data) == 'table' and #tag_data >= 2 then
            local meta_id = getTag('jpt!', tag_data[1])
            if meta_id then
                damage_meta_ids[meta_id] = {
                    credits = tag_data[2],
                    label = tag_data[3]
                }
            end
        end
    end

    -- Use direct assignment instead of separate lookups
    collision_meta_id = getTag('jpt!', CONFIG.CREDITS.damage_tags.collision)

    local vehicles = CONFIG.CREDITS.damage_tags.vehicles
    if vehicles then
        for vehicle_tag, vehicle_data in pairs(vehicles) do
            local vehicle_meta_id = getTag('vehi', vehicle_tag)
            if vehicle_meta_id then
                vehicle_meta_ids[vehicle_meta_id] = {
                    credits = vehicle_data[1],
                    label = vehicle_data[2]
                }
            end
        end
    end
end

local function processVehicleSquash(killer_id)
    local killer_data = players[killer_id]

    local vehicle_object_id = getVehicleObjectID(killer_id)
    if not vehicle_object_id then return false end

    local vehicle_data = vehicle_meta_ids[vehicle_object_id]

    if vehicle_data then
        awardCredits(killer_data, vehicle_data.credits, vehicle_data.label)
        return true
    end

    return false
end

local function processWeaponKill(killer_id, damage_meta_id)
    local killer_data = players[killer_id]

    local damage_data = damage_meta_ids[damage_meta_id]
    if damage_data then
        awardCredits(killer_data, damage_data.credits, damage_data.label)
        return true
    end

    return false
end

local function reloadThis(victim_id, killer_data)
    local dyn_player = get_dynamic_player(victim_id)
    if dyn_player == 0 then return nil end

    local reloading = read_byte(dyn_player + 0x2A4)
    if reloading == 5 then
        awardCredits(killer_data, CONFIG.CREDITS.reload_this[1], CONFIG.CREDITS.reload_this[2])
    end
end

local function closeCall(killer_id, killer_data)
    local dyn_player = get_dynamic_player(killer_id)
    if dyn_player == 0 then return end

    local health = read_float(dyn_player + 0xE0)
    local shields = read_float(dyn_player + 0xE4)
    if shields and shields <= 0 and health and health < 0.3 then
        awardCredits(killer_data, CONFIG.CREDITS.close_call[1], CONFIG.CREDITS.close_call[2])
    end
end

local function awardAvengeBonus(killer_id, victim_id, killer_data)
    for id, player in pairs(players) do
        if id ~= killer_id and player.team == killer_data.team and player.last_killer == victim_id then
            awardCredits(killer_data, CONFIG.CREDITS.avenge[1], CONFIG.CREDITS.avenge[2])
            break
        end
    end
end

local function spree(killer_id)
    local static_player = get_player(killer_id)
    if static_player == 0 then return end

    local spree_count = read_word(static_player + 0x96) -- current spree

    -- Check if the spree count matches any configured threshold
    local award_data = CONFIG.CREDITS.spree[spree_count]
    if award_data then
        local killer_data = players[killer_id]
        if killer_data then
            awardCredits(killer_data, award_data[1], award_data[2])
        end
    end
end

local function multiKiller(killer_id)
    local static_player = get_player(killer_id)
    if static_player == 0 then return end

    local combo = read_word(static_player + 0x98) -- kill-combo

    -- Check if the combo matches any configured threshold
    local award_data = CONFIG.CREDITS.multi_kill[combo]
    if award_data then
        local killer_data = players[killer_id]
        if killer_data then
            awardCredits(killer_data, award_data[1], award_data[2])
        end
    end
end

local function processPlayerDeath(victim_id, killer_id)
    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)

    local victim_data = players[victim_id]
    if not victim_data then return end

    local killer_data = players[killer_id]
    local last_damage = victim_data.last_damage

    -- Reset victim's last damage
    victim_data.last_damage = nil
    victim_data.headshot = nil

    -- Track last killer for revenge/avenge
    victim_data.last_killer = killer_id

    -- Update kill/death stats
    if killer_id > 0 and killer_id ~= victim_id and killer_data then
        killer_data.stats.kills = (killer_data.stats.kills or 0) + 1
    end

    victim_data.stats.deaths = (victim_data.stats.deaths or 0) + 1

    -- Server kill (falling, distance, etc.)
    if killer_id == -1 and not victim_data.switched then
        if last_damage == falling then
            awardCredits(victim_data, CONFIG.CREDITS.falling[1], CONFIG.CREDITS.falling[2])
        elseif last_damage == distance then
            awardCredits(victim_data, CONFIG.CREDITS.distance[1], CONFIG.CREDITS.distance[2])
        else
            awardCredits(victim_data, CONFIG.CREDITS.server[1], CONFIG.CREDITS.server[2])
        end
        -- Guardians kill
    elseif killer_id == nil then
        awardCredits(victim_data, CONFIG.CREDITS.guardians[1], CONFIG.CREDITS.guardians[2])
        -- PvP kills
    elseif killer_id > 0 then
        -- Suicide
        if killer_id == victim_id then
            awardCredits(killer_data, CONFIG.CREDITS.suicide[1], CONFIG.CREDITS.suicide[2])
            -- Betrayal (team kill in non-FFA)
        elseif not ffa and killer_data and victim_data.team == killer_data.team then
            awardCredits(killer_data, CONFIG.CREDITS.betrayal[1], CONFIG.CREDITS.betrayal[2])
        else
            -- First Blood (only award once per game)
            if first_blood then
                first_blood = false
                awardCredits(killer_data, CONFIG.CREDITS.first_blood[1], CONFIG.CREDITS.first_blood[2])
            end

            -- Killed from the grave
            if not player_alive(killer_id) then
                awardCredits(killer_data, CONFIG.CREDITS.killed_from_the_grave[1],
                    CONFIG.CREDITS.killed_from_the_grave[2])
            end

            -- Headshot bonus
            if victim_data.headshot then
                awardCredits(killer_data, CONFIG.CREDITS.head_shot[1], CONFIG.CREDITS.head_shot[2])
            end

            -- Revenge bonus (killed someone who recently killed you)
            if killer_data.last_killer == victim_id then
                awardCredits(killer_data, CONFIG.CREDITS.revenge[1], CONFIG.CREDITS.revenge[2])
            end

            -- Avenge bonus (killed someone who recently killed a teammate)
            if not ffa then
                awardAvengeBonus(killer_id, victim_id, killer_data)
            end

            -- Reloading this bonus
            reloadThis(victim_id, killer_data)

            -- Close call bonus
            closeCall(killer_id, killer_data)

            -- Process spree bonus
            spree(killer_id)

            -- Process multi-kill bonus
            multiKiller(killer_id)

            -- Process vehicle squash
            if collision_meta_id and last_damage == collision_meta_id then
                if processVehicleSquash(killer_id) then
                    return
                end
            end

            -- Process weapon damage
            if last_damage then
                processWeaponKill(killer_id, last_damage)
            end
        end
    end
end

local function getTopPlayers()
    local all_players = {}

    -- Pre-allocate table to avoid resizing
    for name, stats in pairs(stats_db) do
        if (stats.kills or 0) > 0 or (stats.deaths or 0) > 0 then
            all_players[#all_players + 1] = {
                name = name,
                stats = stats,
                score = getPlayerScore(stats)
            }
        end
    end

    -- Use more efficient sort with pre-calculated scores
    table.sort(all_players, function(a, b)
        return a.score > b.score
    end)

    return all_players
end

function OnScriptLoad()
    local success, result = pcall(function()
        return loadfile('json.lua')()
    end)

    if not success or not result then
        error("Failed to load json.lua. Make sure the file exists and is valid.")
        return
    end
    json = result

    local directory = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    db_directory = directory .. '\\sapp\\ranks.json'

    if not loadStatsDB() then
        print("Warning: Could not load stats database, starting with empty database")
    end

    -- Initialize optimized data structures
    for rank_index, rank_data in ipairs(CONFIG.RANKS) do
        local rank_name = rank_data[1]
        RANK_LOOKUP[rank_name] = rank_index

        for grade, threshold in ipairs(rank_data[2]) do
            GRADE_THRESHOLDS[threshold] = { rank_index, grade, rank_name }
            table.insert(SORTED_THRESHOLDS, threshold)
        end
    end

    table_sort(SORTED_THRESHOLDS)

    for _, cmd_data in ipairs(CONFIG.COMMANDS) do
        COMMAND_LOOKUP[cmd_data[1]:lower()] = cmd_data[2]
    end

    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')

    OnStart() -- in case the script is loaded mid-game
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    initializeDamageSystem()
    first_blood = true
    ffa = get_var(0, '$ffa') == '1'
    falling = getTag('jpt!', 'globals\\falling')
    distance = getTag('jpt!', 'globals\\distance')
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    if CONFIG.UPDATE['game_end'] then
        saveStatsDB()
    end
end

function OnJoin(id)
    players[id] = initializePlayer(id)
end

function OnQuit(id)
    players[id] = nil
    if CONFIG.UPDATE['player_quit'] then
        saveStatsDB()
    end
end

function OnDamage(victim_id, _, meta_id, _, hitstring)
    victim_id = tonumber(victim_id)
    if players[victim_id] then
        players[victim_id].last_damage = tonumber(meta_id)
        players[victim_id].headshot = hitstring == 'head' or nil
    end
end

function OnDeath(victim_id, killer_id)
    processPlayerDeath(victim_id, killer_id)
end

function OnSpawn(id)
    if players[id] then
        players[id].switched = nil
        players[id].headshot = nil
        players[id].last_damage = nil
    end
end

function OnSwitch(id)
    if players[id] then
        players[id].switched = true
        players[id].team = get_var(id, '$team')
    end
end

function OnCommand(id, command)
    local args = parseArgs(command)

    if #args == 0 then return true end

    local cmd = args[1]:lower()

    -- Fast command lookup
    local required_level = COMMAND_LOOKUP[cmd]
    if not required_level then return true end

    -- Check permission level
    if not hasPermission(id, required_level) then
        send(id, "Insufficient permission level for this command.")
        return false
    end

    if cmd == 'rank' then
        local target_id = id
        local player = players[target_id]

        if #args >= 2 then
            local input_id = tonumber(args[2])
            if input_id and player_present(input_id) then
                target_id = input_id
                player = players[target_id]
            else
                send(id, "Player not found with ID: " .. args[2])
                return false
            end
        end

        local rank = player.stats.rank
        local grade = player.stats.grade
        local credits = player.stats.credits
        local kills = player.stats.kills or 0
        local deaths = player.stats.deaths or 0
        local kdr = calculateKDR(kills, deaths)

        send(id, string_format("%s: %s (grade %d) (%d credits)", player.name, rank, grade, credits))
        send(id, string_format("Kills: %d | Deaths: %d | KDR: %.2f", kills, deaths, kdr))
        return false
    elseif cmd == 'setrank' then
        if #args < 4 then
            send(id, "Usage: setrank <player_id> <rank_id> <grade>")
            return false
        end

        local target_id = tonumber(args[2])
        if not target_id or not player_present(target_id) then
            send(id, "Player not found with ID: " .. args[2])
            return false
        end

        local rank_id = tonumber(args[3])
        local grade = tonumber(args[4])
        if not rank_id or rank_id < 1 or rank_id > #CONFIG.RANKS then
            send(id, "Invalid rank ID: " .. tostring(args[3]))
            return false
        end

        local selected_rank = CONFIG.RANKS[rank_id]
        if not grade or grade < 1 or grade > #selected_rank[2] then
            send(id, "Invalid grade index for rank " .. selected_rank[1] ..
                ". Must be between 1 and " .. #selected_rank[2])
            return false
        end

        local player = players[target_id]

        -- Set player credits to exact value for that rank/grade
        player.stats.credits = selected_rank[2][grade]
        player.stats.rank = selected_rank[1]
        player.stats.grade = grade

        local new_rank = player.stats.rank
        send(id, "Set " .. player.name .. " to rank " .. new_rank ..
            " (Grade " .. grade .. ", " .. player.stats.credits .. " credits)")

        if target_id ~= id then
            rprint(target_id, "An admin has set your rank!")
            rprint(target_id,
                "New rank: " .. new_rank .. " (Grade " .. grade .. ", " .. player.stats.credits .. " credits)")
        end

        return false
    elseif cmd == 'ranks' then
        send(id, "=== Available Ranks ===")
        for i, rank_data in ipairs(CONFIG.RANKS) do
            local grades = table.concat(rank_data[2], ", ")
            send(id, i .. ". " .. rank_data[1] .. ": [" .. grades .. "]")
        end
        return false
    elseif cmd == 'top' then
        local limit = tonumber(args[2]) or 5
        local top_players = getTopPlayers()

        if #top_players == 0 then
            send(id, "No players found.")
            return false
        end

        send(id, string_format("=== TOP %d PLAYERS ===", math_min(limit, #top_players)))

        for i = 1, math_min(limit, #top_players) do
            local player = top_players[i]
            local kdr = calculateKDR(player.stats.kills, player.stats.deaths)
            send(id, string_format(
                "%d. %s: %s G%d | %d credits | KDR: %.2f (%d/%d)",
                i,
                player.name,
                player.stats.rank,
                player.stats.grade,
                player.stats.credits,
                kdr,
                player.stats.kills,
                player.stats.deaths
            ))
        end
        return false
    end

    return true
end

function OnScriptUnload()
    if CONFIG.UPDATE['script_unload'] then
        saveStatsDB()
    end
end
