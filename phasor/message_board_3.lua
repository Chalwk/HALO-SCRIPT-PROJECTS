-- Name: message_board_3.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

-- Constants
local MESSAGE_INTERVAL = 1000
local MESSAGE_COUNT = 11
local GAME_TYPES = {
    RW_CTF = "RW_CTF_Messages",
    RW_TSlayer = "RW_TSlayer_Messages",
    RW_Slayer = "RW_Slayer_Messages",
    RW_KOTH = "RW_KOTH_Messages",
    RW_Elimination = "RW_Elimination_Messages"
}

-- Function to get the required version
function GetRequiredVersion()
    return 200
end

-- Function called when the script is loaded
function OnScriptLoad(processId, game, persistent)
    -- No actions needed on load
end

-- Function called when the script is unloaded
function OnScriptUnload()
    -- No actions needed on unload
end

-- Function called when a new game starts
function OnNewGame(map)
    local gameType = readstring(gametype_base, 0x2C)
    local timerFunction = GAME_TYPES[gameType]
    if timerFunction then
        _G[gameType .. "Timer"] = registertimer(MESSAGE_INTERVAL, timerFunction)
    end
end

-- Function called when the game ends
function OnGameEnd(mode)
    if mode == 1 then
        for gameType, _ in pairs(GAME_TYPES) do
            _G[gameType .. "Timer"] = nil
        end
    end
end

-- Function to handle messages for a specific game type
local function HandleMessages(id, count, messages)
    local index = (count % MESSAGE_COUNT) + 1
    say(messages[index], false)
    return true
end

-- Message functions for each game type
function RW_CTF_Messages(id, count)
    return HandleMessages(id, count, {
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here"
    })
end

function RW_TSlayer_Messages(id, count)
    return HandleMessages(id, count, {
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here"
    })
end

function RW_Slayer_Messages(id, count)
    return HandleMessages(id, count, {
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here"
    })
end

function RW_KOTH_Messages(id, count)
    return HandleMessages(id, count, {
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here"
    })
end

function RW_Elimination_Messages(id, count)
    return HandleMessages(id, count, {
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here",
        "Your messages will go here"
    })
end

-- Function to read a string from memory
function readstring(address, length, endian)
    local char_table = {}
    local str = ""
    local offset = offset or 0x0
    length = length or (readbyte(address + offset + 1) == 0 and readbyte(address + offset) ~= 0 and 51000 or 256)
    for i = 0, length do
        local byte = readbyte(address + (offset + i))
        if byte ~= 0 then
            table.insert(char_table, string.char(byte))
        elseif i % 2 == 0 and byte == 0 then
            break
        end
    end
    for _, v in pairs(char_table) do
        str = endian == 1 and v .. str or str .. v
    end
    return str
end