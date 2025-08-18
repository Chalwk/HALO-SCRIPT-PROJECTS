--[[
------------------------------------
Description: HPC SetRunningSpeed, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]-- 

RunningSpeed = 1.08
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end
function OnPlayerSpawnEnd(player, m_objectId)
    if getplayer(player) then
        setspeed(player, RunningSpeed)
    end
end	