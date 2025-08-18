--=====================================================================================================--
-- SCRIPT NAME:      Swat
-- DESCRIPTION:      Players spawn armed with a sniper rifle and pistol.
--                   Only headshots count for kills.
--                   First to 25 kills wins the match.
--
--                   * Other weapons and vehicles are disabled.
--                   * Powerups (like camo, overshield) are enabled.
--                   * Options for infinite ammo, bottomless clip, and grenade disabling.
--                   * Configurable default score limit.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2022 Jericho Crosby
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

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

    -- Set to false to enable grenades:
    --
    disable_grenades = true,

    -- Set the default score limit:
    --
    scorelimit = 25,

    -----------------------------------------------------------------------------
    -- E Q U I P M E N T:
    -- Remove the -- in front of the following lines to disable equipment spawning:

    --{ 'eqip', 'powerups\\health pack' },
    --{ 'eqip', 'powerups\\over shield' },
    --{ 'eqip', 'powerups\\active camouflage' },
    { 'eqip', 'weapons\\frag grenade\\frag grenade' },
    { 'eqip', 'weapons\\plasma grenade\\plasma grenade' },
    -----------------------------------------------------------------------------


    -----------------------------------------------------------------------------
    -- W E A P O N S:

    -- Add -- in front of the following lines to enable weapon spawning:

    --{ 'weap', 'weapons\\sniper rifle\\sniper rifle' },
    --{ 'weap', 'weapons\\pistol\\pistol' },
    { 'weap', 'weapons\\shotgun\\shotgun' },
    { 'weap', 'weapons\\needler\\mp_needler' },
    { 'weap', 'weapons\\flamethrower\\flamethrower' },
    { 'weap', 'weapons\\plasma rifle\\plasma rifle' },
    { 'weap', 'weapons\\plasma_cannon\\plasma_cannon' },
    { 'weap', 'weapons\\assault rifle\\assault rifle' },
    { 'weap', 'weapons\\plasma pistol\\plasma pistol' },
    { 'weap', 'weapons\\rocket launcher\\rocket launcher' },

    -----------------------------------------------------------------------------
    -- V E H I C L E S:
    -- Add -- in front of the following lines to enable Vehicle spawning:
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

local objects = {}
local players = {}
local pistol, sniper

function OnScriptLoad()

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_ALIVE'], 'UpdateAmmo')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_OBJECT_SPAWN'], 'OnObjectSpawn')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')

    OnStart()
end

local function GetTag(Class, Name)
    local Tag = lookup_tag(Class, Name)
    return Tag ~= 0 and read_dword(Tag + 0xC) or nil
end

local function TagsToID()
    local t = {}
    for i = 1, #tags do
        local class, name = tags[i][1], tags[i][2]
        local meta_id = GetTag(class, name)
        t[meta_id] = (meta_id and true) or nil
    end
    objects = t
end

function OnStart()

    if (get_var(0, '$gt') ~= 'n/a') then

        objects, players = {}, {}
        TagsToID()

        pistol = GetTag('weap', 'weapons\\pistol\\pistol')
        sniper = GetTag('weap', 'weapons\\sniper rifle\\sniper rifle')

        execute_command('scorelimit ' .. tags.scorelimit)

        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnTick()
    for i, assign in pairs(players) do

        if (player_alive(i) and assign and pistol and sniper) then

            players[i] = false

            execute_command('wdel ' .. i)
            assign_weapon(spawn_object('', '', 0, 0, 0, 0, sniper), i)
            assign_weapon(spawn_object('', '', 0, 0, 0, 0, pistol), i)

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

function OnDamage(victim, killer, _, damage, hitString)

    killer = tonumber(victim)
    victim = tonumber(killer)

    local pvp = (killer > 0 and killer ~= victim)

    if (pvp and hitString ~= 'head') then
        return false
    else
        return true, damage * 100
    end
end

function OnObjectSpawn(id, meta_id)
    if (id == 0 and objects[meta_id]) then
        return true
    end
end

function UpdateAmmo(id)
    if (tags.infinite_ammo) then
        execute_command('ammo ' .. id .. ' 999 5')
    end
    if (tags.bottomless_clip) then
        execute_command('mag ' .. id .. ' 999 5')
    end
    if (tags.disable_grenades) then
        execute_command('nades ' .. id .. ' 0')
    end
end

function OnScriptUnload()
    -- N/A
end