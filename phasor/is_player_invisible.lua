--[[
------------------------------------
Description: HPC IsPlayerInvisible, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
    if game == "PC" then
        gametype_base = 0x671340
    elseif game == "CE" then
        gametype_base = 0x5F5498
    end
    LoadTags()
end

function LoadTags()
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
end

function OnNewGame(map)
    gametype = readbyte(gametype_base + 0x30, 0x0)
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
    LoadTags()
end

function OnPlayerJoin(player)
    for i = 0, 15 do
        if getplayer(i) then
            isplayerinvis()
        end
    end
end

function isplayerinvis(player)

    if player ~= nil then
        local m_playerObjId = readdword(getplayer(player) + 0x34)
        local m_object = getobject(m_playerObjId)
        local obj_invis_scale = readfloat(m_object + 0x37C)
        if obj_invis_scale == 0 then
            -- Not invisible
            hprintf("NOT INVISIBLE!")
            return false
        else
            -- Completely invisible
            hprintf("COMPLETELY INVISIBLE!")
            return true
        end
    end
end