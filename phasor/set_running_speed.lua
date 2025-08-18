-- Name: set_running_speed.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

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