--[[
--------------------------------------------------------------------------
Script Name: HPC Chat Logging, for Phasorv2

Description: This script will log player chat to halo/logs/Server Chat.txt

* Notes at the bottom of the script.

Copyright � 2016 Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--------------------------------------------------------------------------
]]-- 
function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)
    profilepath = getprofilepath()
    if game == true or game == "PC" then
        GAME = "PC"
    else
        GAME = "CE"
    end
    GetGameAddresses(GAME)
    gametype = readbyte(gametype_base + 0x30)
    Game_Mode = readstring(gametype_base, 0x2C)
    map_name = readstring(0x698F21)
    if game == "PC" then
        gametype_base = 0x671340
    elseif game == "CE" then
        gametype_base = 0x5F5498
    end
end

function OnScriptUnload()

end

Write_To_File = true

function OnServerChat(player, chattype, message)
    --[[

	Type:
	0 All chat
	1 Team chat
    2 Vehicle chat
    3 Server message
    4 Private server message

]]

    local type = nil
    if chattype == 0 then
        type = "GLOBAL"
    elseif chattype == 1 then
        type = "TEAM"
    elseif chattype == 2 then
        type = "VEHICLE"
    end

    if string.lower(tostring(message)) == "/pl" or string.lower(tostring(message)) == "\\pl" then
        return false
    end

    if player ~= nil and type ~= nil then
        local name = getname(player)
        local id = resolveplayer(player)
        hprintf("[CHAT] " .. name .. " [" .. id .. "] " .. type .. ": " .. "\"" .. message .. "\"")
        WriteLog(profilepath .. "\\logs\\Server Chat.txt", name .. " [" .. id .. "] " .. type .. ": " .. "\"" .. message .. "\"")
    end
end

function WriteLog(filename, value)
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%H:%M:%S - %d/%m/%Y")
            local line = string.format("%s\t%s\n", timestamp, tostring(value))
            file:write(line)
            file:close()
        end
    end
end

function NewLine(filename, value)
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%H:%M:%S  -  %d/%m/%Y")
            local Line0 = string.format("%s\t%s\n", timestamp, tostring(value))
            Line0 = "\n"
            Line1 = (timestamp)
            Line2 = "\n---------------------------------------------------------------------------------------------------\n"
            Line3 = "New Game, Map: " .. map_name .. ", Mode: " .. Game_Mode .. "\n"
            Line4 = "\n"
            file:write(Line0, Line1, Line2, Line3, Line4)
            file:close()
        end
    end
end

-- For better readability
function OnNewGame(Mapname)
    NewLine(profilepath .. "\\logs\\Server Chat.txt")
    map_name = Mapname
end

-- Announces when a player leaves the game and displays some additional information.
-- Displays: Name, Index ID, Port, IP, Hash and 'quit time'.
function OnPlayerLeave(player)

    local timestamp = os.date("%H:%M:%S, %d/%m/%Y:")
    local name = getname(player)
    local id = resolveplayer(player)
    local port = getport(player)
    local ip = getip(player)
    local hash = gethash(player)

    hprintf("---------------------------------------------------------------------------------------------------")
    hprintf(name .. " quit the game! - IndexID [" .. id .. "] [" .. port .. "]")
    hprintf("CD Hash: <" .. hash .. ">")
    hprintf("Time: " .. timestamp)
    hprintf("IP Address: [" .. ip .. "]")
    hprintf("---------------------------------------------------------------------------------------------------")

end

function GetGameAddresses(GAME)
    if GAME == "PC" then
        gametype_base = 0x671340
    else
        gametype_base = 0x5F5498
    end
end

function readstring(address, length, endian)
    local char_table = { }
    local string = ""
    local offset = offset or 0x0
    if length == nil then
        if readbyte(address + offset + 1) == 0 and readbyte(address + offset) ~= 0 then
            length = 51000
        else
            length = 256
        end
    end
    for i = 0, length do
        if readbyte(address + (offset + i)) ~= 0 then
            table.insert(char_table, string.char(readbyte(address + (offset + i))))
        elseif i % 2 == 0 and readbyte(address + offset + i) == 0 then
            break
        end
    end
    for k, v in pairs(char_table) do
        if endian == 1 then
            string = v .. string
        else
            string = string .. v
        end
    end
    return string
end