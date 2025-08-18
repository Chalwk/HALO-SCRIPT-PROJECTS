-- Name: chat_formatter.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

-- config starts --
local chat_format = {

    -- Global Chat Format:
    [0] = "%name% [%id%]: %msg%",

    -- Team Chat Format:
    [1] = "[%name%] [%id%]: %msg%",

    -- Team Vehicle Chat Format:
    [2] = "[%name%] [%id%]: %msg%"
}

-- Messages containing these keywords will not trigger chat formatting for that message!
-- "rtv" for example, would break otherwise.
local ignore_list = {
    "rtv",
    "skip",
}
-- config ends --

function GetRequiredVersion()
    return 200
end

local gametype_base
function OnScriptLoad(_, game, _)
    if (game == "PC") then
        gametype_base = 0x671340
    else
        gametype_base = 0x5F5498
    end
end

local team_play
function OnNewGame()
    team_play = (readbyte(gametype_base + 0x34) == 1) or false
end

local function STRSplit(Str)
    local args = { }

    for Params in Str:gmatch("([^%s]+)") do
        args[#args + 1] = Params:lower()
    end

    return args
end

local function IsCommand(Str)
    return (Str[1]:sub(1, 1) == "/" or Str[1]:sub(1, 1) == "\\")
end

local gsub = string.gsub
local function SendMessage(Ply, Type, Msg)

    local name = getname(Ply)
    local id = resolveplayer(Ply)

    Msg = gsub(gsub(gsub(chat_format[Type],
            "%%name%%", name),
            "%%id%%", id),
            "%%msg%%", Msg)

    if (Type == 1 or Type == 2) then
        for i = 0, 15 do
            if getplayer(i) and (getteam(i) == getteam(Ply)) then
                privatesay(i, Msg)
            end
        end
    else
        say(Msg)
    end
end

local function Contains(KeyWord)
    for _, v in pairs(ignore_list) do
        if (v == KeyWord) then
            return true
        end
    end
    return false
end

function OnServerChat(Ply, Type, Msg)
    local str = STRSplit(Msg)
    if (not IsCommand(str) and Type ~= 4 and Type ~= 3 and not Contains(str[1])) then
        SendMessage(Ply, Type, Msg)
        return false
    end
end