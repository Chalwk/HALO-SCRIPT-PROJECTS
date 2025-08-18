starting_primary_ammo = 1
starting_secondary_ammo = 1
reset_ammo = true
running_speed = 1.25
message_time = 3
ammo_for_kill = 1
welcome_message = "Welcome to %s\n Look at the bottom left corner for your bullet count!"
console = {}
console.__index = console
registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0
ammo = {}
cur_players = 0
teamslayer = false
usedFlashlight = {}

function GetRequiredVersion()
    return 200
end

function OnScriptLoad(processid, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
    else
        GAME = "CE"
    end
    GetGameAddresses(GAME)
    if persistent == true then
        raiseerror("this script doesn't support persistance.")
    end
    welcome_message = string.format(welcome_message, getservername())
    if readbyte(0x671340 + 0x30) == 2 and readbyte(0x671340, 0x34) ~= 1 then
        teamslayer = true
    end
end

function OnScriptUnload()
end

function OnNewGame(map)
    Pistol_tag_id = gettagid("weap", "weapons\\pistol\\pistol")
    pistolshotdamage_tag_id = gettagid("jpt!", "weapons\\pistol\\bullet")
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
    healthpack_tag_id = gettagid("eqip", "powerups\\health pack")
    overshield_tag_id = gettagid("eqip", "powerups\\over shield")
end

function OnPlayerJoin(player)
    ammo[player] = {}
    ammo[player].loaded = starting_primary_ammo
    ammo[player].unloaded = starting_secondary_ammo
    privatesay(player, welcome_message)
    if teamslayer == true then
        cur_players = cur_players + 1
        check_state()
    end
end

function OnPlayerLeave(player)
    local message = getmessage(player, 1)
    if message then
        message:delete()
    end
    if teamslayer == true then
        cur_players = cur_players - 1
        check_state()
    end
end

function check_state()
    if cur_players == 1 or cur_players == 2 then
        writebyte(0x671340, 0x58, 15)
    elseif cur_players == 3 or cur_players == 4 then
        writebyte(0x671340, 0x58, 20)
    elseif cur_players == 5 or cur_players == 6 then
        writebyte(0x671340, 0x58, 25)
    elseif cur_players == 7 or cur_players == 8 then
        writebyte(0x671340, 0x58, 30)
    elseif cur_players == 9 or cur_players == 10 then
        writebyte(0x671340, 0x58, 35)
    elseif cur_players == 11 or cur_players == 12 then
        writebyte(0x671340, 0x58, 40)
    elseif cur_players == 13 or cur_players == 14 then
        writebyte(0x671340, 0x58, 45)
    elseif cur_players == 15 or cur_players == 16 then
        writebyte(0x671340, 0x58, 50)
    end
end

function OnGameEnd(stage)
    if stage == 1 then
        for i = 0, 15 do
            local message = getmessage(i, 1)
            if message then
                message:delete()
            end
        end
        if updatespeed then
            removetimer(updatespeed)
            updatespeed = nil
        end
    end
end

function stats_timer(id, count, player)
    local message = getmessage(player, 1)
    if message then
        local ammo = getammo(player, "loaded")
        message:append("Bullets: " .. tostring(ammo), true)
    end
    return true
end

function OnWeaponAssignment(player, owner_id, order, weap_id)
    if player then
        if order == 1 then
            return Pistol_tag_id
        else
            return -1
        end
    end
end

function getammo(player, type)
    if getplayer(player) then
        local m_objectId = getplayerobjectid(player)
        if m_objectId then
            local m_object = getobject(m_objectId)
            if m_object then
                local m_weaponId = readdword(m_object + 0x118)
                if m_weaponId then
                    local m_weapon = getobject(m_weaponId)
                    if m_weapon then
                        if type == "unloaded" or type == "1" then
                            local count = readdword(m_weapon + 0x2B6)
                            return count
                        elseif type == "2" or type == "loaded" then
                            local count = readdword(m_weapon + 0x2B8)
                            return count
                        end
                    end
                end
            end
        end
    end
    return 0
end

function setammo(player, type, amount)
    if getplayer(player) then
        local m_objectId = getplayerobjectid(player)
        if m_objectId then
            local m_object = getobject(m_objectId)
            if m_object then
                local m_weaponId = readdword(m_object + 0x118)
                if m_weaponId then
                    local m_weapon = getobject(m_weaponId)
                    if m_weapon then
                        if type == "unloaded" or type == "1" then
                            writedword(m_weapon + 0x2B6, tonumber(amount))
                            ammo[player].unloaded = tonumber(amount)
                        elseif type == "2" or type == "loaded" then
                            writedword(m_weapon + 0x2B8, tonumber(amount))
                            ammo[player].loaded = tonumber(amount)
                            updateammo(m_weaponId)
                        end
                    end
                end
            end
        end
    end
end

function OnPlayerKill(killer, victim, mode)
    if mode == 4 then
        if killer then
            local ammo = getammo(killer, "loaded") + ammo_for_kill
            setammo(killer, "loaded", ammo)
            sendconsoletext(killer, "Bullets: " .. tostring(ammo), message_time, 1, "left")
        end
    end
end

function OnObjectInteraction(player, objId, mapId)
    if mapId == camouflage_tag_id or mapId == healthpack_tag_id or mapId == overshield_tag_id then
        return 1
    end
    return 0
end

function OnDamageLookup(receiver, causer, mapId)
    local name, type = gettaginfo(mapId)
    local tag = tokenizestring(name, "\\")
    if tag[3] == "melee" or mapID == pistolshot_tag_id then
        if causer then
            local c_player = objectidtoplayer(causer)
            local r_player = objectidtoplayer(receiver)
            if c_player then
                if r_player then
                    if getteam(c_player) == getteam(r_player) then
                        return false
                    end
                end
                local m_player = getplayer(c_player)
                if m_player then
                    odl_multiplier(999)
                    return true
                end
            end
        end
    elseif tag[3] == "trigger" then
        local c_player = objectidtoplayer(causer)
        if c_player then
            ammo[c_player].loaded = getammo(c_player, "loaded")
        end
    end
end

function OnWeaponReload(player, objid)
    if player then
        ammo[player].loaded = getammo(player, "loaded")
        ammo[player].unloaded = getammo(player, "unloaded")
    end
end

function OnPlayerSpawnEnd(player, m_objectId)
    local m_player = getplayer(player)
    local objId = readdword(m_player, 0x34)
    local m_object = getobject(objId)
    usedFlashlight[player] = nil
    writebyte(m_object, 0x31E, 0) -- frags
    writebyte(m_object, 0x31F, 0) -- plasmas
    registertimer(100, "delay_ammo", player)
    setspeed(player, running_speed)
    local ammo = getammo(player, "loaded")
    sendconsoletext(player, "Bullets: " .. tostring(ammo), message_time, 1, "left")
end

function delay_ammo(id, count, player)
    if reset_ammo == true then
        setammo(player, "loaded", starting_primary_ammo)
        setammo(player, "unloaded", starting_secondary_ammo)
    else
        setammo(player, "loaded", ammo[player].loaded)
        setammo(player, "unloaded", ammo[player].unloaded)
    end
    return 0
end

function OnVehicleEntry(player, veh_id, seat, mapid, relevant)
    return 0
end

function OnClientUpdate(player)
    local m_objectId = getplayerobjectid(player)
    local m_object = getobject(m_objectId)
    local name = getname(player)
    local flashlight = readbyte(m_object, 0x206)
    if flashlight == 8 and not usedFlashlight[player] then
        usedFlashlight[player] = true
        registertimer(2500, "haveSpeedTimer", player)
        setspeed(player, 2.4)
    end

end

function haveSpeedTimer(id, count, player)
    setspeed(player, running_speed)
    return 0
end

function sendconsoletext(player, message, time, order, align, func)

    console[player] = console[player] or {}

    local temp = {}
    temp.player = player
    temp.id = nextid(player, order)
    temp.message = message or ""
    temp.time = time or 5
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

function GetGameAddresses(GAME)
    if GAME == "PC" then
        oddball_globals = 0x639E18
        slayer_globals = 0x63A0E8
        name_base = 0x745D4A
        specs_addr = 0x662D04
        hashcheck_addr = 0x59c280
        versioncheck_addr = 0x5152E7
        map_pointer = 0x63525c
        gametype_base = 0x671340
        gametime_base = 0x671420
        machine_pointer = 0x745BA0
        timelimit_address = 0x626630
        special_chars = 0x517D6B
        gametype_patch = 0x481F3C
        devmode_patch1 = 0x4A4DBF
        devmode_patch2 = 0x4A4E7F
        hash_duplicate_patch = 0x59C516
    else
        oddball_globals = 0x5BDEB8
        slayer_globals = 0x5BE108
        name_base = 0x6C7B6A
        specs_addr = 0x5E6E63
        hashcheck_addr = 0x530130
        versioncheck_addr = 0x4CB587
        map_pointer = 0x5B927C
        gametype_base = 0x5F5498
        gametime_base = 0x5F55BC
        machine_pointer = 0x6C7980
        timelimit_address = 0x5AA5B0
        special_chars = 0x4CE0CD
        gametype_patch = 0x45E50C
        devmode_patch1 = 0x47DF0C
        devmode_patch2 = 0x47DFBC
        hash_duplicate_patch = 0x5302E6
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

    local temp = {}

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

    local keys = {}
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