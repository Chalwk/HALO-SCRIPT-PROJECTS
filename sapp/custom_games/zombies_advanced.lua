--[[
=====================================================================================
SCRIPT NAME:      zombies.lua
DESCRIPTION:      Zombie survival mode where humans fight against zombies.
                  Zombies convert humans by killing them.

KEY FEATURES:
                 - Team conversion mechanics (humans to zombies)
                 - Zombies use melee weapons only
                 - Configurable attributes for both teams
                 - Real-time team composition changes
                 - Victory condition when all humans are eliminated
                 - Player count-based game activation
                 - Countdown timer before match start
                 - Enhanced team shuffling with anti-duplicate protection
                 - Death message suppression during team changes
                 - Alpha Zombie and Standard Zombie types
                 - Last Man Standing bonus for final human

CONFIGURATION OPTIONS:
                 - Adjustable speed boosts for both teams
                 - Customizable respawn times
                 - Camouflage abilities
                 - Minimum players required

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration -----------------------------------------------------------------------
local CONFIG = {
    REQUIRED_PLAYERS = 2,          -- Minimum players required to start
    COUNTDOWN_DELAY = 5,           -- Seconds before game starts
    SERVER_PREFIX = "**ZOMBIES**", -- Server message prefix
    BLOCK_FALL_DAMAGE = true,      -- Block fall damage

    ATTRIBUTES = {
        ['alpha_zombies'] = {
            SPEED = 15,   -- 1.5x normal speed
            HEALTH = 2.0, -- 200% health
            RESPAWN_TIME = 1.5,
            DAMAGE_MULTIPLIER = 10,
            CAMO = true,
            GRENADES = { frags = 0, plasmas = 2 },
            CAN_USE_VEHICLES = false
        },
        ['standard_zombies'] = {
            SPEED = 14,   -- 1.4x normal speed
            HEALTH = 1.0, -- 100% health
            RESPAWN_TIME = 1.2,
            DAMAGE_MULTIPLIER = 10,
            CAMO = false,
            GRENADES = { frags = 0, plasmas = 0 },
            CAN_USE_VEHICLES = false
        },
        ['humans'] = {
            SPEED = 12,   -- 1.2x normal speed
            HEALTH = 1.0, -- 100% health
            RESPAWN_TIME = 3,
            DAMAGE_MULTIPLIER = 1,
            CAMO = false,
            GRENADES = { frags = 2, plasmas = 2 },
            CAN_USE_VEHICLES = true
        },
        ['last_man_standing'] = {
            SPEED = 15,   -- 1.5x normal speed
            HEALTH = 1.0, -- 100% health
            RESPAWN_TIME = 1,
            DAMAGE_MULTIPLIER = 2,
            CAMO = false,
            GRENADES = { frags = 4, plasmas = 4 },
            CAN_USE_VEHICLES = true,
            HEALTH_REGEN = 0.0005 -- Health regeneration per tick
        }
    }
}
-- End of Configuration -----------------------------------------------------------------

api_version = '1.12.0.0'

local pairs, ipairs, table_insert = pairs, ipairs, table.insert
local math_random, os_time, tonumber = math.random, os.time, tonumber

local get_var, say_all = get_var, say_all
local execute_command, player_present = execute_command, player_present

local death_message_hook_enabled = false
local death_message_address = nil
local original_death_message_bytes = nil
local DEATH_MESSAGE_SIGNATURE = "8B42348A8C28D500000084C9"
local falling, distance
local last_man_id = nil

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_DIE']] = 'OnDeath',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_SPAWN']] = 'OnSpawn',
    [cb['EVENT_GAME_END']] = 'OnEnd',
    [cb['EVENT_TEAM_SWITCH']] = 'OnTeamSwitch',
    [cb['EVENT_WEAPON_DROP']] = 'OnWeaponDrop',
    [cb['EVENT_DAMAGE_APPLICATION']] = 'OnDamage'
}

local function register_callbacks(team_game)
    for event, callback in pairs(sapp_events) do
        if team_game then
            register_callback(event, callback)
        else
            unregister_callback(event)
        end
    end
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function SetupDeathMessageHook()
    local address = sig_scan(DEATH_MESSAGE_SIGNATURE)
    if address == 0 then
        cprint("Zombies: Death message signature not found!", 4)
        return false
    end

    death_message_address = address + 3
    original_death_message_bytes = read_dword(death_message_address)

    if not original_death_message_bytes or original_death_message_bytes == 0 then
        cprint("Zombies: Failed to read original death message bytes!", 4)
        death_message_address = nil
        return false
    end

    return true
end

local function disableDeathMessages()
    if death_message_hook_enabled and death_message_address then
        safe_write(true)
        write_dword(death_message_address, 0x03EB01B1)
        safe_write(false)
    end
end

local function restoreDeathMessages()
    if death_message_hook_enabled and death_message_address and original_death_message_bytes then
        safe_write(true)
        write_dword(death_message_address, original_death_message_bytes)
        safe_write(false)
    end
end

local function getOddbalID()
    local base_tag_table = 0x40440000
    local tag_array = read_dword(base_tag_table)
    local tag_count = read_dword(base_tag_table + 0xC)
    for i = 0, tag_count - 1 do
        local tag = tag_array + 0x20 * i
        if read_dword(tag) == 0x77656170 then
            local tag_data = read_dword(tag + 0x14)
            if read_bit(tag_data + 0x308, 3) == 1 and read_byte(tag_data + 2) == 4 then
                return read_dword(tag + 0xC)
            end
        end
    end
    return nil
end

-- Game State
local game = {
    players = {},
    player_count = 0,
    started = false,
    countdown_start = 0,
    waiting_for_players = true,
    red_count = 0,
    blue_count = 0,
    oddball = nil
}

local function create_player(id)
    return {
        id = id,
        name = get_var(id, '$name'),
        team = get_var(id, '$team'),
        zombie_type = nil, -- 'alpha_zombies' or 'standard_zombies'
        drone = nil,
        assign = false,
        is_last_man_standing = false,
    }
end

local function apply_player_attributes(player, player_type)
    local attributes = CONFIG.ATTRIBUTES[player_type]

    -- Set speed
    execute_command("s " .. player.id .. " " .. attributes.SPEED)

    -- Set health
    if player_alive(player.id) then
        local dyn = get_dynamic_player(player.id)
        if dyn ~= 0 then
            write_float(dyn + 0xE0, attributes.HEALTH)
        end
    end

    -- Set grenades
    execute_command('nades ' .. player.id .. ' ' .. attributes.GRENADES.frags .. ' 1')
    execute_command('nades ' .. player.id .. ' ' .. attributes.GRENADES.plasmas .. ' 2')

    -- Update last man standing status
    player.is_last_man_standing = (player_type == 'last_man_standing')
end

local function blockVehicleEntry(player_id, dyn_player, can_use_vehicles)
    if can_use_vehicles then return end
    if read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF then
        exit_vehicle(player_id)
    end
end

local function switchPlayerTeam(player, new_team, zombie_type)
    execute_command('st ' .. player.id .. ' ' .. new_team)
    player.team = new_team

    if new_team == 'blue' then
        player.zombie_type = zombie_type or 'standard_zombies'
        apply_player_attributes(player, player.zombie_type)
        player.assign = true
    else
        player.zombie_type = nil
        if game.red_count == 1 and game.started then
            apply_player_attributes(player, 'last_man_standing')
        else
            apply_player_attributes(player, 'humans')
        end
        if player.drone then
            destroy_object(player.drone)
            player.drone = nil
        end
        execute_command('wdel ' .. player.id)
    end
end

local function broadcast(msg)
    execute_command('msg_prefix ""')
    say_all(msg)
    execute_command('msg_prefix "' .. CONFIG.SERVER_PREFIX .. '"')
end

local function updateTeamCounts()
    game.red_count, game.blue_count = 0, 0
    for _, player in pairs(game.players) do
        if player.team == 'red' then
            game.red_count = game.red_count + 1
        elseif player.team == 'blue' then
            game.blue_count = game.blue_count + 1
        end
    end
end

local function checkLastManStanding()
    if game.red_count == 1 and game.started then
        for _, player in pairs(game.players) do
            if player.team == 'red' then
                apply_player_attributes(player, 'last_man_standing')
                broadcast(player.name .. " is the Last Man Standing!")
                timer(30, 'RegenHealth')
                break
            end
        end
    end
end

local function shuffleTeams()
    local players = {}
    for id, _ in pairs(game.players) do
        table_insert(players, id)
    end

    if #players < 2 then return end

    -- Fisher-Yates shuffle
    for i = #players, 2, -1 do
        local j = math_random(i)
        players[i], players[j] = players[j], players[i]
    end

    -- Make first player an alpha zombie, rest humans
    for i, id in ipairs(players) do
        if i == 1 then
            switchPlayerTeam(game.players[id], "blue", "alpha_zombies")
        else
            switchPlayerTeam(game.players[id], "red")
        end
    end

    updateTeamCounts()
end

local function checkVictory()
    if game.red_count == 0 then
        broadcast("Zombies have overrun the humans!")
        execute_command('sv_map_next')
    end
end

local function startGame()
    if game.player_count < CONFIG.REQUIRED_PLAYERS then
        game.waiting_for_players = true
        return
    end

    game.waiting_for_players = false
    game.countdown_start = os_time()
    broadcast("Game starting in " .. CONFIG.COUNTDOWN_DELAY .. " seconds...")
    timer(CONFIG.COUNTDOWN_DELAY, 'OnCountdown')
end

local function getRespawnTime(player_type)
    return CONFIG.ATTRIBUTES[player_type].RESPAWN_TIME * 33
end

local function setRespawnTime(id, player_type)
    local respawn_time = getRespawnTime(player_type)
    local player = get_player(id)
    if player ~= 0 then
        write_dword(player + 0x2C, respawn_time)
    end
end

-- SAPP Events
function OnScriptLoad()
    death_message_hook_enabled = SetupDeathMessageHook()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    execute_command('sv_tk_ban 0')
    execute_command('sv_friendly_fire ')

    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    if get_var(0, '$ffa') == '1' then
        register_callbacks(false)
        cprint('====================================================', 12)
        cprint('Zombies: Only runs on team-based games', 12)
        cprint('====================================================', 12)
        return
    end

    game.players = {}
    game.player_count = 0
    game.started = false
    game.oddball = getOddbalID()

    execute_command('scorelimit 9999')

    if CONFIG.BLOCK_FALL_DAMAGE then
        falling = getTag('jpt!', 'globals\\falling')
        distance = getTag('jpt!', 'globals\\distance')
    end

    for i = 1, 16 do
        if player_present(i) then
            game.players[i] = create_player(i)
            game.player_count = game.player_count + 1
        end
    end

    updateTeamCounts()
    startGame()
    register_callbacks(true)
end

function OnEnd()
    game.started = false
    game.waiting_for_players = true
end

function OnJoin(id)
    game.players[id] = create_player(id)
    game.player_count = game.player_count + 1
    updateTeamCounts()

    if game.waiting_for_players and game.player_count >= CONFIG.REQUIRED_PLAYERS then
        startGame()
    end
end

function OnQuit(id)
    if game.players[id] then
        if game.players[id].drone then
            destroy_object(game.players[id].drone)
        end
        game.players[id] = nil
        game.player_count = game.player_count - 1
        updateTeamCounts()
        checkLastManStanding()

        if game.player_count < CONFIG.REQUIRED_PLAYERS and not game.started then
            game.started = false
            game.waiting_for_players = true
            broadcast("Not enough players. Game paused.")
        end
    end
end

function OnTeamSwitch(id)
    if not game.started then return true end

    if game.players[id] then
        game.players[id].team = get_var(id, '$team')
        updateTeamCounts()
        checkLastManStanding()

        if game.started then checkVictory() end
    end
end

function OnDeath(victimId, killerId)
    if not game.started then return end
    victimId = tonumber(victimId)
    killerId = tonumber(killerId)

    local victim = game.players[victimId]
    local killer = game.players[killerId]

    local server_environmental = killerId == 0 or killerId == -1
    if server_environmental or not victim or not killer then
        local player_type = victim.zombie_type or (victim.team == 'red' and 'humans') or 'standard_zombies'
        setRespawnTime(victimId, player_type)
        return
    end

    if victim.team == 'red' and killer.team == 'blue' then
        switchPlayerTeam(victim, 'blue', 'standard_zombies')
        updateTeamCounts()
        checkLastManStanding()
        broadcast(victim.name .. " was infected and became a zombie!")
    else
        local player_type = victim.zombie_type or (victim.team == 'red' and 'humans') or 'standard_zombies'
        setRespawnTime(victimId, player_type)
    end
end

local function getPlayerType(player)
    return player.zombie_type or
        (player.team == 'red' and (player.is_last_man_standing and 'last_man_standing' or 'humans')) or
        'standard_zombies'
end

function OnTick()
    if not game.started then return end

    for id, player in pairs(game.players) do
        if player and player_alive(id) then
            local dyn_player = get_dynamic_player(id)
            if dyn_player == 0 then goto next end

            local player_type = getPlayerType(player)
            local attributes = CONFIG.ATTRIBUTES[player_type]

            -- Handle camouflage for alpha zombies
            if attributes.CAMO then
                local crouching = read_float(dyn_player + 0x50C) == 1
                if crouching then
                    execute_command('camo ' .. id .. ' 1')
                else
                    execute_command('camo ' .. id .. ' 0')
                end
            end

            -- Prevent players from using vehicles
            blockVehicleEntry(id, dyn_player, attributes.CAN_USE_VEHICLES)

            -- Handle weapon assignment for zombies
            if player.team == 'blue' and player.assign then
                player.assign = false
                execute_command('wdel ' .. id)
                player.drone = spawn_object('', '', 0, 0, 0, 0, game.oddball)
                assign_weapon(player.drone, id)
            end
            ::next::
        end
    end
end

function OnWeaponDrop(id)
    if not game.started then return true end

    local player = game.players[id]
    if player then
        if player.drone then
            destroy_object(player.drone)
            player.drone = nil
            player.assign = true
        end
    end
end

local function isFallDamage(metaId)
    return (metaId == falling or metaId == distance)
end

local function isFriendlyFire(killer, victim)
    return killer.id ~= victim.id and killer.team == victim.team
end

function OnDamage(victimId, killerId, metaId, damage)
    if not game.started then return true end
    local killer = tonumber(killerId)
    local victim = tonumber(victimId)

    if CONFIG.BLOCK_FALL_DAMAGE and isFallDamage(metaId) then return false end

    local killer_data = game.players[killer]
    if not killer_data then return true end

    local victim_data = game.players[victim]
    local friendly_fire = isFriendlyFire(killer_data, victim_data)

    if friendly_fire then return false end

    local killer_type = getPlayerType(killer_data)
    local damage_multiplier = CONFIG.ATTRIBUTES[killer_type].DAMAGE_MULTIPLIER

    return true, damage * damage_multiplier
end

function OnSpawn(id)
    if not game.started then return end

    local player = game.players[id]
    if not player then return end

    local player_type = getPlayerType(player)
    apply_player_attributes(player, player_type)
end

function OnCountdown()
    if game.waiting_for_players or game.started then return false end

    local elapsed = os_time() - game.countdown_start
    local remaining = CONFIG.COUNTDOWN_DELAY - elapsed

    if remaining <= 0 then
        broadcast("Zombies are coming! Survive or become one of them!")

        disableDeathMessages()
        execute_command('sv_map_reset')
        shuffleTeams()
        restoreDeathMessages()

        game.started = true
    end

    return true
end

-- Health regeneration system for Last Man Standing
function RegenHealth()
    if not game.started then return false end

    local last_man = game.players[last_man_id]
    if not last_man then return false end

    local id = last_man.id

    local dyn_player = get_dynamic_player(id)
    if dyn_player ~= 0 and player_alive(id) then
        local health = read_float(dyn_player + 0xE0)
        if health < 1 then
            local new_health = math.min(health + CONFIG.ATTRIBUTES['last_man_standing'].HEALTH_REGEN, 1)
            write_float(dyn_player + 0xE0, new_health)
        end
    end
    return true
end

function OnScriptUnload()
    if death_message_hook_enabled then
        restoreDeathMessages()
    end
end
