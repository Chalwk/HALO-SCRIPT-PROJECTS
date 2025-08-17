--[[
--======================================================================================================--
Script Name: Beep On Join, for SAPP (PC & CE)
Description: Added a new script that produces an audible beep when someone joins the server.

Copyright (c) 2020-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

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