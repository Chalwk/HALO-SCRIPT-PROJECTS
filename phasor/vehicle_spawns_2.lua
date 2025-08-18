--[[
------------------------------------
Description: HPC Vehicle Spawn #2, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end
Banshee = { }
math.inf = 1 / 0
Banshee[1] = { "vehicles\\banshee\\banshee_mp", 70.078, -62.626, 3.758 } -- Blue Base
Banshee[2] = { "vehicles\\banshee\\banshee_mp", 64.178, -176.802, 3.960 } -- Red Base
----------------------------------------------------------------------
function OnNewGame(map)
    for k, v in pairs(Banshee) do
        local tag_id = gettagid("vehi", v[1])
        v[1] = tag_id
        v[5] = createobject(tag_id, 0, math.inf, false, v[2], v[3], v[4])
        hprintf(tag_id .. " Banshee Created")
        if getobject(v[5]) == nil then
            hprintf("Error! Object Creation failed. Number: " .. k)
        end
    end
end

function OnScriptLoad(process, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
        gametype_base = 0x671340
        map_name = readstring(0x698F21)
        gametype = readbyte(gametype_base + 0x30)
    end
end

function OnObjectInteraction(player, objId, mapId)
    local Pass = nil
    local name, type = gettaginfo(mapId)
    if type == "vehi" then
        if gametype == 1 or gametype == 3 then
            if name == "vehicles\\banshee\\banshee_mp" then
                Pass = false
                -- False to Block
            end
        end
        return Pass
    end
end