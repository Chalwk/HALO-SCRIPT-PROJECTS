--[[
------------------------------------
Description: HPC Drop PowerUp on Death (standalone), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
players = { }
EQUIPMENT = { }
EQUIPMENT_TAGS = { }
DEATH_LOCATION = { }
Drop_PowerUp = true
EQUIPMENT[1] = { "powerups\\active camouflage" }
EQUIPMENT[2] = { "powerups\\health pack" }
EQUIPMENT[3] = { "powerups\\over shield" }
EQUIPMENT[4] = { "powerups\\assault rifle ammo\\assault rifle ammo" }
EQUIPMENT[5] = { "powerups\\needler ammo\\needler ammo" }
EQUIPMENT[6] = { "powerups\\pistol ammo\\pistol ammo" }
EQUIPMENT[7] = { "powerups\\rocket launcher ammo\\rocket launcher ammo" }
EQUIPMENT[8] = { "powerups\\shotgun ammo\\shotgun ammo" }
EQUIPMENT[9] = { "powerups\\sniper rifle ammo\\sniper rifle ammo" }
EQUIPMENT[10] = { "powerups\\flamethrower ammo\\flamethrower ammo" }
-- 	EQUIPMENT[11] 	= 	{"powerups\\double speed"}
-- 	EQUIPMENT[12] 	= 	{"powerups\\full-spectrum vision"}
for i = 0, 15 do
    DEATH_LOCATION[i] = { }
end
function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnPlayerKill(killer, victim, mode)
    if mode == 4 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    elseif mode == 5 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    elseif mode == 6 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    end
end

function OnPlayerLeave(player)
    for i = 1, 3 do
        DEATH_LOCATION[player][i] = nil
    end
end

function OnPlayerSpawn(player)
    if getplayer(player) then
        for i = 1, 3 do
            DEATH_LOCATION[player][i] = nil
        end
    end
end

function DropPowerup(x, y, z)
    local num = getrandomnumber(1, #EQUIPMENT_TAGS)
    createobject(EQUIPMENT_TAGS[num], 0, 10, false, x, y, z + 0.5)
end

function ApplySpeed(player)
    if player then
        setspeed(player, tonumber(Speed_Powerup))
        registertimer(Speed_Powerup_duration * 1000, "ResetSpeed", player)
        privatesay(player, "Speed Powerup!")
    end
end

function ResetSpeed(id, count, player)
    setspeed(player, 1)
    privatesay(player, "Speed Reset!")
    return 0
end

function OnNewGame(map)
    for k, v in pairs(EQUIPMENT) do
        local tag_id = gettagid("eqip", v[1])
        table.insert(EQUIPMENT_TAGS, tag_id)
    end
    doublespeed_id = gettagid("eqip", "powerups\\double speed")
    full_spec_id = gettagid("eqip", "powerups\\full-spectrum vision")
    map_name = tostring(map)
end

function OnObjectInteraction(player, objId, mapId)
    for i = 0, #EQUIPMENT_TAGS do
        if mapId == EQUIPMENT_TAGS[i] then
            if mapId == doublespeed_id or mapId == full_spec_id then
                registertimer(500, "DelayDestroyObject", objId)
                if mapId == doublespeed_id then
                    ApplySpeed(player)
                else
                end
                return 0
            end
            return 1
        end
    end
end

function DelayDestroyObject(id, count, objId)
    if objId then
        destroyobject(objId)
    end
    return 0
end