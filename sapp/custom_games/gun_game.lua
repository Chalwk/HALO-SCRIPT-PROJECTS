--[[
=====================================================================================
SCRIPT NAME:      gun_game.lua
DESCRIPTION:      Competitive weapon progression mode where players advance through
                  weapon tiers by scoring kills, with the first to complete all
                  levels declared the winner.

KEY FEATURES:
                 - Progressive weapon unlocks through kills
                 - Penalties for suicides and backtaps
                 - Configurable weapon progression tiers
                 - Infinite ammo toggle
                 - Custom grenade loadouts per level
                 - Multiple end-game options
                 - Top player tracking
                 - Admin control commands

CONFIGURATION OPTIONS:
                 - Fully customizable weapon progression
                 - Adjustable starting level
                 - Infinite ammo settings
                 - End-game behavior (reset/continue/change map)
                 - Player command permissions
                 - Message templates
                 - Game object restrictions

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration ------------------------------------------------------------
local GunGame = {
    messages = {
        level_up     = "Level: $lvl/$max [$label]",        -- Message to player on level up
        max_level    = "$name is max level!",              -- Broadcast when a player reaches max level
        demoted      = "$name was demoted to level $lvl",  -- Broadcast when a player loses a level
        won          = "$name won the game!",              -- Broadcast when a player wins
        reset        = "Game reset by $name!",             -- Broadcast when game is manually reset
        stats        = "Level: $lvl/$max | Kills: $kills | Deaths: $deaths", -- Player stats format
        top_players  = "TOP PLAYERS: $list"                -- Broadcast for top players list
    },

    settings = {
        starting_level      = 1,     -- Player starting weapon level
        infinite_ammo       = true,  -- Automatically refill ammo (true/false)
        reset_on_win        = false, -- Reset levels & stats after win (true) or end game/map (false)
        reset_map_on_win    = true,  -- Change map after win (overrides reset_on_win if true)
        allow_commands      = true,  -- Allow in-game commands like /level, /top, /reset
        refill_interval     = 1      -- Seconds between ammo refills (when infinite_ammo = true)
    },

    levels = {
        -- Weapon progression list: each entry = { weapon tag path, display label, frag grenades, plasma grenades }
        { weapon = "weapons\\rocket launcher\\rocket launcher", label = "Rocket Launcher", frags = 1, plasmas = 1 },
        { weapon = "weapons\\plasma_cannon\\plasma_cannon",     label = "Plasma Cannon",   frags = 1, plasmas = 1 },
        { weapon = "weapons\\sniper rifle\\sniper rifle",       label = "Sniper Rifle",    frags = 1, plasmas = 1 },
        { weapon = "weapons\\shotgun\\shotgun",                 label = "Shotgun",         frags = 1, plasmas = 0 },
        { weapon = "weapons\\pistol\\pistol",                   label = "Pistol",          frags = 1, plasmas = 0 },
        { weapon = "weapons\\assault rifle\\assault rifle",     label = "Assault Rifle",   frags = 1, plasmas = 0 },
        { weapon = "weapons\\flamethrower\\flamethrower",       label = "Flamethrower",    frags = 0, plasmas = 1 },
        { weapon = "weapons\\needler\\mp_needler",              label = "Needler",         frags = 0, plasmas = 1 },
        { weapon = "weapons\\plasma rifle\\plasma rifle",       label = "Plasma Rifle",    frags = 0, plasmas = 1 },
        { weapon = "weapons\\plasma pistol\\plasma pistol",     label = "Plasma Pistol",   frags = 0, plasmas = 0 },
    },

    objects = {
        -- Allowed game objects (weapons, grenades, and vehicles)
        -- Any object not in this list will be disabled when game starts
        'weapons\\assault rifle\\assault rifle',
        'weapons\\flamethrower\\flamethrower',
        'weapons\\needler\\mp_needler',
        'weapons\\pistol\\pistol',
        'weapons\\plasma pistol\\plasma pistol',
        'weapons\\plasma rifle\\plasma rifle',
        'weapons\\plasma_cannon\\plasma_cannon',
        'weapons\\rocket launcher\\rocket launcher',
        'weapons\\shotgun\\shotgun',
        'weapons\\sniper rifle\\sniper rifle',

        'weapons\\frag grenade\\frag grenade',
        'weapons\\plasma grenade\\plasma grenade',

        'vehicles\\ghost\\ghost_mp',
        'vehicles\\rwarthog\\rwarthog',
        'vehicles\\banshee\\banshee_mp',
        'vehicles\\warthog\\mp_warthog',
        'vehicles\\scorpion\\scorpion_mp',
        'vehicles\\c gun turret\\c gun turret_mp',
    },

    server_prefix = "**GUN GAME**" -- Prefix shown before all server messages
}

-- Runtime Variables --------------------------------------------------------
local players = {}
local game_over = false
local weapon_ids = {}
local object_ids = {}
local last_refill_time = 0
local max_levels = #GunGame.levels

local time = os.time

api_version = "1.12.0.0"

-- Player Class -------------------------------------------------------------
local Player = {}
Player.__index = Player

function Player.new(id)
    local self = setmetatable({}, Player)
    self.id = id
    self.name = get_var(id, "$name")
    self.level = GunGame.settings.starting_level
    self.assign = true
    self.kills = 0
    self.deaths = 0
    self.weapon_obj = nil
    return self
end

function Player:level_up()
    self.level = self.level + 1
    self.kills = self.kills + 1

    if self.level >= max_levels then
        self:handle_win()
    else
        self:send_message(GunGame.messages.level_up
            :gsub("$lvl", self.level)
            :gsub("$max", max_levels)
            :gsub("$label", GunGame.levels[self.level].label))

        if self.level == #GunGame.levels then
            self:announce(GunGame.messages.max_level:gsub("$name", self.name))
        end
        self.assign = true
    end
end

function Player:level_down()
    self.level = math.max(GunGame.settings.starting_level, self.level - 1)
    self:announce(GunGame.messages.demoted
        :gsub("$name", self.name)
        :gsub("$lvl", self.level))
    self.assign = true
end

local function reset_game(initiator)
    for _, player in pairs(players) do
        player.level = GunGame.settings.starting_level
        player.assign = true
        player.kills = 0
        player.deaths = 0
    end
    game_over = false
    last_refill_time = time()

    if initiator then
        execute_command('msg_prefix ""')
        say_all(GunGame.messages.reset:gsub("$name", initiator))
        execute_command('msg_prefix "' .. GunGame.server_prefix .. '"')
    end
end

function Player:handle_win()
    self:announce(GunGame.messages.won:gsub("$name", self.name))

    if GunGame.settings.reset_on_win then
        reset_game(self.name)
    elseif GunGame.settings.reset_map_on_win then
        execute_command("sv_map_next")
    else
        game_over = true
    end
end

function Player:assign_weapon()
    local level_data = GunGame.levels[self.level]
    if not level_data then return end

    execute_command_sequence("wdel " .. self.id .. "; nades " .. self.id .. " 0")

    if level_data.frags > 0 then
        execute_command("nades " .. self.id .. " " .. level_data.frags .. " 1")
    end
    if level_data.plasmas > 0 then
        execute_command("nades " .. self.id .. " " .. level_data.plasmas .. " 2")
    end

    local weapon_id = weapon_ids[level_data.weapon]
    if weapon_id then
        self.weapon_obj = spawn_object('', '', 0, 0, 0, 0, weapon_id)
        assign_weapon(self.weapon_obj, self.id)
    end

    self.assign = false
end

function Player:send_message(msg)
    execute_command('msg_prefix ""')
    say(self.id, msg)
    execute_command('msg_prefix "' .. GunGame.server_prefix .. '"')
end

function Player:announce(msg)
    execute_command('msg_prefix ""')
    say_all(msg)
    execute_command('msg_prefix "' .. GunGame.server_prefix .. '"')
end

function Player:get_stats()
    return GunGame.messages.stats
        :gsub("$lvl", self.level)
        :gsub("$max", max_levels)
        :gsub("$kills", self.kills)
        :gsub("$deaths", self.deaths)
end

-- Main Functions -----------------------------------------------------------
local function get_tag_id(class, path)
    local tag = lookup_tag(class, path)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function cache_tag_ids()
    -- Cache weapon IDs
    for _, level in ipairs(GunGame.levels) do
        if not weapon_ids[level.weapon] then
            weapon_ids[level.weapon] = get_tag_id("weap", level.weapon)
        end
    end

    -- Cache object IDs for restriction
    for _, object in ipairs(GunGame.objects) do
        object_ids[object] = true
    end
end

local function manage_objects(enable)
    for object, _ in pairs(object_ids) do
        execute_command((enable and "enable" or "disable") .. "_object '" .. object .. "'")
    end
end

local function show_top_players()
    local sorted = {}
    for _, player in pairs(players) do
        table.insert(sorted, player)
    end

    table.sort(sorted, function(a, b)
        return a.level > b.level or (a.level == b.level and a.kills > b.kills)
    end)

    local top_list = {}
    for i = 1, math.min(3, #sorted) do
        table.insert(top_list, sorted[i].name .. " (" .. sorted[i].level .. ")")
    end

    execute_command('msg_prefix ""')
    say_all(GunGame.messages.top_players:gsub("$list", table.concat(top_list, ", ")))
    execute_command('msg_prefix "' .. GunGame.server_prefix .. '"')
end

-- Event Handlers -----------------------------------------------------------
function OnScriptLoad()
    cache_tag_ids()
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_SPAWN'], "OnSpawn")
    register_callback(cb['EVENT_DIE'], "OnDeath")
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamage")
    register_callback(cb['EVENT_OBJECT_SPAWN'], "OnObjectSpawn")
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_GAME_END'], "OnEnd")

    last_refill_time = time()

    if get_var(0, "$gt") ~= "n/a" then
        OnStart()
    end
end

function OnStart()
    cache_tag_ids()
    manage_objects(false)
    execute_command("scorelimit 99999")

    players = {}
    game_over = false
    last_refill_time = time()

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    game_over = true
    manage_objects(true)
end

function OnTick()
    if game_over then return end

    local current_time = time()

    for id, player in pairs(players) do
        if player_alive(id) then
            if player.assign then
                player:assign_weapon()
            elseif GunGame.settings.infinite_ammo then
                if current_time >= last_refill_time + GunGame.settings.refill_interval then
                    last_refill_time = current_time
                    execute_command_sequence("ammo " .. id .. " 999; battery " .. id .. " 100")
                end
            end
        end
    end
end

function OnJoin(id)
    players[id] = Player.new(id)
end

function OnQuit(id)
    players[id] = nil
end

function OnSpawn(id)
    local player = players[id]
    if player then
        player.assign = true
    end
end

function OnDeath(victim_id, killer_id)
    if game_over then return end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)

    local victim = players[victim_id]
    local killer = players[killer_id]
    if not victim then return end

    local suicide = (victim_id == killer_id)

    victim.deaths = victim.deaths + 1

    if suicide then
        victim:level_down()
    elseif killer then
        killer:level_up()
    end
end

function OnDamage(victim_id, killer_id, _, _, _, backtap)
    if game_over then return end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)

    local victim = players[victim_id]
    local killer = players[killer_id]

    if killer and victim and backtap == 1 then
        victim:level_down()
        killer:level_up()
        return true
    end
end

function OnObjectSpawn(object_id)
    local object = get_object_memory(object_id)
    if object ~= 0 then
        local tag_id = read_dword(object)
        for _, tag in pairs(weapon_ids) do
            if tag == tag_id then
                destroy_object(object_id)
                return false
            end
        end
    end
end

function OnCommand(id, command)
    if not GunGame.settings.allow_commands then return true end

    local player = players[id]
    if not player then return true end

    command = command:lower()
    if command == "level" then
        player:send_message(player:get_stats())
        return false
    elseif command == "top" then
        show_top_players()
        return false
    elseif command == "reset" and tonumber(get_var(id, "$lvl")) == 4 then
        reset_game(get_var(id, "$name"))
        return false
    end
    return true
end

function OnScriptUnload()
    manage_objects(true)
end