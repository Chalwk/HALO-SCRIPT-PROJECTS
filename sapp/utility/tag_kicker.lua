--[[
===============================================================================
SCRIPT NAME:      tag_kicker.lua
DESCRIPTION:      Simple clan tag anti-impersonator.
                  - Kicks any player using your clans tag (prefix) in their name if not whitelisted.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Config --------------------------------------------------------------
local CONFIG = {

    -- The prefix to detect in player names.
    -- Any player whose name starts with this string and is NOT whitelisted will be kicked.
    PREFIX = "CLAN-",

    -- Whitelisted members (exact names, case-sensitive)
    -- Players in this list are allowed to use the PREFIX without being kicked.
    WHITELIST = {
        "CLAN-TestAdmin",   -- Example
        "CLAN-Fictional1",  -- Example
        "CLAN-DemoUser"     -- Example
    },

    -- Kick reason
    -- The message that will appear in-game when a player is kicked.
    KICK_REASON = "Unauthorized use of Clan Tag"
}
-- Config ends ----------------------------------------------

api_version = "1.12.0.0"

local function isWhitelisted(name)
    for _, member in ipairs(CONFIG.WHITELIST) do
        if name == member then return true end
    end
    return false
end

function OnJoin(playerId)
    local name = get_var(playerId, '$name')
    if name:sub(1, #CONFIG.PREFIX) == CONFIG.PREFIX and not isWhitelisted(name) then
        execute_command(string.format('k %d "%s"', playerId, CONFIG.KICK_REASON))
        cprint(string.format("[Tag Kicker] Player %s kicked for unauthorized tag use.", name), 12)
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function OnScriptUnload() end