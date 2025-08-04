--=====================================================================================================--
-- SCRIPT NAME:      Admin Chat
-- DESCRIPTION:      Enables a toggleable admin-only chat system.
--                   Admins with required permission levels can opt in/out using a command.
--                   Messages sent in admin chat are visible only to other opted-in admins.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

-- CONFIGURATION ----------------------------------------------------------------

local AdminChat = {
    -- Command to toggle admin chat on or off
    command = 'achat',

    -- Minimum permission level required to execute the command
    permission = 1,

    -- If true, admin chat will be enabled for admins by default
    enabled_by_default = false,

    -- Admin Chat message format
    output = '[AdminChat] $name: $msg'
}
-- END OF CONFIGURATION ----------------------------------------------------------

local players = {}

api_version = '1.12.0.0'

-- Register event callbacks
function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_CHAT'], 'showMessage')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    OnStart()
end

-- Constructor for AdminChat player object
function AdminChat:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Initialize player-specific properties
    o.lvl = tonumber(get_var(o.id, '$lvl'))
    o.state = (o.lvl >= self.permission and self.enabled_by_default) or false

    return o
end

-- Toggle admin chat state
function AdminChat:Toggle()
    if self:hasPermission() then
        self.state = not self.state
        rprint(self.id, 'Admin Chat ' .. (self.state and 'on' or 'off'))
    else
        rprint(self.id, 'Insufficient Permission')
    end
end

-- Check if the player has permission to use admin chat
function AdminChat:hasPermission()
    return self.lvl >= self.permission
end

-- Show admin chat message
function AdminChat:showMessage(message)
    local msg_format = self.output:gsub('$name', self.name):gsub('$msg', message)
    local response = true

    for i = 1, 16 do
        if player_present(i) then
            local player = players[i]
            if player.state then
                response = false
                rprint(i, msg_format)
            end
        end
    end

    return response
end

-- Handle game start event
function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

-- Handle command event
function OnCommand(playerId, command)
    local player = players[playerId]
    command = command:lower()

    if player and command == player.command:lower() then
        player:Toggle()
        return false
    end
end

-- Check if a message is a command
local function isCommand(msg)
    return msg:sub(1, 1) == '/' or msg:sub(1, 1) == '\\'
end

-- Handle chat event
function showMessage(playerId, message)
    local player = players[playerId]

    if player and not isCommand(message) and player.state then
        return player:showMessage(message)
    end
end

-- Handle player join event
function OnJoin(playerId)
    players[playerId] = AdminChat:new({
        id = playerId,
        name = get_var(playerId, '$name')
    })
end

-- Handle player leave event
function OnQuit(playerId)
    players[playerId] = nil
end

-- Handle script unload event
function OnScriptUnload()
    -- No action required
end