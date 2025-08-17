--[[
------------------------------------
Description: HPC Death Messages, Phasor V2
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

last_damage = { }
team_change = { }
logging = true

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(process, game, persistent)
    logging = true
    for i = 0, 15 do
        if getplayer(i) then
            team_change[i] = false
        end
    end
    last_damage = { }
    team_change = { }
end

function OnNewGame(map)
    for i = 0, 15 do
        if getplayer(i) then
            team_change[i] = false
        end
    end
    last_damage = { }
    team_change = { }
end

function OnGameEnd(stage)
    if stage == 1 then
        if announce then
            removetimer(announce)
            announce = nil
        end
    end
end

function OnPlayerJoin(player)
    if getplayer(player) then
        team_change[player] = false
    end
end

function OnDamageApplication(receiving, causing, tagid, hit, backtap)
    if receiving then
        local r_object = getobject(receiving)
        if r_object then
            local receiver = objectaddrtoplayer(r_object)
            if receiver then
                local r_hash = gethash(receiver)
                local tagname, tagtype = gettaginfo(tagid)
                last_damage[r_hash] = tagname
            end
        end
    end
end

function OnPlayerSpawnEnd(player, m_objectId)
    if getplayer(player) then
        local hash = gethash(player)
        last_damage[hash] = nil
        team_change[player] = false
    end
end

----------------------------------
--  Death Messages Begin Here 	--
----------------------------------
function OnPlayerKill(killer, victim, mode, m_player)
    local response = false
    if mode == 0 then
        -- (Player x) was killed by the server.
        response = false

        local KillMessage = GenerateKillType(killslang)
        if getplayer(victim) then
            say("** DEATH **   " .. getname(victim) .. " was killed by the server.", false)
            -- On " sv_kill or \kill "
            hprintf("D  E  A  T  H     -     " .. getname(victim) .. " was killed by the server.")
        end

    elseif mode == 1 then
        -- (Player x) was killed by falling or team-change.
        response = false
        if getplayer(victim) then
            local vhash = gethash(victim)
            if not team_change[victim] then
                response = false
                if last_damage[vhash] == "globals\\distance" or last_damage[vhash] == "globals\\falling" then
                    -- Falling
                    say("** DEATH **   " .. getname(victim) .. " fell and perished!", false)
                    hprintf("D  E  A  T  H     -     " .. getname(victim) .. " fell and perished!")
                end
            else
                response = false
                say("** TEAM CHANGE ** " .. getname(victim) .. " has changed teams!", false)
                -- (Player x) changed teams.
                hprintf("T E A M   C H A N G E  " .. getname(victim) .. " has changed teams!")
                team_change[victim] = false
            end
        end
    elseif mode == 2 then
        -- (Player x) was killed by a mysterious force.
        response = false
        if getplayer(victim) then
            say("** DEATH **   " .. getname(victim) .. " was killed by a mysterious force... ", false)
            hprintf("D  E  A  T  H     -     " .. getname(victim) .. " was killed by a mysterious force...")
        end
    elseif mode == 3 then
        -- (Player x) was killed by vehicle.
        response = false
        if getplayer(victim) then
            local vhash = gethash(victim)
            say("** DEATH **   " .. getname(victim) .. " was squashed by a vehicle", false)
            hprintf("D  E  A  T  H     -     " .. getname(victim) .. " was squashed by a vehicle.")
        end
    elseif mode == 4 then
        -- (Player x) was killed by another player, killer is not always valid, victim is always valid.
        response = false
        local KillMessage = GenerateKillType(killslang)
        if getplayer(victim) then
            local vhash = gethash(victim)
            if last_damage[vhash] then
                if getplayer(killer) ~= nil then
                    if string.find(last_damage[vhash], "melee") then
                        -- Weapon Meele		
                        say("** DEATH **   " .. getname(killer) .. " smashed " .. getname(victim) .. " in the skull!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " smashed " .. getname(victim) .. " in the skull!")
                    elseif last_damage[vhash] == "globals\\distance" or last_damage[vhash] == "globals\\falling" then
                        say("** DEATH **   " .. getname(victim) .. " fell and perished!", false)
                        -- Falling
                        hprintf("D  E  A  T  H     -     " .. getname(victim) .. " fell and perished!")
                    elseif last_damage[vhash] == "globals\\vehicle_collision" then
                        -- On Vehicle Collision
                        say("** DEATH **   " .. getname(killer) .. " ran over " .. getname(victim), false)
                        -- Run Over
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " ran over " .. getname(victim))
                    elseif string.find(last_damage[vhash], "banshee") then
                        -- Banshee (General)
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a banshee.")
                    elseif last_damage[vhash] == "vehicles\\banshee\\mp_fuel rod explosion" then
                        -- Fuel Rod Explosion / Banshee
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Banshee's Fuel Rod.")
                    elseif last_damage[vhash] == "vehicles\\banshee\\banshee bolt" then
                        -- Banshee Bolt
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Banshee's Plasma Guns.")
                    elseif last_damage[vhash] == "vehicles\\c gun turret\\mp bolt" then
                        -- Turret Bolt
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with the covenant turret.")
                    elseif last_damage[vhash] == "vehicles\\ghost\\ghost bolt" then
                        -- Ghost Bolt
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with the ghost plasma guns.")
                        if logging then
                            log_msg(1, getname(killer) .. " killed " .. getname(victim) .. " with the ghost plasma guns.")
                        end
                    elseif last_damage[vhash] == "vehicles\\scorpion\\bullet" then
                        -- Scorpion Tank Bullet
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Scorpion Tank")
                    elseif last_damage[vhash] == "vehicles\\scorpion\\shell explosion" then
                        -- Scorpion tank Shell Explosion
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Sniper Rifle!")
                        if logging then
                            log_msg(1, getname(killer) .. " killed " .. getname(victim) .. " with a Sniper Rifle!")
                        end
                    elseif last_damage[vhash] == "vehicles\\warthog\\bullet" then
                        -- Warthog chain-gun bullet
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a warthog chain-gun.")
                    elseif last_damage[vhash] == "weapons\\assault rifle\\bullet" then
                        -- Assault Rifle Bullet
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with an assault rifle.")
                    elseif last_damage[vhash] == "weapons\\flamethrower\\burning" or last_damage[vhash] == "weapons\\flamethrower\\explosion" or last_damage[vhash] == "weapons\\flamethrower\\impact damage" then
                        -- Flame Thrower
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a flame-thrower.")
                    elseif last_damage[vhash] == "weapons\\frag grenade\\explosion" then
                        -- Frag Grenade Explosion
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Frag Grenade!")
                    elseif last_damage[vhash] == "weapons\\needler\\detonation damage" or last_damage[vhash] == "weapons\\needler\\explosion" or last_damage[vhash] == "weapons\\needler\\impact damage" then
                        -- Needler
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a needler.")
                    elseif last_damage[vhash] == "weapons\\pistol\\bullet" then
                        -- Pistol Bullet
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a Pistol!")
                    elseif last_damage[vhash] == "weapons\\plasma grenade\\attached" or last_damage[vhash] == "weapons\\plasma grenade\\explosion" then
                        -- Plasma Grenade
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a plasma grenade.")
                    elseif last_damage[vhash] == "weapons\\plasma pistol\\bolt" or last_damage[vhash] == "weapons\\plasma rifle\\charged bolt" then
                        -- Plasma Pistol Bolt
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a plasma pistol.")
                    elseif last_damage[vhash] == "weapons\\plasma rifle\\bolt" then
                        -- Plasma Rifle Bolt
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a plasma rifle.")
                    elseif last_damage[vhash] == "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion" or last_damage[vhash] == "weapons\\plasma_cannon\\impact damage" then
                        -- Plasma Cannon Explosion
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a fuel-rod gun.")
                    elseif last_damage[vhash] == "weapons\\rocket launcher\\explosion" then
                        -- Rocket Hog - Rocket Launcher Explosion
                        if isinvehicle(killer) then
                            -- Vehicle Weapon (RHog, Rocket Launcher)
                            say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                            hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a warthog rocket.")
                        else
                            -- Rocket Launcher (weapon)
                            say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                            hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a rocket launcher.")
                        end
                    elseif last_damage[vhash] == "weapons\\shotgun\\pellet" then
                        -- Shotgun
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a shotgun.")
                    elseif last_damage[vhash] == "weapons\\sniper rifle\\sniper bullet" then
                        -- Sniper Rifle
                        say("** DEATH **   " .. getname(killer) .. " killed " .. getname(victim) .. "!", false)
                        hprintf("D  E  A  T  H     -     " .. getname(killer) .. " killed " .. getname(victim) .. " with a sniper rifle!")
                    end
                end
            end
        end
    elseif mode == 5 then
        -- (Player x) was killed by teammate.
        response = true
        if getplayer(killer) then
            privatesay(killer, "Do not betray your Team mates!")
            hprintf("B E T R A Y     -     " .. killer .. " has been warned for betraying team mates.")
        end
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        -- S U I C I D E S --
    elseif mode == 6 then
        response = false
        if getplayer(victim) then
            local vhash = gethash(victim)
            if last_damage[vhash] then
                if last_damage[vhash] == "weapons\\frag grenade\\explosion" then
                    say(getname(victim) .. " failed to handle the Frag Grenade with care.", false)
                    -- Frag Grenade.
                    hprintf("S  U  I  C  I  D  E  " .. getname(victim) .. " failed to handle the Frag Grenade with care.")
                elseif last_damage[vhash] == "weapons\\plasma grenade\\attached" or last_damage[vhash] == "weapons\\plasma grenade\\explosion" then
                    say(getname(victim) .. " failed to handle the Plasma Grenade with care.", false)
                    -- Plasma Grenade
                    hprintf("S  U  I  C  I  D  E  " .. getname(victim) .. " failed to handle the Plasma Grenade with care.")
                end
            end
            say("* * R I P * *     " .. getname(victim) .. " has committed suicide!", false)
            -- General Suicide.
            hprintf("S  U  I  C  I  D  E  " .. getname(victim) .. " committed suicide.")
        end
    end
    return response
end

function OnTeamChange(player, old_team, new_team, relevant)
    if getplayer(player) then
        team_change[player] = true
    end
    return nil
end

function GenerateKillType(killslang)
    local killcount = #KillType
    local rand_type = getrandomnumber(1, killcount + 1)
    local kill_type = string.format("%s", KillType[rand_type])
    if kill_type then
        return kill_type
    else
        return "killed"
    end
end

function GenerateHeadSlang(head)
    local headcount = #HeadSlang
    local rand_type = getrandomnumber(1, headcount + 1)
    local head_type = string.format("%s", HeadSlang[rand_type])
    if head_type then
        return head_type
    else
        return "head"
    end
end

function GenerateHitSlang(hit)
    local hitcount = #HitSlang
    local rand_type = getrandomnumber(1, hitcount + 1)
    local hit_type = string.format("%s", HitSlang[rand_type])
    if hit_type then
        return hit_type
    else
        return "hit"
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Kill Type, Head Slang, Hit Slang.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
KillType = { "killed" }
HeadSlang = { "mouth", "skull", "head", "brains", "trap", "chops", "gob" }
HitSlang = { "smacked", "punched", "whacked", "clocked", "thumped", "slugged", "smashed", "hammered", "beat", "slapped", "bashed", "clobbered", "socked" }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEND CONSOLETEXT OVERRIDE
console = { }
console.__index = console
registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0
function sendconsoletext(player, message, time, order, align, func)
    console[player] = console[player] or { }
    local temp = { }
    temp.player = player
    temp.id = nextid(player, order)
    temp.message = message or ""
    temp.time = time or 1.3
    temp.remain = temp.time
    temp.align = align or "left"

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