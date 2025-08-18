--[[
=====================================================================================
SCRIPT NAME:      shotty_snipes.lua
DESCRIPTION:      Intense close-quarters/long-range combat featuring:
                  - Exclusive shotgun and sniper rifle gameplay
                  - All other weapons and vehicles disabled
                  - Equipment (grenades/powerups) remains active
                  - Configurable weapon settings:
                    * Infinite ammo toggle
                    * Bottomless clip option
                    * Damage modifiers
                  - Map-specific weapon loadout support

Copyright (c) 2022-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

-- Configuration table for the Shotty-Snipes script
local config = {

    -- Enable or disable infinite ammo
    infinite_ammo = true,

    -- Enable or disable bottomless clip
    bottomless_clip = true,

    -- List of equipment that can be used in the game
    equipment = {
        -- Example equipment (currently commented out):
        -- { 'eqip', 'powerups\\health pack' },
        -- { 'eqip', 'powerups\\over shield' },
        -- { 'eqip', 'powerups\\active camouflage' },
        -- { 'eqip', 'weapons\\frag grenade\\frag grenade' },
        -- { 'eqip', 'weapons\\plasma grenade\\plasma grenade' },
    },

    -- List of weapons that can be used in the game
    weapons = {
        -- Example weapons (currently commented out):
        -- { 'weap', 'weapons\\shotgun\\shotgun' },
        -- { 'weap', 'weapons\\sniper rifle\\sniper rifle' },
        { 'weap', 'weapons\\pistol\\pistol' },
        { 'weap', 'weapons\\needler\\mp_needler' },
        { 'weap', 'weapons\\flamethrower\\flamethrower' },
        { 'weap', 'weapons\\plasma rifle\\plasma rifle' },
        { 'weap', 'weapons\\plasma_cannon\\plasma_cannon' },
        { 'weap', 'weapons\\assault rifle\\assault rifle' },
        { 'weap', 'weapons\\plasma pistol\\plasma pistol' },
        { 'weap', 'weapons\\rocket launcher\\rocket launcher' },
    },

    -- List of vehicles that can be used in the game
    vehicles = {
        { 'vehi', 'vehicles\\ghost\\ghost_mp' },
        { 'vehi', 'vehicles\\rwarthog\\rwarthog' },
        { 'vehi', 'vehicles\\banshee\\banshee_mp' },
        { 'vehi', 'vehicles\\warthog\\mp_warthog' },
        { 'vehi', 'vehicles\\scorpion\\scorpion_mp' },
        { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp' }
    }
}

local objects = {}
local players = {}
local shotgun, sniper

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function tagsToID()
    local t = {}
    for _, tag in ipairs(config.weapons) do
        local class, name = tag[1], tag[2]
        local meta_id = getTag(class, name)
        t[meta_id] = meta_id and true or nil
    end
    objects = t
end

local function initializeGame()
    objects, players = {}, {}
    tagsToID()
    sniper = getTag('weap', 'weapons\\sniper rifle\\sniper rifle')
    shotgun = getTag('weap', 'weapons\\shotgun\\shotgun')
    for i = 1, 16 do
        if player_present(i) then
            onPlayerJoin(i)
        end
    end
end

local function updateAmmo(id)
    if config.infinite_ammo then
        execute_command('ammo ' .. id .. ' 999 5')
    end
    if config.bottomless_clip then
        execute_command('mag ' .. id .. ' 999 5')
    end
end

function onPlayerJoin(id)
    players[id] = false
end

function onPlayerSpawn(id)
    players[id] = true
end

function onPlayerQuit(id)
    players[id] = nil
end

function onObjectSpawn(id, meta_id)
    if id == 0 and objects[meta_id] then
        return false
    end
end

function onTick()
    for id, assign in pairs(players) do
        if player_alive(id) and assign and shotgun and sniper then
            players[id] = false
            execute_command('wdel ' .. id)
            assign_weapon(spawn_object('', '', 0, 0, 0, 0, sniper), id)
            assign_weapon(spawn_object('', '', 0, 0, 0, 0, shotgun), id)
            updateAmmo(id)
        end
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'onPlayerJoin')
    register_callback(cb['EVENT_TICK'], 'onTick')
    register_callback(cb['EVENT_LEAVE'], 'onPlayerQuit')
    register_callback(cb['EVENT_SPAWN'], 'onPlayerSpawn')
    register_callback(cb['EVENT_ALIVE'], 'updateAmmo')
    register_callback(cb['EVENT_GAME_START'], 'initializeGame')
    register_callback(cb['EVENT_OBJECT_SPAWN'], 'onObjectSpawn')
    initializeGame()
end

function OnScriptUnload()
    -- N/A
end