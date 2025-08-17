--[[
------------------------------------
Description: HPC OnWeaponPickup, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

PICKUP = { }
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end
function OnNewGame(map)
    -- Equipment --
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
    healthpack_tag_id = gettagid("eqip", "powerups\\health pack")
    overshield_tag_id = gettagid("eqip", "powerups\\over shield")
    doublespeed_tag_id = gettagid("eqip", "powerups\\double speed")
    fullspec_tag_id = gettagid("eqip", "powerups\\full-spectrum vision")
    fragnade_tag_id = gettagid("eqip", "equips\\frag grenade\\frag grenade")
    plasmanade_tag_id = gettagid("eqip", "equips\\plasma grenade\\plasma grenade")
    -- Ammo --
    rifleammo_tag_id = gettagid("eqip", "powerups\\assault rifle ammo\\assault rifle ammo")
    needlerammo_tag_id = gettagid("eqip", "powerups\\needler ammo\\needler ammo")
    pistolammo_tag_id = gettagid("eqip", "powerups\\pistol ammo\\pistol ammo")
    rocketammo_tag_id = gettagid("eqip", "powerups\\rocket launcher ammo\\rocket launcher ammo")
    shotgunammo_tag_id = gettagid("eqip", "powerups\\shotgun ammo\\shotgun ammo")
    sniperammo_tag_id = gettagid("eqip", "powerups\\sniper rifle ammo\\sniper rifle ammo")
    flameammo_tag_id = gettagid("eqip", "powerups\\flamethrower ammo\\flamethrower ammo")
    -- Weapons --
    assaultrifle_tag_id = gettagid("weap", "weapons\\assault rifle\\assault rifle")
    oddball_tag_id = gettagid("weap", "weapons\\ball\\ball")
    flag_tag_id = gettagid("weap", "weapons\\flag\\flag")
    flamethrower_tag_id = gettagid("weap", "weapons\\flamethrower\\flamethrower")
    gravityrifle_tag_id = gettagid("weap", "weapons\\gravity rifle\\gravity rifle")
    needler_tag_id = gettagid("weap", "weapons\\needler\\mp_needler")
    pistol_tag_id = gettagid("weap", "weapons\\pistol\\pistol")
    plasmapistol_tag_id = gettagid("weap", "weapons\\plasma pistol\\plasma pistol")
    plasmarifle_tag_id = gettagid("weap", "weapons\\plasma rifle\\plasma rifle")
    plasmacannon_tag_id = gettagid("weap", "weapons\\plasma_cannon\\plasma_cannon")
    rocketlauncher_tag_id = gettagid("weap", "weapons\\rocket launcher\\rocket launcher")
    shotgun_tag_id = gettagid("weap", "weapons\\shotgun\\shotgun")
    sniper_tag_id = gettagid("weap", "weapons\\sniper rifle\\sniper rifle")
    energysword_tag_id = gettagid("weap", "weapons\\energy sword\\energy sword")
end

function OnClientUpdate(player)

    local m_playerObjId = getplayerobjectid(player)
    if m_playerObjId and not isinvehicle(player) then
        local pick_boolean = readbyte(getplayer(player) + 0x3E)
        if pick_boolean == 1 and PICKUP[player] == nil then
            local slot = readword(getobject(m_playerObjId) + 0x2F4)
            local m_weaponId = getweaponobjectid(player, slot)
            OnWeaponPickup(player, m_weaponId, slot, readdword(getobject(m_weaponId)))
            PICKUP[player] = pick_boolean
        elseif pick_boolean ~= PICKUP[player] then
            PICKUP[player] = nil
        end

        local m_object = getobject(m_playerObjId)
        local INVISIBILITY = readbyte(m_object + 0x204)
        local INVISIBILITY_SCALE = readfloat(m_object + 0x37C)
        if INVISIBILITY == 81 and INVISIBILITY_SCALE <= 0.005 then
            OnCamoAssignment(player, "invisible")
        elseif INVISIBILITY == 65 and INVISIBILITY_SCALE >= 0.995 then
            OnCamoAssignment(player, "visible")
        end
    end
end

function OnObjectInteraction(player, objid, mapid)
    if getplayer(player) then
        local tag_name, tag_type = gettaginfo(mapid)
        if string.find(tag_name, "ammo") or (tag_type == "weap" and mapid ~= oddball_tag_id or mapid ~= flag_tag_id) then
            local weap = false
            if tag_type == "weap" then
                weap = true
            end
            local m_objectId = getplayerobjectid(player)
            if m_objectId then
                local m_object = getobject(m_objectId)
                if m_object then
                    local m_weaponId = readdword(m_object + 0x24)
                    if m_weaponId then
                        local m_weapon = getobject(m_weaponId)
                        if m_weapon then
                            if weap == false or (weap == true and readdword(m_weapon) == mapid) then
                                local unloaded = readdword(m_weapon + 0x2B6)
                                local loaded = readdword(m_weapon + 0x2B8)

                                local t = { unloaded, loaded, player, mapid, m_weapon }
                                registertimer(200, "CheckForAmmoChange", t)
                            end
                        end
                    end
                end
            end

            if mapid == healthpack_tag_id then
                if FullHealth(player) ~= true then
                    hprintf("HEALTH (+)  -  " .. tostring(getname(player)) .. " picked up a Health Pack")
                end
            end

            if mapid == overshield_tag_id then
                if OverShield(player) ~= true then
                    hprintf("OVERSHIELD: " .. tostring(getname(player)) .. " picked up an Overshield")
                end
            end

            if map_id == fragnade_tag_id or mapid == plasmanade_tag_id then
                local m_objectId = getplayerobjectid(player)
                if m_objectId then
                    local m_object = getobject(m_objectId)
                    if m_object then
                        local frags = readbyte(m_object + 0x31E)
                        local plasmas = readbyte(m_object + 0x31F)
                        local t = { frags, plasmas, player, mapid, m_object }
                        registertimer(200, "CheckForNadeChange", t)
                    end
                end
            end
        end
    end
end

function CheckForNadeChange(id, count, t)
    local ORIGINAL_FRAGS = t[1]
    local ORIGINAL_PLASMAS = t[2]
    local NEW_FRAGS = readbyte(t[5] + 0x31E)
    local NEW_PLASMAS = readbyte(t[5] + 0x31F)
    if (ORIGINAL_FRAGS ~= NEW_FRAGS) or (ORIGINAL_PLASMAS ~= NEW_PLASMAS) then
        OnGrenadePickup(t[3], t[4])
    end
    return (0)
end

function FullHealth(player)
    local m_objectId = getplayerobjectid(player)
    if m_objectId then
        local m_object = getobject(m_objectId)
        if m_object then
            local obj_health = readfloat(m_object + 0xE0)
            if obj_health < 1 then
                return false
            else
                return true
            end
        end
    end
end

function OverShield(player)
    local m_objectId = getplayerobjectid(player)
    if m_objectId then
        local m_object = getobject(m_objectId)
        if m_object then
            local obj_shields = readfloat(m_object + 0xE4)
            if obj_shields <= 1 then
                return false
            else
                return true
            end
        end
    end
end

function CheckForAmmoChange(id, count, t)
    local ORIGINAL_UNLOADED = t[1]
    local ORIGINAL_LOADED = t[2]
    local NEW_UNLOADED = readdword(t[5] + 0x2B6)
    local NEW_LOADED = readdword(t[5] + 0x2B8)
    if (ORIGINAL_UNLOADED ~= NEW_UNLOADED) or (ORIGINAL_LOADED ~= NEW_LOADED) then
        OnAmmoPickup(t[3], t[4])
    end
    return (0)
end

function OnWeaponPickup(player, m_weaponId, slot, mapid)
    local name = getname(player)
    if mapid == sniper_tag_id then
        privatesay(player, "You Picked up a Sniper Rifle", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Sniper Rifle")
    elseif mapid == shotgun_tag_id then
        privatesay(player, "You Picked up a Shotgun", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Shotgun")
    elseif mapid == rocketlauncher_tag_id then
        privatesay(player, "You Picked up a Rocket Launcher", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Rocket Launcher")
    elseif mapid == plasmacannon_tag_id then
        privatesay(player, "You Picked up a Fuel Rod", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Fuel Rod")
    elseif mapid == plasmarifle_tag_id then
        privatesay(player, "You Picked up a Plasma rifle)", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Plasma rifle")
    elseif mapid == plasmapistol_tag_id then
        privatesay(player, "You Picked up a Plasma pistol", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Plasma pistol")
    elseif mapid == pistol_tag_id then
        privatesay(player, "You Picked up a Pistol", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Pistol")
    elseif mapid == needler_tag_id then
        privatesay(player, "You Picked up a Needler", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Needler")
    elseif mapid == gravityrifle_tag_id then
        privatesay(player, "You Picked up a Gravity Rifle", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Gravity Rifle")
    elseif mapid == flamethrower_tag_id then
        privatesay(player, "You Picked up a Flamethrower", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Flamethrower")
    elseif mapid == energysword_tag_id then
        privatesay(player, "You Picked up an Energy Sword", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up an Energy Sword")
    elseif mapid == flag_tag_id then
        privatesay(player, "You Picked up a Flag", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Flag")
    elseif mapid == oddball_tag_id then
        privatesay(player, "You Picked up an Oddball", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up an Oddball")
    elseif mapid == assaultrifle_tag_id then
        privatesay(player, "You Picked up an Assault Rifle", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up an Assault Rifle")
    end
end

function OnAmmoPickup(player, mapid)
    local name = getname(player)
    if mapid == sniperammo_tag_id or mapid == sniper_tag_id then
        privatesay(player, "You Picked ammo for the Sniper Rifle")
        hprintf(name .. " Picked up ammo for the Sniper Rifle")
    elseif mapid == pistolammo_tag_id or mapid == pistol_tag_id then
        privatesay(player, "You Picked up ammo for the Assault Pistol")
        hprintf(name .. " Picked up ammo for the Assault Pistol")
    elseif mapid == shotgunammo_tag_id or mapid == shotgun_tag_id then
        privatesay(player, "You Picked up ammo for the Shotgun")
        hprintf(name .. " Picked up ammo for the Shotgun")
    elseif mapid == flameammo_tag_id or mapid == flamethrower_tag_id then
        privatesay(player, "You Picked up a gas canister for the Flamethrower")
        hprintf(name .. " Picked up a gas canister for the Flamethrower")
    elseif mapid == needlerammo_tag_id or mapid == needler_tag_id then
        privatesay(player, "You Picked up ammo for the Needler")
        hprintf(name .. " Picked up ammo for the Needler")
    elseif mapid == rocketammo_tag_id or mapid == rocketlauncher_tag_id then
        privatesay(player, "You Picked up ammo for the Rocket Launcher")
        hprintf(name .. " Picked up ammo for the Rocket Launcher")
    elseif mapid == rifleammo_tag_id or mapid == assaultrifle_tag_id then
        privatesay(player, "You Picked up ammo for the Assault Rifle")
        hprintf(name .. " Picked up ammo for the Assault Rifle")
    end
end

function OnCamoAssignment(player, visibility)
    privatesay(player, "You Picked up a Camouflage", false)
    hprintf("WEAPON PICKUP: " .. tostring(getname(player)) .. " picked up a Camouflage")
end

function OnGrenadePickup(player, mapid)
    local name = getname(player)
    if mapid == fragnade_tag_id then
        privatesay(player, "You Picked up a Frag Grenade", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Frag Grenade")
    elseif mapid == plasmanade_tag_id then
        privatesay(player, "You Picked up Plasma Grenade", false)
        hprintf("WEAPON PICKUP: " .. name .. " Picked up a Plasma Grenade")
    end
end

function getweaponobjectid(player, slot)
    local m_objectId = getplayerobjectid(player)
    if m_objectId then
        return readdword(getobject(m_objectId) + 0x2F8 + slot * 4)
    end
end