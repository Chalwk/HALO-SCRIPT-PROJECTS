--[[
------------------------------------
Description: HPC Live on Three, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

-- Script Settings
local Live_On_Three = 07
local Live_On_Two = 08
local Live_On_One = 09

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)

end

function OnScriptUnload()

end

function OnNewGame(map)
    --  About 700 - 800 milliseconds.
    registertimer(Live_On_Three * 2100, "LiveOnThree")
    registertimer(Live_On_Two * 2100, "LiveOnTwo")
    registertimer(Live_On_One * 2100, "LiveOnOne")
end

function OnGameEnd(stage)
    if stage == 1 then
        -- Post game Carnage report
        removetimer(Live_On_Three)
        removetimer(Live_On_Two)
        removetimer(Live_On_One)
    end
end

function LiveOnThree(id, count)
    for player = 0, 15 do
        local m_player = getplayer(player)
        if game_started then
            return false
            -- Ends the loop on game end.
        end
        if Live_On_Three == 07 then
            -- In (seconds)
            if m_player == nil then
                return 0
            end
            sendconsoletext(player, "                         ( Live on 3 )")
            hprintf("                                         ( Live on 3 )")
            return false
        end
    end
    return false
    -- Ends the loop
end

function LiveOnTwo(id, count)
    for player = 0, 15 do
        local m_player = getplayer(player)
        if game_started then
            return false
            -- Ends the loop on game end.
        end
        if Live_On_Two == 08 then
            -- In (seconds)
            if m_player == nil then
                return 0
            end
            sendconsoletext(player, "                         ( Live on 2 )")
            hprintf("                                         ( Live on 2 )")
            return false
        end
    end
    return false
    -- Ends the loop
end

function LiveOnOne(id, count)
    for player = 0, 15 do
        local m_player = getplayer(player)
        if game_started then
            return false
            -- Ends the loop on game end.
        end
        if Live_On_One == 09 then
            -- In (seconds)
            if m_player == nil then
                return 0
            end
            sendconsoletext(player, "                         ( Live on 1 )")
            hprintf("                                         ( Live on 1 )")
            return false
        end
    end
    return false
    -- Ends the loop
end