--[[
--======================================================================================================--
Script Name: April Fools - Chat, for SAPP (PC & CE)
Description: Other players will start speaking for you....

Copyright (c) 2020-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

api_version = "1.12.0.0"

-- Config [starts]--------------------------------
local SERVER_PREFIX = "**SAPP** "
local TRIGGER_WORDS = { "that", "que" }
local REQUIRED_PERMISSION_LEVEL = 1
-- Config [ends]----------------------------------

local is_chat_modified = false

function string.split(inputString)
    local words = {}
    for word in inputString:gmatch('([^%s]+)') do
        words[#words + 1] = word
    end
    return words
end

local function isChatCommand(message)
    local firstChar = message:sub(1, 1)
    return firstChar == "/" or firstChar == "\\"
end

local function getRandomPlayer(excludedPlayerId)
    local availablePlayers = {}
    for playerId = 1, 16 do
        if player_present(playerId) and playerId ~= excludedPlayerId then
            availablePlayers[#availablePlayers + 1] = playerId
        end
    end
    return (#availablePlayers > 0) and availablePlayers[rand(1, #availablePlayers + 1)] or nil
end

local function hasPermissionToModifyChat(playerLevel)
    local hasPermission = playerLevel and playerLevel >= REQUIRED_PERMISSION_LEVEL
    is_chat_modified = hasPermission and not is_chat_modified
    return is_chat_modified
end

local function alterChatMessage(originalPlayerId, message)
    local randomPlayerId = getRandomPlayer(originalPlayerId)
    if randomPlayerId then
        local randomPlayerName = get_var(randomPlayerId, "$name")
        execute_command('msg_prefix ""')
        say_all(randomPlayerName .. ": " .. message)
        execute_command('msg_prefix "' .. SERVER_PREFIX .. '"')
        return false
    end
    return true
end

function OnChat(playerId, message, messageType)

    if messageType == 6 or isChatCommand(message) then
        return true
    end

    local playerLevel = tonumber(get_var(playerId, "$lvl"))
    local wordsInMessage = string.split(message)

    for _, word in ipairs(wordsInMessage) do
        for _, triggerWord in ipairs(TRIGGER_WORDS) do
            if word == triggerWord then
                if hasPermissionToModifyChat(playerLevel) then
                    return alterChatMessage(playerId, message)
                end
            end
        end
    end

    return true
end

function OnScriptLoad()
    register_callback(cb["EVENT_CHAT"], "OnChat")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    if get_var(0, "$gt") ~= nil then
        is_chat_modified = false
    end
end

function OnGameStart()
    if get_var(0, "$gt") ~= nil then
        is_chat_modified = false
    end
end

function OnScriptUnload()
    -- N/A
end