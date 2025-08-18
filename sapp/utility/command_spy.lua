--[[
=====================================================================================
SCRIPT NAME:      command_monitor.lua
DESCRIPTION:      Admin command monitoring system featuring:
                  - Real-time command execution alerts:
                    * Customizable admin notification levels
                    * Per-command monitoring controls
                  - Security features:
                    * Command blacklisting
                    * Sensitive command filtering
                  - Logging options:
                    * Console output logging
                    * Timestamped command history
                    * Player-specific tracking

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Admin levels allowed to see spy messages:
local spy_levels = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true
}

-- Blacklisted commands that will not be monitored:
local blacklist = {
    "login",
    "admin_add",
    "sv_password",
    "change_password",
    "admin_change_pw",
    "admin_add_manually"
}

-- Output message formats:
local messages = {
    spy_notify = "[SPY] $name used command: $cmd",
    no_permission = "You do not have permission to use this command.",
}

-- Log commands to console as well?
local log_to_console = true

-- CONFIG ENDS -----------------------------------------------

local players = {}

api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
end

function OnJoin(id)
    players[id] = {
        name = get_var(id, "$name"),
        get_level = function()
            return tonumber(get_var(id, "$lvl")) or 0
        end
    }
end

function OnQuit(id)
    players[id] = nil
end

local function is_blacklisted(cmd)
    cmd = cmd:lower():match("^(%S+)")
    for _, black_cmd in ipairs(blacklist) do
        if cmd == black_cmd:lower() then
            return true
        end
    end
    return false
end

function OnCommand(id, Command)
    if id > 0 then
        if is_blacklisted(Command) then return end

        local player = players[id]
        local name = player.name

        -- Notify admins:
        for i = 1, 16 do
            if player_present(i) then
                local a = players[i]
                if a and spy_levels[a.get_level()] and i ~= id then
                    local msg = messages.spy_notify
                    msg = msg:gsub("$name", name)
                    msg = msg:gsub("$cmd", Command)
                    rprint(i, msg)
                end
            end
        end

        -- Log to console:
        if log_to_console then
            cprint(string.format("[CommandSpy] %s used: %s", name, Command))
        end
    end
end

function OnScriptUnload() end