--=====================================================================================================--
-- SCRIPT NAME:      Melee Attack
-- DESCRIPTION:      Players are restricted to melee combat only.
--                   Striking an opponent with the skull results in an instant kill.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2023-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

--- Configuration
local score_limit = 50
local respawn_time = 0

--- Game objects to restrict
local game_objects = {
    'eqip\\powerups\\health pack',
    'eqip\\powerups\\over shield',
    'eqip\\powerups\\active camouflage',
    'eqip\\weapons\\frag grenade\\frag grenade',
    'eqip\\weapons\\plasma grenade\\plasma grenade',
    'vehi\\vehicles\\ghost\\ghost_mp',
    'vehi\\vehicles\\rwarthog\\rwarthog',
    'vehi\\vehicles\\banshee\\banshee_mp',
    'vehi\\vehicles\\warthog\\mp_warthog',
    'vehi\\vehicles\\scorpion\\scorpion_mp',
    'vehi\\vehicles\\c gun turret\\c gun turret_mp',
    'weap\\weapons\\flag\\flag',
    'weap\\weapons\\pistol\\pistol',
    'weap\\weapons\\shotgun\\shotgun',
    'weap\\weapons\\needler\\mp_needler',
    'weap\\weapons\\flamethrower\\flamethrower',
    'weap\\weapons\\plasma rifle\\plasma rifle',
    'weap\\weapons\\sniper rifle\\sniper rifle',
    'weap\\weapons\\plasma pistol\\plasma pistol',
    'weap\\weapons\\plasma_cannon\\plasma_cannon',
    'weap\\weapons\\assault rifle\\assault rifle',
    'weap\\weapons\\rocket launcher\\rocket launcher'
}

api_version = '1.12.0.0'

-- Precomputed values
local objects = {}
local players = {}
local oddball_tag
local respawn_ticks = respawn_time * 33

local function get_tag_address(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function init_restricted_objects()
    for _, path in ipairs(game_objects) do
        local class, name = path:match('^(%a+)\\(.+)$')
        local tag = get_tag_address(class, name)
        if tag then objects[tag] = true end
    end
end

local function delete_drone(id)
    local player = players[id]
    if player and player.drone then
        destroy_object(player.drone)
        player.drone = nil
    end
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    execute_command('scorelimit ' .. score_limit)
    oddball_tag = get_tag_address('weap', 'weapons\\ball\\ball')
    objects = {}
    init_restricted_objects()

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnJoin(id)
    players[id] = { assign = false, drone = nil }
end

function OnQuit(id)
    delete_drone(id)
    players[id] = nil
end

function OnSpawn(id)
    local player = players[id]
    if player then
        player.assign = true
    end
end

function OnTick()
    for id, player in pairs(players) do
        if player and player.assign then
            local dyn = get_dynamic_player(id)
            if dyn ~= 0 and player_alive(id) then
                player.assign = false
                execute_command('wdel ' .. id)
                player.drone = spawn_object('', '', 0, 0, -9999, 0, oddball_tag)
                assign_weapon(player.drone, id)
            end
        end
    end
end

function OnWeaponDrop(id)
    delete_drone(id)
    local player = players[id]
    if player then
        player.assign = true
    end
end

function OnDeath(victim, killer)
    victim = tonumber(victim)
    if killer == 0 or killer == -1 then return end

    local player = get_player(victim)
    if player ~= 0 then
        write_dword(player + 0x2C, respawn_ticks)
    end
end

function OnObjectSpawn(_, object_id)
    if objects[object_id] then return false end
end

function OnScriptLoad()
    register_callback(cb.EVENT_DIE, 'OnDeath')
    register_callback(cb.EVENT_TICK, 'OnTick')
    register_callback(cb.EVENT_JOIN, 'OnJoin')
    register_callback(cb.EVENT_LEAVE, 'OnQuit')
    register_callback(cb.EVENT_SPAWN, 'OnSpawn')
    register_callback(cb.EVENT_GAME_START, 'OnStart')
    register_callback(cb.EVENT_WEAPON_DROP, 'OnWeaponDrop')
    register_callback(cb.EVENT_OBJECT_SPAWN, 'OnObjectSpawn')

    OnStart()
end

function OnScriptUnload() end