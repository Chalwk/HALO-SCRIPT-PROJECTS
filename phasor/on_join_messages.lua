--[[
------------------------------------
Description: HPC OnJoinMessages (delayed), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby

About:
This document will send a private chat message to the player 5 seconds after joining
-----------------------------------
]]--
local message1 = "Warning:"
local message2 = "This server features high intensity carnage, portals, overpowered weapons and more!"
local message3 = "Type /info for help."

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processid, game, persistent)

end

function OnScriptUnload()

end

function DelayMessage(id, count, player)
    if getplayer(player) then
        privatesay(player, message1, false)
        privatesay(player, message2, false)
        privatesay(player, message3, false)
    end
    return false
end

function OnPlayerJoin(player)
    registertimer(1000 * 5, "DelayMessage", player)
end

function OnGameEnd(mode)
    removetimer(DelayMessage)
end