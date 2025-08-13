--=====================================================================================--
-- SCRIPT NAME:      Battle Royale
-- DESCRIPTION:      Minigame implementing a shrinking safe zone.
--                   Players outside the boundary take damage and receive warnings.
--                   Supports map-specific settings, configurable shrink steps,
--                   bonus periods, and automatic game start/end management.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--===========================
-- CONFIG START
--===========================

--    Notes on measurements:
--    - Halo uses "world units" for distances.
--    - 1 world unit = 10 feet.
--    - 1 foot = 0.3048 meters, so: 1 world unit ≈ 3.048 meters.
--    - All min_size and max_size values below are in world units.

local MSG_PREFIX = "SAPP"    -- SAPP msg_prefix
local DAMAGE_INTERVAL = 0.2  -- Apply damage every 0.2 seconds (5x/sec)
local WARNING_INTERVAL = 2.0 -- Warn players every 2 seconds

local MAPS = {
    ["bloodgulch"] = {
        center                  = { x = 0, y = 0, z = 0 }, -- Boundary center position
        min_size                = 20,                      -- Minimum radius of playable area
        max_size                = 500,                     -- Maximum radius (starting size)
        shrink_steps            = 5,                       -- Number of shrink steps to reach min_size
        game_time               = 5 * 60,                  -- Default game duration in seconds
        bonus_time              = 30,                      -- Bonus period duration in seconds
        public_message_interval = 10,                      -- Seconds between private reminders
        damage_per_second       = 0.0333,                  -- Default 0.0333% damage every 1 second (dead in 30 seconds)
    },
    ["sidewinder"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 60,
        max_size                = 1400,
        shrink_steps            = 6,
        game_time               = 6 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["damnation"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 300,
        shrink_steps            = 4,
        game_time               = 4 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["prisoner"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 15,
        max_size                = 250,
        shrink_steps            = 3,
        game_time               = 3 * 60,
        bonus_time              = 30,
        public_message_interval = 6,
        damage_per_second       = 0.0333
    },
    ["hangemhigh"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 25,
        max_size                = 350,
        shrink_steps            = 4,
        game_time               = 4 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["chillout"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 300,
        shrink_steps            = 4,
        game_time               = 4 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["ratrace"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 300,
        shrink_steps            = 3,
        game_time               = 3 * 60,
        bonus_time              = 30,
        public_message_interval = 6,
        damage_per_second       = 0.0333
    },
    ["wizard"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 250,
        shrink_steps            = 3,
        game_time               = 3 * 60,
        bonus_time              = 30,
        public_message_interval = 6,
        damage_per_second       = 0.0333
    },
    ["longest"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 250,
        shrink_steps            = 3,
        game_time               = 3 * 60,
        bonus_time              = 30,
        public_message_interval = 6,
        damage_per_second       = 0.0333
    },
    ["beavercreek"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 40,
        max_size                = 600,
        shrink_steps            = 4,
        game_time               = 4 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["boardingaction"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 30,
        max_size                = 500,
        shrink_steps            = 4,
        game_time               = 4 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["carousel"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 20,
        max_size                = 300,
        shrink_steps            = 3,
        game_time               = 3 * 60,
        bonus_time              = 30,
        public_message_interval = 6,
        damage_per_second       = 0.0333
    },
    ["deathisland"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 80,
        max_size                = 1600,
        shrink_steps            = 6,
        game_time               = 7 * 60,
        bonus_time              = 30,
        public_message_interval = 10,
        damage_per_second       = 0.0333
    },
    ["gephyrophobia"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 80,
        max_size                = 1600,
        shrink_steps            = 6,
        game_time               = 7 * 60,
        bonus_time              = 30,
        public_message_interval = 10,
        damage_per_second       = 0.0333
    },
    ["infinity"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 100,
        max_size                = 2000,
        shrink_steps            = 6,
        game_time               = 8 * 60,
        bonus_time              = 30,
        public_message_interval = 10,
        damage_per_second       = 0.0333
    },
    ["timberland"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 70,
        max_size                = 1500,
        shrink_steps            = 5,
        game_time               = 6 * 60,
        bonus_time              = 30,
        public_message_interval = 8,
        damage_per_second       = 0.0333
    },
    ["icefields"] = {
        center                  = { x = 0, y = 0, z = 0 },
        min_size                = 80,
        max_size                = 1600,
        shrink_steps            = 6,
        game_time               = 7 * 60,
        bonus_time              = 30,
        public_message_interval = 10,
        damage_per_second       = 0.0333
    }
}
-- CONFIG END -------------------------------------------------------------------------------------

api_version = "1.12.0.0"

local CFG = {}
local prefix = "SAPP"
local game_start_time = 0
local current_radius = CFG.max_size
local expected_reductions = 0
local total_game_time = 0
local game_active = false
local prev_radius = CFG.max_size
local last_public_message = 0
local bonus_period = false
local bonus_end_time = 0
local reductions_remaining = 0

-- Player timers for damage/warning rate limiting
local player_timers = {} -- player_id -> { last_damage = time, last_warning = time }

local floor, format, max, clock, pairs = math.floor, string.format, math.max, os.clock, pairs

-- Convert seconds to MM:SS format
local function secondsToTime(seconds)
    if seconds <= 0 then return "00", "00" end
    local mins = floor(seconds / 60)
    local secs = floor(seconds % 60)
    return format("%02d", mins), format("%02d", secs)
end

-- Convert world units to feet (1 world unit = 10 ft)
local function unitsToFeet(units)
    return units * 10
end

-- Calculate expected number of shrink steps
local function calculateExpectedReductions()
    return CFG.shrink_steps or 5
end

-- Check if a point is inside the radius
local function in_range(x1, y1, z1, x2, y2, z2, radius)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end

-- Retrieve player's world coordinates, accounting for crouch/vehicle
local function get_player_position(dyn_player)
    local crouch = read_float(dyn_player + 0x50C)
    local vehicle_id = read_dword(dyn_player + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn_player + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_offset = (crouch == 0) and 0.65 or 0.35 * crouch
    return x, y, z + z_offset
end

-- Check if a player is present and alive
local function player_valid(id)
    return player_present(id) and player_alive(id)
end

-- Reduce player's health
local function hurt_player(player_id, dyn_player, amount)
    local health = read_float(dyn_player + 0xE0)
    if health <= amount then
        execute_command('kill ' .. player_id)
    else
        write_float(dyn_player + 0xE0, health - amount)
    end
end

local function announce(message)
    execute_command('msg_prefix "' .. prefix .. '"')
    say_all(message)
    execute_command('msg_prefix "' .. MSG_PREFIX .. '"')
end

local function initializeBoundary()
    current_radius = CFG.max_size
    prev_radius = CFG.max_size
    expected_reductions = calculateExpectedReductions()
    reductions_remaining = expected_reductions
    total_game_time = CFG.game_time or (5 * 60)
    CFG.reduction_amount = (CFG.max_size - CFG.min_size) / expected_reductions
    CFG.reduction_rate = total_game_time / expected_reductions
    game_active = true
    bonus_period = false
    last_public_message = clock()

    announce(format(
        "[BATTLE ROYALE] Center: X %.1f Y %.1f Z %.1f | RAD: %.0f | Shrinks: %d | Time: %.0f sec | Bonus: %d sec",
        CFG.center.x, CFG.center.y, CFG.center.z, current_radius, expected_reductions, total_game_time, CFG.bonus_time))
end

local function register_callbacks()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")
end

local function unregister_callbacks()
    unregister_callback(cb["EVENT_TICK"])
    unregister_callback(cb["EVENT_GAME_END"])
    unregister_callback(cb["EVENT_JOIN"])
    unregister_callback(cb["EVENT_LEAVE"])
end

-- Apply map-specific settings
local function applyMapSettings()
    CFG = {}
    local map_name = get_var(0, "$map")
    local map_cfg = MAPS[map_name]

    if not map_cfg then
        unregister_callbacks()
        error(("[BATTLE ROYALE] Map not configured: %s"):format(map_name), 2)
    end

    -- Merge map settings into global CFG
    for k, v in pairs(map_cfg) do
        CFG[k] = v
    end

    -- Print loaded map message with each setting on a new line
    cprint(("[BATTLE ROYALE] Loaded settings for map: %s"):format(map_name), 10)
    for k, v in pairs(CFG) do
        local value_str
        if type(v) == "table" then
            local tbl_items = {}
            for tk, tv in pairs(v) do
                table.insert(tbl_items, tk .. "=" .. tostring(tv))
            end
            value_str = "{ " .. table.concat(tbl_items, ", ") .. " }"
        else
            value_str = tostring(v)
        end
        cprint(string.format("  %s = %s", k, value_str), 10)
    end

    register_callbacks()
end

function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    OnGameStart()
end

function OnGameStart()
    if get_var(0, '$gt') == 'n/a' then return end
    applyMapSettings()
    initializeBoundary()
    game_start_time = clock()
    for i = 1, 16 do
        if player_present(i) then
            player_timers[i] = { last_damage = 0, last_warning = 0 }
        end
    end
end

function OnGameEnd()
    game_active = false
    bonus_period = false
end

function OnPlayerJoin(PlayerIndex)
    player_timers[tonumber(PlayerIndex)] = {
        last_damage = 0,
        last_warning = 0
    }
end

function OnPlayerLeave(PlayerIndex)
    player_timers[tonumber(PlayerIndex)] = nil
end

function OnTick()
    if not game_active then return end

    local now = clock()
    local elapsed = now - game_start_time
    local reductions_done = floor(elapsed / CFG.reduction_rate)
    reductions_remaining = max(expected_reductions - reductions_done, 0)

    -- Start bonus period when reductions run out
    if reductions_remaining == 0 and not bonus_period then
        bonus_period = true
        bonus_end_time = now + CFG.bonus_time
        current_radius = CFG.min_size
        prev_radius = current_radius
        announce(format("Last man standing for %d seconds at %.0f ft radius!",
            CFG.bonus_time, unitsToFeet(current_radius)))
    end

    -- Update radius (only if not in bonus period)
    if not bonus_period then
        current_radius = max(CFG.max_size - reductions_done * CFG.reduction_amount, CFG.min_size)
    end

    -- SHRINK EVENT: announce if radius decreased
    if current_radius < prev_radius then
        announce(format(
            "Radius shrunk to %.0f | Shrinks left: %d | Min radius: %.0f ft",
            current_radius, reductions_remaining, unitsToFeet(CFG.min_size)))
        prev_radius = current_radius
    end

    -- REAL-TIME BOUNDARY ENFORCEMENT
    local damage_per_interval = (CFG.damage_per_second or 10) * DAMAGE_INTERVAL

    for i = 1, 16 do
        if player_valid(i) then
            local dyn_player = get_dynamic_player(i)
            local px, py, pz = get_player_position(dyn_player)

            -- Initialize timer if missing
            if not player_timers[i] then
                player_timers[i] = { last_damage = 0, last_warning = 0 }
            end
            local timer = player_timers[i]

            if px and py and pz then -- Ensure valid coordinates
                local inside_boundary = in_range(px, py, pz, CFG.center.x, CFG.center.y, CFG.center.z, current_radius)

                if not inside_boundary then
                    -- Apply damage at high frequency
                    if now - timer.last_damage >= DAMAGE_INTERVAL then
                        hurt_player(i, dyn_player, damage_per_interval)
                        timer.last_damage = now
                    end

                    -- Rate-limited warnings
                    if now - timer.last_warning >= WARNING_INTERVAL then
                        rprint(i, "You are outside the boundary! Return to the play area.")
                        timer.last_warning = now
                    end
                end
            end
        end
    end

    -- PERIODIC PRIVATE REMINDERS
    if now - last_public_message >= CFG.public_message_interval then
        for i = 1, 16 do
            if player_valid(i) then
                local dyn_player = get_dynamic_player(i)
                local px, py, pz = get_player_position(dyn_player)

                local min_str, sec_str
                local status_msg

                -- Different messages during bonus period
                if bonus_period then
                    local bonus_remaining = max(bonus_end_time - now, 0)
                    min_str, sec_str = secondsToTime(bonus_remaining)
                    status_msg = format("BONUS TIME: %s:%s | Radius: %.0f ft",
                        min_str, sec_str, unitsToFeet(current_radius))
                else
                    min_str, sec_str = secondsToTime(total_game_time - elapsed)
                    status_msg = format("Radius: %.0f | Time: %s:%s | Shrinks left: %d",
                        current_radius, min_str, sec_str, reductions_remaining)
                end

                local outside = ""
                if px and py and pz then
                    outside = not in_range(px, py, pz, CFG.center.x, CFG.center.y, CFG.center.z, current_radius)
                        and " [OUT]" or ""
                end

                rprint(i, status_msg .. outside)
            end
        end
        last_public_message = now
    end

    -- GAME END CHECK - UPDATED FOR BONUS PERIOD
    if bonus_period and now >= bonus_end_time then
        game_active = false
        bonus_period = false
        execute_command("sv_map_next")
    end
end

function OnScriptUnload() end
