-- Name: vehicle_spawns_3.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

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

function OnNewGame(map)
    createobject(gettagid("vehi", "vehicles\\rwarthog\\rwarthog"), 0, 30, false, 96.663, -151.103, -0.007 + 0.4)
end