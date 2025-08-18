--[[
------------------------------------
Description: HPC BeaverCreek Messages, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

-- Settings
local message1 = "On this map you start wihout a weapon."
local message2 = "Each player will have to find a weapon every time you spawn."

function GetRequiredVersion()
    return
    200
end

function OnScriptLoad(processId, game, persistent)

end

function OnNewGame(map)
    gamemap = map
    if player ~= nil then
        if gamemap == "beavercreek" then
            privatesay(player, message1, false)
            privatesay(player, message2, false)
        end
    end
    return false
end

function OnPlayerJoin(player)
    gamemap = map
    if player ~= nil then
        if gamemap == "beavercreek" then
            privatesay(player, message1, message2, false)
            privatesay(player, message2, false)
        end
    end
end