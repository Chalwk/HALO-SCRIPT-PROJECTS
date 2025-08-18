--[[
------------------------------------
Description: HPC Spawn where killed (standalone), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

players = { }
DEATH_LOCATION = { }
Spawn_Where_Killed = true
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
        ADD_KILL(killer)
        if Spawn_Where_Killed == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    elseif mode == 5 then
        ADD_KILL(killer)
        if Spawn_Where_Killed == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    elseif mode == 6 then
        if Spawn_Where_Killed == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    end
end

function ADD_KILL(player)
    if getplayer(player) then
        local kills = players[player][2]
        players[player][2] = kills + 1
    end
end

function OnPlayerLeave(player)
    for i = 1, 3 do
        DEATH_LOCATION[player][i] = nil
    end
end

function OnPlayerSpawn(player)
    if getplayer(player) then
        if Spawn_Where_Killed == true then
            if DEATH_LOCATION[player][1] ~= nil and DEATH_LOCATION[player][2] ~= nil then
                movobjectcoords(getplayerobjectid(player), DEATH_LOCATION[player][1], DEATH_LOCATION[player][2], DEATH_LOCATION[player][3])
                for i = 1, 3 do
                    DEATH_LOCATION[player][i] = nil
                end
            end
        end
    end
end