--[[
=====================================================================================
SCRIPT NAME:      console_text_lib.lua
DESCRIPTION:      Dynamic RCON message system with expiration and targeting.

                  Key Features:
                  - Player-specific console messaging
                  - Multi-line text support
                  - Timed auto-clear functionality
                  - Low-memory footprint
                  - Optional forced console clears

                  Basic Usage:
                  SendMessage(player_id, message, duration_secs, clear_console)

Copyright (c) 2018-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Cache global functions for performance
local os_time      = os.time
local rprint       = rprint
local type         = type
local player_present = player_present
local t_remove     = table.remove

local ConsoleText = { messages = {} }

-- Prebuilt blank lines for clearing console (faster than looping each time)
local CLEAR_LINES = {}
for i = 1, 25 do
    CLEAR_LINES[i] = ' '
end

-- Internal print function (avoids closure creation per message)
local function printToConsole(pid, msg, clear)
    if clear then
        for i = 1, #CLEAR_LINES do
            rprint(pid, CLEAR_LINES[i])
        end
    end
    if type(msg) == "table" then
        for i = 1, #msg do
            rprint(pid, msg[i])
        end
    else
        rprint(pid, msg)
    end
end

--- Create a new message for a player
-- @param playerID number
-- @param content string|table
-- @param duration number
-- @param clear boolean
function ConsoleText:NewMessage(playerID, content, duration, clear)
    local count = #self.messages + 1
    self.messages[count] = {
        player  = playerID,
        clear   = clear,
        content = content,
        finish  = os_time() + duration
    }
end

--- Update and display active messages
function ConsoleText:GameTick()
    local now = os_time()
    for i = #self.messages, 1, -1 do
        local m = self.messages[i]
        if not player_present(m.player) or now >= m.finish then
            t_remove(self.messages, i)
        else
            printToConsole(m.player, m.content, m.clear)
        end
    end
end

return ConsoleText