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
        center                  = { x = 65.749, y = -120.409, z = 0.118 }, -- Boundary center position
        min_size                = 1,                                       -- Minimum radius of playable area
        max_size                = 5,                                       -- Maximum radius (starting size)
        shrink_steps            = 2,                                       -- Number of shrink steps to reach min_size
        game_time               = 60,                                      -- Default game duration in seconds
        bonus_time              = 30,                                      -- Bonus period duration in seconds
        public_message_interval = 10,                                      -- Seconds between private reminders
        damage_per_second       = 0.0333,                                  -- Default 0.0333% damage every 1 second (dead in 30 seconds)
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
-- CONFIG END ---------------------------------------------------------------------------

api_version = "1.12.0.0"

-- Localized frequently used functions and variables
local floor, format, max, clock = math.floor, string.format, math.max, os.clock
local read_float, read_dword, read_vector3d = read_float, read_dword, read_vector3d
local player_present, player_alive = player_present, player_alive
local get_dynamic_player, get_object_memory = get_dynamic_player, get_object_memory
local execute_command, say_all, rprint = execute_command, say_all, rprint

-- Runtime variables
local CFG = {}
local game_active = false
local game_start_time = 0
local total_game_time = 0
local last_public_message = 0
local bonus_period = false
local bonus_end_time = 0
local current_radius = 0
local expected_reductions = 0
local reductions_remaining = 0
local damage_per_interval = 0
local player_timers = {}

-- Precomputed values
local DAMAGE_INTERVAL_MS = DAMAGE_INTERVAL * 1000
local WARNING_INTERVAL_MS = WARNING_INTERVAL * 1000

-- Convert seconds to MM:SS format
local function secondsToTime(seconds)
    seconds = floor(seconds)
    return format("%02d:%02d", floor(seconds / 60), seconds % 60)
end

local function announce(message)
    execute_command('msg_prefix ""')
    say_all(message)
    execute_command('msg_prefix "' .. MSG_PREFIX .. '"')
end

-- Initialize game boundary
local function initializeBoundary()
    current_radius = CFG.max_size
    expected_reductions = CFG.shrink_steps
    reductions_remaining = expected_reductions
    total_game_time = CFG.game_time
    damage_per_interval = CFG.damage_per_second * DAMAGE_INTERVAL

    -- Precompute shrink values
    CFG.reduction_amount = (CFG.max_size - CFG.min_size) / expected_reductions
    CFG.reduction_rate = total_game_time / expected_reductions

    game_active = true
    bonus_period = false
    last_public_message = clock()

    announce(format(
        "[BATTLE ROYALE] Center: X %.1f Y %.1f Z %.1f | RAD: %.0f | Shrinks: %d | Time: %.0f sec | Bonus: %d sec",
        CFG.center_x, CFG.center_y, CFG.center_z, current_radius,
        expected_reductions, total_game_time, CFG.bonus_time
    ))
end

-- Boundary check (inlined for performance)
local function isInsideBoundary(px, py, pz, radius)
    local dx = px - CFG.center_x
    local dy = py - CFG.center_y
    local dz = pz - CFG.center_z
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end

-- Player position retrieval
local function getPlayerPosition(dyn_player)
    local object = read_dword(dyn_player + 0x11C) -- vehicle ID
    if object ~= 0xFFFFFFFF then
        object = get_object_memory(ptr)
        if object == 0 then return end -- invalid vehicle
    else
        object = dyn_player
    end

    local x, y, z = read_vector3d(object + 0x5C)
    local crouch = read_float(dyn_player + 0x50C)
    z = z + (crouch ~= 0 and 0.35 * crouch or 0.65)

    return x, y, z
end

-- Player damage handler
local function hurtPlayer(player_id, dyn_player)
    local health = read_float(dyn_player + 0xE0)
    if health <= damage_per_interval then
        execute_command('kill ' .. player_id)
    else
        write_float(dyn_player + 0xE0, health - damage_per_interval)
    end
end

-- Callback management
local function registerCallbacks()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnEnd")
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
end

local function unregisterCallbacks()
    unregister_callback(cb["EVENT_TICK"])
    unregister_callback(cb["EVENT_GAME_END"])
    unregister_callback(cb["EVENT_JOIN"])
    unregister_callback(cb["EVENT_LEAVE"])
end

-- Map configuration
local function applyMapSettings()
    local map_name = get_var(0, "$map")
    local map_cfg = MAPS[map_name]

    if not map_cfg then
        unregisterCallbacks()
        error("[BATTLE ROYALE] Map not configured: " .. map_name, 10)
    end

    CFG = {
        center_x = map_cfg.center.x,
        center_y = map_cfg.center.y,
        center_z = map_cfg.center.z,
        min_size = map_cfg.min_size,
        max_size = map_cfg.max_size,
        shrink_steps = map_cfg.shrink_steps,
        game_time = map_cfg.game_time,
        bonus_time = map_cfg.bonus_time,
        public_message_interval = map_cfg.public_message_interval,
        damage_per_second = map_cfg.damage_per_second
    }

    registerCallbacks()
end

-- Event handlers
function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    applyMapSettings()
    initializeBoundary()
    game_start_time = clock()

    -- Initialize player timers
    for i = 1, 16 do
        if player_present(i) then
            player_timers[i] = { last_damage = 0, last_warning = 0 }
        end
    end
end

function OnEnd()
    game_active = false
    bonus_period = false
end

function OnJoin(id)
    player_timers[id] = { last_damage = 0, last_warning = 0 }
end

function OnQuit(id)
    player_timers[id] = nil
end

function OnTick()
    if not game_active then return end

    local now = clock()
    local elapsed = now - game_start_time
    local radius_changed = false

    -- Boundary shrinking logic
    if not bonus_period then
        local reductions_done = floor(elapsed / CFG.reduction_rate)
        reductions_remaining = max(expected_reductions - reductions_done, 0)
        local new_radius = max(CFG.max_size - reductions_done * CFG.reduction_amount, CFG.min_size)

        if new_radius < current_radius then
            current_radius = new_radius
            radius_changed = true
        end

        if reductions_remaining == 0 then
            bonus_period = true
            bonus_end_time = now + CFG.bonus_time
            current_radius = CFG.min_size
            radius_changed = true

            announce(format("Last man standing for %d seconds at %.0f world units!",
                CFG.bonus_time, current_radius))
        end
    end

    -- Announce radius changes
    if radius_changed then
        announce(format("Radius shrunk to %.0f | Shrinks left: %d | Min radius: %.0f",
            current_radius, reductions_remaining, CFG.min_size))
    end

    -- Precompute values for boundary checks
    local radius_sq = current_radius * current_radius
    local current_time_ms = now * 1000

    -- Player processing
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local dyn_player = get_dynamic_player(i)
            if not dyn_player then goto continue end

            local x, y, z = getPlayerPosition(dyn_player)
            if not x then goto continue end

            local timer = player_timers[i]
            local inside = isInsideBoundary(x, y, z, radius_sq)

            if not inside then
                -- Damage application
                if current_time_ms - timer.last_damage >= DAMAGE_INTERVAL_MS then
                    hurtPlayer(i, dyn_player)
                    timer.last_damage = current_time_ms
                end

                -- Warning messages
                if current_time_ms - timer.last_warning >= WARNING_INTERVAL_MS then
                    rprint(i, "You are outside the boundary! Return to the play area.")
                    timer.last_warning = current_time_ms
                end
            end

            -- Periodic status updates
            if now - last_public_message >= CFG.public_message_interval then
                local status
                if bonus_period then
                    status = format("BONUS TIME: %s | Radius: %.0f",
                        secondsToTime(bonus_end_time - now),
                        current_radius)
                else
                    status = format("Radius: %.0f | Time: %s | Shrinks left: %d",
                        current_radius,
                        secondsToTime(total_game_time - elapsed),
                        reductions_remaining)
                end
                rprint(i, status .. (not inside and " [OUT]" or ""))
            end
        end
        ::continue::
    end

    -- Update public message timer
    if now - last_public_message >= CFG.public_message_interval then
        last_public_message = now
    end

    -- End game after bonus period
    if bonus_period and now >= bonus_end_time then
        game_active = false
        execute_command("sv_map_next")
    end
end

function OnScriptUnload() end