--[[
------------------------------------
Description: HPC Killer Reward!, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby

Reward killer with special attributes
-----------------------------------
]]-- 
players = { }
EQUIPMENT = { }
EQUIPMENT_TAGS = { }
KILL_LOCATION = { }
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
EQUIPMENT[11] = { "powerups\\double speed" }
EQUIPMENT[12] = { "powerups\\full-spectrum vision" }
for i = 0, 15 do
    KILL_LOCATION[i] = { }
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
end
function OnPlayerKill(killer, victim, mode)
    if mode == 4 then
        local kills = readword(getplayer(killer) + 0x98)
        local kills = readword(getplayer(killer) + 0x96)
        if tonumber(kills) then
            if kills == 10 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 20 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 30 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 40 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 50 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 60 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 70 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 80 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills == 90 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            elseif kills >= 100 then
                local x, y, z = getobjectcoords(getplayerobjectid(killer))
                KILL_LOCATION[killer][1] = x
                KILL_LOCATION[killer][2] = y
                KILL_LOCATION[killer][3] = z
                DropPowerUp(x, y, z)
            end
        end
    end
end

function DropPowerUp(x, y, z)
    local num = getrandomnumber(1, #EQUIPMENT_TAGS)
    createobject(EQUIPMENT_TAGS[num], 0, 10, false, x, y, z + 0.5)
end

function OnNewGame(map)
    for k, v in pairs(EQUIPMENT) do
        local tag_id = gettagid("eqip", v[1])
        table.insert(EQUIPMENT_TAGS, tag_id)
    end
    map_name = tostring(map)
end