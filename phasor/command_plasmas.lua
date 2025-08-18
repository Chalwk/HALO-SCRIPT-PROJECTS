--[[
------------------------------------
Description: HPC Command_Setplasmas (Fixed), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
Script Version: 2.5
-----------------------------------
]]--

function Command_Setplasmas(executor, command, player, plasmas, count)
    if count == 3 and tonumber(plasmas) then
        local players = getvalidplayers(player, executor)
        if players then
            for i,_ in pairs(players) do
                local m_objectId = getplayerobjectid(players[i])
                if m_objectId then
                    local m_object = getobject(m_objectId)
                    if m_object then
                        if tonumber(plasmas) <= 255 then
                            writebyte(m_object + 0x31F, tonumber(plasmas))
                            sendresponse("Setting " .. getname(players[i]) .. "'s plasma grenades to: " .. plasmas, command, executor)
                            sendresponse("Your plasma grenades were set to: " .. plasmas, command, players[i])
                        else
                            writebyte(m_object + 0x31F, 255)
                            sendresponse("Setting " .. getname(players[i]) .. "'s plasma grenades to " .. plasmas, command, executor)
                            sendresponse("Your plasma grenades were set to: " .. plasmas, command, players[i])
                        end
                    else
                        sendresponse(getname(players[i]) .. " is dead!", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead!", command, executor)
                end
            end
        else
            sendresponse("Error 005: Invalid Player", command, executor)
        end
    else
        sendresponse("Error 004: Invalid Syntax: sv_setplasmas [player] [amount]", command, executor)
    end
end