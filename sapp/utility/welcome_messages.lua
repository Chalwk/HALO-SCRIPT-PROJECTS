--[[
--=====================================================================================================--
Script Name: Welcome Message, for SAPP (PC & CE)
Description: This script was requested by "mdc81" on opencarnage.net for use on their private server.

            NOTE: This can be easily achieved by using SAPP's event system:
            event_join 'say $n "Welcome friend, $name"'

Copyright (c) 2016-2022, Jericho Crosby
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
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