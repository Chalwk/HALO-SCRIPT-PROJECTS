--[[
=====================================================================================
SCRIPT NAME:      welcome_message.lua
DESCRIPTION:      Customizable welcome messages for joining players.
                  Originally requested by mdc81 on OpenCarnage forums.

                  Implementation Note:
                  Basic functionality can be achieved with SAPP's built-in:
                  event_join 'say $n "Welcome message here"'

Copyright (c) 2016-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function OnJoin(Ply)
    say(Ply, 'Welcome friend, ' .. get_var(Ply, '$name'))
end

function OnScriptUnload()
    -- N/A
end