--[[
--===================================================================--
Description: HPC Custom Messages, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
--===================================================================--
]]--

function OnScriptUnload()
end

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processId, game, persistent)

end

function OnNewGame(map)
    timer = registertimer(1000, "SayMessages")
end

function SayMessages(id, count)
    if (count % 11) == 1 then
        say("Message 1", false)

    elseif (count % 11) == (2) then
        say("Message 2", false)

    elseif (count % 11) == (3) then
        say("Message 3", false)

    elseif (count % 11) == (4) then
        say("Message 4", false)

    elseif (count % 11) == (5) then
        say("Message 5", false)

    elseif (count % 11) == (6) then
        say("Message 6", false)

    elseif (count % 11) == (7) then
        say("Message 7", false)

    elseif (count % 11) == (8) then
        say("Message 8", false)

    elseif (count % 11) == (9) then
        say("Message 9", false)

    elseif (count % 11) == (10) then
        say("Message 10", false)

    elseif (count % 11) == (0) then
        say("Message 11", false)
    end
    return true
end

function OnGameEnd(mode)
    if mode == 1 then
        if timer then
            removetimer(timer)
            timer = nil
        end
    end
end