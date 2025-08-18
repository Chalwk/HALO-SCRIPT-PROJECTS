--[[
------------------------------------
Description: HPC Set Flag Limit, Phasor V2+
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
function OnScriptLoad(processid, game, persistent)
    writebyte(0x671340, 0x58, 21)
end