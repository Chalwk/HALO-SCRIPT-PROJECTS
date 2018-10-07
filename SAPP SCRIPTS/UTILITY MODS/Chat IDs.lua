--[[
--=====================================================================================================--
Script Name: ChatIDs, for SAPP (PC & CE)
Implementing API version: 1.11.0.0
Description:    This script will modify your players message chat format
                by adding an IndexID in front of their name in square brackets.

Team output: [Chalwk] [1]: This is a test message
Global output: Chalwk [1]: This is a test message

Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
global_format = "%sender_name% [%index%]: %message%"
team_format = "[%sender_name%] [%index%]: %message%"

function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
end

function OnScriptUnload() end

function OnPlayerChat(PlayerIndex, Message)
    local message = tokenizestring(Message)
    if #message == 0 then return nil end
    for i = 0, #message do
        if message[i] then
            if string.sub(message[1], 1, 1) == "/" or string.sub(message[1], 1, 1) == "\\" then
                return true
            else
                if (GetTeamPlay == true) then
                    if type == 0 or type == 2 then
                        SendToAll(Message, PlayerIndex)
                        return false
                    elseif type == 1 then
                        SendToTeam(Message, PlayerIndex)
                        return false
                    end
                else
                    SendToAll(Message, PlayerIndex)
                    return false
                end
            end
        end
    end
end

function SendToTeam(Message, PlayerIndex)
    for i = 1, 16 do
        if player_present(i) then
            if (get_var(i, "$team")) == (get_var(PlayerIndex, "$team")) then
                local team_format = string.gsub(team_format, "%%sender_name%%", get_var(PlayerIndex, "$name"))
                local team_format = string.gsub(team_format, "%%index%%", get_var(PlayerIndex, "$n"))
                local team_format = string.gsub(team_format, "%%message%%", Message)
                execute_command("msg_prefix \"\"")
                say(i, team_format)
                execute_command("msg_prefix \" *  * SERVER *  * \"")
            end
        end
    end
end

function SendToAll(Message, PlayerIndex)
    if player_present(PlayerIndex) then
        local global_format = string.gsub(global_format, "%%sender_name%%", get_var(PlayerIndex, "$name"))
        local global_format = string.gsub(global_format, "%%index%%", get_var(PlayerIndex, "$n"))
        local global_format = string.gsub(global_format, "%%message%%", Message)
        execute_command("msg_prefix \"\"")
        say_all(global_format)
        execute_command("msg_prefix \" *  * SERVER *  * \"")
    end
end

function GetTeamPlay()
    if get_var(0, "$ffa") == "0" then
        return true
    else
        return false
    end
    return
end

function tokenizestring(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {} ; i = 1
for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
end
return t
end
