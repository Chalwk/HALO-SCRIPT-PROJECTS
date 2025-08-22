--[[
===============================================================================
SCRIPT NAME:      auto_message.lua
DESCRIPTION:      Automated rotating message system that broadcasts:
                  - Scheduled announcements to all players
                  - Multi-line messages with customizable intervals
                  - Optional console output for monitoring

LAST UPDATED:     22/08/2025

Copyright (c) 2024-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- Start of configuration --------------------------------------------------------------------------
local ANNOUNCEMENTS = {
    { 'Multi-Line Support | Message 1, line 1',                 'Message 2, line 2' },
    { 'Like us on Facebook | facebook.com/page_id' },
    { 'Follow us on Twitter | twitter.com/twitter_id' },
    { 'We are recruiting. Sign up on our website | website url' },
    { 'Rules / Server Information' },
    { 'Announcement 6' },
    { 'Other information here' },
}

local INTERVAL = 300      -- Interval in seconds
local CONSOLE = true      -- Console output
local PREFIX = '**SAPP**' -- Message prefix

-- End of configuration ----------------------------------------------------------------------------

api_version = '1.12.0.0'

local game_active = false
local index = 1

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function BroadcastAnnouncement()
    local announcement = ANNOUNCEMENTS[index]
    execute_command('msg_prefix ""')
    for _, message in ipairs(announcement) do
        if CONSOLE then cprint(message) end
        say_all(message)
    end
    execute_command('msg_prefix "' .. PREFIX .. '"')
    index = (index % #ANNOUNCEMENTS) + 1

    return game_active
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    index = 1; game_active = true
    timer(1000 * INTERVAL, "BroadcastAnnouncement")
end

function OnEnd() game_active = false end

function OnScriptUnload() end
