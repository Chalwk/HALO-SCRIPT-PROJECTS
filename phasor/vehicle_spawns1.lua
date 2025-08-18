--[[
------------------------------------
Description: HPC Vehicle Spawn #1, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function GetRequiredVersion()
    return 200
end
function OnScriptUnload()
end
function OnScriptLoad(process, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
        gametype_base = 0x671340
        map_name = readstring(0x698F21)
        gametype = readbyte(gametype_base + 0x30)
    end
end

Banshee = { }
Turret = { }
math.inf = 1 / 0
Banshee[1] = { "vehicles\\banshee\\banshee_mp", 70.078, -62.626, 3.758 } -- Blue Base
Banshee[2] = { "vehicles\\banshee\\banshee_mp", 64.178, -176.802, 3.960 } -- Red Base

Turret[1] = { "vehicles\\c gun turret\\c gun turret_mp", 51.315, -154.075, 21.561 } -- Turret Mountain
Turret[2] = { "vehicles\\c gun turret\\c gun turret_mp", 118.084, -185.346, 6.563 } -- Fox Hill
Turret[3] = { "vehicles\\c gun turret\\c gun turret_mp", 29.544, -53.628, 3.302 } -- Behind Blue Base

function OnNewGame(map)
    for k, v in pairs(Banshee) do
        local tag_id = gettagid("vehi", v[1])
        v[1] = tag_id
        v[5] = createobject(tag_id, 0, math.inf, true, v[2], v[3], v[4])
        if getobject(v[5]) == nil then
            hprintf("Error! Object Creation failed. Number: " .. k)
        end
    end

    for k, v in pairs(Turret) do
        local tag_id = gettagid("vehi", v[1])
        v[1] = tag_id
        v[5] = createobject(tag_id, 0, math.inf, true, v[2], v[3], v[4])
        if getobject(v[5]) == nil then
            hprintf("Error! Object Creation failed. Number: " .. k)
        end
    end
end