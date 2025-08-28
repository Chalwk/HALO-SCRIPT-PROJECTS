--[[
===============================================================================
SCRIPT NAME:      tag_kicker.lua
DESCRIPTION:      Simple clan tag anti-impersonator.
                  - Kicks any player using "LIB-" in their name if not whitelisted.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Config --------------------------------------------------------------
local CONFIG = {

    PREFIX = "LIB-",

    -- Whitelisted members (exact names, case-sensitive)
    WHITELIST = {
        "LIB-Chalwk",
        "LIB-Alpha",
        "LIB-Beta"
    },

    -- Kick reason
    KICK_REASON = "Unauthorized use of LIB- tag"
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
    if name:sub(1, 4) == CONFIG.PREFIX and not isWhitelisted(name) then
        execute_command(string.format('k %d "%s"', playerId, CONFIG.KICK_REASON))
        cprint(string.format("[Tag Kicker] Player %s kicked for unauthorized tag use.", name), 12)
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function OnScriptUnload() end
