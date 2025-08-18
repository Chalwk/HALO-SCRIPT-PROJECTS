--[[
------------------------------------
Description: HPC Get Server Name, Phasor V2+
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
function OnNewGame(map)
    network_name = readwidestring(network_struct + 0x8, 0x42)
    hprintf("Server Name: " .. network_name)
end