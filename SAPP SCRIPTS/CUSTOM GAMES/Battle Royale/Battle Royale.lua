--=====================================================================================--
-- SCRIPT NAME:      Battle Royale
-- DESCRIPTION:      Minigame implementing a shrinking safe zone.
--                   Players outside the boundary take damage and receive warnings.
--                   Supports map-specific settings, configurable shrink steps,
--                   bonus periods, and automatic game start/end management.
--
--                   Additional features:
--                   - Loot crates
--
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

local CFG = {
    MSG_PREFIX = "SAPP",           -- SAPP msg_prefix
    DAMAGE_INTERVAL = 0.2,         -- Apply damage every 0.2 seconds (5x/sec) while outside boundary
    WARNING_INTERVAL = 2.0,        -- Warn players every 2 seconds while outside boundary
    DEBUG = true,                  -- Enable debug messages
}

-- CONFIG END ---------------------------------------------------------------------------

api_version = '1.12.0.0'

-- Localized frequently used functions and variables
local insert, remove = table.insert, table.remove
local floor, max, random = math.floor, math.max, math.random
local format, clock = string.format, os.clock
local get_dynamic_player, get_object_memory = get_dynamic_player, get_object_memory
local read_float, write_float, write_bit = read_float, write_float, write_bit
local player_present = player_present
local execute_command = execute_command
local spawn_object = spawn_object
local pairs = pairs

-- Runtime variables
local players, active_crates, respawn_timers, player_effects, enabled_spoils = {}, {}, {}, {}, {}
local crate_meta_id
local game_active = false
local bonus_period = false
local bonus_end_time = 0
local current_radius = 0
local game_start_time = 0
local total_game_time = 0
local expected_reductions = 0
local last_public_message = 0
local damage_per_interval = 0
local reductions_remaining = 0

-- Precomputed values
local DAMAGE_INTERVAL_MS = CFG.DAMAGE_INTERVAL * 1000
local WARNING_INTERVAL_MS = CFG.WARNING_INTERVAL * 1000

-- Initialize game boundary
local function initializeBoundary()
    current_radius = CFG.safe_zone.max_size
    expected_reductions = CFG.safe_zone.shrink_steps
    reductions_remaining = expected_reductions
    total_game_time = CFG.safe_zone.game_time
    damage_per_interval = CFG.safe_zone.damage_per_second * CFG.DAMAGE_INTERVAL

    -- Precompute shrink values
    CFG.safe_zone.reduction_amount = (CFG.safe_zone.max_size - CFG.safe_zone.min_size) / expected_reductions
    CFG.safe_zone.reduction_rate = total_game_time / expected_reductions

    game_active = true
    bonus_period = false
    last_public_message = clock()
end

local function spectate(id, dyn_player, px, py, pz)
    local player = get_player(id) -- static memory address (not dyn_player)

    if (player or not player.spectator) then return end

    write_float(player + 0xF8, px - 1000)  -- player x (x,y,z different from read_vector3d)
    write_float(player + 0xFC, py - 1000)  -- player y
    write_float(player + 0x100, pz - 1000) -- player z

    execute_command('wdrop ' .. id)
    execute_command('vexit ' .. id)

    -- only set these once
    if not players[id].spectator_once then
        -- Force into camoflauge:
        execute_command('camo ' .. id .. ' 1')
        -- Force into god mode:
        execute_command('god ' .. id)

        write_bit(dyn_player + 0x10, 0, 1)   -- uncollidable/invulnerable
        write_bit(dyn_player + 0x106, 11, 1) -- undamageable except for shields w explosions
    end
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

-- Spoil handlers
local function apply_bonus_life(player_id)
    CFG:send(player_id, "Received bonus life!")
    local player = players[player_id]
    player.lives = player.lives + 1
    return true
end

local function apply_full_overshield(player_id, spoil)
    local level = spoil.overshield[random(#spoil.overshield)]
    execute_command("sh " .. player_id .. " " .. level)
    CFG:send(player_id, "Received %sX overshield!", level)
    return true
end

local function apply_random_weapon(player_id, spoil, dyn_player)
    local weapon_names = {}
    for name, _ in pairs(spoil.weapons) do
        insert(weapon_names, name)
    end

    local weapon_name = weapon_names[random(#weapon_names)]
    local weapon_path = spoil.weapons[weapon_name]

    local inventory = CFG.get_inventory(dyn_player)
    if #inventory == 4 then
        CFG.cls(player_id)
        CFG:send(player_id, "Attempted to receive %s, but you're already full!", weapon_name)
        return false
    end

    local meta_id = CFG.get_tag('weap', weapon_path)
    if not meta_id then
        CFG:send(player_id, "This crate was a dud!")
        error("ERROR: Invalid object tag: weap " .. weapon_path, 10)
        return false
    end

    local weapon = spawn_object('', '', 0, 0, 0, 0, meta_id)
    assign_weapon(weapon, player_id)
    CFG:send(player_id, "Received %s!", weapon_name)

    return true
end

local function apply_speed_boost(player_id, spoil)
    local boost = spoil.multipliers[random(#spoil.multipliers)]
    local mult, duration = boost[1], boost[2]
    player_effects[player_id] = player_effects[player_id] or {}
    insert(player_effects[player_id], { effect = "speed", multiplier = mult, expires = clock() + duration })
    execute_command("s " .. player_id .. " " .. mult)
    CFG:send(player_id, "%.1fX speed boost for %d seconds!", mult, duration)
    return true
end

local function apply_camouflage(player_id, spoil)
    local duration = spoil.camouflage[random(#spoil.camouflage)]
    player_effects[player_id] = player_effects[player_id] or {}
    insert(player_effects[player_id], { effect = "camouflage", expires = clock() + duration })
    execute_command("camo " .. player_id .. " " .. duration)
    CFG:send(player_id, "Received camouflage for %d seconds!", duration)
    return true
end

local function apply_health_boost(_, spoil, dyn_player)
    local health = spoil.health[random(#spoil.health)]
    local current_health = read_float(dyn_player + 0xE0)
    write_float(dyn_player + 0xE0, current_health + health)
    CFG:send(player_id, "Received %dX health!", health)
    return true
end

local function apply_grenades(player_id, spoil)
    local frags, plasmas = spoil.grenades[1], spoil.grenades[2]
    execute_command('nades ' .. player_id .. ' ' .. frags .. ' 1')
    execute_command('nades ' .. player_id .. ' ' .. plasmas .. ' 2')
    CFG:send(player_id, "Received %dX frags, %dX plasmas!", frags, plasmas)
    return true
end

local function spawn_crate(loc_idx)
    local loc = CFG.crates.locations[loc_idx]
    if not loc then return end
    local height_offset = 0.3
    local obj = spawn_object('', '', loc[1], loc[2], loc[3] + height_offset, 0, crate_meta_id)
    if obj ~= 0 then
        CFG:debug_print("Spawning crate at location #%d (x=%.3f, y=%.3f, z=%.3f)", loc_idx, loc[1], loc[2], loc[3])
        active_crates[obj] = { loc_idx = loc_idx, spawn_time = clock() }
        return true
    end
    return false
end

-- Crate management
-- In the main script, modify the initCrates function:
local function initCrates()
    active_crates = {}
    respawn_timers = {}

    local crates = CFG.crates
    local tag = crates.crate_tag
    local class, name = tag[1], tag[2]
    crate_meta_id = CFG.get_tag(class, name)
    if not crate_meta_id then
        unregisterCallbacks()
        error("ERROR: Invalid object tag: " .. class .. " " .. name, 10)
    end

    -- Set defaults if min/max not defined
    crates.min_crates = crates.min_crates or 1
    crates.max_crates = crates.max_crates or #crates.locations
    crates.max_crates = math.min(math.max(crates.min_crates, crates.max_crates), #crates.locations)

    for i = 1, #crates.spoils do
        local spoil = crates.spoils[i]
        if spoil.enabled then
            enabled_spoils[#enabled_spoils + 1] = spoil
        end
    end

    if #enabled_spoils == 0 or #crates.locations == 0 then return end

    execute_command('disable_object ' .. '"' .. tag[2] .. '"')

    -- Spawn random number of crates at random locations
    local num_to_spawn = random(crates.min_crates, crates.max_crates)
    local indices = {}
    for i = 1, #crates.locations do indices[i] = i end

    -- Shuffle indices
    for i = #indices, 2, -1 do
        local j = random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    for i = 1, num_to_spawn do
        spawn_crate(indices[i])
    end
end

-- Spoil handlers
local spoil_handlers = {
    lives = apply_bonus_life,
    weapons = apply_random_weapon,
    multipliers = apply_speed_boost,
    overshield = apply_full_overshield,
    grenades = apply_grenades,
    health = apply_health_boost,
    camouflage = apply_camouflage
}

-- Crate spoil management
local function open_crate(player_id, dyn_player)
    local spoil = enabled_spoils[random(#enabled_spoils)]
    for k in pairs(spoil) do
        if k ~= "enabled" and spoil_handlers[k] then
            return spoil_handlers[k](player_id, spoil, dyn_player)
        end
    end
    return false
end

-- Crate Effect management
local function update_effects()
    local current_time = clock()
    for player_id, effects in pairs(player_effects) do
        for i = #effects, 1, -1 do
            local eff = effects[i]
            if current_time >= eff.expires then
                if eff.effect == "speed" then
                    execute_command("s " .. player_id .. " 1.0")
                    CFG:send(player_id, "Speed boost ended")
                elseif eff.effect == "camouflage" then
                    execute_command("camo " .. player_id .. " 0")
                    CFG:send(player_id, "Camouflage ended")
                end
                remove(effects, i)
            end
        end
        if #effects == 0 then player_effects[player_id] = nil end
    end
end

-- Callback management
local function registerCallbacks()
    register_callback(cb["EVENT_DIE"], "OnDeath")
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_GAME_END"], "OnEnd")
end

local function unregisterCallbacks()
    unregister_callback(cb["EVENT_DIE"])
    unregister_callback(cb["EVENT_TICK"])
    unregister_callback(cb["EVENT_JOIN"])
    unregister_callback(cb["EVENT_LEAVE"])
    unregister_callback(cb["EVENT_GAME_END"])
end

local function safeLoadFile(path)
    local chunk, load_err = loadfile(path)
    if not chunk then
        return nil, "[LOAD ERROR] Failed to load file: " .. path .. "\nError: " .. tostring(load_err)
    end

    local ok, result = pcall(chunk)
    if not ok then
        return nil, "[RUN ERROR] Error executing file: " .. path .. "\nError: " .. tostring(result)
    end

    return result
end

function CFG:loadFiles()
    local files = {
        './Battle Royale/helpers.lua',
        './Battle Royale/maps/' .. get_var(0, "$map") .. '.lua'
    }

    for i = 1, #files do
        local path = files[i]
        local loaded, err = safeLoadFile(path)
        if not loaded then
            unregisterCallbacks()
            error("[BATTLE ROYALE] " .. err, 10)
            return false
        end

        -- Merge loaded table into CFG
        for k, v in pairs(loaded) do
            self[k] = v
        end
    end

    math.randomseed(clock())
    registerCallbacks()
    return true
end

-- SAPP Event handlers
function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    if CFG:loadFiles() then
        initializeBoundary()
        game_start_time = clock()
        initCrates()
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnEnd()
    game_active = false
    bonus_period = false
    player_effects = {}
end

function OnJoin(id)
    players[id] = {
        lives = CFG.sfe_zone.max_deaths_until_spectate,
        last_damage = 0,
        last_warning = 0,
        spectator = false,
        spectator_once = false,
    }
end

function OnQuit(id)
    players[id] = nil
end

function OnDeath(victim, killer)
    victim = tonumber(victim)
    killer = tonumber(killer)

    local player = players[victim]
    if killer == 0 or killer == victim or not player then return end

    player_effects[victim] = nil
    if player.lives <= 0 then
        player.spectator = true
        player.spectator_once = true
        return
    end
    player.lives = player.lives - 1
end

function OnTick()
    if not game_active then return end

    update_effects()

    local now = clock()
    local elapsed = now - game_start_time
    local radius_changed = false

    -- Boundary shrinking logic
    if not bonus_period then
        local reductions_done = floor(elapsed / CFG.safe_zone.reduction_rate)
        reductions_remaining = max(expected_reductions - reductions_done, 0)
        local new_radius = max(CFG.safe_zone.max_size - reductions_done * CFG.safe_zone.reduction_amount,
            CFG.safe_zone.min_size)

        if new_radius < current_radius then
            current_radius = new_radius
            radius_changed = true
        end

        if reductions_remaining == 0 then
            bonus_period = true
            bonus_end_time = now + CFG.safe_zone.bonus_time
            current_radius = CFG.safe_zone.min_size
            radius_changed = true

            CFG:send(nil, "Last man standing for %d seconds at %.0f world units!",
                CFG.safe_zone.bonus_time, current_radius)
        end
    end

    -- Announce radius changes
    if radius_changed then
        CFG:send(nil, "Radius shrunk to %.0f | Shrinks left: %d | Min radius: %.0f",
            current_radius, reductions_remaining, CFG.safe_zone.min_size)
    end

    -- Precompute values for boundary checks
    local radius_sq = current_radius * current_radius
    local current_time_ms = now * 1000

    -- Precompute active crate count
    local active_crate_count = 0
    for _ in pairs(active_crates) do active_crate_count = active_crate_count + 1 end

    -- Handle crate respawns
    for loc_idx, respawn_time in pairs(respawn_timers) do
        if now >= respawn_time then
            if active_crate_count < CFG.crates.max_crates then
                if spawn_crate(loc_idx) then
                    respawn_timers[loc_idx] = nil
                    active_crate_count = active_crate_count + 1
                end
            else
                -- Reschedule if at max crates
                respawn_timers[loc_idx] = now + 5
            end
        end
    end

    -- Detect naturally despawned crates
    local crate_locs = CFG.crates.locations
    for crate_id, crate_data in pairs(active_crates) do
        local crate = get_object_memory(crate_id)
        if crate == 0 then
            active_crates[crate_id] = nil
            local loc_idx = crate_data.loc_idx
            if not respawn_timers[loc_idx] then
                local respawn_delay = CFG:get_crate_respawn_time()
                respawn_timers[loc_idx] = now + respawn_delay
                CFG:debug_print("Crate at location #%d despawned naturally. Respawning in %d seconds.", loc_idx,
                    respawn_delay)
            end
        end
    end

    -- Player processing
    for i = 1, 16 do
        if CFG.validate_player(i) then
            local dyn_player = get_dynamic_player(i)
            if not dyn_player then goto continue end

            local x, y, z, in_vehicle = CFG.get_player_position(dyn_player)
            if not x then goto continue end

            local player = players[i]

            ---------------------
            -- Spectator logic
            ---------------------
            if player.spectator then
                spectate(i, dyn_player, x, y, z)
                goto continue
            end

            --------------------------------
            -- CRATE MANAGEMENT
            --------------------------------

            --- Player-crate collision detection
            if in_vehicle or player.spectator then goto skip_collision end
            for crate_id, crate_data in pairs(active_crates) do
                local crate = get_object_memory(crate_id)
                if crate == 0 then
                    active_crates[crate_id] = nil; goto continue_crate
                end
                local loc = crate_locs[crate_data.loc_idx]
                if CFG.distance_squared(x, y, z, loc[1], loc[2], loc[3], CFG.crates.collision_radius) then
                    if not open_crate(i, dyn_player) then goto continue_crate end
                    active_crates[crate_id] = nil
                    respawn_timers[crate_data.loc_idx] = now + CFG:get_crate_respawn_time()
                    CFG:debug_print("Player %d collected crate at location #%d", i, crate_data.loc_idx)
                    destroy_object(crate_id)
                    break
                end
                ::continue_crate::
            end
            ::skip_collision::

            ------------------------------------------------
            -- PLAYABLE BOUNDARY (safe zone) CHECK
            ------------------------------------------------
            local center = CFG.safe_zone.center
            local inside = CFG.distance_squared(x, y, z, center.x, center.y, center.z, radius_sq)
            if not inside then
                if current_time_ms - player.last_damage >= DAMAGE_INTERVAL_MS then
                    hurtPlayer(i, dyn_player)
                    player.last_damage = current_time_ms
                end
                if current_time_ms - player.last_warning >= WARNING_INTERVAL_MS then
                    CFG:send(i, "You are outside the boundary! Return to the play area.")
                    player.last_warning = current_time_ms
                end
            end

            if now - last_public_message >= CFG.safe_zone.public_message_interval then
                local status
                if bonus_period then
                    status = format("BONUS TIME: %s | Radius: %.0f",
                        CFG.seconds_to_time(bonus_end_time - now),
                        current_radius)
                else
                    status = format("Radius: %.0f | Time: %s | Shrinks left: %d",
                        current_radius,
                        CFG.seconds_to_time(total_game_time - elapsed),
                        reductions_remaining)
                end
                CFG:send(i, status .. (not inside and " [OUT]" or ""))
            end
        end
        ::continue::
    end

    -- Update public message timer
    if now - last_public_message >= CFG.safe_zone.public_message_interval then
        last_public_message = now
    end

    -- End game after bonus period
    if bonus_period and now >= bonus_end_time then
        game_active = false
        execute_command("sv_map_next")
    end
end

function OnScriptUnload() end
