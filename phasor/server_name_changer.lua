--[[
------------------------------------
Description: HPC Change Server Name, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

Server_Name = "NewServerNameHere"

function GetRequiredVersion()
    return
    200
end

function OnScriptUnload()

end

function OnScriptLoad(process, game, persistent)
    Server_Name = getservername()
    if game == "PC" then
        gametype_base = 0x671340
    end
    Server_Name = getservername()
end
function OnNewGame(map)
    gametype = readbyte(gametype_base + 0x30, 0x0)
    map_name = tostring(map)
    if map_name == "bloodgulch" then
        if readstring(gametype_base, 0x2C) == "owv-c" then
            Server_Name = getservername()
            svcmd("sv_name " .. Server_Name)
        end
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