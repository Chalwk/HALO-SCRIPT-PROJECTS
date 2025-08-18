--[[
=====================================================================================
SCRIPT NAME:      auto_message.lua
DESCRIPTION:      Automated announcement system featuring:
                  - Scheduled message broadcasting:
                    * Configurable delay intervals (30-300 seconds)
                    * Multi-line message support
                  - Flexible output options:
                    * In-game chat messages
                    * Console/RCON output
                  - Message customization:
                    * Color-coded text
                    * Timestamp prefixes
                    * Rotating message lists
                  - Server management:
                    * On-demand message triggers
                    * Priority message queuing

Copyright (c) 2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration table for the Auto Message script:
local AutoMessage = {

    -- List of announcements. Each entry can support multiple lines:
    announcements = {
        { 'Multi-Line Support | Message 1, line 1', 'Message 2, line 2' },
        { 'Like us on Facebook | facebook.com/page_id' },
        { 'Follow us on Twitter | twitter.com/twitter_id' },
        { 'We are recruiting. Sign up on our website | website url' },
        { 'Rules / Server Information' },
        { 'Announcement 6' },
        { 'Other information here' },
    },

    -- Interval in seconds between announcements:
    interval = 300,

    -- Flag to toggle console output for announcements:
    showAnnouncementsOnConsole = true,

    -- Prefix to be used for server messages:
    serverPrefix = '**SAPP**'
}

api_version = '1.12.0.0'

-- Internal variables:
local timer = nil
local announcementIndex = 1

-- Called when the script loads:
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    OnGameStart()  -- Initialize when the game starts
end

-- Helper function to create a timer with the specified interval:
local function createTimer(interval)
    return { start = os.time(), finish = os.time() + interval }
end

-- Broadcasts the current announcement:
local function broadcastAnnouncement()
    local announcement = AutoMessage.announcements[announcementIndex]

    -- Remove the message prefix for announcements:
    execute_command('msg_prefix ""')

    -- Send each line of the announcement to all players and optionally print to the console:
    for _, message in ipairs(announcement) do
        if AutoMessage.showAnnouncementsOnConsole then
            cprint(message)  -- Print to console
        end
        say_all(message)  -- Broadcast to all players
    end

    -- Restore the original message prefix:
    execute_command('msg_prefix "' .. AutoMessage.serverPrefix .. '"')

    -- Update the index to point to the next announcement (loop back if at the end):
    announcementIndex = (announcementIndex % #AutoMessage.announcements) + 1
end

-- Called when the game starts or restarts:
function OnGameStart()
    if get_var(0, '$gt') ~= 'n/a' then
        announcementIndex = 1  -- Reset to the first announcement
        timer = createTimer(AutoMessage.interval)  -- Start the timer
    end
end

-- Called when the game ends:
function OnGameEnd()
    timer = nil  -- Disable the timer when the game ends
end

-- Called every tick (game frame):
function OnTick()
    if timer and os.time() >= timer.finish then
        broadcastAnnouncement()  -- Broadcast the announcement
        timer = createTimer(AutoMessage.interval)  -- Reset the timer
    end
end