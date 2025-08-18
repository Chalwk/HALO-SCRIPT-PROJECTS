--[[
------------------------------------
Description: HPC Classic Snipers Chat Logging, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
function OnScriptUnload()

end

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)
    profilepath = getprofilepath()
end

-- Settings:
local Write_To_File = true
local Running_Speed = 1.10
if getplayer(player) then
    setspeed(player, Running_Speed)
end

function OnServerChat(player, chattype, message)
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
        hprintf("[CHAT] " .. name .. " (" .. id .. ")  " .. type .. ": " .. "\"" .. message .. "\"")
        WriteLog(profilepath .. "\\logs\\Server Chat.txt", "[" .. type .. "]: " .. name .. " (" .. id .. "):  " .. "\"" .. message .. "\"")
    end
end

function WriteLog(filename, value)
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("[%H:%M:%S - %d/%m/%Y]: ")
            local line = string.format("%s\t%s\n", timestamp, tostring(value))
            file:write(line)
            file:close()
        end
    end
end

function WriteLine(filename, value)
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%H:%M:%S  -  %d/%m/%Y")
            Line_1 = "\n"
            Line_2 = "[NEW GAME] - [" .. timestamp .. "]"
            Line_3 = "\n"
            file:write(Line_1, Line_2, Line_3)
            file:close()
        end
    end
end

function OnNewGame(Mapname)
    WriteLine(profilepath .. "\\logs\\Server Chat.txt")
end

function OnPlayerLeave(player)

    local timestamp = os.date("%H:%M:%S, %d/%m/%Y:")
    local name = getname(player)
    local id = resolveplayer(player)
    local port = getport(player)
    local ip = getip(player)
    local ping = readword(getplayer(player) + 0xDC)
    local hash = gethash(player)

    hprintf("P L A Y E R   Q U I T   T H E   G A M E")
    hprintf("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")
    hprintf(name .. " (" .. id .. ")   -   Quit The Game.")
    hprintf("IP Address: (" .. ip .. ")  Quit Time: (" .. timestamp .. ")  Player Ping: (" .. ping .. ")")
    hprintf("CD Hash: " .. hash)
    hprintf("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")
end

function cmdsplit(str)
    local subs = { }
    local sub = ""
    local ignore_quote, inquote, endquote
    for i = 1, string.len(str) do
        local bool
        local char = string.sub(str, i, i)
        if char == " " then
            if (inquote and endquote) or (not inquote and not endquote) then
                bool = true
            end
        elseif char == "\\" then
            ignore_quote = true
        elseif char == "\"" then
            if not ignore_quote then
                if not inquote then
                    inquote = true
                else
                    endquote = true
                end
            end
        end

        if char ~= "\\" then
            ignore_quote = false
        end

        if bool then
            if inquote and endquote then
                sub = string.sub(sub, 2, string.len(sub) - 1)
            end

            if sub ~= "" then
                table.insert(subs, sub)
            end
            sub = ""
            inquote = false
            endquote = false
        else
            sub = sub .. char
        end

        if i == string.len(str) then
            if string.sub(sub, 1, 1) == "\"" and string.sub(sub, string.len(sub), string.len(sub)) == "\"" then
                sub = string.sub(sub, 2, string.len(sub) - 1)
            end
            table.insert(subs, sub)
        end
    end

    local cmd = subs[1]
    local args = subs
    table.remove(args, 1)

    return cmd, args
end