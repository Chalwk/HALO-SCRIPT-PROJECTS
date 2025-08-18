--[[
=====================================================================================
SCRIPT NAME:      damage_multiplier.lua
DESCRIPTION:      Set the damage multiplier of any player.
                  Command Syntax: /damage [id] [range]
                  * Use '-1' for the range definition to reset someone's multiplier.

Copyright (c) 2022-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

-- Configurations [starts]----------------------------------
local COMMAND_NAME = 'damage'
local DAMAGE_RANGE = { min = 1, max = 10 }
local REQUIRED_PERMISSION_LEVEL = 4
-- Configurations [ends]------------------------------------

local players = {}

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnPlayerJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnPlayerQuit')
    register_callback(cb['EVENT_COMMAND'], 'OnCommandReceived')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamageApplication')
    OnGameStart()
end

function OnGameStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}
        for playerId = 1, 16 do
            if player_present(playerId) then
                OnPlayerJoin(playerId)
            end
        end
    end
end

local function splitString(inputString)
    local words = {}
    for word in inputString:gmatch('([^%s]+)') do
        words[#words + 1] = word:lower()
    end
    return words
end

local function hasPermission(playerId)
    local level = tonumber(get_var(playerId, '$lvl'))
    return playerId == 0 or level >= REQUIRED_PERMISSION_LEVEL
end

local function respond(playerId, message)
    return playerId == 0 and cprint(message) or rprint(playerId, message)
end

function OnCommandReceived(playerId, command)
    local args = splitString(command)

    if args[1] == COMMAND_NAME then
        if hasPermission(playerId) then
            local targetId = args[2] and tonumber(args[2])
            local damageMultiplier = args[3] and tonumber(args[3])

            if not targetId or not player_present(targetId) then
                respond(playerId, 'Invalid player ID. Please enter a number between 1-16.')
                return false
            end

            local targetPlayer = players[targetId]

            if not damageMultiplier then
                respond(playerId, 'Please specify a damage multiplier value.')
                return false
            elseif damageMultiplier == -1 then
                targetPlayer.mult = 0
                respond(playerId, 'Resetting ' .. targetPlayer.name .. "'s damage multiplier.")
                return false
            elseif damageMultiplier < DAMAGE_RANGE.min or damageMultiplier > DAMAGE_RANGE.max then
                respond(playerId, 'Invalid range. Please enter a number between ' .. DAMAGE_RANGE.min .. ' and ' .. DAMAGE_RANGE.max .. '.')
                return false
            end

            targetPlayer.mult = damageMultiplier
            respond(playerId, 'Setting ' .. targetPlayer.name .. "'s damage multiplier to " .. damageMultiplier .. 'x.')
        else
            respond(playerId, 'You do not have permission to execute that command.')
        end

        return false
    end
end

function OnPlayerJoin(playerId)
    players[playerId] = {
        mult = 0,
        name = get_var(playerId, '$name')
    }
end

function OnPlayerQuit(playerId)
    players[playerId] = nil
end

function OnDamageApplication(_, killerId, _, damage)
    local killer = players[tonumber(killerId)]
    if killer and killer.mult ~= 0 then
        return true, damage * killer.mult
    end
end

function OnScriptUnload()
    -- No action required
end