--[[
=====================================================================================
SCRIPT NAME:      kill_confirmed.lua
DESCRIPTION:      Team-based objective mode where players must collect enemy dog tags
                  to score points, inspired by Call of Duty's Kill Confirmed.

KEY FEATURES:
                 - Dog tag collection system for scoring
                 - Team-based confirmation/denial mechanics
                 - Configurable score limits and point values
                 - Automatic dog tag despawn timer
                 - Friendly fire prevention option
                 - Real-time scoring and team updates
                 - In-game statistics tracking

CONFIGURATION OPTIONS:
                 - Adjustable score limits and point values
                 - Customizable messages and announcements
                 - Dog tag despawn delay settings
                 - Friendly fire toggle
                 - In-game command accessibility

LAST UPDATED:     21/8/2025

Copyright (c) 2020-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG STARTS -------------------------------------------------------------
local messages = {
    confirm_own = "$name confirmed a kill on $victim",
    confirm_ally = "$name confirmed $killer's kill on $victim",
    deny = "$name denied $killer's kill",
    suicide = "$name committed suicide!",
    friendly_fire = "$name team-killed $victim!",
    stats = "Kills: $kills | Deaths: $deaths | Confirms: $confirms | Denies: $denies",
    top_players = "TOP PLAYERS: $list"
}

local settings = {
    score_limit = 65,           -- Score needed to win
    points_on_confirm = 2,      -- Points for confirming a kill
    despawn_delay = 30,         -- Seconds before dog tags disappear
    block_friendly_fire = true, -- Prevent team damage (true/false)
    allow_commands = true       -- Enable in-game commands
}

local dog_tag_path = "weapons\\ball\\ball" -- The object tag path to represent a dog tag

local server_prefix = "**KILL CONFIRMED**" -- Prefix for server announcements

-- CONFIG ENDS --------------------------------------------------------------

-- Runtime Variables --------------------------------------------------------
local players = {}
local dog_tags = {}
local dog_tag_id
local game_active = false
local os_time = os.time

api_version = "1.12.0.0"

-- Localize globals ---------------------------------------------------------
local tonumber, ipairs, table_remove = tonumber, ipairs, table.remove
local get_var, say_all, execute_command = get_var, say_all, execute_command
local get_dynamic_player, get_object_memory = get_dynamic_player, get_object_memory
local read_dword, read_word, read_string = read_dword, read_word, read_string
local read_vector3d, spawn_object, destroy_object = read_vector3d, spawn_object, destroy_object

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_DIE']] = 'OnDeath',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_GAME_END']] = 'OnEnd',
    [cb['EVENT_DAMAGE_APPLICATION']] = 'OnDamage',
    [cb['EVENT_WEAPON_PICKUP']] = 'OnWeaponPickup'
}

-- Helper Functions --------------------------------------------------------
local function register_callbacks(enable)
    for event, callback in pairs(sapp_events) do
        if enable then
            register_callback(event, callback)
        else
            unregister_callback(event, callback)
        end
    end
end

local function fmt(msg, vars)
    return (msg:gsub("%$(%w+)", function(key)
        return vars[key] or ("$" .. key)
    end))
end

local function announce(msg, vars)
    execute_command('msg_prefix ""')
    say_all(fmt(msg, vars))
    execute_command('msg_prefix "' .. server_prefix .. '"')
end

local function has_oddball(player_id, slot_index)
    local dyn = get_dynamic_player(player_id)
    if dyn == 0 then return nil end

    local weapon_id = read_dword(dyn + 0x2F8 + (slot_index - 1) * 4)
    local object_memory = get_object_memory(weapon_id)

    if weapon_id == 0xFFFFFFFF or object_memory == 0 then return nil end
    local object_path = read_string(read_dword(read_word(object_memory) * 32 + 0x40440038))

    return object_path == dog_tag_path and object_memory or nil
end

local function update_score(player, points)
    local current_score = tonumber(get_var(player.id, "$score"))
    execute_command("score " .. player.id .. " " .. (current_score + points))

    local team = player.team == "red" and 0 or 1
    local team_score = tonumber(get_var(0, player.team == "red" and "$redscore" or "$bluescore"))
    execute_command("team_score " .. team .. " " .. (team_score + points))
end

local function new_player(id)
    return {
        id = id,
        name = get_var(id, "$name"),
        team = get_var(id, "$team"),
        kills = 0,
        deaths = 0,
        confirms = 0,
        denies = 0
    }
end

local function destroy_dogtag(tag)
    if tag.object_id then
        destroy_object(tag.object_id)
    end
end

local function should_despawn(tag)
    return (os_time() - tag.spawn_time) >= settings.despawn_delay
end

local function get_coordinates(player_id)
    local dyn = get_dynamic_player(player_id)
    if dyn == 0 then return nil end

    local crouch = read_float(dyn + 0x50C)
    local vehicle_id = read_dword(dyn + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_offset = (crouch == 0) and 0.65 or 0.35 * crouch
    return x, y, z + z_offset
end

local function spawn_dogtag(tag)
    local x, y, z = get_coordinates(tag.victim_id)
    if not x then return end
    tag.object_id = spawn_object('', '', x, y, z + 0.3, 0, dog_tag_id)
    tag.object_memory = get_object_memory(tag.object_id)
end

local function new_dogtag(killer_id, victim_id)
    local killer = players[killer_id]
    local victim = players[victim_id]

    local tag = {
        killer_id = killer_id,
        victim_id = victim_id,
        killer_name = killer.name,
        victim_name = victim.name,
        killer_team = killer.team,
        victim_team = victim.team,
        spawn_time = os_time(),
        object_id = nil,
        object_memory = nil
    }
    spawn_dogtag(tag)
    return tag
end

local function handle_dog_tag_collection(player_id, object_memory)
    for i, tag in ipairs(dog_tags) do
        if tag.object_memory == object_memory then
            local collector = players[player_id]
            local is_confirmation = collector.team == tag.killer_team
            local is_denial = collector.team == tag.victim_team

            if is_confirmation then
                collector.confirms = collector.confirms + 1
                update_score(collector, settings.points_on_confirm)

                local msg = (player_id == tag.killer_id) and
                    messages.confirm_own or
                    messages.confirm_ally

                announce(msg, {
                    name = collector.name,
                    killer = tag.killer_name,
                    victim = tag.victim_name
                })
            elseif is_denial then
                collector.denies = collector.denies + 1

                announce(messages.deny, {
                    name = collector.name,
                    killer = tag.killer_name
                })
            end

            destroy_dogtag(tag)
            table_remove(dog_tags, i)
            return true
        end
    end
    return false
end

local function get_tag_id(class, path)
    local tag = lookup_tag(class, path)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

-- Event Handlers -----------------------------------------------------------
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    game_active, players, dog_tags = true, {}, {}

    dog_tag_id = get_tag_id("weap", dog_tag_path)
    if dog_tag_id == nil then
        cprint("Dog Tag '" .. dog_tag_path .. "' not found.", 10)
        register_callbacks(false)
        return
    end

    for i = 1, 16 do
        if player_present(i) then
            players[i] = new_player(i)
        end
    end

    register_callbacks(true)
    execute_command("scorelimit " .. settings.score_limit)
end

function OnEnd()
    game_active = false
    for _, tag in ipairs(dog_tags) do
        destroy_dogtag(tag)
    end
    dog_tags = {}
end

function OnJoin(id)
    players[id] = new_player(id)
end

function OnQuit(id)
    for i = #dog_tags, 1, -1 do
        local tag = dog_tags[i]
        if tag.killer_id == id or tag.victim_id == id then
            destroy_dogtag(tag)
            table_remove(dog_tags, i)
        end
    end

    players[id] = nil
end

function OnTick()
    if not game_active then return end

    for i = #dog_tags, 1, -1 do
        if should_despawn(dog_tags[i]) then
            destroy_dogtag(dog_tags[i])
            table_remove(dog_tags, i)
        end
    end
end

function OnDeath(victim_id, killer_id)
    if not game_active then return end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)
    if killer_id == 0 or killer_id == -1 then return end -- server/environmental kill

    local victim = players[victim_id]
    local killer = players[killer_id]

    -- Technical note:
    --  Important to check killer is not nil, as it's possible to get a delayed kill (e.g., plasma grenade kill),
    --  after quitting the game.

    if not victim or not killer then return end

    if victim_id == killer_id then
        announce(messages.suicide, { name = victim.name })
        victim.deaths = victim.deaths + 1
        return
    end

    if not settings.block_friendly_fire then
        if killer.team == victim.team then
            announce(messages.friendly_fire, {
                name = killer.name,
                victim = victim.name
            })
            killer.kills = killer.kills + 1
            victim.deaths = victim.deaths + 1
            update_score(killer, -1)
            return
        end
    end

    killer.kills = killer.kills + 1
    victim.deaths = victim.deaths + 1

    table.insert(dog_tags, new_dogtag(killer_id, victim_id))
    update_score(killer, -1)
end

function OnWeaponPickup(player_id, slot_index, weapon_type)
    if not game_active or tonumber(weapon_type) ~= 1 then return true end

    local object_memory = has_oddball(player_id, slot_index)
    if not object_memory then return end

    handle_dog_tag_collection(player_id, object_memory)
end

function OnDamage(victim_id, killer_id)
    if not game_active or not settings.block_friendly_fire then return true end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)
    if killer_id == 0 then return true end

    local victim = players[victim_id]
    local killer = players[killer_id]
    if not victim or not killer then return true end

    if victim_id ~= killer_id and victim.team == killer.team then
        return false
    end
    return true
end

function OnScriptUnload()
    for _, tag in ipairs(dog_tags) do
        destroy_dogtag(tag)
    end
end
