--[[
------------------------------------
Description: HPC Random Message Board, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
end
function OnNewGame(map)
    if readstring(gametype_base, 0x2C) == "RW_CTF" then
        FirstTimer = registertimer(1000, "RW_CTF_Messages")
    end
    if readstring(gametype_base, 0x2C) == "RW_TSlayer" then
        SecondTimer = registertimer(1000, "RW_TSlayer_Messages")
    end
    if readstring(gametype_base, 0x2C) == "RW_Slayer" then
        ThirdTimer = registertimer(1000, "RW_Slayer_Messages")
    end
    if readstring(gametype_base, 0x2C) == "RW_KOTH" then
        ForthTimer = registertimer(1000, "RW_KOTH_Messages")
    end
    if readstring(gametype_base, 0x2C) == "RW_Elimination" then
        FifthTimer = registertimer(1000, "RW_Elimination_Messages")
    end
end

function OnGameEnd(mode)
    if mode == 1 then
        if FirstTimer then
            FirstTimer = nil
        end
        if SecondTimer then
            SecondTimer = nil
        end
        if ThirdTimer then
            ThirdTimer = nil
        end
        if ForthTimer then
            ForthTimer = nil
        end
        if FifthTimer then
            FifthTimer = nil
        end
    end
end

function RW_CTF_Messages(id, count)
    if (count % 11) == 1 then
        say("Your messages will go here", false)

    elseif (count % 11) == (2) then
        say("Your messages will go here", false)

    elseif (count % 11) == (3) then
        say("Your messages will go here", false)

    elseif (count % 11) == (4) then
        say("Your messages will go here", false)

    elseif (count % 11) == (5) then
        say("Your messages will go here", false)

    elseif (count % 11) == (6) then
        say("Your messages will go here", false)

    elseif (count % 11) == (7) then
        say("Your messages will go here", false)

    elseif (count % 11) == (8) then
        say("Your messages will go here", false)

    elseif (count % 11) == (9) then
        say("Your messages will go here", false)

    elseif (count % 11) == (10) then
        say("Your messages will go here", false)

    elseif (count % 11) == (0) then
        say("Your messages will go here", false)
    end
    return true
end

function RW_TSlayer_Messages(id, count)
    if (count % 11) == 1 then
        say("Your messages will go here", false)

    elseif (count % 11) == (2) then
        say("Your messages will go here", false)

    elseif (count % 11) == (3) then
        say("Your messages will go here", false)

    elseif (count % 11) == (4) then
        say("Your messages will go here", false)

    elseif (count % 11) == (5) then
        say("Your messages will go here", false)

    elseif (count % 11) == (6) then
        say("Your messages will go here", false)

    elseif (count % 11) == (7) then
        say("Your messages will go here", false)

    elseif (count % 11) == (8) then
        say("Your messages will go here", false)

    elseif (count % 11) == (9) then
        say("Your messages will go here", false)

    elseif (count % 11) == (10) then
        say("Your messages will go here", false)

    elseif (count % 11) == (0) then
        say("Your messages will go here", false)
    end
    return true
end

function RW_Slayer_Messages(id, count)
    if (count % 11) == 1 then
        say("Your messages will go here", false)

    elseif (count % 11) == (2) then
        say("Your messages will go here", false)

    elseif (count % 11) == (3) then
        say("Your messages will go here", false)

    elseif (count % 11) == (4) then
        say("Your messages will go here", false)

    elseif (count % 11) == (5) then
        say("Your messages will go here", false)

    elseif (count % 11) == (6) then
        say("Your messages will go here", false)

    elseif (count % 11) == (7) then
        say("Your messages will go here", false)

    elseif (count % 11) == (8) then
        say("Your messages will go here", false)

    elseif (count % 11) == (9) then
        say("Your messages will go here", false)

    elseif (count % 11) == (10) then
        say("Your messages will go here", false)

    elseif (count % 11) == (0) then
        say("Your messages will go here", false)
    end
    return true
end

function RW_KOTH_Messages(id, count)
    if (count % 11) == 1 then
        say("Your messages will go here", false)

    elseif (count % 11) == (2) then
        say("Your messages will go here", false)

    elseif (count % 11) == (3) then
        say("Your messages will go here", false)

    elseif (count % 11) == (4) then
        say("Your messages will go here", false)

    elseif (count % 11) == (5) then
        say("Your messages will go here", false)

    elseif (count % 11) == (6) then
        say("Your messages will go here", false)

    elseif (count % 11) == (7) then
        say("Your messages will go here", false)

    elseif (count % 11) == (8) then
        say("Your messages will go here", false)

    elseif (count % 11) == (9) then
        say("Your messages will go here", false)

    elseif (count % 11) == (10) then
        say("Your messages will go here", false)

    elseif (count % 11) == (0) then
        say("Your messages will go here", false)
    end
    return true
end

function RW_Elimination_Messages(id, count)
    if (count % 11) == 1 then
        say("Your messages will go here", false)

    elseif (count % 11) == (2) then
        say("Your messages will go here", false)

    elseif (count % 11) == (3) then
        say("Your messages will go here", false)

    elseif (count % 11) == (4) then
        say("Your messages will go here", false)

    elseif (count % 11) == (5) then
        say("Your messages will go here", false)

    elseif (count % 11) == (6) then
        say("Your messages will go here", false)

    elseif (count % 11) == (7) then
        say("Your messages will go here", false)

    elseif (count % 11) == (8) then
        say("Your messages will go here", false)

    elseif (count % 11) == (9) then
        say("Your messages will go here", false)

    elseif (count % 11) == (10) then
        say("Your messages will go here", false)

    elseif (count % 11) == (0) then
        say("Your messages will go here", false)
    end
    return true
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