--[[
--=====================================================================================================--
Script Name: Chat Logging (utility), for SAPP (PC & CE)
Implementing API version: 1.11.0.0
    
Description: This script will log player chat to <sapp server>/Server Chat.txt

    Change Log:
        [+] Added Command Logging
        [+] Added Quit/Join logging
        [*] Reformatted file output so all the text aligns properly.
        [^] Separated Command/Chat logging. Commands appear in Magenta by default, and Chat in Cyan
        
Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--


api_version = "1.12.0.0"
local dir = 'sapp\\Server Chat.txt'
local timestamp = os.date("[%d/%m/%Y - %H:%M:%S]")

function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], "OnChatMessage")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
end

function OnScriptUnload() end

function OnNewGame()
    local file = io.open(dir, "a+")
    if file ~= nil then
        local map = get_var(0, "$map")
        local gt = get_var(0, "$mode")
        local n1 = "\n"
        local t1 = os.date("[%A %d %B %Y] - %X - A new game has started on " .. tostring(map) .. ", Mode: " .. tostring(gt))
        local n2 = "\n---------------------------------------------------------------------------------------------\n"
        file:write(n1, t1, n2)
        file:close()
    end
end

function OnGameEnd()
    local file = io.open(dir, "a+")
    if file ~= nil then
        local data = os.date("[%A %d %B %Y] - %X - The game is ending - ")
        file:write(data)
        file:close()
    end
end

function OnPlayerJoin(PlayerIndex)
    name = get_var(PlayerIndex, "$name")
    id = get_var(PlayerIndex, "$n")
    ip = get_var(PlayerIndex, "$ip")
    hash = get_var(PlayerIndex, "$hash")
    local file = io.open(dir, "a+")
    if file ~= nil then
        file:write(timestamp .. "    [JOIN]    Name: " .. name .. "    ID: [" .. id .. "]    IP: [" .. ip .. "]    CD-Key Hash: [" .. hash .. "]\n")
        file:close()
    end
end

function OnPlayerLeave(PlayerIndex)
    local file = io.open(dir, "a+")
    if file ~= nil then
        file:write(timestamp .. "    [QUIT]    Name: " .. name .. "    ID: [" .. id .. "]    IP: [" .. ip .. "]    CD-Key Hash: [" .. hash .. "]\n")
        file:close()
    end
end

function OnChatMessage(PlayerIndex, Message, type)
    local Message = tostring(Message)
    local Command = tokenizestring(Message)
    local name = get_var(PlayerIndex, "$name")
    iscommand = nil
    if string.sub(Command[1], 1, 1) == "/" or string.sub(Command[1], 1, 1) == "\\" then 
        iscommand = true
        chattype = "[COMMAND] "
    else 
        iscommand = false
    end
    if type == 0 then
        Type = "[GLOBAL]  "
    elseif type == 1 then
        Type = "[TEAM]    "
    elseif type == 2 then
        Type = "[VEHICLE] "
    end    
    if (player_present(PlayerIndex) ~= nil) then
        if iscommand then 
            WriteData(dir, "   " .. chattype .. "     " .. name .. " [" .. id .. "]: " .. Message)
            cprint(chattype .." " .. name .. " [" .. id .. "]: " .. Message, 3+8)
        else
            WriteData(dir, "   " .. Type .. "     " .. name .. " [" .. id .. "]: " .. Message)
            cprint(Type .." " .. name .. " [" .. id .. "]: " .. Message, 3+8)
        end
    end
    return true
end

function tokenizestring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function WriteData(dir, value)
    local file = io.open(dir, "a+")
    if file ~= nil then
        local chatValue = string.format("%s\t%s\n", timestamp, tostring(value))
        file:write(chatValue)
        file:close()
    end
end

function OnError(Message)
    print(debug.traceback())
end

--[[

SAPP will log player chat to the sapp.log file, however, it's difficult to wade through all the other event logs it handles.
Personally, I find it convenient to have a 'dedicated' server chat.txt file. Which is where this script comes into play.

]]
