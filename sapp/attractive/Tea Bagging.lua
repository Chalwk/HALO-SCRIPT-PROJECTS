--=====================================================================================================--
-- SCRIPT NAME:      Tea Bagging
-- DESCRIPTION:      Players are automatically t-bagged when they crouch near a corpse.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2019-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

-- CONFIGURATION --

local config = {
    enabled = true,             -- Tea Bagging feature enabled by default
    admin_level_required = 4,   -- Minimum admin level required to use commands

    messages = {
        "$attacker is lap-dancing on $victim's body!",
        "$attacker is giving $victim a one-way ticket to the ground!",
        "$attacker is practicing their dance moves on $victim!",
        "$attacker thinks $victim needs a little 'up close' attention!",
        "$attacker is trying to revive $victim with their dance skills!",
        "$attacker is making $victim their personal dance floor!",
        "$attacker is showing $victim how to 'drop it like it's hot!'",
    },

    radius = 2.5,           -- Distance from corpse to count crouch
    expire_time = 120,      -- Seconds after death to keep corpse coords
    required_crouches = 3,  -- Number of crouches to trigger t-bag
    cooldown_time = 30,     -- Seconds cooldown between triggers per player
}

-- CONFIGURATION ENDS --

local players = {}
local time = os.time
local sqrt = math.sqrt

api_version = "1.12.0.0"

-- UTILS --

-- Get a player's coordinates and dynamic object pointer
local function GetPlayerCoords(id)
    local dyn = get_dynamic_player(id)
    if dyn == 0 then return nil end
    local x, y, z = read_vector3d(dyn + 0x5C)
    return x, y, z, dyn
end

-- Calculate distance between two 3D points
local function IsInRange(x1, y1, z1, x2, y2, z2, radius)
    return sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2) <= radius
end

-- Format a random message with attacker and victim names
local function GetRandomMessage(attackerName, victimName)
    local template = config.messages[rand(1, #config.messages + 1)]
    return template:gsub("$attacker", attackerName):gsub("$victim", victimName)
end

-- Check if player is crouching
local function IsCrouching(dyn)
    if dyn == 0 then return false end
    return read_bit(dyn + 0x208, 0) == 1
end

-- Send a message to all players
local function SendGlobalMessage(msg)
    for i = 1, 16 do
        if player_present(i) then
            rprint(i, msg)
        end
    end
end

-- PLAYER DATA CLASS --

local Player = {}
Player.__index = Player

function Player.new(id)
    local self = setmetatable({}, Player)
    self.id = id
    self.name = get_var(id, "$name")
    self.death_positions = {} -- Stores {x, y, z, expire_time}
    self.crouch_count = 0
    self.last_crouch_state = false
    self.last_tbag_time = 0
    return self
end

function Player:AddDeathPosition(x, y, z)
    table.insert(self.death_positions, { x = x, y = y, z = z, expire_time = time() + config.expire_time })
end

function Player:CleanExpiredPositions()
    local now = time()
    for i = #self.death_positions, 1, -1 do
        if self.death_positions[i].expire_time < now then
            table.remove(self.death_positions, i)
        end
    end
end

-- CORE LOGIC --

local function HandleTBag(attacker, victim, deathIndex)
    local msg = GetRandomMessage(attacker.name, victim.name)
    SendGlobalMessage(msg)
    attacker.last_tbag_time = time()
    attacker.crouch_count = 0
    table.remove(victim.death_positions, deathIndex)
end

local function CheckTBagCondition(attacker, victim)
    attacker:CleanExpiredPositions()

    local ax, ay, az, aDyn = GetPlayerCoords(attacker.id)
    if not ax then return end

    for i, pos in ipairs(victim.death_positions) do
        if IsInRange(ax, ay, az, pos.x, pos.y, pos.z, config.radius) then

            local crouching = IsCrouching(aDyn)
            if crouching and not attacker.last_crouch_state then
                attacker.crouch_count = attacker.crouch_count + 1
            end
            attacker.last_crouch_state = crouching

            local time_since_last = time() - attacker.last_tbag_time
            if attacker.crouch_count >= config.required_crouches and time_since_last >= config.cooldown_time then
                HandleTBag(attacker, victim, i)
                break
            end
        end
    end
end

-- COMMAND HANDLER --

local function OnServerCommand(id, command)
    if command == "tbag toggle" then
        local access = tonumber(get_var(id, "$lvl"))
        if access and access <= config.admin_level_required then
            config.enabled = not config.enabled
            local status = config.enabled and "ENABLED" or "DISABLED"
            SendGlobalMessage("[Tea Bagging] has been " .. status .. " by " .. get_var(id, "$name"))
        else
            rprint(id, "You do not have permission to use this command.")
        end
        return false -- Prevent command from going to chat
    end
    return true -- Allow other commands
end

-- CALLBACKS --

function OnScriptLoad()
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_SPAWN"], "OnSpawn")
    register_callback(cb["EVENT_DIE"], "OnDeath")
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_COMMAND"], "OnServerCommand")

    if get_var(0, "$gt") ~= "n/a" then
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
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
    if players[id] then
        players[id].crouch_count = 0
        players[id].last_crouch_state = false
    end
end

function OnDeath(id)
    local player = players[id]
    if player then
        local x, y, z = GetPlayerCoords(id)
        if x then
            player:AddDeathPosition(x, y, z)
        end
    end
end

function OnTick()
    if not config.enabled then return end
    for attackerID, attacker in pairs(players) do
        for victimID, victim in pairs(players) do
            if attackerID ~= victimID and #victim.death_positions > 0 then
                CheckTBagCondition(attacker, victim)
            end
        end
    end
end

function OnScriptUnload() end