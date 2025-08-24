--[[
=====================================================================================
SCRIPT NAME:      needles_galore.lua
DESCRIPTION:      Exclusive Needler combat mode featuring:
                  - All players spawn with Needlers only
                  - Comprehensive weapon/vehicle restrictions
                  - Customizable equipment settings
                  - Optional infinite ammo and bottomless clips
                  - Focused Needler-versus-Needler combat

KEY FEATURES:
                 - Forced Needler loadouts
                 - Configurable weapon restrictions
                 - Equipment management system
                 - Ammo customization options
                 - Balanced competitive environment

CONFIGURATION OPTIONS:
                 - Toggle infinite ammo
                 - Enable/disable bottomless clips
                 - Customize equipment availability
                 - Manage weapon spawns
                 - Control vehicle availability

Copyright (c) 2022 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

local tags = {

    -------------------
    -- config starts --
    -------------------

    -- Set to false to disable infinite ammo:
    --
    infinite_ammo = true,

    -- Set to false to disable bottomless clip:
    --
    bottomless_clip = true,

    -----------------------------------------------------------------------------
    -- E Q U I P M E N T:

    -- Equipment objects are enabled by default and will spawn.
    -- Remove the double hyphen on the relevant line to prevent it from spawning.
    --
    --{ 'eqip', 'powerups\\health pack' },
    --{ 'eqip', 'powerups\\over shield' },
    --{ 'eqip', 'powerups\\active camouflage' },
    --{ 'eqip', 'weapons\\frag grenade\\frag grenade' },
    --{ 'eqip', 'weapons\\plasma grenade\\plasma grenade' },
    -----------------------------------------------------------------------------


    -----------------------------------------------------------------------------
    -- W E A P O N S:

    -- Weapon objects are blocked by default and will not spawn.
    -- Prefix the relevant line with a double hyphen to allow spawning.
    --

    -- Do not remove the double hyphen from this line.
    -- This is the needler object (and the weapon you will spawn with).
    --{ 'weap', 'weapons\\needler\\mp_needler' },
    --
    { 'weap', 'weapons\\shotgun\\shotgun' },
    { 'weap', 'weapons\\sniper rifle\\sniper rifle' },
    { 'weap', 'weapons\\pistol\\pistol' },
    { 'weap', 'weapons\\flamethrower\\flamethrower' },
    { 'weap', 'weapons\\plasma rifle\\plasma rifle' },
    { 'weap', 'weapons\\plasma_cannon\\plasma_cannon' },
    { 'weap', 'weapons\\assault rifle\\assault rifle' },
    { 'weap', 'weapons\\plasma pistol\\plasma pistol' },
    { 'weap', 'weapons\\rocket launcher\\rocket launcher' },

    -----------------------------------------------------------------------------
    -- V E H I C L E S:

    -- Vehicle objects are blocked by default and will not spawn.
    -- Prefix the relevant line with a double hyphen to allow spawning.
    --
    { 'vehi', 'vehicles\\ghost\\ghost_mp' },
    { 'vehi', 'vehicles\\rwarthog\\rwarthog' },
    { 'vehi', 'vehicles\\banshee\\banshee_mp' },
    { 'vehi', 'vehicles\\warthog\\mp_warthog' },
    { 'vehi', 'vehicles\\scorpion\\scorpion_mp' },
    { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp' }

    -----------------
    -- config ends --
    -----------------
}

-- Do not touch anything below this point, unless you know what you're doing!

local needler
local objects = {}
local players = {}

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_ALIVE'], 'UpdateAmmo')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_OBJECT_SPAWN'], 'OnObjectSpawn')

    OnStart()
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function TagsToID()
    local t = {}
    for i = 1, #tags do
        local class, name = tags[i][1], tags[i][2]
        local meta_id = getTag(class, name)
        if meta_id then
            t[meta_id] = true
        end
    end

    objects = t
end

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        objects, players = {}, {}
        TagsToID()

        needler = GetTag('weap', 'weapons\\needler\\mp_needler')

        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnTick()
    for i, assign in pairs(players) do
        if (player_alive(i) and assign and needler) then
            players[i] = false
            execute_command('wdel ' .. i)

            local weapon = spawn_object('', '', 0, 0, 0, 0, needler)
            assign_weapon(weapon, i)

            UpdateAmmo(i)
        end
    end
end

function OnJoin(id)
    players[id] = false
end

function OnSpawn(id)
    players[id] = true
end

function OnQuit(id)
    players[id] = nil
end

function UpdateAmmo(id)
    if (tags.infinite_ammo) then
        execute_command('ammo ' .. id .. ' 999 5')
    end
    if (tags.bottomless_clip) then
        execute_command('mag ' .. id .. ' 999 5')
    end
end

function OnObjectSpawn(id, meta_id)
    if (id == 0 and objects[meta_id]) then
        return false
    end
end

function OnScriptUnload()
    -- N/A
end
