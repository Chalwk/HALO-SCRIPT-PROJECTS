--[[
=====================================================================================
SCRIPT NAME:      kill_confirmed.lua
DESCRIPTION:      Modern Warfare 3-inspired team objective:
                  - Collect enemy dog tags (skulls) dropped on death
                  - First to 65 points wins
                  - Highest score wins if time expires
                  - Tags disappear after configurable delay
                  - Team scoring notifications

Copyright (c) 2019-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG STARTS -------------------------------------------------------------
local KillConfirmed = {
    messages = {
        confirm_own = "$name confirmed a kill on $victim",
        confirm_ally = "$name confirmed $killer's kill on $victim",
        deny = "$name denied $killer's kill",
        suicide = "$name committed suicide!",
        friendly_fire = "$name team-killed $victim!",
        stats = "Kills: $kills | Deaths: $deaths | Confirms: $confirms | Denies: $denies",
        top_players = "TOP PLAYERS: $list"
    },

    settings = {
        score_limit = 65,                  -- Score needed to win
        points_on_confirm = 2,             -- Points for confirming a kill
        despawn_delay = 30,                -- Seconds before dog tags disappear
        block_friendly_fire = true,         -- Prevent team damage (true/false)
        allow_commands = true              -- Enable in-game commands
    },

    dog_tag = {
        tag = "weapons\\ball\\ball",        -- Dog tag object path
    },

    server_prefix = "**KILL CONFIRMED**"    -- Server message prefix
}

-- CONFIG ENDS --------------------------------------------------------------

-- Runtime Variables --------------------------------------------------------
local players = {}          -- Active players table
local dog_tags = {}         -- Active dog tags table
local game_started = false  -- Game state flag
local time = os.time        -- Time function reference

api_version = "1.12.0.0"

-- Player Class -------------------------------------------------------------
local Player = {}
Player.__index = Player

function Player.new(id)
    local self = setmetatable({}, Player)
    self.id = id
    self.name = get_var(id, "$name")
    self.team = get_var(id, "$team")
    self.kills = 0
    self.deaths = 0
    self.confirms = 0
    self.denies = 0
    return self
end

function Player:send_message(msg)
    execute_command('msg_prefix ""')
    say(self.id, msg)
    execute_command('msg_prefix "' .. KillConfirmed.server_prefix .. '"')
end

function Player:announce(msg)
    execute_command('msg_prefix ""')
    say_all(msg)
    execute_command('msg_prefix "' .. KillConfirmed.server_prefix .. '"')
end

function Player:get_stats()
    return KillConfirmed.messages.stats
        :gsub("$kills", self.kills)
        :gsub("$deaths", self.deaths)
        :gsub("$confirms", self.confirms)
        :gsub("$denies", self.denies)
end

function Player:update_score(points)
    local current_score = tonumber(get_var(self.id, "$score"))
    execute_command("score " .. self.id .. " " .. (current_score + points))

    -- Update team score
    local team = self.team == "red" and 0 or 1
    local team_score = tonumber(get_var(0, self.team == "red" and "$redscore" or "$bluescore"))
    execute_command("team_score " .. team .. " " .. (team_score + points))
end

-- Dog Tag Class ------------------------------------------------------------
local DogTag = {}
DogTag.__index = DogTag

function DogTag.new(killer_id, victim_id)
    local self = setmetatable({}, DogTag)
    self.killer_id = killer_id
    self.victim_id = victim_id
    self.killer_name = get_var(killer_id, "$name")
    self.victim_name = get_var(victim_id, "$name")
    self.killer_team = get_var(killer_id, "$team")
    self.victim_team = get_var(victim_id, "$team")
    self.spawn_time = time()
    self.object = nil
    self:spawn()
    return self
end

function DogTag:spawn()
    local x, y, z = self:get_spawn_coordinates()
    if x then
        self.object = spawn_object('', '', x, y, z + 0.3, 0, KillConfirmed.dog_tag.id)
    end
end

function DogTag:get_spawn_coordinates()
    local dyn_player = get_dynamic_player(self.victim_id)
    if dyn_player ~= 0 then
        local vehicle_id = read_dword(dyn_player + 0x11C)
        local vehicle = get_object_memory(vehicle_id)

        if vehicle_id == 0xFFFFFFFF then
            return read_vector3d(dyn_player + 0x5C)
        elseif vehicle ~= 0 then
            return read_vector3d(vehicle + 0x5C)
        end
    end
    return nil
end

function DogTag:should_despawn()
    return (time() - self.spawn_time) >= KillConfirmed.settings.despawn_delay
end

function DogTag:destroy()
    if self.object then
        destroy_object(self.object)
    end
end

-- Main Functions -----------------------------------------------------------
local function reset_game()
    players = {}
    dog_tags = {}
    game_started = false

    for i = 1, 16 do
        if player_present(i) then
            players[i] = Player.new(i)
        end
    end
end

local function show_top_players()
    local sorted = {}
    for _, player in pairs(players) do
        table.insert(sorted, player)
    end

    table.sort(sorted, function(a, b)
        return (a.kills + a.confirms) > (b.kills + b.confirms)
    end)

    local top_list = {}
    for i = 1, math.min(3, #sorted) do
        table.insert(top_list, sorted[i].name .. " (" .. (sorted[i].kills + sorted[i].confirms) .. ")")
    end

    execute_command('msg_prefix ""')
    say_all(KillConfirmed.messages.top_players:gsub("$list", table.concat(top_list, ", ")))
    execute_command('msg_prefix "' .. KillConfirmed.server_prefix .. '"')
end

local function handle_dog_tag_collection(player_id, object)
    for i, tag in ipairs(dog_tags) do
        if tag.object == object then
            local collector = players[player_id]
            local is_confirmation = collector.team == tag.killer_team
            local is_denial = collector.team == tag.victim_team

            if is_confirmation then
                collector.confirms = collector.confirms + 1
                collector:update_score(KillConfirmed.settings.points_on_confirm)

                local msg = (player_id == tag.killer_id) and
                    KillConfirmed.messages.confirm_own or
                    KillConfirmed.messages.confirm_ally

                msg = msg:gsub("$name", collector.name)
                    :gsub("$killer", tag.killer_name)
                    :gsub("$victim", tag.victim_name)

                collector:announce(msg)
            elseif is_denial then
                collector.denies = collector.denies + 1

                local msg = KillConfirmed.messages.deny
                    :gsub("$name", collector.name)
                    :gsub("$killer", tag.killer_name)

                collector:announce(msg)
            end

            tag:destroy()
            table.remove(dog_tags, i)
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
    register_callback(cb['EVENT_GAME_END'], "OnEnd")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_DIE'], "OnDeath")
    register_callback(cb['EVENT_WEAPON_PICKUP'], "OnWeaponPickup")
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamage")
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_COMMAND'], "OnCommand")

    if get_var(0, "$gt") ~= "n/a" then
        OnStart()
    end
end

function OnStart()
    KillConfirmed.dog_tag.id = get_tag_id("weap", KillConfirmed.dog_tag.tag)
    execute_command("scorelimit " .. KillConfirmed.settings.score_limit)
    reset_game()
    game_started = true
end

function OnEnd()
    game_started = false
    for _, tag in ipairs(dog_tags) do
        tag:destroy()
    end
    dog_tags = {}
end

function OnJoin(id)
    players[id] = Player.new(id)
end

function OnQuit(id)
    players[id] = nil
end

function OnTick()
    if not game_started then return end

    -- Handle dog tag despawns
    for i = #dog_tags, 1, -1 do
        if dog_tags[i]:should_despawn() then
            dog_tags[i]:destroy()
            table.remove(dog_tags, i)
        end
    end
end

function OnDeath(victim_id, killer_id)
    if not game_started then return end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)

    local victim = players[victim_id]
    local killer = players[killer_id]
    if not victim then return end

    -- Handle suicide
    if victim_id == killer_id then
        victim:announce(KillConfirmed.messages.suicide:gsub("$name", victim.name))
        victim.deaths = victim.deaths + 1
        return
    end

    -- Handle team kill
    if killer and killer.team == victim.team then
        killer:announce(KillConfirmed.messages.friendly_fire
            :gsub("$name", killer.name)
            :gsub("$victim", victim.name))

        killer.kills = killer.kills + 1
        victim.deaths = victim.deaths + 1
        killer:update_score(-1)
        return
    end

    -- Handle enemy kill
    if killer then
        killer.kills = killer.kills + 1
        victim.deaths = victim.deaths + 1

        -- Create dog tag
        table.insert(dog_tags, DogTag.new(killer_id, victim_id))
        killer:update_score(-1) -- Temporary penalty until confirmation
    end
end

local function get_object_path(object)
    return read_string(read_dword(read_word(object) * 32 + 0x40440038)) or nil
end

function OnWeaponPickup(player_id, weapon_index, weapon_type)
    if not game_started or tonumber(weapon_type) ~= 1 then return true end

    local dyn_player = get_dynamic_player(player_id)
    if dyn_player == 0 then return true end

    local weapon = read_dword(dyn_player + 0x2F8 + (tonumber(weapon_index) - 1) * 4)
    local object = get_object_memory(weapon)
    if object == 0 then return true end

    if get_object_path(object) == KillConfirmed.dog_tag.tag then
        handle_dog_tag_collection(player_id, weapon)
    end
end

function OnDamage(victim_id, killer_id, _, _, _, _)
    if not game_started or not KillConfirmed.settings.block_friendly_fire then
        return true
    end

    victim_id = tonumber(victim_id)
    killer_id = tonumber(killer_id)

    if victim_id == killer_id then return true end

    local victim = players[victim_id]
    local killer = players[killer_id]

    if victim and killer and victim.team == killer.team then
        return false
    end

    return true
end

function OnCommand(player_id, command)
    if player_id == 0 or not KillConfirmed.settings.allow_commands then return true end

    command = command:lower()
    local player = players[player_id]
    if not player then return true end

    if command == "stats" then
        player:send_message(player:get_stats())
        return false
    elseif command == "top" then
        show_top_players()
        return false
    end

    return true
end

function OnScriptUnload()
    for _, tag in ipairs(dog_tags) do
        tag:destroy()
    end
end