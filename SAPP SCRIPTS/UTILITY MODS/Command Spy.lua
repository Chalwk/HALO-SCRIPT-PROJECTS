--[[
--=====================================================================================================--
Script Name: Command Spy, for SAPP (PC & CE)
Description: Get notified when a player executes a command. Admins with level 1 or higher will be notified
             when a player executes a command from RCON or chat.

Admins can toggle the command spy functionality on/off using /spy. Blacklisted commands like login or admin
password changes are excluded from monitoring to protect sensitive information.

Copyright (c) 2022-2025, Jericho Crosby
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]

-- Configuration table:
local CSpy = {
    command = "spy", -- Command to toggle command spy.
    permissionLevel = 1, -- Minimum admin level required to toggle spy.
    enabledByDefault = true, -- Command Spy is enabled for all admins by default.
    ignoreAdmins = false, -- Whether to ignore commands executed by admins.
    loggingEnabled = true, -- Enable logging of monitored commands.

    -- Custom notification message formats:
    notification = {
        rcon = "[R-SPY] $name executed: $cmd",
        chat = "[C-SPY] $name typed: /$cmd"
    },

    -- Blacklisted commands that will not be monitored:
    blacklist = {
        "login",
        "admin_add",
        "sv_password",
        "change_password",
        "admin_change_pw",
        "admin_add_manually"
    },

    -- Admin list to notify (empty = notify all admins with permission level):
    notifyAdminsOnly = { "Admin1", "Admin2" },

    -- Optional admin-specific blacklists (for more flexibility):
    adminBlacklists = {
        Admin1 = { "specific_command_1", "specific_command_2" },
        Admin2 = { "teleport" }
    }
}

-- Player table to track admins and their spy status:
local players = {}

api_version = "1.12.0.0"

-- Utility function to log actions:
local function logAction(message)
    if CSpy.loggingEnabled then
        cprint("[LOG] " .. message)
    end
end

-- Helper function to check if a command is blacklisted globally:
local function isGlobalBlacklisted(cmd)
    for _, word in ipairs(CSpy.blacklist) do
        if cmd:lower():find(word) then
            return true
        end
    end
    return false
end

-- Check if a command is blacklisted for a specific admin:
local function isAdminBlacklisted(adminName, cmd)
    local blacklist = CSpy.adminBlacklists[adminName]
    if blacklist then
        for _, word in ipairs(blacklist) do
            if cmd:lower():find(word) then
                return true
            end
        end
    end
    return false
end

-- Custom function to check if a value exists in a table:
local function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Notify selected admins of the executed command:
local function notifySelectedAdmins(env, cmd, player)
    for _, admin in pairs(players) do
        if admin.id ~= player.id and admin.spyEnabled and admin.level >= CSpy.permissionLevel then
            -- If specific admins are to be notified, check if this admin is one of them:
            if #CSpy.notifyAdminsOnly > 0 and not table_contains(CSpy.notifyAdminsOnly, admin.name) then
                goto continue
            end

            -- Ignore admin if they have blacklisted this command:
            if isAdminBlacklisted(admin.name, cmd) then
                goto continue
            end

            -- Format and send the notification:
            local messageFormat = CSpy.notification[env]
            local msg = messageFormat:gsub("$name", player.name):gsub("$cmd", cmd)
            rprint(admin.id, msg)
            ::continue::
        end
    end
end

-- Toggle command spy for a specific player:
local function toggleSpy(player)
    if player.level >= CSpy.permissionLevel then
        player.spyEnabled = not player.spyEnabled
        rprint(player.id, "Command Spy " .. (player.spyEnabled and "enabled" or "disabled"))
    else
        rprint(player.id, "Insufficient Permission")
    end
end

-- Handle player command execution:
function OnCommand(id, cmd, env)
    local player = players[id]
    if player then
        local command = cmd:lower()

        -- Handle the spy toggle command:
        if command == CSpy.command then
            toggleSpy(player)
            return false
        end

        -- If the command is blacklisted globally, ignore it:
        if isGlobalBlacklisted(command) then
            return false
        end

        -- Notify admins unless it's an ignored command from an admin:
        if id > 0 and not (CSpy.ignoreAdmins and player.level >= CSpy.permissionLevel) then
            notifySelectedAdmins(env, cmd, player)
            logAction(player.name .. " executed command: " .. cmd)
        end
    end
end

-- Handle player joining:
function OnJoin(id)
    players[id] = {
        id = id,
        name = get_var(id, "$name"),
        level = tonumber(get_var(id, "$lvl")),
        spyEnabled = CSpy.enabledByDefault
    }
end

-- Handle player leaving:
function OnQuit(id)
    players[id] = nil
end

-- Initialize players on game start:
function OnStart()
    if get_var(0, "$gt") ~= "n/a" then
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnScriptUnload()
    -- N/A
end