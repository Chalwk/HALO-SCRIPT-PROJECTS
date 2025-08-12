--=====================================================================================--
-- SCRIPT NAME:      Anti-Aimbot (Aim-lock Detection)
-- DESCRIPTION:      Detects automated aim/lock assistance by monitoring sudden
--                   camera snaps and sustained aim alignment on enemy players.
--                   Uses angle-based aim checks (vector dot product), raycast
--                   hit-validation, and a time-based score decay system to
--                   minimise false positives. Executes configurable enforcement
--                   (kick/ban/command) when per-player score exceeds threshold.
--                   Includes per-player state, join/death/leave handling, and
--                   configurable sensitivity and decay parameters.
--
-- KEY FEATURES:
--   - Angle-based aim alignment (robust to tick variance)
--   - Raycast validation to confirm intent/hits
--   - Per-player lock_count and aim_score tracking
--   - Configurable enforcement command & reason
--   - Safe initialization on game start / player join / player leave
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
        ANGLE_THRESHOLD_DEGREES = 2.5,     -- max angle difference (degrees) to consider "aimed at" target
        MIN_ANGLE_THRESHOLD_DEGREES = 0.2, -- minimum angle threshold fallback
        MAX_SCORE = 3000                   -- enforcement threshold
    },

    SNAP_DETECTION = {
        BASELINE_DEGREES = 6.0,        -- significant snap angle (degrees)
        MOVING_THRESHOLD_DEGREES = 0.4 -- subtle snap threshold while moving (degrees)
    },

    PLAYER = {
        STANDING_EYE_HEIGHT = 0.64,  -- eye/aim Z offset while standing
        CROUCHING_EYE_HEIGHT = 0.35, -- eye/aim Z offset while crouching
        TRACE_DISTANCE = 250         -- raycast length for hit validation
    },

    ENFORCEMENT = {
        COMMAND = "k",              -- command executed on detection (e.g. "k")
        REASON = "Aimbot detection" -- reason message for enforcement command
    },

    DECAY = {
        POINTS_PER_SECOND = 0.25, -- aim score reduced per second
        INTERVAL_SECONDS = 0.25   -- update granularity (seconds)
    }
}
-- END CONFIG ---------------------------------------------------------------

api_version = "1.12.0.0"

-- Internal state
local players = {}        -- per-player state (indexed 1..16)
local camera_vectors = {} -- last-camera vector per player (for orientation delta)
local time = os.clock

-- Safe clamp
local function clamp(v, lo, hi) return (v < lo) and lo or ((v > hi) and hi or v) end

-- Vector helpers -------------------------------------------------------------
local function vector_length(x, y, z) return math.sqrt(x * x + y * y + z * z) end

local function normalize(x, y, z)
    local len = vector_length(x, y, z)
    if len <= 0 then return 0, 0, 0 end
    return x / len, y / len, z / len
end

local function dot_product(ax, ay, az, bx, by, bz) return ax * bx + ay * by + az * bz end

-- Calculate angular change between frames (degrees)
local function calculate_orientation_change(player_id, dyn_ptr)
    if dyn_ptr == 0 then return 0 end
    local cx, cy, cz = read_vector3d(dyn_ptr + 0x230) -- camera/aim vector

    local prev = camera_vectors[player_id]
    camera_vectors[player_id] = { cx, cy, cz }

    if not prev then
        return 0
    end

    local px, py, pz = prev[1], prev[2], prev[3]
    local d = dot_product(px, py, pz, cx, cy, cz)
    d = clamp(d, -1, 1)
    local angle_rad = math.acos(d)
    return (angle_rad * 180) / math.pi
end

-- Get player's eye (aim) position with crouch/stand offset
local function get_player_eye_position(dyn_ptr)
    if dyn_ptr == 0 then return nil end
    local x, y, z = read_vector3d(dyn_ptr + 0x5C)
    local crouch_state = read_float(dyn_ptr + 0x50C)
    local eye_height = (crouch_state == 0) and CONFIG.PLAYER.STANDING_EYE_HEIGHT or CONFIG.PLAYER.CROUCHING_EYE_HEIGHT
    return x, y, z + eye_height
end

-- Check whether current aim vector is aligned with direction to target using angle threshold
local function check_aim_at_target(shooter_dyn, target_id)
    if shooter_dyn == 0 then return nil end
    local target_dyn = get_dynamic_player(target_id)
    if target_dyn == 0 then return nil end

    -- shooter eye pos and target pos
    local sx, sy, sz = get_player_eye_position(shooter_dyn)
    if not sx then return nil end
    local tx, ty, tz = read_vector3d(target_dyn + 0x5C)
    -- adjust target Z to roughly target eye / torso (no crouch check for target for speed)
    tz = tz + CONFIG.PLAYER.STANDING_EYE_HEIGHT

    local dx, dy, dz = tx - sx, ty - sy, tz - sz
    local dist = vector_length(dx, dy, dz)
    if dist < 0.001 then return nil end

    local dir_x, dir_y, dir_z = normalize(dx, dy, dz)
    local aim_x, aim_y, aim_z = read_vector3d(shooter_dyn + 0x230)
    aim_x, aim_y, aim_z = normalize(aim_x, aim_y, aim_z)

    -- compute angle between aim vector and direction vector (degrees)
    local dp = dot_product(aim_x, aim_y, aim_z, dir_x, dir_y, dir_z)
    dp = clamp(dp, -1, 1)
    local angle_deg = math.acos(dp) * 180 / math.pi

    -- sensitivity -> an angle threshold (config stores degrees)
    local threshold = math.max(CONFIG.AUTO_AIM.ANGLE_THRESHOLD_DEGREES, CONFIG.AUTO_AIM.MIN_ANGLE_THRESHOLD_DEGREES)
    -- adjust threshold slightly with distance if desired (kept simple here)

    if angle_deg <= threshold then
        return {
            distance = dist,
            direction = { dir_x, dir_y, dir_z },
            angle = angle_deg
        }
    end

    return nil
end

-- Returns horizontal speed of a player (meters / second approximate)
local function get_player_horizontal_speed(player_id)
    local dyn = get_dynamic_player(player_id)
    if dyn == 0 then return 0 end
    local vx, vy, _ = read_vector3d(dyn + 0x278)
    return math.sqrt(vx * vx + vy * vy)
end

-- Validate whether the aim ray would hit a player object (basic raycast)
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

    -- check if hit_object corresponds to any player dynamic object other than shooter
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
local function evaluate_aim_event(shooter_id, shooter_dyn, snap_angle_deg, distance, direction)
    local state = players[shooter_id]
    if not state then return false end

    -- base score uses lock_count and distance (smaller distance -> stronger base)
    local base_score = (state.lock_count * distance) * 0.0015
    local hit_detected = validate_raycast_hit(shooter_dyn, shooter_id, direction)
    local final_score = base_score
    local is_moving = get_player_horizontal_speed(shooter_id) > 0.1 -- tolerance

    -- scoring logic
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
    return true
end

-- Ensure per-player state exists
local function ensure_player_state(pid)
    if not players[pid] then
        players[pid] = {
            aim_score = 0,
            lock_count = 0,
            last_decay_time = time()
        }
    end
end

-- Process a single player's aim checks / decay / enforcement
local function process_player_aim(pid)
    ensure_player_state(pid)
    local state = players[pid]

    -- time-based decay
    local now = time()
    local elapsed = now - (state.last_decay_time or now)
    if elapsed >= CONFIG.DECAY.INTERVAL_SECONDS and state.aim_score > 0 then
        local decay_amount = elapsed * CONFIG.DECAY.POINTS_PER_SECOND
        state.aim_score = math.max(0, state.aim_score - decay_amount)
        state.last_decay_time = now
        -- optionally: print("decayed", pid, decay_amount, "->", state.aim_score")
    end

    local dyn = get_dynamic_player(pid)
    if dyn == 0 then
        camera_vectors[pid] = nil
        return
    end

    local team = get_var(pid, "$team")
    local orientation_change = calculate_orientation_change(pid, dyn)
    local scoring_occurred = false

    -- iterate targets and evaluate
    for target = 1, 16 do
        if target ~= pid and player_present(target) and player_alive(target) and get_var(target, "$team") ~= team then
            local aim_data = check_aim_at_target(dyn, target)
            if aim_data then
                scoring_occurred = evaluate_aim_event(pid, dyn, orientation_change, aim_data.distance, aim_data
                .direction)
                break -- one primary evaluation per tick
            end
        end
    end

    if not scoring_occurred then
        state.lock_count = 0
    end

    -- enforcement
    if state.aim_score > CONFIG.AUTO_AIM.MAX_SCORE then
        execute_command(string.format("%s %d \"%s\"", CONFIG.ENFORCEMENT.COMMAND, pid, CONFIG.ENFORCEMENT.REASON))
        -- clear score to avoid repeat enforcement spam
        state.aim_score = 0
        state.lock_count = 0
    end
end

-- SAPP Callbacks --------------------------------------------------------------
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_DIE'], "OnDeath")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

function OnScriptUnload() end

function OnStart()
    -- only initialize when a game exists
    if get_var(0, "$gt") == "n/a" then return end
    for i = 1, 16 do
        players[i] = { aim_score = 0, lock_count = 0, last_decay_time = time() }
        camera_vectors[i] = nil
    end
end

function OnJoin(player_id)
    ensure_player_state(player_id)
    camera_vectors[player_id] = nil
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
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            process_player_aim(i)
        end
    end
end