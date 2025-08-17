--[[
------------------------------------
Description: HPC Custom Weapon Spawns, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
--[[
function OnObjectCreationAttempt(mapid, parentid, player)

	local name, type = gettaginfo(mapid)

	if name == "weapons\\assault rifle\\assault rifle"
                    or name == "weapons\\flamethrower\\flamethrower"
                    or name == "weapons\\gravity rifle\\gravity rifle"
                    or name == "weapons\\needler\\mp_needler"
                    or name == "weapons\\plasma pistol\\plasma pistol"
                    or name == "weapons\\plasma rifle\\plasma rifle"
                    or name == "weapons\\plasma_cannon\\plasma_cannon"
                    or name == "weapons\\rocket launcher\\rocket launcher"
                    or name == "weapons\\shotgun\\shotgun" then
		return false
	end
end
]]
arifle = "weapons\\assault rifle\\assault rifle"
prifle = "weapons\\plasma rifle\\plasma rifle"
pistol = "weapons\\pistol\\pistol"
ppistol = "weapons\\plasma pistol\\plasma pistol"
needler = "weapons\\needler\\mp_needler"
shotgun = "weapons\\shotgun\\shotgun"
sniper = "weapons\\sniper rifle\\sniper rifle"
fuelrod = "weapons\\plasma_cannon\\plasma_cannon"
rocket = "weapons\\rocket launcher\\rocket launcher"
flamethrower = "weapons\\flamethrower\\flamethrower"
covspiker = "cmt\\weapons\\covenant\\spiker\\spiker"
covpr = "cmt\\weapons\\covenant\\brute_plasma_rifle\\brute plasma rifle"
covpp = "cmt\\weapons\\covenant\\brute_plasma_pistol\\brute plasma pistol"
covsmg = "cmt\\weapons\\human\\smg\\silenced smg"
covbr = "cmt\\weapons\\human\\battle_rifle\\battle_rifle_specops"
revsniper = "revolution\\weapons\\sniper\\revolution sniper"

-- Capture The Flag -------------------------------------------------------
ladrangvalley_CTF = { sniper, pistol, revsniper }
beavercreek_CTF = { sniper, pistol, nil, nil }
-------------------------------------------------
-- BLOODGULCH
bloodgulch_CTF = { sniper, pistol, fuelrod }
-------------------------------------------------
boardingaction_CTF = { prifle, fuelrod, sniper }
carousel_CTF = { pistol, arifle, nil }
chillout_CTF = { ppistol, prifle, shotgun }
damnation_CTF = { prifle, needler, flamethrower }
dangercanyon_CTF = { pistol, arifle, sniper }
deathisland_CTF = { pistol, arifle, sniper }
gephyrophobia_CTF = { pistol, arifle, sniper }
hangemhigh_CTF = { ppistol, prifle, arifle }
icefields_CTF = { prifle, arifle, sniper }
infinity_CTF = { pistol, arifle, sniper }
longest_CTF = { pistol, nil, nil }
prisoner_CTF = { pistol, shotgun, sniper }
putput_CTF = { shotgun }
ratrace_CTF = { pistol, arifle, nil }
sidewinder_CTF = { pistol, arifle, sniper }
timberland_CTF = { pistol, arifle, sniper }
wizard_CTF = { ppistol, prifle, pistol }
--------------------------------------------------------------------------

-- Slayer ----------------------------------------------------------------
ratrace_Slayer = { sniper, pistol, nil }
wizard_Slayer = { sniper, pistol, nil }
beavercreek_Slayer = { sniper, pistol, nil, nil }
bloodgulch_Slayer = { sniper, pistol, nil }
timberland_Slayer = { sniper, pistol, nil }

boardingaction_Slayer = { prifle, fuelrod, sniper, nil }
carousel_Slayer = { pistol, arifle, nil, nil }
chillout_Slayer = { ppistol, prifle, shotgun, nil }
damnation_Slayer = { prifle, needler, flamethrower, shotgun }
dangercanyon_Slayer = { pistol, arifle, sniper, rocket }
deathisland_Slayer = { pistol, arifle, sniper, rocket }
gephyrophobia_Slayer = { pistol, arifle, sniper, rocket }
hangemhigh_Slayer = { ppistol, prifle, arifle, sniper }
icefields_Slayer = { prifle, arifle, sniper, rocket }
infinity_Slayer = { pistol, arifle, sniper, rocket }
longest_Slayer = { pistol, nil, nil, nil }
prisoner_Slayer = { pistol, shotgun, sniper, nil }
putput_Slayer = { shotgun, nil, nil, nil }
sidewinder_Slayer = { pistol, arifle, sniper, rocket }
ladrangvalley_Slayer = { sniper, pistol, nil, nil }
--------------------------------------------------------------------------

-- Oddball ---------------------------------------------------------------
beavercreek_Oddball = { sniper, pistol, nil, nil }
bloodgulch_Oddball = { shotgun, nil, nil }
boardingaction_Oddball = { prifle, fuelrod, sniper }
carousel_Oddball = { pistol, arifle, nil }
chillout_Oddball = { ppistol, prifle, shotgun }
damnation_Oddball = { prifle, needler, flamethrower }
dangercanyon_Oddball = { pistol, arifle, sniper }
deathisland_Oddball = { pistol, arifle, sniper }
gephyrophobia_Oddball = { pistol, arifle, sniper }
hangemhigh_Oddball = { ppistol, prifle, arifle }
icefields_Oddball = { prifle, arifle, sniper }
infinity_Oddball = { pistol, arifle, sniper }
longest_Oddball = { pistol, nil, nil }
prisoner_Oddball = { pistol, shotgun, sniper }
putput_Oddball = { shotgun, nil, nil }
ratrace_Oddball = { pistol, arifle, nil }
sidewinder_Oddball = { pistol, arifle, sniper }
timberland_Oddball = { pistol, arifle, sniper }
wizard_Oddball = { ppistol, prifle, pistol }
ladrangvalley_Oddball = { sniper, pistol, nil, nil }
--------------------------------------------------------------------------

-- King Of The Hill ------------------------------------------------------
beavercreek_KOTH = { sniper, pistol, nil, nil }
bloodgulch_KOTH = { flamethrower, nil, nil, nil }
boardingaction_KOTH = { prifle, fuelrod, sniper, nil }
carousel_KOTH = { pistol, arifle, nil, nil }
chillout_KOTH = { ppistol, prifle, shotgun, nil }
damnation_KOTH = { prifle, needler, flamethrower, shotgun }
dangercanyon_KOTH = { pistol, arifle, sniper, rocket }
deathisland_KOTH = { pistol, arifle, sniper, rocket }
gephyrophobia_KOTH = { pistol, arifle, sniper, rocket }
hangemhigh_KOTH = { ppistol, prifle, arifle, sniper }
icefields_KOTH = { prifle, arifle, sniper, rocket }
infinity_KOTH = { pistol, arifle, sniper, rocket }
longest_KOTH = { pistol, nil, nil, nil }
prisoner_KOTH = { pistol, shotgun, sniper, nil }
putput_KOTH = { shotgun, nil, nil, nil }
ratrace_KOTH = { pistol, arifle, nil, nil }
sidewinder_KOTH = { pistol, arifle, sniper, rocket }
timberland_KOTH = { pistol, arifle, sniper, rocket }
wizard_KOTH = { ppistol, prifle, pistol, nil }
ladrangvalley_KOTH = { sniper, pistol, nil, nil }
--------------------------------------------------------------------------

-- Race ------------------------------------------------------------------
beavercreek_Race = { sniper, pistol, nil, nil }
bloodgulch_Race = { pistol, nil, nil, nil }
boardingaction_Race = { prifle, fuelrod, sniper, nil }
carousel_Race = { pistol, arifle, nil, nil }
chillout_Race = { ppistol, prifle, shotgun, nil }
damnation_Race = { prifle, needler, flamethrower, shotgun }
dangercanyon_Race = { pistol, arifle, sniper, rocket }
deathisland_Race = { pistol, arifle, sniper, rocket }
gephyrophobia_Race = { pistol, arifle, sniper, rocket }
hangemhigh_Race = { ppistol, prifle, arifle, sniper }
icefields_Race = { prifle, arifle, sniper, rocket }
infinity_Race = { pistol, arifle, sniper, rocket }
longest_Race = { pistol, nil, nil, nil }
prisoner_Race = { pistol, shotgun, sniper, nil }
putput_Race = { shotgun, nil, nil, nil }
ratrace_Race = { pistol, arifle, nil, nil }
sidewinder_Race = { pistol, arifle, sniper, rocket }
timberland_Race = { pistol, arifle, sniper, rocket }
wizard_Race = { ppistol, prifle, pistol, nil }
ladrangvalley_Race = { sniper, pistol, nil, nil }
--------------------------------------------------------------------------

CTF = {
    beavercreek_CTF, bloodgulch_CTF, boardingaction_CTF, carousel_CTF,
    chillout_CTF, damnation_CTF, dangercanyon_CTF, deathisland_CTF,
    gephyrophobia_CTF, hangemhigh_CTF, icefields_CTF, infinity_CTF, longest_CTF,
    prisoner_CTF, putput_CTF, ratrace_CTF, sidewinder_CTF, timberland_CTF, wizard_CTF, ladrangvalley_CTF
}

Slayer = {
    beavercreek_Slayer, bloodgulch_Slayer, boardingaction_Slayer,
    carousel_Slayer, chillout_Slayer, damnation_Slayer, dangercanyon_Slayer,
    deathisland_Slayer, gephyrophobia_Slayer, hangemhigh_Slayer,
    icefields_Slayer, infinity_Slayer, longest_Slayer, prisoner_Slayer,
    putput_Slayer, ratrace_Slayer, sidewinder_Slayer, timberland_Slayer, wizard_Slayer, ladrangvalley_Slayer
}

Oddball = {
    beavercreek_Oddball, bloodgulch_Oddball,
    boardingaction_Oddball, carousel_Oddball, chillout_Oddball,
    damnation_Oddball, dangercanyon_Oddball, deathisland_Oddball,
    gephyrophobia_Oddball, hangemhigh_Oddball, icefields_Oddball,
    infinity_Oddball, longest_Oddball, prisoner_Oddball, putput_Oddball,
    ratrace_Oddball, sidewinder_Oddball, timberland_Oddball, wizard_Oddball, ladrangvalley_Oddball
}

KOTH = {
    beavercreek_KOTH, bloodgulch_KOTH, boardingaction_KOTH,
    carousel_KOTH, chillout_KOTH, damnation_KOTH, dangercanyon_KOTH,
    deathisland_KOTH, gephyrophobia_KOTH, hangemhigh_KOTH,
    icefields_KOTH, infinity_KOTH, longest_KOTH, prisoner_KOTH,
    putput_KOTH, ratrace_KOTH, sidewinder_KOTH, timberland_KOTH, wizard_KOTH, ladrangvalley_KOTH
}

Race = {
    beavercreek_Race, bloodgulch_Race, boardingaction_Race,
    carousel_Race, chillout_Race, damnation_Race, dangercanyon_Race,
    deathisland_Race, gephyrophobia_Race, hangemhigh_Race, icefields_Race,
    infinity_Race, longest_Race, prisoner_Race, putput_Race,
    ratrace_Race, sidewinder_Race, timberland_Race, wizard_Race, ladrangvalley_Race
}

spawnweaps = CTF, Slayer, Oddball, KOTH, Race
weapons = { }
restore_weap = { }

function GetRequiredVersion()
    return 200
end

function OnScriptLoad(processId, game, persistent)
    if game == "PC" then
        gametype_base = 0x671340
        ctf_globals = 0x639B98
    elseif game == "CE" then
        ctf_globals = 0x5BDBB8
        gametype_base = 0x5F5498
    end
    local gametype_game = readbyte(gametype_base, 0x30)
    if gametype_game == 1 then
        spawnweaps = CTF
    elseif gametype_game == 2 then
        spawnweaps = Slayer
    elseif gametype_game == 3 then
        spawnweaps = Oddball
    elseif gametype_game == 4 then
        spawnweaps = KOTH
    elseif gametype_game == 5 then
        spawnweaps = Race
    end
    WeaponsMonitor = registertimer(12, "WeaponMonitor")
end

function OnScriptUnload()
    if WeaponsMonitor then
        removetimer(WeaponsMonitor)
    end
end

function OnNewGame(map)
    -- if map == "beavercreek" then privatesay(player, "You will start without a weapon on this map") end
    if map == "beavercreek" then
        -- weapon1 = spawnweaps[1][1]
        -- weapon2 = spawnweaps[1][2]
        -- weapon3 = spawnweaps[1][3]
        -- weapon4 = spawnweaps[1][4]
    elseif map == "bloodgulch" then
        weapon1 = spawnweaps[2][1]
        weapon2 = spawnweaps[2][2]
        weapon3 = spawnweaps[2][3]
        weapon4 = spawnweaps[2][4]
    elseif map == "boardingaction" then
        weapon1 = spawnweaps[3][1]
        weapon2 = spawnweaps[3][2]
        weapon3 = spawnweaps[3][3]
        weapon4 = spawnweaps[3][4]
    elseif map == "carousel" then
        weapon1 = spawnweaps[4][1]
        weapon2 = spawnweaps[4][2]
        weapon3 = spawnweaps[4][3]
        weapon4 = spawnweaps[4][4]
    elseif map == "chillout" then
        weapon1 = spawnweaps[5][1]
        weapon2 = spawnweaps[5][2]
        weapon3 = spawnweaps[5][3]
        weapon4 = spawnweaps[5][4]
    elseif map == "damnation" then
        weapon1 = spawnweaps[6][1]
        weapon2 = spawnweaps[6][2]
        weapon3 = spawnweaps[6][3]
        weapon4 = spawnweaps[6][4]
    elseif map == "dangercanyon" then
        weapon1 = spawnweaps[7][1]
        weapon2 = spawnweaps[7][2]
        weapon3 = spawnweaps[7][3]
        weapon4 = spawnweaps[7][4]
    elseif map == "deathisland" then
        weapon1 = spawnweaps[8][1]
        weapon2 = spawnweaps[8][2]
        weapon3 = spawnweaps[8][3]
        weapon4 = spawnweaps[8][4]
    elseif map == "gephyrophobia" then
        weapon1 = spawnweaps[9][1]
        weapon2 = spawnweaps[9][2]
        weapon3 = spawnweaps[9][3]
        weapon4 = spawnweaps[9][4]
    elseif map == "hangemhigh" then
        weapon1 = spawnweaps[10][1]
        weapon2 = spawnweaps[10][2]
        weapon3 = spawnweaps[10][3]
        weapon4 = spawnweaps[10][4]
    elseif map == "icefields" then
        weapon1 = spawnweaps[11][1]
        weapon2 = spawnweaps[11][2]
        weapon3 = spawnweaps[11][3]
        weapon4 = spawnweaps[11][4]
    elseif map == "infinity" then
        weapon1 = spawnweaps[12][1]
        weapon2 = spawnweaps[12][2]
        weapon3 = spawnweaps[12][3]
        weapon4 = spawnweaps[12][4]
    elseif map == "longest" then
        weapon1 = spawnweaps[13][1]
        weapon2 = spawnweaps[13][2]
        weapon3 = spawnweaps[13][3]
        weapon4 = spawnweaps[13][4]
    elseif map == "prisoner" then
        weapon1 = spawnweaps[14][1]
        weapon2 = spawnweaps[14][2]
        weapon3 = spawnweaps[14][3]
        weapon4 = spawnweaps[14][4]
    elseif map == "putput" then
        weapon1 = spawnweaps[15][1]
        weapon2 = spawnweaps[15][2]
        weapon3 = spawnweaps[15][3]
        weapon4 = spawnweaps[15][4]
    elseif map == "ratrace" then
        weapon1 = spawnweaps[16][1]
        weapon2 = spawnweaps[16][2]
        weapon3 = spawnweaps[16][3]
        weapon4 = spawnweaps[16][4]
    elseif map == "sidewinder" then
        weapon1 = spawnweaps[17][1]
        weapon2 = spawnweaps[17][2]
        weapon3 = spawnweaps[17][3]
        weapon4 = spawnweaps[17][4]
    elseif map == "timberland" then
        weapon1 = spawnweaps[18][1]
        weapon2 = spawnweaps[18][2]
        weapon3 = spawnweaps[18][3]
        weapon4 = spawnweaps[18][4]
    elseif map == "wizard" then
        weapon1 = spawnweaps[19][1]
        weapon2 = spawnweaps[19][2]
        weapon3 = spawnweaps[19][3]
        weapon4 = spawnweaps[19][4]

    elseif map == "ladrangvalley" then
        weapon1 = spawnweaps[20][1]
        weapon2 = spawnweaps[20][2]
        weapon3 = spawnweaps[20][3]
        weapon4 = spawnweaps[20][4]
    end
end

function OnGameEnd(mode)
    if mode == 2 then
        removetimer(WeaponsMonitor)
        WeaponsMonitor = nil
    end
end

function OnPlayerJoin(player)
    restore_weap[player] = { }
    restore_weap[player].tagName = nil
end

function OnPlayerLeave(player)
    restore_weap[player] = nil
end

function OnPlayerSpawn(player, objectId)
    if getobject(objectId) then
        for i = 0, 3 do
            local weapID = readdword(getobject(objectId), 0x2F8 + i * 4)
            if weapID ~= 0xFFFFFFFF then
                destroyobject(weapID)
            end
        end
        registertimer(50, "AssignWeapons", player)
        -- registertimer(100, "SetNades", player)
    end
end

function AssignWeapons(id, count, player)
    if getobject(readdword(getplayer(player), 0x34)) then
        if weapon1 ~= nil then
            assignweapon(player, createobject(gettagid("weap", weapon1), 0, 60, false, 0, 1, 2))
        end
        if weapon2 ~= nil then
            assignweapon(player, createobject(gettagid("weap", weapon2), 0, 60, false, 0, 1, 2))
        end
        if weapon3 ~= nil then
            assignweapon(player, createobject(gettagid("weap", weapon3), 0, 60, false, 0, 1, 2))
        end
        if weapon4 ~= nil then
            assignweapon(player, createobject(gettagid("weap", weapon4), 0, 60, false, 0, 1, 2))
        end
    end
end

function OnObjectInteraction(player, objectId, mapId)
    -------------------------------------------------------------------------------------------------------------------
    local Pass = nil
    local name, type = gettaginfo(mapId)
    if type == "eqip" then
        if gametype == 1 or gametype == 3 then
            if name == "powerups\\full-spectrum vision" then
                Pass = false
            end
        end
        return Pass
    end
    -------------------------------------------------------------------------------------------------------------------
    local tagName, tagType = gettaginfo(mapId)
    if tagType == "weap" and restore_weap[player].tagName == nil then
        local check = false
        if tagName == "weapons\\flag\\flag" then
            if (getteam(player) == 0 and objectId == readdword(ctf_globals + 1 * 4, 0x8)) or (getteam(player) == 1 and objectId == readdword(ctf_globals + 0 * 4, 0x8)) then
                check = true
            else
                check = false
            end
        elseif tagName == "weapons\\ball\\ball" then
            check = true
        end
        if check == true then
            local m_object = getobject(readdword(getplayer(player), 0x34))
            local slot = readword(m_object, 0x2F2)
            local slot_offset = 0x2F8
            if slot == 0 then
                slot_offset = 0x2F8
            elseif slot == 1 then
                slot_offset = 0x2F8 + 4
            elseif slot == 2 then
                slot_offset = 0x2F8 + 8
            elseif slot == 3 then
                slot_offset = 0x2F8 + 12
            end
            local weapId = readdword(m_object, slot_offset)
            if (getobject(readdword(m_object, 0x304)) and readdword(m_object, 0x304) ~= 0xFFFFFFFF) and (weapId ~= 0xFFFFFFFF and getobject(weapId)) then
                local tag = gettaginfo(readdword(getobject(weapId)))
                if tag ~= "weapons\\flag\\flag" and tag ~= "weapons\\ball\\ball" then
                    local m_weapon = getobject(readdword(m_object, 0x118))
                    local ammo
                    if tag == "weapons\\flamethrower\\flamethrower" then
                        ammo = readfloat(m_weapon, 0x124)
                    elseif tag == "weapons\\plasma pistol\\plasma pistol" then
                        ammo = readfloat(m_weapon, 0x140)
                    elseif tag == "weapons\\plasma rifle\\plasma rifle" or tag == "weapons\\plasma_cannon\\plasma_cannon" then
                        local m_weapon = getobject(readdword(m_object, 0x118))
                        ammo = readfloat(m_weapon, 0x240)
                    else
                        ammo = readword(m_weapon, 0x2B6)
                    end
                    restore_weap[player].tagName = tag
                    restore_weap[player].Clip = readword(m_weapon, 0x2B8)
                    restore_weap[player].Ammo = ammo
                    destroyobject(weapId)
                end
            end
        end
    end
    return 1
end

function WeaponMonitor(id, count)
    for player = 0, 15 do
        weapons[player] = weapons[player] or { }
        if getplayer(player) then
            local m_object = getobject(readdword(getplayer(player), 0x34))
            if m_object then
                for i = 0, 3 do
                    local weapId = readdword(m_object, 0x2F8 + (i * 4))
                    if getobject(weapId) then
                        local mapId = readdword(getobject(weapId))
                        if weapons[player][i] then
                            if weapons[player][i].weapId ~= weapId then
                                OnWeaponDrop(player, weapons[player][i].weapId, i, weapons[player][i].mapId)
                                weapons[player][i] = { }
                                weapons[player][i].weapId = weapId
                                weapons[player][i].mapId = mapId
                                OnWeaponPickup(player, weapId, i, mapId)
                            end
                        else
                            weapons[player][i] = { }
                            weapons[player][i].weapId = weapId
                            weapons[player][i].mapId = mapId
                            OnWeaponPickup(player, weapId, i, mapId)
                        end
                    else
                        if weapons[player][i] then
                            OnWeaponDrop(player, weapons[player][i].weapId, i, weapons[player][i].mapId)
                            weapons[player][i] = nil
                        end
                    end
                end
            else
                for i = 0, 3 do
                    if weapons[player][i] then
                        OnWeaponDrop(player, weapons[player][i].weapId, i, weapons[player][i].mapId)
                        weapons[player][i] = nil
                    end
                end
            end
        end
    end
    return 1
end

function OnWeaponPickup(player, weapId, slot, mapId)
end

function OnWeaponDrop(player, weapId, slot, mapId)
    if getobject(readdword(getplayer(player), 0x34)) then
        local tagName = gettaginfo(mapId)
        if (tagName == "weapons\\flag\\flag" or tagName == "weapons\\ball\\ball") and restore_weap[player].tagName ~= nil then
            registertimer(401, "RestoreWeapon", player)
        end
    end
end

function RestoreWeapon(id, count, player)
    if getobject(readdword(getplayer(player), 0x34)) and restore_weap[player].tagName ~= nil then
        local tagname = restore_weap[player].tagName
        local weaponId = createobject(gettagid("weap", tagname), 0, 60, false, 0, 1, 2)
        local m_weapon = getobject(weaponId)
        if tagname == "weapons\\flamethrower\\flamethrower" then
            writefloat(m_weapon, 0x124, restore_weap[player].Ammo)
        elseif tagname == "weapons\\plasma pistol\\plasma pistol" then
            writefloat(m_weapon, 0x140, restore_weap[player].Ammo)
        elseif tagname == "weapons\\plasma rifle\\plasma rifle" or tagname == "weapons\\plasma_cannon\\plasma_cannon" then
            writefloat(m_weapon, 0x240, restore_weap[player].Ammo)
        else
            writeword(m_weapon, 0x2B6, restore_weap[player].Ammo)
            writeword(m_weapon, 0x2B8, restore_weap[player].Clip)
        end
        updateammo(weaponId)
        assignweapon(player, weaponId)
        restore_weap[player].tagName = nil
        restore_weap[player].Ammo = nil
        restore_weap[player].PackAmmo = nil
    end
    return 0
end