--[[
=====================================================================================
SCRIPT NAME:      timed_authentication.lua
DESCRIPTION:      This script enforces a timed authentication challenge for players
                  using the clan tag (e.g. LIB-) in their name. When such a player
                  joins, they must type a predefined secret phrase in chat within a
                  set number of seconds. If they fail to do so, they are
                  automatically kicked.

                  Intended as a lightweight deterrent to unauthorized tag usage.
                  This implementation uses a static secret phrase and should not
                  be considered highly secure for sensitive use-cases.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Config Start ---------------------------------------------------------------
local CLAN_TAG = 'LIB-'
local AUTH_TIME = 20                        -- seconds allowed to authenticate
local SECRET_PHRASE = "!your_secret_phrase" -- phrase a player must type
-- Config End -----------------------------------------------------------------

api_version = "1.12.0.0"

local pending_auth = {} -- tracks players awaiting authentication

local function hasUnauthorizedTag(name)
    return name:sub(1, #CLAN_TAG) == CLAN_TAG
end

function OnJoin(id)
    local name = get_var(id, "$name")

    if hasUnauthorizedTag(name) then
        pending_auth[id] = true
        rprint(id, CLAN_TAG .. " recognised.")
        rprint("Type the secret phrase in chat: (within " .. AUTH_TIME .. " seconds)")

        timer(1000 * AUTH_TIME, "CheckAuth", id)
    end
end

function CheckAuth(id)
    if pending_auth[id] then
        execute_command("k " .. id .. ' "Failed to authenticate in time"')
        pending_auth[id] = nil
    end
    return false -- always stop the timer after first execution
end

function OnChat(id, msg)
    if pending_auth[id] and msg:lower():gsub("%s+", "") == SECRET_PHRASE:lower() then
        pending_auth[id] = nil
        rprint(id, "Authentication successful. Welcome!")
        return false -- block phrase from appearing in public chat
    end
end

function OnQuit(id)
    pending_auth[id] = nil
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_CHAT'], "OnChat")
    register_callback(cb['EVENT_LEAVE'], "OnQuit")
end

function OnScriptUnload() end
