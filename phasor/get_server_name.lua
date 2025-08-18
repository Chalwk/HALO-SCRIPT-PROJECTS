-- Name: get_server_name.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end
function OnNewGame(map)
    network_name = readwidestring(network_struct + 0x8, 0x42)
    hprintf("Server Name: " .. network_name)
end