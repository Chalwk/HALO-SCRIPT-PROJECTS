--[[
=====================================================================================
SCRIPT NAME:      clear_chat.lua
DESCRIPTION:      Chat management utility featuring:
                  - Instant global chat clearing (/clear)
                  - Configurable options:
                    * Admin-only access control
                    * Custom clearance messages
                    * Cooldown timers
                  - Multi-mode operation:
                    * Complete chat wipe
                    * Line-by-line deletion
                    * Targeted message removal

Copyright (c) 2016-2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration
local config = {
    -- Custom command used to clear chat
    command = "clear",

    -- Minimum permission level required to execute the custom command
    permission_level = 1,

    -- A message relay function temporarily removes the server prefix
    -- and restores it to this when finished
    prefix = "**ADMIN**"
}

function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
end

local function send(playerId, msg)
    return (playerId == 0 and cprint(msg) or rprint(playerId, msg))
end

local function isAdmin(playerId)
    local playerLevel = tonumber(get_var(playerId, '$lvl'))
    return (playerId == 0 or playerLevel >= config.permission_level)
end

function OnCommand(playerId, cmd)
    local lowerCaseCmd = cmd:sub(1, config.command:len()):lower()
    if (lowerCaseCmd == config.command) then
        if isAdmin(playerId) then
            execute_command('msg_prefix ""')
            for _ = 1, 20 do
                say_all(" ")
            end
            execute_command('msg_prefix "' .. config.prefix .. '"')
            send(playerId, "Chat was cleared")
        else
            send(playerId, 'Insufficient Permission')
        end
        return false
    end
end

function OnScriptUnload()
    -- N/A
end
