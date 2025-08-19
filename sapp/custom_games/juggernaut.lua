--[[
=====================================================================================
SCRIPT NAME:      juggernaut.lua
DESCRIPTION:      Asymmetric combat mode featuring a powerful Juggernaut that
                  hunts down other players with enhanced abilities.

KEY FEATURES:
                 - Random Juggernaut selection
                 - Time-limited Juggernaut turns
                 - Enhanced Juggernaut attributes:
                   * Increased health and shields
                   * Movement speed boost
                   * Damage amplification
                   * Health regeneration
                 - Role passing on death/timeout
                 - Supports all game types

CONFIGURATION OPTIONS:
                 - Adjustable player requirements
                 - Customizable Juggernaut attributes
                 - Configurable turn duration
                 - Game start delay
                 - Server message prefix

Copyright (c) 2019-2023 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

local Juggernaut = {
    required_players = 2,
    delay = 5,
    turn_time = 120,
    prefix = '**SAPP**',
    attributes = {
        health_boost = true,
        health_percentage = 10,
        speed = true,
        speed_percentage = 1.5,
        shield = true,
        shield_percentage = 10,
        damage = true,
        damage_percentage = 10,
        health_regen = true,
        health_increment = 0.0005,
    }
}
api_version = '1.12.0.0'

local game, players, timer = nil, {}, {}
local clock, floor = os.clock, math.floor
local death_message_address, original_death_message_address, post_game_carnage_report

-- Timer class
timer.__index = timer
function timer:new()
    return setmetatable({ start_time = nil }, self)
end

function timer:start()
    self.start_time = clock()
end

function timer:stop()
    self.start_time = nil
end

function timer:get()
    return (self.start_time and clock() - self.start_time) or 0
end

-- Juggernaut class
Juggernaut.__index = Juggernaut
function Juggernaut:newPlayer(id, name)
    local player = setmetatable({
        id = id,
        name = name,
        juggernaut = nil,
        assign = false
    }, self)
    self:gameCheck()
    return player
end

function Juggernaut:setDynamicAttributes(dyn)
    local attributes = self.attributes
    if attributes.health_regen then
        self:regenHealth(dyn)
    end
    if attributes.speed then
        execute_command('s ' .. self.id .. ' ' .. attributes.speed_percentage)
    end
end

function Juggernaut:setStaticAttributes()
    local attributes = self.attributes
    if attributes.shield then
        execute_command('sh ' .. self.id .. ' ' .. attributes.shield_percentage)
    end
    if attributes.health_boost then
        execute_command('hp ' .. self.id .. ' ' .. attributes.health_percentage)
    end
end

function Juggernaut:regenHealth(dyn)
    local health = read_float(dyn + 0xE0)
    if health < 1 then
        write_float(dyn + 0xE0, health + self.attributes.health_increment)
    end
end

function Juggernaut:multiplyDamage(damage)
    if not self.juggernaut or not self.attributes.damage then
        return true, damage
    end
    return true, damage * self.attributes.damage_percentage
end

function Juggernaut:setJuggernaut()
    self.juggernaut = timer:new()
    self.juggernaut:start()
    self:setStaticAttributes()
    say(self.name .. ' is the Juggernaut!')
end

function Juggernaut:gameCheck(quit)
    if post_game_carnage_report then
        return
    end
    local count = tonumber(get_var(0, '$pn'))
    count = (quit and count - 1) or count
    if count >= self.required_players and not game then
        game = timer:new()
        game:start()
    elseif game and not game.started then
        game = nil
    end
end

-- Utility functions
local function cls(id)
    for _ = 1, 25 do
        rprint(id, ' ')
    end
end

local function say(message, tick)
    if tick then
        for i, _ in pairs(players) do
            cls(i)
            rprint(i, message)
        end
        return
    end
    execute_command('msg_prefix ""')
    say_all(message)
    execute_command('msg_prefix "' .. Juggernaut.prefix .. '"')
end

local function setRandomJuggernaut()
    local index = math.random(1, #players)
    local player = players[index]
    if player then
        player:setJuggernaut()
    end
end

local function disableDeathMessages()
    safe_write(true)
    write_dword(death_message_address, 0x03EB01B1)
    safe_write(false)
end

local function enableDeathMessages()
    safe_write(true)
    write_dword(death_message_address, original_death_message_address)
    safe_write(false)
end

local function silentKill(id)
    disableDeathMessages()
    execute_command('kill ' .. id)
    enableDeathMessages()
    local deaths = tonumber(get_var(0, '$deaths'))
    deaths = (deaths - 1 == 0 and 0 or deaths - 1)
    execute_command('deaths ' .. id .. ' ' .. deaths)
end

local function timeRemaining(delay)
    return floor(delay - game:get())
end

-- Event handlers
function OnScriptLoad()
    death_message_address = sig_scan("8B42348A8C28D500000084C9") + 3
    original_death_message_address = read_dword(death_message_address)
    register_callback(cb['EVENT_DIE'], 'onDeath')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'onDeath')
    register_callback(cb['EVENT_TICK'], 'onTick')
    register_callback(cb['EVENT_JOIN'], 'onJoin')
    register_callback(cb['EVENT_LEAVE'], 'onQuit')
    register_callback(cb['EVENT_GAME_END'], 'onEnd')
    register_callback(cb['EVENT_GAME_START'], 'onStart')
    register_callback(cb['EVENT_SPAWN'], 'onSpawn')
    onStart()
end

function onStart()
    if get_var(0, '$gt') ~= 'n/a' then
        game = nil
        post_game_carnage_report = false
        for i = 1, 16 do
            if player_present(i) then
                onJoin(i)
            end
        end
    end
end

function onEnd()
    game = nil
    post_game_carnage_report = true
end

function onTick()
    math.randomseed(os.time())
    if not game or game.started then
        for i, v in pairs(players) do
            local dyn = get_dynamic_player(i)
            if v.juggernaut and dyn ~= 0 then
                v:setDynamicAttributes(dyn)
                if v.juggernaut:get() >= v.turn_time then
                    v.juggernaut = nil
                    setRandomJuggernaut()
                    say(v.name .. ' is no longer the Juggernaut!')
                    silentKill(i)
                end
            end
        end
        return
    end
    if game:get() >= Juggernaut.delay then
        game:stop()
        game.started = true
        disableDeathMessages()
        execute_command('sv_map_reset')
        enableDeathMessages()
        setRandomJuggernaut()
    else
        say('Game will start in ' .. timeRemaining(Juggernaut.delay) .. ' seconds!', true)
    end
end

function onJoin(id)
    players[id] = Juggernaut:newPlayer(id, get_var(id, '$name'))
end

function onQuit(id)
    players[id] = nil
    Juggernaut:gameCheck(true)
end

function onSpawn(id)
    execute_command('s ' .. id .. ' 1') -- reset speed
end

function onDeath(victim, killer, meta_id, damage)
    if not game or not game.started then
        return
    end

    victim, killer = tonumber(victim), tonumber(killer)
    if killer == 0 or killer == -1 or not killer then
        return
    end

    victim, killer = players[victim], players[killer]
    if meta_id then
        return killer:multiplyDamage(damage)
    end

    if killer.id == victim.id then
        killer.juggernaut = nil
        setRandomJuggernaut()
    elseif victim.juggernaut then
        victim.juggernaut = nil
        killer:setJuggernaut()
    end
end

function OnScriptUnload()
    -- N/A
end