---------------------------------------------------
-- Chat Command Tutorial for SAPP
-- Responds to player chat commands like "!hello"
---------------------------------------------------

--------------------------------------------------------------------------------
-- CONFIG / CONSTANTS
--------------------------------------------------------------------------------
local COMMAND_PREFIX = "!"                -- Prefix that identifies commands
local HELLO_COMMAND = "hello"             -- Example command

-- * Required for all SAPP Lua scripts.
-- Tells SAPP the Lua API version being used on the server.
api_version = '1.12.0.0'

--------------------------------------------------------------------------------
-- EVENT CALLBACKS
--------------------------------------------------------------------------------
function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
    print("Chat Command tutorial loaded!")
end

function OnScriptUnload() end

--------------------------------------------------------------------------------
-- EVENT HANDLERS
--------------------------------------------------------------------------------
function OnPlayerChat(playerIndex, message, type)
    local msg = string.lower(message) -- Make command case-insensitive

    -- Only process messages that start with the command prefix
    if string.sub(msg, 1, 1) == COMMAND_PREFIX then
        local command = string.sub(msg, 2) -- Remove prefix

        -- Example: respond to "!hello"
        if command == HELLO_COMMAND then
            local playerName = get_var(playerIndex, '$name')
            rprint(playerIndex, "Hello " .. playerName .. "! Welcome to the server!")
        end

        return false -- Block the chat message from appearing in global chat
    end
end
