--=====================================================================================================--
-- SCRIPT NAME:      One In The Chamber
-- DESCRIPTION:      Each player starts with a pistol loaded with a single bullet.
--                   - Every shot is a guaranteed kill.
--                   - Miss a shot, and you're down to melee combat only.
--                   - Each kill awards you one bullet.
--                   - Mastery demands precision and quick reflexes.
--                   - Choose your shots wisely: snipe or close in for the kill.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2023-2024 Jericho Crosby
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

api_version = '1.12.0.0'

-- Configuration table for the "One In The Chamber" game mode
local config = {

    -- Starting ammo for the primary weapon (pistol)
    starting_primary_ammo = 1,

    -- Starting ammo for the secondary weapon (none)
    starting_secondary_ammo = 0,

    -- Ammo awarded per kill
    ammo_per_kill = 1,

    -- Starting number of frag grenades
    starting_frags = 0,

    -- Starting number of plasma grenades
    starting_plasmas = 0,

    -- Weapon assigned to players (pistol)
    weapon = 'weapons\\pistol\\pistol',

    -- Flag to disable vehicles in the game
    disable_vehicles = true,

    -- Flag to disable weapon pickups in the game
    disable_weapon_pickups = true,

    -- Flag to disable grenade pickups in the game
    disable_grenade_pickups = true,

    -- Damage multipliers for various weapons and actions
    multipliers = {
        ['weapons\\assault rifle\\melee'] = 1.50,
        ['weapons\\ball\\melee'] = 1.50,
        ['weapons\\flag\\melee'] = 1.50,
        ['weapons\\flamethrower\\melee'] = 1.50,
        ['weapons\\needler\\melee'] = 1.50,
        ['weapons\\pistol\\melee'] = 1.50,
        ['weapons\\plasma pistol\\melee'] = 1.50,
        ['weapons\\plasma rifle\\melee'] = 1.50,
        ['weapons\\rocket launcher\\melee'] = 1.50,
        ['weapons\\shotgun\\melee'] = 1.50,
        ['weapons\\sniper rifle\\melee'] = 1.50,
        ['weapons\\plasma_cannon\\effects\\plasma_cannon_melee'] = 1.50,
        ['weapons\\frag grenade\\explosion'] = 1.00,
        ['weapons\\plasma grenade\\explosion'] = 1.50,
        ['weapons\\plasma grenade\\attached'] = 10.0,
        ['vehicles\\ghost\\ghost bolt'] = 1.015,
        ['vehicles\\scorpion\\bullet'] = 1.020,
        ['vehicles\\warthog\\bullet'] = 1.025,
        ['vehicles\\c gun turret\\mp bolt'] = 1.030,
        ['vehicles\\banshee\\banshee bolt'] = 1.035,
        ['vehicles\\scorpion\\shell explosion'] = 1.00,
        ['vehicles\\banshee\\mp_fuel rod explosion'] = 1.00,
        ['weapons\\pistol\\bullet'] = 10.0,
        ['weapons\\plasma rifle\\bolt'] = 10.0,
        ['weapons\\shotgun\\pellet'] = 10.0,
        ['weapons\\plasma pistol\\bolt'] = 10.0,
        ['weapons\\needler\\explosion'] = 10.0,
        ['weapons\\assault rifle\\bullet'] = 10.0,
        ['weapons\\needler\\impact damage'] = 10.0,
        ['weapons\\flamethrower\\explosion'] = 10.0,
        ['weapons\\sniper rifle\\sniper bullet'] = 10.0,
        ['weapons\\rocket launcher\\explosion'] = 10.0,
        ['weapons\\needler\\detonation damage'] = 10.0,
        ['weapons\\plasma rifle\\charged bolt'] = 10.0,
        ['weapons\\plasma_cannon\\effects\\plasma_cannon_melee'] = 10.0,
        ['weapons\\plasma_cannon\\effects\\plasma_cannon_explosion'] = 10.0,
        ['globals\\vehicle_collision'] = 1.00,
        ['globals\\falling'] = 1.00,
        ['globals\\distance'] = 1.00,
    }
}

local multipliers = {}

-- Utility Functions
local function GetTag(Type, Name)
    local tag = lookup_tag(Type, Name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

local function TagsToID()
    multipliers = {}
    for tag, multiplier in pairs(config.multipliers) do
        local tag_id = GetTag('jpt!', tag)
        if tag_id then
            multipliers[tag_id] = multiplier
        end
    end
end

local function setAmmo(player, ammoType, amount)
    local command = (ammoType == 'unloaded') and 'ammo' or 'mag'
    for i = 1, 4 do
        execute_command(command .. ' ' .. player .. ' ' .. amount .. ' ' .. i)
    end
end

-- Event Handlers
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then
        return
    end

    TagsToID()
    config.players = {}
    config.game_over = false
    config.weap = GetTag('weap', config.weapon)

    if not config.weap then
        unregister_callback(cb['EVENT_DIE'])
        unregister_callback(cb["EVENT_TICK"])
        unregister_callback(cb["EVENT_SPAWN"])
        unregister_callback(cb["EVENT_LEAVE"])
        unregister_callback(cb["EVENT_GAME_END"])
        unregister_callback(cb['EVENT_DAMAGE_APPLICATION'])
        return
    end

    for i = 1, 16 do
        if player_present(i) then
            config.players[i] = false
        end
    end

    if config.disable_vehicles then
        execute_command("disable_all_vehicles 0 1")
    end

    if config.disable_weapon_pickups then
        for _, weapon in ipairs({
            'weapons\\assault rifle\\assault rifle',
            'weapons\\flamethrower\\flamethrower',
            'weapons\\needler\\mp_needler',
            'weapons\\pistol\\pistol',
            'weapons\\plasma pistol\\plasma pistol',
            'weapons\\plasma rifle\\plasma rifle',
            'weapons\\plasma_cannon\\plasma_cannon',
            'weapons\\rocket launcher\\rocket launcher',
            'weapons\\shotgun\\shotgun',
            'weapons\\sniper rifle\\sniper rifle'
        }) do
            execute_command("disable_object '" .. weapon .. "'")
        end
    end

    if config.disable_grenade_pickups then
        for _, grenade in ipairs({
            'weapons\\frag grenade\\frag grenade',
            'weapons\\plasma grenade\\plasma grenade'
        }) do
            execute_command("disable_object '" .. grenade .. "'")
        end
    end

    register_callback(cb['EVENT_DIE'], "OnKill")
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_SPAWN"], "OnSpawn")
    register_callback(cb["EVENT_GAME_END"], "OnEnd")
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamage")
end

function OnEnd()
    config.game_over = true
end

function OnTick()
    if not config.game_over then
        for i, assign in pairs(config.players) do
            if player_alive(i) and assign then
                config.players[i] = false
                execute_command('wdel ' .. i)
                assign_weapon(spawn_object('', '', 0, 0, 0, 0, config.weap), i)
                setAmmo(i, 'loaded', config.starting_primary_ammo)
                setAmmo(i, 'unloaded', config.starting_secondary_ammo)
            end
        end
    end
end

function OnKill(Victim, Killer)
    if not config.game_over then
        local k, v = tonumber(Killer), tonumber(Victim)
        if k > 0 and k ~= v then
            setAmmo(k, 'loaded', config.ammo_per_kill)
        end
    end
end

function OnSpawn(playerId)
    local dynamic_player = get_dynamic_player(playerId)
    if dynamic_player ~= 0 and player_alive(playerId) then -- just in case
        config.players[playerId] = true
        execute_command('nades ' .. playerId .. ' ' .. config.starting_frags .. ' 1')
        execute_command('nades ' .. playerId .. ' ' .. config.starting_plasmas .. ' 2')
    end
end

function OnDamage(victimIndex, causerIndex, MetaID, Damage)
    if causerIndex > 0 and victimIndex ~= causerIndex and multipliers[MetaID] then
        return true, Damage * multipliers[MetaID]
    end
end

function OnQuit(playerId)
    config.players[playerId] = nil
end

function OnScriptUnload()
    -- N/A
end