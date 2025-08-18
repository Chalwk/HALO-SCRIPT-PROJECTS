--=====================================================================================================--
-- SCRIPT NAME: Chat IDs, for SAPP (PC & CE)
-- Description: Appends the player id to their message.
--
-- Copyright (c) 2014-2024, Jericho Crosby <jericho.crosby227@gmail.com>
-- Notice: You can use this script subject to the following conditions:
-- https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

-- Define chat formats
local chat = {
    -- global:
    [0] = "$name [$id]: $msg",

    -- team:
    [1] = "[$name] [$id]: $msg",

    -- vehicle:
    [2] = "[$name] [$id]: $msg"
}

-- Define server prefix as a constant
local SERVER_PREFIX = "**SAPP**"

-- API version constant
api_version = "1.12.0.0"

-- Register the callback when the script is loaded
function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], "ShowChatIDs")
end

-- Helper function to check if a message is a chat command
local function isCommand(msg)
    return (msg:sub(1, 1) == '/' or msg:sub(1, 1) == '\\')
end

-- Function to format the chat message with placeholders
local function formatMessage(msgFormat, name, message, playerId)
    return msgFormat:gsub('$name', name):gsub('$msg', message):gsub('$id', playerId)
end

-- Function to send message to the appropriate recipients based on type
local function sendMessageToAppropriateRecipients(type, msg, team)
    if type == 0 then
        say_all(msg)
    elseif type == 1 or type == 2 then
        for i = 1, 16 do
            if player_present(i) and get_var(i, '$team') == team then
                say(i, msg)
            end
        end
    end
end

-- Display chat messages with IDs
function ShowChatIDs(playerId, msg, type)

    -- Check if the message is not a chat command
    if not isCommand(msg) then

        local name = get_var(playerId, '$name')
        local team = get_var(playerId, '$team')
        local formattedMsg = chat[type]

        formattedMsg = formatMessage(formattedMsg, name, msg, playerId)

        -- Temporarily remove the server prefix
        execute_command('msg_prefix ""')

        sendMessageToAppropriateRecipients(type, formattedMsg, team)

        -- Restore the server prefix
        execute_command('msg_prefix "' .. SERVER_PREFIX .. '"')
        return false
    end
end

-- No additional actions required when the script is unloaded
function OnScriptUnload()
    -- N/A
end