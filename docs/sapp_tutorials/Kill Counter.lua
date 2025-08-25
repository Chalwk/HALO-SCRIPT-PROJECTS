---------------------------------------------------
-- Kill Counter Tutorial for SAPP
-- Tracks and announces player kill achievements
---------------------------------------------------

--------------------------------------------------------------------------------
-- CONFIG / CONSTANTS
--------------------------------------------------------------------------------
-- Settings that rarely change during runtime
local ANNOUNCE_MILESTONES = { 5, 10, 25, 50 }        -- Kill counts that trigger announcements
local MILESTONE_MESSAGE = "%s has reached %d kills!" -- %s = player name, %d = kill count
local SHOW_KILL_MESSAGE = true                       -- Whether to show a message on each kill
local KILL_MESSAGE = "+1 kill (%d total)"            -- Message format for individual kills

--------------------------------------------------------------------------------
-- EVENT CALLBACKS
--------------------------------------------------------------------------------
-- Called automatically when the script is loaded
function OnScriptLoad()
    -- Register the OnKill function to run whenever a kill occurs
    register_callback(cb['EVENT_KILL'], "OnKill")

    -- Print a message to the server console so we know the script loaded successfully
    print("Kill Counter script loaded successfully!")
end

-- Called automatically when the script is unloaded (optional, here left empty)
function OnScriptUnload() end

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------
-- Formats a string using string.format
-- Accepts variable arguments and returns the formatted string
local function formatMessage(...)
    return string.format(...)
end

--------------------------------------------------------------------------------
-- EVENT HANDLERS
--------------------------------------------------------------------------------
-- Called whenever a player gets a kill
function OnKill(victimIndex, killerIndex)
    -- Convert indices to numbers
    victimIndex = tonumber(victimIndex)
    killerIndex = tonumber(killerIndex)

    -- Ignore server kills, suicides, and environmental kills
    -- killerIndex == 0             -> server
    -- killerIndex == -1            -> environmental object (e.g., unoccupied vehicle)
    -- victimIndex == killerIndex   -> suicide
    if killerIndex == 0 or killerIndex == -1 or victimIndex == killerIndex then return end

    -- Get the killer's name and current number of kills
    local playerName = get_var(killerIndex, "$name")
    local currentKills = tonumber(get_var(killerIndex, "$kills"))

    -- Show individual kill message if enabled
    if SHOW_KILL_MESSAGE then
        local output = formatMessage(KILL_MESSAGE, currentKills)
        rprint(killerIndex, output) -- Prints message only to the killer
    end

    -- Check if this kill count matches any milestone
    for _, milestone in ipairs(ANNOUNCE_MILESTONES) do
        if currentKills == milestone then
            local output = formatMessage(MILESTONE_MESSAGE, playerName, milestone)
            say_all(output) -- Announce milestone to all players
            break           -- Stop checking further milestones once matched
        end
    end
end
