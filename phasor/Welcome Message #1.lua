--[[
------------------------------------------------------------------------
Script Name: HPC Welcome Messages, for PhasorV2+

Copyright (c) 2016 Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE

* IGN: Chalwk
------------------------------------------------------------------------
]]--

Welcome_Message = "Welcome Message Here"

function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end

function WelcomeMessage(id, count)
    say(Welcome_Message)
    return true
end

function OnNewGame(Mapname)
    W_M = registertimer(1000 * 60 * 20, "WelcomeMessage")
    -- 10 seconds.
end

function OnGameEnd(mode)
    gameend = true
    notyetshown = true
    if mode == 1 then
        if W_M then
            removetimer(W_M)
            W_M = nil
        end
    end
end

function DelayWM(id, count, player)
    if getplayer(player) then
        privatesay(player, Welcome_Message)
    end
    return false
end

function OnPlayerJoin(player)
    registertimer(1000 * 10, "DelayWM", player)
end