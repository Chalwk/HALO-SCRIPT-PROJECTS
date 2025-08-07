--=====================================================================================--
-- SCRIPT NAME:      Anti-AFK System
-- DESCRIPTION:      Monitors player activity and automatically kicks players
--                   who remain AFK (Away From Keyboard) beyond a configurable
--                   threshold. Activity includes movement, camera aim, and input.
--                   Grace period and warning messages are included before kicking.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--========================= CONFIGURATION ====================================--
local MAX_AFK_TIME = 300                     -- Maximum allowed AFK time (seconds)
local GRACE_PERIOD = 60                      -- Grace period before kicking (seconds)
local WARNING_INTERVAL = 30                  -- Warning frequency (seconds)
local AIM_THRESHOLD = 0.001                  -- Camera aim detection sensitivity
local WARNING_MESSAGE = "Warning: You will be kicked in $time_until_kick seconds for being AFK."
local KICK_MESSAGE = "Kicked for being AFK!"
local AFK_IMMUNITY = {                       -- Players exempt from AFK checks
    -- Example: ["Player1"] = true,
}
-- Configuration ends here.

api_version = "1.12.0.0"
local players = {}
local abs, clock, pairs, ipairs = math.abs, os.clock, pairs, ipairs

-- Player class definition
local Player = {}
Player.__index = Player

function Player:new(id)
    local player = setmetatable({}, Player)
    player.id = id
    player.name = get_var(id, "$name")
    player.lastActive = clock()
    player.lastWarning = 0
    player.previousCamera = {0, 0, 0}

    player.inputStates = {
        { read_float, 0x490, 0 },   -- shooting
        { read_byte, 0x2A3, 0 },    -- forward, backward, left, right, grenade throw
        { read_byte, 0x47C, 0 },    -- weapon switch
        { read_byte, 0x47E, 0 },    -- grenade switch
        { read_byte, 0x2A4, 0 },    -- weapon reload
        { read_word, 0x480, 0 },    -- zoom
        { read_word, 0x208, 0 }     -- melee, flashlight, action, crouch, jump
    }

    return player
end

function Player:broadcast(message)
    rprint(self.id, message)
end

function Player:isAFK()
    local inactiveDuration = clock() - self.lastActive
    local remainingAFKTime = MAX_AFK_TIME - inactiveDuration
    local remainingKickTime = MAX_AFK_TIME + GRACE_PERIOD - inactiveDuration

    if remainingAFKTime <= 0 then
        return true
    elseif remainingKickTime <= 0 and (clock() - self.lastWarning) >= WARNING_INTERVAL then
        local formattedMessage = WARNING_MESSAGE:gsub("$time_until_kick", abs(remainingKickTime))
        self:broadcast(formattedMessage)
        self.lastWarning = clock()
    end

    return false
end

function Player:updateCamera(cameraPosition)
    self.lastActive = clock()
    self.previousCamera = {cameraPosition[1], cameraPosition[2], cameraPosition[3]}
end

function Player:hasCameraMoved(currentCamera)
    return abs(currentCamera[1] - self.previousCamera[1]) > AIM_THRESHOLD
        or abs(currentCamera[2] - self.previousCamera[2]) > AIM_THRESHOLD
        or abs(currentCamera[3] - self.previousCamera[3]) > AIM_THRESHOLD
end

function Player:processInputs(dynamicAddress)
    for _, input in ipairs(self.inputStates) do
        local readFunc, address = input[1], input[2]
        local currentValue = readFunc(dynamicAddress + address)

        if currentValue ~= input[3] then
            self.lastActive = clock()
            input[3] = currentValue
        end
    end
end

function Player:terminate()
    execute_command("k " .. self.id .. " \"" .. KICK_MESSAGE .. "\"")
    self:broadcast(KICK_MESSAGE)
    players[self.id] = nil
end

local function getCurrentCamera(dynamicAddress)
    return {
        read_float(dynamicAddress + 0x230),
        read_float(dynamicAddress + 0x234),
        read_float(dynamicAddress + 0x238)
    }
end

-- Event handlers
function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    register_callback(cb["EVENT_CHAT"], "OnChatOrCommand")
    register_callback(cb["EVENT_COMMAND"], "OnChatOrCommand")
    OnStart()
end

function OnStart()
    players = {}
    if get_var(0, "$gt") ~= "n/a" then
        for id = 1, 16 do
            if player_present(id) then
                players[id] = Player:new(id)
            end
        end
    end
end

function OnTick()
    for id, player in pairs(players) do
        if not player or AFK_IMMUNITY[player.name] then goto continue end

        if player:isAFK() then
            player:terminate()
            goto continue
        end

        local dynamicAddress = get_dynamic_player(id)
        if dynamicAddress == 0 or not player_alive(id) then goto continue end

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

function OnChatOrCommand(id)
    if id > 0 and players[id] then
        players[id].lastActive = clock()
    end
end