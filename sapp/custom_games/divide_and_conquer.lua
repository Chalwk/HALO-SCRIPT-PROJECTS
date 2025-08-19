--[[
=====================================================================================
SCRIPT NAME:      divide_and_conquer.lua
DESCRIPTION:      Team conversion warfare mode where kills convert enemies to allies,
                  creating dynamic team shifts and strategic gameplay.

KEY FEATURES:
                 - Team conversion mechanics:
                   * Kills convert victims to killer's team
                   * Real-time team composition changes
                   * Automatic team balancing on game start
                 - Victory condition when one team is eliminated
                 - Player count-based game activation
                 - Countdown timer before match start
                 - Team switch announcements

CONFIGURATION OPTIONS:
                 - Adjustable minimum player requirement
                 - Customizable pre-game countdown
                 - Admin message prefix
                 - Team balancing controls

Copyright (c) 2023-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

--- Configuration settings for the game.
local config = {
    delay = 5,
    required_players = 3,
    prefix = '**SAPP**'
}

--- Timer Class ---
local Timer = {}
Timer.__index = Timer

function Timer:new()
    local self = setmetatable({}, Timer)
    self.start_time = nil
    return self
end

function Timer:start()
    self.start_time = os.clock()
end

function Timer:stop()
    self.start_time = nil
end

function Timer:get()
    return (self.start_time and os.clock() - self.start_time) or 0
end

--- Player Class ---
local Player = {}
Player.__index = Player

function Player:new(playerId)
    local self = setmetatable({}, Player)
    self.id = playerId
    self.team = get_var(playerId, '$team')
    return self
end

function Player:switchTeam(team)
    execute_command('st ' .. self.id .. ' ' .. team)
    self.team = team
end

--- Game Class ---
local Game = {}
Game.__index = Game

function Game:new()
    local self = setmetatable({}, Game)
    self.players = {}
    self.timer = nil
    self.started = false
    self.winner = nil
    self.death_message_address = sig_scan("8B42348A8C28D500000084C9") + 3
    self.original_death_message_address = read_dword(self.death_message_address)
    return self
end

function Game:addPlayer(playerId)
    self.players[playerId] = Player:new(playerId)
    self:checkStartCondition()
end

function Game:removePlayer(playerId)
    self.players[playerId] = nil
    self:checkStartCondition(true)
end

function Game:checkStartCondition(quit)
    local count = tonumber(get_var(0, '$pn'))
    count = (quit and count - 1) or count

    if count >= config.required_players and not self.timer then
        self.timer = Timer:new()
        self.timer:start()
    elseif self.timer and self.started then
        self:endGame()
    elseif self.timer and not self.started then
        return
    else
        self.timer = nil
    end
end

function Game:resetTimer()
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end
end

function Game:start()
    if get_var(0, '$gt') ~= 'n/a' then

        self.players = {}
        self.winner, self.started = nil, false

        execute_command('sv_tk_ban 0')
        execute_command('sv_friendly_fire 0')
        execute_command('scorelimit 99999')

        for playerId = 1, 16 do
            if player_present(playerId) then
                self:addPlayer(playerId)
            end
        end

        self:resetTimer()
    end
end

function Game:endGame()
    local reds, blues = self:getTeamCounts()
    if reds == 0 or blues == 0 then
        self.winner = (reds == 0) and 'Blue' or 'Red'
        execute_command('sv_map_next')
        self:resetTimer()
    end
end

function Game:getTeamCounts()
    local reds, blues = 0, 0
    for _, player in pairs(self.players) do
        if player.team == 'red' then
            reds = reds + 1
        else
            blues = blues + 1
        end
    end
    return reds, blues
end

local function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function Game:shuffleTeams()
    local t = {}
    for _, player in pairs(self.players) do
        table.insert(t, player)
    end
    t = shuffle(t)

    for i, player in ipairs(t) do
        local team = (i <= #t / 2) and 'red' or 'blue'
        player:switchTeam(team)
    end
end

function Game:disableDeathMessages()
    safe_write(true)
    write_dword(self.death_message_address, 0x03EB01B1)
    safe_write(false)
end

function Game:enableDeathMessages()
    safe_write(true)
    write_dword(self.death_message_address, self.original_death_message_address)
    safe_write(false)
end

local function clearScreen(playerId)
    for _ = 1, 25 do
        rprint(playerId, ' ')
    end
end

function Game:say(message, tick)

    if tick then
        for playerId, _ in pairs(self.players) do
            clearScreen(playerId)
            rprint(playerId, message)
        end
        return
    end

    execute_command('msg_prefix ""')
    say_all(message)
    execute_command('msg_prefix "' .. config.prefix .. '"')
end

function Game:onTick()
    if not self.timer or self.started then
        return
    end

    if self.timer:get() >= config.delay then
        self.timer:stop()
        self.started = true

        self:disableDeathMessages()
        execute_command('sv_map_reset')
        self:shuffleTeams()
        self:enableDeathMessages()

        self:say('Game Start!', true)
    else
        self:say('Game will start in ' .. math.floor(config.delay - self.timer:get()) .. ' seconds!', true)
    end
end

function Game:announceTeamSwitch(victimPlayer, newTeam)
    local message = string.format("%s has been switched to the %s team!", get_var(victimPlayer.id, "$name"), newTeam)
    self:say(message)
end

function Game:onDeath(victim, killer, meta_id)

    if not self.started then
        return
    end

    victim = tonumber(victim)
    killer = tonumber(killer)

    if killer == 0 or killer == -1 or not killer then
        return
    end

    local victimPlayer = self.players[victim]
    local killerPlayer = self.players[killer]

    if meta_id and killerPlayer.team == victimPlayer.team then
        return false
    end

    if killerPlayer.team == 'red' then
        victimPlayer:switchTeam('red')
        self:announceTeamSwitch(victimPlayer, 'red')
    elseif killerPlayer.team == 'blue' then
        victimPlayer:switchTeam('blue')
        self:announceTeamSwitch(victimPlayer, 'blue')
    end

    self:endGame()
end

function Game:onTeamSwitch(id)
    self.players[id].team = get_var(id, '$team')
end

--- Global Game Instance ---
local game

--- Callbacks ---
function OnScriptLoad()

    game = Game:new()

    for event, method in pairs({
        EVENT_DIE = 'onDeath',
        EVENT_DAMAGE_APPLICATION = 'onDeath',
        EVENT_TICK = 'onTick',
        EVENT_TEAM_SWITCH = 'onTeamSwitch',
        EVENT_JOIN = 'addPlayer',
        EVENT_LEAVE = 'removePlayer',
        EVENT_GAME_END = 'endGame',
        EVENT_GAME_START = 'start'
    }) do
        _G[method] = function(...) return game[method](game, ...) end
        register_callback(cb[event], method)
    end

    game:start()
end

function OnScriptUnload()
    -- N/A
end