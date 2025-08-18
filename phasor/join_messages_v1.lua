-- Name: join_messages_v1.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

-- Settings
local console = {}
console.__index = console
local consoletimer = registertimer(100, "ConsoleTimer")
local phasor_sendconsoletext = sendconsoletext
local Server_Name
local SDTM_1 = "Welcome to"
local SDTM_2 = ""
local SDTM_3 = "Enjoy, and have fun!"
local message1 = "This server has no lead!"
local message2 = "Commands: /lead 1, (on) /lead 0, (off)"

-- Function to get the required version
function GetRequiredVersion()
    return 200
end

-- Function called when the script is loaded
function OnScriptLoad(processid, game, persistent)
    Server_Name = getservername()
end

-- Function called when the script is unloaded
function OnScriptUnload()
    -- No actions needed on unload
end

-- Function to send a private message to a player
local function privateSay(player, message)
    if message then
        sendconsoletext(player, message)
    end
end

-- Function to delay sending messages to a player
local function DelayMessages(id, count, player)
    if getplayer(player) then
        privateSay(player, message1)
        privateSay(player, message2)
    end
    return false
end

-- Function to delay sending the welcome message to a player
local function DelayMessage(id, count, player)
    if getplayer(player) then
        privateSay(player, SDTM_1)
        privateSay(player, Server_Name)
        privateSay(player, SDTM_2)
        privateSay(player, SDTM_3)
    end
    return false
end

-- Function called when a player joins the game
function OnPlayerJoin(player)
    registertimer(1000 * 10, "DelayMessage", player)
    registertimer(1000 * 5, "DelayMessages", player)
end

-- Function called when the game ends
function OnGameEnd(mode)
    removetimer(DelayMessages)
    if mode == 1 and main_message then
        main_message = nil
    end
end

-- Function to send console text to a player
function sendconsoletext(player, message, time, order, align, height, func)
    if player then
        console[player] = console[player] or {}
        local temp = {
            player = player,
            id = nextid(player, order),
            message = message or "",
            time = time or 5,
            remain = time or 5,
            align = align or "center",
            height = height or 0,
            func = type(func) == "function" and func or _G[func]
        }
        console[player][temp.id] = setmetatable(temp, console)
        return console[player][temp.id]
    end
end

-- Function to get the next available ID for a player
local function nextid(player, order)
    if not order then
        local x = 0
        for k in pairs(console[player]) do
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

-- Function to get a message for a player
function getmessage(player, order)
    return console[player] and console[player][order]
end

-- Function to get all messages for a player
function getmessages(player)
    return console[player]
end

-- Function to get a block of messages for a player
function getmessageblock(player, order)
    local temp = {}
    for k, v in opairs(console[player]) do
        if k >= order and k < order + 1 then
            table.insert(temp, console[player][k])
        end
    end
    return temp
end

-- Console metatable functions
function console:getmessage()
    return self.message
end

function console:append(message, reset)
    if console[self.player] and console[self.player][self.id] and getplayer(self.player) then
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

-- Timer function to handle console messages
function ConsoleTimer(id, count)
    for i in opairs(console) do
        if tonumber(i) and getplayer(i) then
            for k, v in opairs(console[i]) do
                if console[i][k].pausetime then
                    console[i][k].pausetime = console[i][k].pausetime - 0.1
                    if console[i][k].pausetime <= 0 then
                        console[i][k].pausetime = nil
                    end
                else
                    if console[i][k].func and not console[i][k].func(i) then
                        console[i][k] = nil
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
                for k in pairs(console[i]) do
                    if console[i][k].pausetime then
                        paused = paused + 1
                    end
                end
                if paused < table.len(console[i]) then
                    local str = string.rep(" \n", 30)
                    phasor_sendconsoletext(i, str)
                    for k, v in opairs(console[i]) do
                        if not console[i][k].pausetime then
                            local msg = string.sub(console[i][k].message, 1, 78)
                            if console[i][k].align == "right" or console[i][k].align == "center" then
                                phasor_sendconsoletext(i, consolecenter(msg))
                            else
                                phasor_sendconsoletext(i, msg)
                            end
                        end
                    end
                end
            end
        else
            console[i] = nil
        end
    end
    return true
end

-- Function to center console text
local function consolecenter(text)
    if text then
        return string.rep(" ", 78 - #text) .. text
    end
end

-- Function to iterate over pairs in a sorted order
local function opairs(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
            return a < b
        end
        local an, bn = string.lower(tostring(a)), string.lower(tostring(b))
        return an ~= bn and an < bn or tostring(a) < tostring(b)
    end)
    local count = 1
    return function()
        local key = keys[count]
        count = count + 1
        return key, t[key]
    end
end

-- Function to get the length of a table
function table.len(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end