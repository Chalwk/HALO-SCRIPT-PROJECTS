--[[
------------------------------------
Description: HPC OnFlagInteraction (Advanced), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
stats = { }
gametypes = { }
flag_stats = { }
ctf_flag = { }
scores = { }
kills = { }
Enable_Logging = true
console = { }
console.__index = console
consoletimer = registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0

function GetRequiredVersion()
    return
    200
end

function OnScriptUnload()

end

function OnScriptLoad(processId, game, persistent)
    if game == "PC" then
        gametype_base = 0x671340
    elseif game == "CE" then
        gametype_base = 0x5F5498
    end
    gametype_game = readbyte(0x671340 + 0x30)
    team_play = readbyte(0x671340 + 0x34)
    main_timer = registertimer(500, "OnFlagInteraction")
    gametype = readbyte(gametype_base + 0x30)
    Team_Play = getteamplay()
end

function OnFlagInteraction(id, count)

    for i = 0, 15 do
        if getplayer(i) then
            local hash = gethash(i)
            if gametype == 1 then
                local captured = readword(getplayer(i) + 0xC8)
                if captured ~= flag_stats[hash].captures then
                    flag_stats[hash].captures = captured
                    -- 				* BLANK *
                    -- 				(captured) - Managed by OnClientUpdate()
                end
                local returns = readword(getplayer(i) + 0xC6)
                if returns ~= flag_stats[hash].returns then
                    local name = getname(i)
                    local player_team = getteam(i)
                    if Team_Play then
                        if player_team == 0 then
                            player_team = "the Blue Teams flag!"
                        elseif player_team == 1 then
                            player_team = "the Red Teams flag!"
                        else
                            player_team = "Hidden"
                        end
                    else
                        player_team = "the FFA"
                    end
                    flag_stats[hash].returns = returns
                    say(tostring(name) .. " returned " .. player_team, false)
                    hprintf("F L A G  -  " .. name .. " returned " .. player_team)
                    if Enable_Logging then
                        log_msg(1, tostring(name) .. " returned " .. player_team)
                    end
                end
                local grabs = readword(getplayer(i) + 0xC4)
                if grabs ~= flag_stats[hash].grabs then
                    local name = getname(i)
                    local player_team = getteam(i)
                    if Team_Play then
                        if player_team == 0 then
                            player_team = "the Blue Teams flag."
                        elseif player_team == 1 then
                            player_team = "the Red Teams flag."
                        else
                            player_team = "Hidden"
                        end
                    else
                        player_team = "the FFA"
                    end
                    flag_stats[hash].grabs = grabs
                    -- 					local m_playerObjId = getplayerobjectid(i)
                    -- 						if m_playerObjId then
                    -- 							local m_object = getobject(m_playerObjId)
                    -- 							if m_object then
                    -- 								local x,y,z = getobjectcoords(m_playerObjId)
                    -- 								local os = createobject(camouflage_tag_id, 0, 0, false, x, y, z+0.5)
                    say(tostring(name) .. " has " .. player_team .. " Kill him!", false)
                    hprintf("F L A G  -  " .. name .. " has " .. player_team .. " Kill him!")
                    if Enable_Logging then
                        log_msg(1, tostring(name) .. " GRABBED " .. player_team)
                    end
                    -- 						end
                    -- 					end
                end
            end
        end
    end
    return true
end

function OnPlayerJoin(player)
    local hash = gethash(player)
    local name = getname(player)
    if gametype == 1 then
        flag_stats[hash] = { }
        flag_stats[hash].grabs = 0
        flag_stats[hash].returns = 0
        flag_stats[hash].captures = 0
    end
    stats[hash] = { }
    gametypes[hash] = { }
    gametypes[hash].ctf = { }
    gametypes[hash].ctf.captures = 0
    gametypes[hash].ctf.returns = 0
    gametypes[hash].ctf.grabs = 0
    scores[gethash(player)] = 0
end

function getteamplay()
    if readbyte(gametype_base + 0x34) == 1 then
        return true
    else
        return false
    end
end

function OnNewGame(map)
    Team_Play = getteamplay()
    -- camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
end

function OnPlayerScore(player, score, gametype)

end

function OnClientUpdate(player)
    local name = getname(player)
    local player_team = getteam(player)
    if team_play then
        if player_team == 0 then
            player_team = "the Red Team."
        elseif player_team == 1 then
            player_team = "the Blue Team."
        else
            player_team = "Hidden"
        end
    else
        player_team = "FFA"
    end
    if gethash(player) then
        local score = getscore(player)
        if score > scores[gethash(player)] then
            OnPlayerScore(player, score, gametype_game)
            scores[gethash(player)] = score
            say(tostring(name) .. " captured a flag for " .. player_team, false)
            privatesay(player, "** SCORE **  You have: (" .. score .. ") total captures", false)
            hprintf("** SCORE **	{" .. tostring(player) .. "}   captured a flag for " .. player_team .. "\nThis player has (" .. score .. ") total captures.")
            if Enable_Logging then
                log_msg(1, tostring(name) .. " captured a flag for " .. player_team)
            end
            if Enable_Logging then
                log_msg(1, tostring(name) .. "'s total flag captures are: (" .. score .. ")")
            end
        end
    end
end

function getscore(player)
    local score = 0
    local timed = false
    if gametype_game == 1 then
        score = readword(getplayer(player) + 0xC8)
    elseif gametype_game == 2 then
        local kills = readword(getplayer(player) + 0x9C)
        local antikills = 0
        if team_play == 0 then
            antikills = readword(getplayer(player) + 0xB0)
        else
            antikills = readword(getplayer(player) + 0xAC)
        end
        score = kills - antikills
    elseif gametype_game == 3 then
        oddball_type = readbyte(0x671340 + 0x8C)
        if oddball_type == 0 or oddball_type == 1 then
            score = readdword(0x639E5C, player)
            timed = true
        else
            score = readword(getplayer(player) + 0xC8)
        end
    elseif gametype_game == 4 then
        score = readword(getplayer(player) + 0xC4)
        timed = true
    elseif gametype_game == 5 then
        score = readword(getplayer(player) + 0xC6)
    end
    if timed == true then
        score = math.floor(score / 30)
    end
    return score
end

function sendconsoletext(player, message, time, order, align, height, func)
    if player then
        console[player] = console[player] or { }
        local temp = { }
        temp.player = player
        temp.id = nextid(player, order)
        temp.message = message or ""
        temp.time = time or 3
        temp.remain = temp.time
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