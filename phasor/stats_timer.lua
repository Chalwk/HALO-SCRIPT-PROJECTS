--[[
------------------------------------
Description: HPC Status Timer, Phasor V2+
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
    Status_Timer = registertimer(1500, "StatusTimer")
end

function StatusTimer(id, count)
    if current_players == nil then
        current_players = 0
    end
    respond("* Updating   -   There are currently: (" .. current_players .. " / " .. readword(0x4029CE88 + 0x28) .. " players online)")
    return true
end

function OnPlayerJoin(player)
    if current_players == nil then
        current_players = 1
    else
        current_players = current_players + 1
    end
end

function OnPlayerLeave(player)
    current_players = current_players - 1
end

function OnNewGame(map)
    current_players = 0
end