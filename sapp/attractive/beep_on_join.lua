--[[
=====================================================================================
SCRIPT NAME:      beep_on_join.lua
DESCRIPTION:      Produces an audible beep when someone joins the server.

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function OnJoin(_)
    os.execute('echo \7')
end

function OnScriptUnload()
    -- N/A
end