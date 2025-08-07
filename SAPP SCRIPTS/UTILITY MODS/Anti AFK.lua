--=====================================================================================--
-- SCRIPT NAME:      Anti-AFK System
-- DESCRIPTION:      Monitors player activity and automatically kicks players
--                   who remain AFK (Away From Keyboard) beyond a configurable
--                   threshold. Activity includes movement, camera aim, and input.
--                   Grace period and warning messages are included before kicking.
--                   Supports voluntary AFK status and admin immunity.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--========================= CONFIGURATION ====================================--
local MAX_AFK_TIME = 300    -- Maximum allowed AFK time (seconds)
local GRACE_PERIOD = 60     -- Grace period before kicking (seconds)
local WARNING_INTERVAL = 30 -- Warning frequency (seconds)
local AIM_THRESHOLD = 0.001 -- Camera aim detection sensitivity (adjust as needed)
local WARNING_MESSAGE = "Warning: You will be kicked in $time_until_kick seconds for being AFK."
local KICK_MESSAGE = "$name was kicked for being AFK!"
local AFK_IMMUNITY = { -- Admin levels with immunity
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true
}
-- Voluntary AFK
local VOLUNTARY_AFK_COMMAND = "afk" -- Command to toggle AFK status
local VOLUNTARY_AFK_ACTIVATE_MSG = "$name is AFK."
local VOLUNTARY_AFK_DEACTIVATE_MSG = "$name is no longer AFK."
-- Configuration ends here.

api_version = "1.12.0.0"
local players = {}
local abs, floor, time, pairs, ipairs = math.abs, math.floor, os.time, pairs, ipairs

-- Player class definition
local Player = {}
Player.__index = Player

function Player:new(id)
    local player = setmetatable({}, Player)

    player.id = id
    player.name = get_var(id, "$name")
    player.lastActive = time()
    player.lastWarning = 0
    player.previousCamera = { 0, 0, 0 }
    player.voluntaryAFK = false
    player.inputStatesInitialized = false

    player.immune = function()
        return AFK_IMMUNITY[tonumber(get_var(id, '$lvl'))]
    end

    player.inputStates = {
        { read_float, 0x490 }, -- shooting
        { read_byte,  0x2A3 }, -- forward, backward, left, right, grenade throw
        { read_byte,  0x47C }, -- weapon switch
        { read_byte,  0x47E }, -- grenade switch
        { read_byte,  0x2A4 }, -- weapon reload
        { read_word,  0x480 }, -- zoom
        { read_word,  0x208 } -- melee, flashlight, action, crouch, jump
    }

    player:initInputStates()
    return player
end

function Player:initInputStates()
    local dynamicAddress = get_dynamic_player(self.id)
    if dynamicAddress ~= 0 then
        for _, input in ipairs(self.inputStates) do
            input[3] = input[1](dynamicAddress + input[2])
        end
        self.inputStatesInitialized = true
    end
end

function Player:broadcast(message, public)
    local msg = message:gsub("$name", self.name)
    return public and say_all(msg) or rprint(self.id, msg)
end

-- Toggle voluntary AFK status
function Player:toggleVoluntaryAFK()
    self.voluntaryAFK = not self.voluntaryAFK
    local msg = self.voluntaryAFK and VOLUNTARY_AFK_ACTIVATE_MSG or VOLUNTARY_AFK_DEACTIVATE_MSG
    self:broadcast(msg, true)
end

-- Remove voluntary AFK status automatically
function Player:checkVoluntaryAFKActivity()
    if self.voluntaryAFK then
        self.voluntaryAFK = false
        self:broadcast(VOLUNTARY_AFK_DEACTIVATE_MSG, true)
        return true
    end
    return false
end

function Player:isAFK()
    -- Skip AFK checks if player is voluntarily AFK
    if self.voluntaryAFK then return false end

    -- Pause AFK timer when player is dead
    if not player_alive(self.id) then return false end

    local current_time = time()
    local inactiveDuration = current_time - self.lastActive
    local totalAllowed = MAX_AFK_TIME + GRACE_PERIOD

    if inactiveDuration >= totalAllowed then
        return true
    elseif inactiveDuration >= MAX_AFK_TIME then
        local timeLeft = totalAllowed - inactiveDuration
        if current_time - self.lastWarning >= WARNING_INTERVAL then
            local msg = WARNING_MESSAGE:gsub("$time_until_kick", floor(timeLeft))
            self:broadcast(msg)
            self.lastWarning = current_time
        end
    end

    return false
end

function Player:updateCamera(cameraPosition)
    self:checkVoluntaryAFKActivity()
    self.lastActive = time()
    self.previousCamera = { cameraPosition[1], cameraPosition[2], cameraPosition[3] }
end

function Player:hasCameraMoved(currentCamera)
    return abs(currentCamera[1] - self.previousCamera[1]) > AIM_THRESHOLD or
        abs(currentCamera[2] - self.previousCamera[2]) > AIM_THRESHOLD or
        abs(currentCamera[3] - self.previousCamera[3]) > AIM_THRESHOLD
end

function Player:processInputs(dynamicAddress)
    if dynamicAddress == 0 then return end

    -- Initialize input states if needed
    if not self.inputStatesInitialized then
        self:initInputStates()
        if not self.inputStatesInitialized then return end
    end

    for _, input in ipairs(self.inputStates) do
        local currentValue = input[1](dynamicAddress + input[2])

        if currentValue ~= input[3] then
            self:checkVoluntaryAFKActivity()
            self.lastActive = time()
            input[3] = currentValue
        end
    end
end

function Player:terminate()
    local kick_msg = KICK_MESSAGE:gsub("$name", self.name)
    execute_command("k " .. self.id)
    say_all(kick_msg)
    players[self.id] = nil
end

-- Helper function to get current camera position
local function getCurrentCamera(dynamicAddress)
    if dynamicAddress == 0 then return {0,0,0} end
    return {
        read_float(dynamicAddress + 0x230),
        read_float(dynamicAddress + 0x234),
        read_float(dynamicAddress + 0x238)
    }
end

-- Event handlers
function OnScriptLoad()
    register_callback(cb["EVENT_CHAT"], "OnChat")
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end

    players = {}

    for id = 1, 16 do
        if player_present(id) then
            OnJoin(id)
        end
    end
end

function OnTick()
    for id, player in pairs(players) do
        if not player or player.immune() then goto continue end

        if player:isAFK() then
            player:terminate()
            goto continue
        end

        local dynamicAddress = get_dynamic_player(id)
        if dynamicAddress == 0 then goto continue end

        player:processInputs(dynamicAddress)
        local currentCamera = getCurrentCamera(dynamicAddress)

        if player:hasCameraMoved(currentCamera) then
            player:updateCamera(currentCamera)
        end

        ::continue::
    end
end

function OnJoin(id)
    players[id] = Player:new(id)
end

function OnQuit(id)
    players[id] = nil
end

function OnCommand(id, command)
    if id > 0 and players[id] then
        players[id].lastActive = time() -- Critical reset for any command

        if command:lower() == VOLUNTARY_AFK_COMMAND then
            players[id]:toggleVoluntaryAFK()
        else
            players[id]:checkVoluntaryAFKActivity()
        end
    end
end

function OnChat(id)
    if id > 0 and players[id] then
        players[id]:checkVoluntaryAFKActivity()
        players[id].lastActive = time() -- Reset activity timer
    end
end