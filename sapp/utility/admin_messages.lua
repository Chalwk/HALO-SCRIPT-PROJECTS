--[[
=====================================================================================
SCRIPT NAME:      admin_messages.lua
DESCRIPTION:      Configurable admin join message system.
                  - Displays messages per admin level (1–4)
                  - Supports chat or RCON output
                  - Customizable formatting: alignment, color codes, server prefix
                  - Easy to configure per level and toggle display environment

Copyright (c) 2019–2021 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- config starts --

local Join_Messages = {

    -- Level 1:
    --
    [1] = '[TRIAL-MOD] $name joined the server. Everybody hide!',

    -- Level 2:
    --
    [2] = '[MODERATOR] $name just showed up. Hold my beer!',

    -- Level 3:
    --
    [3] = '[ADMIN] $name just joined. Hide your bananas!',

    -- Level 4:
    --
    [4] = '[SENIOR-ADMIN] $name joined the server.',

    -- Where should messages appear, chat or rcon?
    --
    environment = 'chat',

    -- Message alignment (has not affect for clients running Chimera)
    -- Left = |l, Right = |r, Center = |c, Tab: |t
    --
    alignment = '|l',

    --

    -- Advanced users only:
    --
    -- A message relay function temporarily removes the server prefix
    -- and will restore it to this when the relay is finished:
    -- Technical note: This only applies to the chat environment.
    server_prefix = '**SAPP**',
    --
}
-- config ends --

api_version = '1.11.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function Join_Messages:Broadcast(Ply)

    local lvl = tonumber(get_var(Ply, '$lvl'))
    if (lvl >= 1) then

        local name = get_var(Ply, '$name')
        local msg = self.alignment .. ' ' .. self[lvl]
        msg = msg:gsub('$name', name)

        if (self.environment == 'chat') then
            execute_command('msg_prefix ""')
            say_all(msg)
            execute_command('msg_prefix ' .. self.server_prefix .. '"')
        elseif (self.environment == 'rcon') then
            for i = 1, 16 do
                if player_present(i) then
                    rprint(i, msg)
                end
            end
        end
    end
end

function OnJoin(P)
    Join_Messages:Broadcast(P)
end

function OnScriptUnload()
    -- N/A
end