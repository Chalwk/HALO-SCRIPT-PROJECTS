--[[
------------------------------------
Description: HPC Countdown to Game Start (Console Version), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

-- Settings
Countdown_To_GameStart = (0)
console = { }
console.__index = console
registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0

function OnScriptUnload()

end

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)
    if GAME == "PC" then
        gametype_base = 0x671340
        map_name = readstring(0x698F21)
    elseif GAME == "CE" then
        gametype_base = 0x5F5498
        map_name = readstring(0x61D151)
    end
end

function OnNewGame(map)
    Countdown_To_GameStart = registertimer(800, "CountdownToGameStart")
    -- 700 to 800 milliseconds
    if GAME == "PC" then
        gametype_base = 0x671340
        map_name = readstring(0x698F21)
    elseif GAME == "CE" then
        gametype_base = 0x5F5498
        map_name = readstring(0x61D151)
    end
end

function OnGameEnd(stage)
    if stage == (1) then
        removetimer(Countdown_To_GameStart)
    elseif stage == (3) then
        sendconsoletext(0, "Match Loading | Get Ready!", 3)
        sendconsoletext(1, "Match Loading | Get Ready!", 3)
        sendconsoletext(2, "Match Loading | Get Ready!", 3)
        sendconsoletext(3, "Match Loading | Get Ready!", 3)
        sendconsoletext(4, "Match Loading | Get Ready!", 3)
        sendconsoletext(5, "Match Loading | Get Ready!", 3)
        sendconsoletext(6, "Match Loading | Get Ready!", 3)
        sendconsoletext(7, "Match Loading | Get Ready!", 3)
        sendconsoletext(8, "Match Loading | Get Ready!", 3)
        sendconsoletext(9, "Match Loading | Get Ready!", 3)
        sendconsoletext(10, "Match Loading | Get Ready!", 3)
        sendconsoletext(11, "Match Loading | Get Ready!", 3)
        sendconsoletext(12, "Match Loading | Get Ready!", 3)
        sendconsoletext(13, "Match Loading | Get Ready!", 3)
        sendconsoletext(14, "Match Loading | Get Ready!", 3)
        sendconsoletext(15, "Match Loading | Get Ready!", 3)
        hprintf("Match Loading | Get Ready!")
    end
end

function CountdownToGameStart(id, count)
    if count == (10) then

        sendconsoletext(0, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(1, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(2, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(3, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(4, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(5, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(6, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(7, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(8, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(9, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(10, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(11, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(12, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(13, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(14, "                                                          B  E  G  I  N !", 1)
        sendconsoletext(15, "                                                          B  E  G  I  N !", 1)
        svcmd("sv_map_reset")
        svcmd("sv_balance")
        hprintf("Match has begun!")

        if game_started then
            return false
        end
        return (0)
    else
        hprintf("Match starts in: (00:0" .. (10) - count .. ")")
        -- 			(SENDCONSOLE TEXT FORMAT): sendconsoletext(player, message, [time])
        -------------------------------------------------------------------------------------
        sendconsoletext(0, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(0, "                                                          GET READY", 0.5)
        sendconsoletext(0, "                                                    Match will start in:", 0.5)
        sendconsoletext(0, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 1 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(1, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(1, "                                                          GET READY", 0.5)
        sendconsoletext(1, "                                                    Match will start in:", 0.5)
        sendconsoletext(1, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 2 // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(2, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(2, "                                                          GET READY", 0.5)
        sendconsoletext(2, "                                                    Match will start in:", 0.5)
        sendconsoletext(2, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 3 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(3, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(3, "                                                          GET READY", 0.5)
        sendconsoletext(3, "                                                    Match will start in:", 0.5)
        sendconsoletext(3, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 4 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(4, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(4, "                                                          GET READY", 0.5)
        sendconsoletext(4, "                                                    Match will start in:", 0.5)
        sendconsoletext(4, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 5 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(5, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(5, "                                                          GET READY", 0.5)
        sendconsoletext(5, "                                                    Match will start in:", 0.5)
        sendconsoletext(5, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 6 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(6, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(6, "                                                          GET READY", 0.5)
        sendconsoletext(6, "                                                    Match will start in:", 0.5)
        sendconsoletext(6, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 7 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(7, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(7, "                                                          GET READY", 0.5)
        sendconsoletext(7, "                                                    Match will start in:", 0.5)
        sendconsoletext(7, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 8 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(8, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(8, "                                                          GET READY", 0.5)
        sendconsoletext(8, "                                                    Match will start in:", 0.5)
        sendconsoletext(8, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 9 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(9, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(9, "                                                          GET READY", 0.5)
        sendconsoletext(9, "                                                    Match will start in:", 0.5)
        sendconsoletext(9, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 10 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(10, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(10, "                                                          GET READY", 0.5)
        sendconsoletext(10, "                                                    Match will start in:", 0.5)
        sendconsoletext(10, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 11 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(11, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(11, "                                                          GET READY", 0.5)
        sendconsoletext(11, "                                                    Match will start in:", 0.5)
        sendconsoletext(11, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 12 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(12, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(12, "                                                          GET READY", 0.5)
        sendconsoletext(12, "                                                    Match will start in:", 0.5)
        sendconsoletext(12, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 13 -- // -- Countdown
        -------------------------------------------------------------------------------------
        sendconsoletext(13, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(13, "                                                          GET READY", 0.5)
        sendconsoletext(13, "                                                    Match will start in:", 0.5)
        sendconsoletext(13, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 14 --
        ------------------------- // -- Countdown------------------------------------------------------------
        sendconsoletext(14, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(14, "                                                          GET READY", 0.5)
        sendconsoletext(14, "                                                    Match will start in:", 0.5)
        sendconsoletext(14, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        -------------------------------------------------------------------------------------
        -- Player 15 -- // -- Countdown (15 is player 16)
        -------------------------------------------------------------------------------------
        sendconsoletext(15, "                                        *  *  C  O  U  N  T  D  O  W  N  *  *", 0.5)
        sendconsoletext(15, "                                                          GET READY", 0.5)
        sendconsoletext(15, "                                                    Match will start in:", 0.5)
        sendconsoletext(15, "                                                              (00:0" .. (10) - count .. ")", 0.5)
        return true
    end
end

function sendconsoletext(player, message, time, order, func)
    console[player] = console[player] or { }

    local temp = { }
    temp.player = player
    temp.id = nextid(player, order)
    temp.message = message or ""
    temp.time = time or 3
    temp.remain = temp.time

    if type(func) == "function" then
        temp.func = func
    elseif type(func) == "string" then
        temp.func = _G[func]
    end

    console[player][temp.id] = temp
    setmetatable(console[player][temp.id], console)
    return console[player][temp.id]
end

function nextid(player, order)

    if not order then
        local x = 0
        for k, v in pairs(console[player]) do
            if k > x + 1 then
                return x + 1
            end

            x = x + 1
        end

        return x + 1
    else
        local original = order
        while console[player][order] do
            order = order + 0.001
            if order == original + 0.999 then
                break
            end
        end

        return order
    end
end

function getmessage(player, order)
    if console[player] then
        if order then
            return console[player][order]
        end
    end
end

function getmessages(player)
    return console[player]
end

function getmessageblock(player, order)

    local temp = { }

    for k, v in opairs(console[player]) do
        if k >= order and k < order + 1 then
            table.insert(temp, console[player][k])
        end
    end

    return temp
end

function console:getmessage()
    return self.message
end

function console:append(message, reset)

    if console[self.player] then
        if console[self.player][self.id] then
            if getplayer(self.player) then
                if reset then
                    if reset == true then
                        console[self.player][self.id].remain = console[self.player][self.id].time
                    elseif tonumber(reset) then
                        console[self.player][self.id].time = tonumber(reset)
                        console[self.player][self.id].remain = tonumber(reset)
                    end
                end

                console[self.player][self.id].message = message or ""
                return true
            end
        end
    end
end

function console:shift(order)

    local temp = console[self.player][self.id]
    console[self.player][self.id] = console[self.player][order]
    console[self.player][order] = temp
end

function console:pause(time)

    console[self.player][self.id].pausetime = time or 5
end

function console:delete()

    console[self.player][self.id] = nil
end

function ConsoleTimer(id, count)

    for i, _ in opairs(console) do
        if tonumber(i) then
            if getplayer(i) then
                for k, v in opairs(console[i]) do
                    if console[i][k].pausetime then
                        console[i][k].pausetime = console[i][k].pausetime - 0.1
                        if console[i][k].pausetime <= 0 then
                            console[i][k].pausetime = nil
                        end
                    else
                        if console[i][k].func then
                            if not console[i][k].func(i) then
                                console[i][k] = nil
                            end
                        end

                        if console[i][k] then
                            console[i][k].remain = console[i][k].remain - 0.1
                            if console[i][k].remain <= 0 then
                                console[i][k] = nil
                            end
                        end
                    end
                end

                if table.len(console[i]) > 0 then

                    local paused = 0
                    for k, v in pairs(console[i]) do
                        if console[i][k].pausetime then
                            paused = paused + 1
                        end
                    end

                    if paused < table.len(console[i]) then
                        local str = ""
                        for i = 0, 30 do
                            str = str .. " \n"
                        end

                        phasor_sendconsoletext(i, str)

                        for k, v in opairs(console[i]) do
                            if not console[i][k].pausetime then
                                if console[i][k].align == "right" or console[i][k].align == "center" then
                                    phasor_sendconsoletext(i, consolecenter(string.sub(console[i][k].message, 1, 78)))
                                else
                                    phasor_sendconsoletext(i, string.sub(console[i][k].message, 1, 78))
                                end
                            end
                        end
                    end
                end
            else
                console[i] = nil
            end
        end
    end

    return true
end

function consolecenter(text)

    if text then
        local len = string.len(text)
        for i = len + 1, 78 do
            text = " " .. text
        end

        return text
    end
end

function opairs(t)

    local keys = { }
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys,
            function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                end
                an = string.lower(tostring(a))
                bn = string.lower(tostring(b))
                if an ~= bn then
                    return an < bn
                else
                    return tostring(a) < tostring(b)
                end
            end)
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function table.len(t)

    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end

    return count
end