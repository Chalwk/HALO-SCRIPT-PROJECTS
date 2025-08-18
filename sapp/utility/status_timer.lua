--=====================================================================================================--
-- SCRIPT NAME: Status Timer for SAPP (PC & CE)
-- Description: Prints the number of players currently online (to console).
--
-- Copyright (c) 2016-2024, Jericho Crosby
-- Notice: You can use this script subject to the following conditions:
--         https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

-- Specify the interval to print the number of players (in seconds)
local interval = 3
api_version = "1.12.0.0"

-- Event handlers
function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    -- Call OnStart to initialize the script on load
    OnStart()
end

-- Prints the current number of players in the console
function StatusTimer()
    local currentPlayers = tonumber(get_var(0, "$pn"))
    local maxPlayers = read_word(0x4029CE88 + 0x28)
    cprint(string.format("Players: %d/%d", currentPlayers, maxPlayers), 10)
    return true
end

-- Starts the timer to periodically print the number of players
function OnStart()
    if (get_var(0, "$gt") ~= "n/a") then
        timer(interval * 1000, "StatusTimer")
    end
end

function OnScriptUnload()
    -- N/A
end