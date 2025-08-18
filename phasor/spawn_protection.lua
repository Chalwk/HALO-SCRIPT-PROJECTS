--[[
------------------------------------
Description: HPC Spawn Protection V1, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

OnSpawnKill = 5
DEATHS = { }
function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end

function OnPlayerJoin(player)
    DEATHS[player] = { 0 }
end

function OnPlayerKill(killer, victim, mode)
    if mode == 4 then
        DEATHS[victim][1] = DEATHS[victim][1] + 1
        if killer then
            if DEATHS[killer][1] ~= 0 then
                DEATHS[killer][1] = 0
            end
        end
    end
end

function OnPlayerSpawnEnd(player, m_objectId)
    local name = getname(player)
    if player then
        if DEATHS[player][1] == OnSpawnKill then
            local m_playerObjId = getplayerobjectid(player)
            if m_playerObjId then
                local m_object = getobject(m_playerObjId)
                if m_object then
                    local x, y, z = getobjectcoords(m_playerObjId)
                    local os = createobject(overshield_tag_id, 0, 0, false, x, y, z + 0.5)
                    local os = createobject(camouflage_tag_id, 0, 0, false, x, y, z + 0.5)
                    privatesay(player, "* * Spawn Protection * *    You have been given an Over-Shield and Camouflage.", false)
                    hprintf("Spawn Protection  -  " .. name .. " has been given Spawn Protection.")
                end
            end
            DEATHS[player][1] = 0
        end
    end
end

function OnNewGame(map)
    overshield_tag_id = gettagid("eqip", "powerups\\over shield")
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
end