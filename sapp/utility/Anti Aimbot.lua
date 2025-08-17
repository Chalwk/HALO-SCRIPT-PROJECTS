--=====================================================================================--
-- SCRIPT NAME:      Anti-Aimbot (Advanced Aim-lock Detection)
-- DESCRIPTION:      Enhanced detection system with velocity-based thresholding,
--                   trajectory prediction, dynamic sensitivity adjustment, pattern
--                   recognition, and environmental awareness. Detects automated
--                   aim assistance while minimizing false positives.
--
-- KEY FEATURES:
--   - Velocity-adjusted aim thresholds
--   - Projectile trajectory prediction
--   - Dynamic sensitivity based on player accuracy
--   - Machine-like pattern detection
--   - Environmental visibility checks
--   - Weapon-specific detection modifiers
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- CONFIGURATION --------------------------------------------------------------
local CONFIG = {
    AUTO_AIM = {
        ANGLE_THRESHOLD_DEGREES = 2.5,     -- Base angle threshold (degrees)
        MIN_ANGLE_THRESHOLD_DEGREES = 0.2, -- Minimum angle threshold fallback
        MAX_SCORE = 3000,                  -- Enforcement threshold
        DYNAMIC_THRESHOLD = {              -- Dynamic threshold adjustment
            ENABLED = true,
            BASE_MULTIPLIER = 1.0,         -- Base multiplier for threshold
            ACCURACY_WEIGHT = 0.5,         -- How much accuracy affects threshold (0-1)
            MIN_MULTIPLIER = 0.8,          -- Minimum threshold multiplier
            MAX_MULTIPLIER = 1.2           -- Maximum threshold multiplier
        }
    },

    SNAP_DETECTION = {
        BASELINE_DEGREES = 6.0,        -- Significant snap angle (degrees)
        MOVING_THRESHOLD_DEGREES = 0.4 -- Subtle snap threshold while moving (degrees)
    },

    PLAYER = {
        STANDING_EYE_HEIGHT = 0.64,  -- Eye/aim Z offset while standing
        CROUCHING_EYE_HEIGHT = 0.35, -- Eye/aim Z offset while crouching
        TRACE_DISTANCE = 250,        -- Raycast length for hit validation
        PROJECTILE_SPEED = 30.0      -- Assumed projectile speed for trajectory prediction (m/s)
    },

    ENFORCEMENT = {
        COMMAND = "k",              -- Command executed on detection (e.g. "k", "b")
        REASON = "Aimbot detection" -- Reason message for enforcement command
    },

    DECAY = {
        POINTS_PER_SECOND = 0.25, -- Aim score reduced per second
        INTERVAL_SECONDS = 0.25   -- Update granularity (seconds)
    },

    VELOCITY_ADJUSTED = {
        ENABLED = true,        -- Enable velocity adjustment
        SPEED_THRESHOLD = 1.5, -- Minimum speed (m/s) to trigger adjustment
        ANGLE_MODIFIER = 0.8   -- Multiplier for angle threshold during movement
    },

    WEAPON_MODIFIERS = {
        ["weapons\\pistol\\pistol"]                   = 1.15, -- High accuracy, fast TTK
        ["weapons\\sniper rifle\\sniper rifle"]       = 0.65, -- Extreme precision required, slower ROF
        ['weapons\\rocket launcher\\rocket launcher'] = 0.75, -- Splash damage, slow projectile
        ['weapons\\flamethrower\\flamethrower']       = 0.50, -- Short range, easy to keep aim on target
        ['weapons\\needler\\mp_needler']              = 0.90, -- Homing projectiles but delayed kill
        ['weapons\\shotgun\\shotgun']                 = 1.40, -- Forgiving spread, high CQC lethality
        ['weapons\\plasma pistol\\plasma pistol']     = 1.10, -- Charged shot aim assist + normal fire
        ['weapons\\plasma rifle\\plasma rifle']       = 1.00, -- Sustained fire, moderate tracking
        ['weapons\\assault rifle\\assault rifle']     = 1.20, -- Bullet spray but easy tracking
        ['weapons\\plasma_cannon\\plasma_cannon']     = 0.85, -- Slow projectile, splash
        DEFAULT                                       = 1.0   -- Default multiplier
    },

    PATTERN_DETECTION = {
        ENABLED = true,        -- Enable pattern recognition
        MAX_STD_DEV = 0.05,    -- Max allowed interval deviation
        SCORE_BOOST = 150,     -- Score added when pattern detected
        MAX_PATTERN_LENGTH = 5 -- Number of recent locks to consider
    },

    ENVIRONMENTAL = {
        ENABLED = true,           -- Enable environmental awareness
        OBSCURED_MULTIPLIER = 0.3 -- Multiplier for score when target is obscured
    }
}
-- END CONFIG ---------------------------------------------------------------

api_version = "1.12.0.0"

-- Internal state
local players = {}        -- Per-player state (indexed 1..16)
local camera_vectors = {} -- Last-camera vector per player
local weapon_cache = {}   -- Weapon name cache for performance

local time = os.clock
local fmt = string.format

local sqrt = math.sqrt
local acos = math.acos
local max = math.max
local pi = math.pi

local ipairs = ipairs
local insert = table.insert
local remove = table.remove

local read_vector3d = read_vector3d
local get_object_memory = get_object_memory
local get_dynamic_player = get_dynamic_player
local get_var, get_player = get_var, get_player
local player_present, player_alive = player_present, player_alive
local read_float, read_string, read_dword, read_word = read_float, read_string, read_dword, read_word

-- Safe clamp
local function clamp(v, lo, hi) return (v < lo) and lo or ((v > hi) and hi or v) end

-- Vector helpers -------------------------------------------------------------
local function vector_length(x, y, z) return sqrt(x * x + y * y + z * z) end

local function normalize(x, y, z)
    local len = vector_length(x, y, z)
    if len <= 0 then return 0, 0, 0 end
    return x / len, y / len, z / len
end

local function dot_product(ax, ay, az, bx, by, bz) return ax * bx + ay * by + az * bz end

-- Calculate angular change between frames (degrees)
local function calculate_orientation_change(player_id, dyn_ptr)
    if dyn_ptr == 0 then return 0 end
    local cx, cy, cz = read_vector3d(dyn_ptr + 0x230) -- Camera/aim vector

    local prev = camera_vectors[player_id]
    camera_vectors[player_id] = { cx, cy, cz }

    if not prev then return 0 end

    local px, py, pz = prev[1], prev[2], prev[3]
    local d = dot_product(px, py, pz, cx, cy, cz)
    d = clamp(d, -1, 1)
    local angle_rad = acos(d)
    return (angle_rad * 180) / pi
end

-- Get player's eye (aim) position with crouch/stand offset
local function get_player_eye_position(dyn_ptr)
    if dyn_ptr == 0 then return nil end
    local x, y, z = read_vector3d(dyn_ptr + 0x5C)
    local crouch_state = read_float(dyn_ptr + 0x50C)
    local eye_height = (crouch_state == 0) and CONFIG.PLAYER.STANDING_EYE_HEIGHT or CONFIG.PLAYER.CROUCHING_EYE_HEIGHT
    return x, y, z + eye_height
end

-- Calculate mean and standard deviation
local function compute_stats(t)
    local sum = 0
    for i = 1, #t do sum = sum + t[i] end
    local mean = sum / #t

    local variance = 0
    for i = 1, #t do
        variance = variance + (t[i] - mean) ^ 2
    end
    return mean, sqrt(variance / #t)
end

-- Get weapon name with caching
local function get_weapon_name(player_id)
    if weapon_cache[player_id] then
        return weapon_cache[player_id]
    end

    local dyn = get_dynamic_player(player_id)
    if dyn == 0 then return "DEFAULT" end

    local weapon = read_dword(dyn + 0x118)
    local object = get_object_memory(weapon)
    if object == 0 then return "DEFAULT" end

    local name = read_string(read_dword(read_word(object) * 32 + 0x40440038)) or "DEFAULT"
    weapon_cache[player_id] = name
    return name
end

-- Check if target is visible (not behind wall)
local function is_visible(shooter_id, target_id)
    local shooter_dyn = get_dynamic_player(shooter_id)
    local target_dyn = get_dynamic_player(target_id)
    if shooter_dyn == 0 or target_dyn == 0 then return false end

    local sx, sy, sz = get_player_eye_position(shooter_dyn)
    local tx, ty, tz = read_vector3d(target_dyn + 0x5C)
    tz = tz + CONFIG.PLAYER.STANDING_EYE_HEIGHT

    local shooter_unit = read_dword(get_player(shooter_id) + 0x34)
    local hit, _, _, _, _ = intersect(sx, sy, sz, tx, ty, tz, shooter_unit)
    return not hit
end

-- Returns horizontal speed of a player (m/s)
local function get_player_horizontal_speed(player_id)
    local dyn = get_dynamic_player(player_id)
    if dyn == 0 then return 0 end
    local vx, vy, _ = read_vector3d(dyn + 0x278)
    return sqrt(vx * vx + vy * vy)
end

-- Check whether current aim vector is aligned with direction to target
local function check_aim_at_target(shooter_dyn, shooter_id, target_id)
    if shooter_dyn == 0 then return nil end
    local target_dyn = get_dynamic_player(target_id)
    if target_dyn == 0 then return nil end

    -- Get shooter state for dynamic threshold
    local state = players[shooter_id]
    local threshold = state.dynamic_threshold or CONFIG.AUTO_AIM.ANGLE_THRESHOLD_DEGREES

    -- Apply velocity adjustment to threshold
    if CONFIG.VELOCITY_ADJUSTED.ENABLED then
        local speed = get_player_horizontal_speed(shooter_id)
        if speed > CONFIG.VELOCITY_ADJUSTED.SPEED_THRESHOLD then
            threshold = threshold * CONFIG.VELOCITY_ADJUSTED.ANGLE_MODIFIER
        end
    end

    -- Shooter eye position
    local sx, sy, sz = get_player_eye_position(shooter_dyn)
    if not sx then return nil end

    -- Target position (center mass)
    local tx, ty, tz = read_vector3d(target_dyn + 0x5C)
    tz = tz + CONFIG.PLAYER.STANDING_EYE_HEIGHT

    -- Get target velocity for prediction
    local vx, vy, vz = read_vector3d(target_dyn + 0x278)
    local dx, dy, dz = tx - sx, ty - sy, tz - sz
    local dist = vector_length(dx, dy, dz)

    -- Predict future position
    local time_to_target = dist / CONFIG.PLAYER.PROJECTILE_SPEED
    local predicted_x = tx + vx * time_to_target
    local predicted_y = ty + vy * time_to_target
    local predicted_z = tz + vz * time_to_target

    -- Recalculate direction with prediction
    dx, dy, dz = predicted_x - sx, predicted_y - sy, predicted_z - sz
    dist = vector_length(dx, dy, dz)
    if dist < 0.001 then return nil end

    local dir_x, dir_y, dir_z = normalize(dx, dy, dz)
    local aim_x, aim_y, aim_z = read_vector3d(shooter_dyn + 0x230)
    aim_x, aim_y, aim_z = normalize(aim_x, aim_y, aim_z)

    -- Compute angle between vectors (degrees)
    local dp = dot_product(aim_x, aim_y, aim_z, dir_x, dir_y, dir_z)
    dp = clamp(dp, -1, 1)
    local angle_deg = acos(dp) * 180 / pi

    -- Apply weapon-specific modifier
    local weapon = get_weapon_name(shooter_id)
    local modifier = CONFIG.WEAPON_MODIFIERS[weapon] or CONFIG.WEAPON_MODIFIERS.DEFAULT
    threshold = threshold * modifier

    if angle_deg <= threshold then
        return {
            distance = dist,
            direction = { dir_x, dir_y, dir_z },
            angle = angle_deg
        }
    end

    return nil
end

-- Validate whether the aim ray would hit a player object
local function validate_raycast_hit(shooter_dyn, shooter_player_id, direction)
    if shooter_dyn == 0 then return false end
    local sx, sy, sz = get_player_eye_position(shooter_dyn)
    if not sx then return false end

    local dir_x, dir_y, dir_z = unpack(direction)
    local ex = sx + dir_x * CONFIG.PLAYER.TRACE_DISTANCE
    local ey = sy + dir_y * CONFIG.PLAYER.TRACE_DISTANCE
    local ez = sz + dir_z * CONFIG.PLAYER.TRACE_DISTANCE

    local shooter_unit = read_dword(get_player(shooter_player_id) + 0x34)
    local hit, _, _, _, hit_object = intersect(sx, sy, sz, ex, ey, ez, shooter_unit)

    if not hit or hit_object == 0 then return false end

    -- Check if hit_object is another player
    for pid = 1, 16 do
        if pid ~= shooter_player_id and player_alive(pid) then
            local pdyn = get_dynamic_player(pid)
            if pdyn ~= 0 and get_object_memory(hit_object) == pdyn then
                return true
            end
        end
    end

    return false
end

-- Score evaluation for an aim event
local function evaluate_aim_event(shooter_id, shooter_dyn, snap_angle_deg, distance, direction, target_id)
    local state = players[shooter_id]
    if not state then return false end

    -- Base score uses lock_count and distance
    local base_score = (state.lock_count * distance) * 0.0015
    local hit_detected = validate_raycast_hit(shooter_dyn, shooter_id, direction)
    local final_score = base_score
    local is_moving = get_player_horizontal_speed(shooter_id) > 0.1

    -- Environmental awareness check
    local obscured = false
    if CONFIG.ENVIRONMENTAL.ENABLED then
        obscured = not is_visible(shooter_id, target_id)
        if obscured then
            final_score = final_score * CONFIG.ENVIRONMENTAL.OBSCURED_MULTIPLIER
        end
    end

    -- Scoring logic
    if snap_angle_deg > CONFIG.SNAP_DETECTION.BASELINE_DEGREES then
        state.lock_count = state.lock_count + 1
        final_score = final_score + (hit_detected and snap_angle_deg * 5 or snap_angle_deg * 15)
    elseif is_moving and snap_angle_deg > 0 and snap_angle_deg < CONFIG.SNAP_DETECTION.MOVING_THRESHOLD_DEGREES then
        state.lock_count = state.lock_count + 1
        final_score = final_score + (hit_detected and 4 or 10)
    else
        return false
    end

    state.aim_score = state.aim_score + final_score

    -- Pattern recognition
    if CONFIG.PATTERN_DETECTION.ENABLED then
        insert(state.lock_pattern, time())
        if #state.lock_pattern > CONFIG.PATTERN_DETECTION.MAX_PATTERN_LENGTH then
            remove(state.lock_pattern, 1)
        end

        if #state.lock_pattern >= 3 then
            local intervals = {}
            for i = 2, #state.lock_pattern do
                insert(intervals, state.lock_pattern[i] - state.lock_pattern[i - 1])
            end

            local mean, std_dev = compute_stats(intervals)
            if std_dev < CONFIG.PATTERN_DETECTION.MAX_STD_DEV then
                state.aim_score = state.aim_score + CONFIG.PATTERN_DETECTION.SCORE_BOOST
            end
        end
    end

    return true
end

-- Ensure per-player state exists
local function ensure_player_state(pid)
    if not players[pid] then
        players[pid] = {
            aim_score = 0,
            lock_count = 0,
            last_decay_time = time(),
            lock_pattern = {},
            dynamic_threshold = CONFIG.AUTO_AIM.ANGLE_THRESHOLD_DEGREES,
            accuracy_history = { 0.5 } -- Start with 50% accuracy
        }
    end
end

-- Update dynamic threshold based on accuracy
local function update_dynamic_threshold(pid)
    if not CONFIG.AUTO_AIM.DYNAMIC_THRESHOLD.ENABLED then return end

    local state = players[pid]
    if not state then return end

    -- Calculate recent accuracy (placeholder implementation)
    local accuracy = 0.5 -- Replace with actual accuracy tracking

    -- Update accuracy history
    insert(state.accuracy_history, accuracy)
    if #state.accuracy_history > 10 then
        remove(state.accuracy_history, 1)
    end

    -- Calculate weighted average accuracy
    local avg_accuracy = 0
    for _, acc in ipairs(state.accuracy_history) do
        avg_accuracy = avg_accuracy + acc
    end
    avg_accuracy = avg_accuracy / #state.accuracy_history

    -- Adjust threshold based on accuracy
    local multiplier = CONFIG.AUTO_AIM.DYNAMIC_THRESHOLD.BASE_MULTIPLIER +
        CONFIG.AUTO_AIM.DYNAMIC_THRESHOLD.ACCURACY_WEIGHT * (avg_accuracy - 0.5) * 2 multiplier = clamp(multiplier,
        CONFIG.AUTO_AIM.DYNAMIC_THRESHOLD.MIN_MULTIPLIER,
        CONFIG.AUTO_AIM.DYNAMIC_THRESHOLD.MAX_MULTIPLIER)

    state.dynamic_threshold = CONFIG.AUTO_AIM.ANGLE_THRESHOLD_DEGREES * multiplier
end

-- Process a single player's aim checks / decay / enforcement
local function process_player_aim(pid)
    ensure_player_state(pid)
    local state = players[pid]

    -- Update dynamic threshold
    update_dynamic_threshold(pid)

    -- Time-based decay
    local now = time()
    local elapsed = now - (state.last_decay_time or now)
    if elapsed >= CONFIG.DECAY.INTERVAL_SECONDS and state.aim_score > 0 then
        local decay_amount = elapsed * CONFIG.DECAY.POINTS_PER_SECOND
        state.aim_score = max(0, state.aim_score - decay_amount)
        state.last_decay_time = now
    end

    local dyn = get_dynamic_player(pid)
    if dyn == 0 then
        camera_vectors[pid] = nil
        return
    end

    local team = get_var(pid, "$team")
    local orientation_change = calculate_orientation_change(pid, dyn)
    local scoring_occurred = false

    -- Iterate targets and evaluate
    for target = 1, 16 do
        if target ~= pid and player_present(target) and player_alive(target) and get_var(target, "$team") ~= team then
            local aim_data = check_aim_at_target(dyn, pid, target)
            if aim_data then
                scoring_occurred = evaluate_aim_event(
                    pid,
                    dyn,
                    orientation_change,
                    aim_data.distance,
                    aim_data.direction,
                    target)
                break -- One primary evaluation per tick
            end
        end
    end

    if not scoring_occurred then
        state.lock_count = max(0, state.lock_count - 0.5)
    end

    -- Enforcement
    if state.aim_score > CONFIG.AUTO_AIM.MAX_SCORE then
        execute_command(fmt("%s %d \"%s\"", CONFIG.ENFORCEMENT.COMMAND, pid, CONFIG.ENFORCEMENT.REASON))
        state.aim_score = 0
        state.lock_count = 0
        state.lock_pattern = {}
    end
end

-- SAPP Callbacks --------------------------------------------------------------
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_DIE'], "OnDeath")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    register_callback(cb['EVENT_GAME_END'], "OnEnd")
    OnStart()
end

function OnScriptUnload() end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end
    for i = 1, 16 do
        players[i] = {
            aim_score = 0,
            lock_count = 0,
            last_decay_time = time(),
            lock_pattern = {},
            dynamic_threshold = CONFIG.AUTO_AIM.ANGLE_THRESHOLD_DEGREES,
            accuracy_history = { 0.5 }
        }
        camera_vectors[i] = nil
    end
    weapon_cache = {}
end

function OnEnd()
    for i = 1, 16 do
        players[i] = nil
        camera_vectors[i] = nil
    end
    weapon_cache = {}
end

function OnJoin(player_id)
    ensure_player_state(player_id)
    camera_vectors[player_id] = nil
    weapon_cache[player_id] = nil
end

function OnDeath(player_id)
    if players[player_id] then
        players[player_id].lock_count = 0
        players[player_id].aim_score = 0
        players[player_id].last_decay_time = time()
    end
    camera_vectors[player_id] = nil
end

function OnQuit(player_id)
    players[player_id] = nil
    camera_vectors[player_id] = nil
    weapon_cache[player_id] = nil
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            process_player_aim(i)
        end
    end
end