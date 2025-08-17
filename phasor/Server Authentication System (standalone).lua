--[[
------------------------------------
Description: HPC Server Authentication System (standalone), Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function GetRequiredVersion()
    return 200
end
function AuthorizeServer()
    local file = io.open(string.format("%s\\data\\Server_ID.key", profilepath), "r")
    if file then
        value = file:read("*line")
        file:close()
    else
        registertimer(2000, "delay_terminate", { "~~~~~~~~~~~~WARNING~~~~~~~~~~~", "~~~~~~NO SERVER KEY FOUND~~~~~", "~~YOU CANNOT USE THIS SCRIPT~~" })
    end
    return value or "undefined"
end

function delay_terminate(id, count, message)
    if message then
        for v = 1, #message do
            hprintf(message[v])
        end
    end
    svcmd("sv_end_game")
    return 0
end

function OnScriptLoad(process, game, persistent)
    profilepath = getprofilepath()
    local file = io.open(string.format("%s\\data\\auth_" .. tostring(process) .. ".key", profilepath), "r")
    if file then
        server_id = file:read("*line")
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            server_token = words[1]
            server_id = words[2]
        end
    else
        server_id = AuthorizeServer()
    end
    server_id = AuthorizeServer()
end
		