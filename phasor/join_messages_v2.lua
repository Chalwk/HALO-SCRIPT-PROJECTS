--[[
------------------------------------
Description: HPC AnnounceOnJoin (medium), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

-- Settings
console = { }
console.__index = console
consoletimer = registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0
SDTM_1 = "Welcome to"
SDTM_2 = ""
SDTM_3 = "Enjoy, and have fun!"
local message1 = "Warning:"
local message2 = "This server features high intensity carnage, portals, overpowered weapons and more!"
local message3 = "Type /info for help."

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)

    Server_Name = getservername()

end

function OnScriptUnload()

end

function privateSay(player, message)
    if message then
        sendconsoletext(player, message)
    end
end

function DelayMessages(id, count, player)
    if getplayer(player) then
        privatesay(player, message1, false)
        privatesay(player, message2, false)
        privatesay(player, message3, false)
    end
    return false
end

function DelayMessage(id, count, player)
    if getplayer(player) then
        privateSay(player, SDTM_1)
        privateSay(player, Server_Name)
        privateSay(player, SDTM_2)
        privateSay(player, SDTM_3)
    end
    return false
end

function OnPlayerJoin(player)
    registertimer(1000 * 10, "DelayMessage", player)
    registertimer(1000 * 5, "DelayMessages", player)
end

function OnGameEnd(mode)
    removetimer(DelayMessages)
    if mode == 1 then
        if main_message then
            main_message = nil
        end
    end
end

function sendconsoletext(player, message, time, order, align, height, func)
    if player then
        console[player] = console[player] or { }
        local temp = { }
        temp.player = player
        temp.id = nextid(player, order)
        temp.message = message or ""
        temp.time = time or 5
        temp.remain = temp.time
        temp.align = align or "center"
        temp.height = height or 0
        if type(func) == "function" then
            temp.func = func
        elseif type(func) == "string" then
            temp.func = _G[func]
        end
        console[player][temp.id] = temp
        setmetatable(console[player][temp.id], console)
        return console[player][temp.id]
    end
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