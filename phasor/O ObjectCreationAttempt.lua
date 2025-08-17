--[[
------------------------------------
Description: OnObjectCreationAttempt, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function OnObjectCreationAttempt(mapid, parentid, player)

    local name, type = gettaginfo(mapid)

    if name == "weapons\\assault rifle\\assault rifle"
            or name == "weapons\\flamethrower\\flamethrower"
            or name == "weapons\\gravity rifle\\gravity rifle"
            or name == "weapons\\needler\\mp_needler"
            or name == "weapons\\plasma pistol\\plasma pistol"
            or name == "weapons\\plasma rifle\\plasma rifle"
            or name == "weapons\\plasma_cannon\\plasma_cannon"
            or name == "weapons\\rocket launcher\\rocket launcher"
            or name == "weapons\\shotgun\\shotgun" then
        return false
    end
end

function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end