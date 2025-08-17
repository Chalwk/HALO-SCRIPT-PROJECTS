--[[
================================================================================
TECHNICAL NOTE: CRATE DESPAWN LIMITATION
--------------------------------------------------------------------------------
Due to inherent limitations in the Halo game engine (netcode), full-spectrum
vision powerups automatically despawn after exactly 30 seconds of existence.
This behavior is hardcoded in the game and cannot be modified through SAPP scripting.

WHAT THIS MEANS:
1. Crates will disappear 30 seconds after spawning, regardless of player interaction
2. I cannot prevent this despawn - it's enforced by the game engine
3. The "respawn_delay_seconds" value in location configuration determines:
   - Minimum time between crate appearances at a location
   - The delay AFTER natural despawn BEFORE a new crate appears
================================================================================
--]]

-- Configuration
local CFG = {
    crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
    collision_radius = 1.5, -- Player-crate collision radius

    locations = {
        { 63.427,  -177.249, 4.756,  30 },
        { 63.874,  -155.632, 7.398,  35 },
        { 44.685,  -151.848, 4.660,  40 },
        { 118.143, -185.154, 7.170,  45 },
        { 112.120, -138.996, 0.911,  30 },
        { 98.765,  -108.723, 4.971,  35 },
        { 109.798, -110.394, 2.791,  40 },
        { 79.092,  -90.719,  5.246,  45 },
        { 70.556,  -84.854,  6.341,  30 },
        { 79.578,  -64.590,  5.311,  35 },
        { 21.884,  -108.882, 2.846,  40 },
        { 68.947,  -92.482,  2.702,  45 },
        { 76.069,  -132.263, 0.543,  30 },
        { 95.687,  -159.449, -0.100, 35 },
        { 40.240,  -79.123,  -0.100, 40 }
    },

    spoils = {
        { label = '$lives Bonus lives', lives = 1 },
        { label = 'Random Weapon', weapons = {
            'weapons\\plasma pistol\\plasma pistol',
            'weapons\\plasma rifle\\plasma rifle',
            'weapons\\assault rifle\\assault rifle',
            'weapons\\pistol\\pistol',
            'weapons\\needler\\mp_needler',
            'weapons\\flamethrower\\flamethrower',
            'weapons\\shotgun\\shotgun',
            'weapons\\sniper rifle\\sniper rifle',
            'weapons\\plasma_cannon\\plasma_cannon',
            'weapons\\rocket launcher\\rocket launcher'
        }},
        { label = '%sX Speed Boost for %s seconds', multipliers = { {1.2,10},{1.3,15},{1.4,20},{1.5,25} }},
        { types = {
            [1] = {0, '%sX normal bullets'},
            [2] = {1.5, '%sX armour piercing bullets'},
            [3] = {5, '%sX explosive bullets'},
            [4] = {100, '%sX golden bullets'}
        }, clip_sizes = {
            ['weapons\\plasma pistol\\plasma pistol'] = 100,
            ['weapons\\plasma rifle\\plasma rifle'] = 100,
            ['weapons\\assault rifle\\assault rifle'] = 60,
            ['weapons\\pistol\\pistol'] = 12,
            ['weapons\\needler\\mp_needler'] = 20,
            ['weapons\\flamethrower\\flamethrower'] = 100,
            ['weapons\\shotgun\\shotgun'] = 12,
            ['weapons\\sniper rifle\\sniper rifle'] = 4,
            ['weapons\\plasma_cannon\\plasma_cannon'] = 100,
            ['weapons\\rocket launcher\\rocket launcher'] = 2
        }},
        { label = '%s frags, %s plasmas', count = {4, 4} },
        { label = 'Camo for $time seconds', durations = {30,45,60,75,90,105,120} },
        { label = 'Overshield' },
        { label = '%sX Health Boost', levels = {1.2,1.3,1.4,1.5} }
    }
}

-- Debug toggle
local DEBUG = true

-- Internal state
local MSG_PREFIX = 'SAPP'
local game_active = false
local crate_meta_id
local active_crates = {}
local respawn_timers = {}
local player_effects = {}

local format = string.format
api_version = '1.12.0.0'

-- Helper functions
local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function send_message(player_id, ...)
    if not player_id then
        execute_command('msg_prefix ""') -- temporarily remove (means we canfit more characters in the message)
        say_all(format(...))
        execute_command('msg_prefix "' .. MSG_PREFIX .. '"') -- restore
        return
    end
    rprint(player_id, format(...)) -- rprint prints to the player's console
end

local function debug_print(...)
    if DEBUG then
        cprint("[DEBUG] " .. format(...))
    end
end

local function validate_player(id)
    return player_present(id) and player_alive(id)
end

local function get_player_position(dyn)
    local vehicle = read_dword(dyn + 0x11C)
    local x, y, z
    if vehicle ~= 0xFFFFFFFF then
        local obj = get_object_memory(vehicle)
        if obj ~= 0 then x, y, z = read_vector3d(obj + 0x5C) end
    else
        x, y, z = read_vector3d(dyn + 0x5C)
    end
    if not x then return end
    local crouching = read_float(dyn + 0x50C)
    return x, y, z + (crouching ~= 0 and 0.35 * crouching or 0.65)
end

local function distance_squared(x1, y1, z1, x2, y2, z2)
    local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
    return dx*dx + dy*dy + dz*dz
end

-- Crate management
local function spawn_crate(loc_idx)
    local loc = CFG.locations[loc_idx]
    if not loc then return end
    local height_offset = 0.3
    local obj = spawn_object('', '', loc[1], loc[2], loc[3] + height_offset, 0, crate_meta_id)
    if obj ~= 0 then
        debug_print("Spawning crate at location #%d (x=%.3f, y=%.3f, z=%.3f)", loc_idx, loc[1], loc[2], loc[3])
        active_crates[obj] = { loc_idx = loc_idx, spawn_time = os.clock() }
        return true
    end
    return false
end

local function init_crates()
    active_crates = {}
    respawn_timers = {}
    for i=1,#CFG.locations do
        spawn_crate(i)
    end
end

-- Spoil handlers
local function apply_bonus_life(player_id, spoil)
    send_message(player_id, "Received bonus life!")
    -- implementation pending
end

local function apply_random_weapon(player_id, spoil)
    local weapon = spoil.weapons[math.random(#spoil.weapons)]
    -- implementation pending
end

local function apply_speed_boost(player_id, spoil)
    local boost = spoil.multipliers[math.random(#spoil.multipliers)]
    local mult, duration = boost[1], boost[2]
    player_effects[player_id] = player_effects[player_id] or {}
    table.insert(player_effects[player_id], { effect = "speed", multiplier = mult, expires = os.clock() + duration })
    execute_command("s " .. player_id .. " " .. mult)
    send_message(player_id, "%.1fX speed boost for %d seconds!", mult, duration)
end

local spoil_handlers = {
    lives = apply_bonus_life,
    weapons = apply_random_weapon,
    multipliers = apply_speed_boost
    -- add others as needed
}

local function open_crate(player_id, dyn_player)
    local spoil = CFG.spoils[math.random(#CFG.spoils)]
    for k,_ in pairs(spoil) do
        if spoil_handlers[k] then
            spoil_handlers[k](player_id, spoil)
            break
        end
    end
end

-- Effect management
local function update_effects()
    local current_time = os.clock()
    for player_id, effects in pairs(player_effects) do
        for i = #effects,1,-1 do
            local eff = effects[i]
            if current_time >= eff.expires then
                if eff.effect == "speed" then
                    execute_command("s " .. player_id .. " 1.0")
                    send_message(player_id, "Speed boost ended")
                end
                table.remove(effects, i)
            end
        end
        if #effects == 0 then player_effects[player_id] = nil end
    end
end

-- Event registration
local function register_events()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
end

local function unregister_events()
    unregister_callback(cb['EVENT_TICK'])
    unregister_callback(cb['EVENT_GAME_END'])
end

-- Event handlers
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    math.randomseed(os.clock())
end

function OnGameStart()
    if get_var(0, '$gt') == 'n/a' then return end
    crate_meta_id = get_tag(CFG.crate_tag[1], CFG.crate_tag[2])
    if not crate_meta_id then
        unregister_events()
        error("Loot Crate Error: Invalid object tag: " .. CFG.crate_tag[1] .. " " .. CFG.crate_tag[2])
    end
    game_active = true
    init_crates()
    register_events()
end

function OnGameEnd()
    game_active = false
    player_effects = {}
end

function OnTick()
    if not game_active then return end
    update_effects()
    local current_time = os.clock()

    -- Handle crate respawns
    for loc_idx, respawn_time in pairs(respawn_timers) do
        if current_time >= respawn_time then
            if spawn_crate(loc_idx) then respawn_timers[loc_idx] = nil end
        end
    end

    -- Detect naturally despawned crates
    for crate_id, crate_data in pairs(active_crates) do
        local crate = get_object_memory(crate_id)
        if crate == 0 then
            active_crates[crate_id] = nil
            local loc_idx = crate_data.loc_idx
            local respawn_delay = CFG.locations[loc_idx][4]
            if not respawn_timers[loc_idx] then
                respawn_timers[loc_idx] = os.clock() + respawn_delay
                debug_print("Crate at location #%d despawned naturally. Respawning in %d seconds.", loc_idx, respawn_delay)
            end
        end
    end

    -- Player-crate collision detection
    for i=1,16 do
        if validate_player(i) then
            local dyn = get_dynamic_player(i)
            if dyn ~= 0 then
                local x, y, z = get_player_position(dyn_player)
                if not x then goto continue end
                for crate_id, crate_data in pairs(active_crates) do
                    local crate = get_object_memory(crate_id)
                    if crate == 0 then active_crates[crate_id] = nil; goto continue_crate end
                    local loc = CFG.locations[crate_data.loc_idx]
                    local dist_sq = distance_squared(x, y, z, loc[1], loc[2], loc[3])
                    if dist_sq <= (CFG.collision_radius^2) then
                        destroy_object(crate_id)
                        active_crates[crate_id] = nil
                        respawn_timers[crate_data.loc_idx] = os.clock() + loc[4]
                        open_crate(i, dyn)
                        debug_print("Player %d collected crate at location #%d", i, crate_data.loc_idx)
                        break
                    end
                    ::continue_crate::
                end
            end
        end
        ::continue::
    end
end

function OnScriptUnload() end