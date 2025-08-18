-- Name: set_flag_limit.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
    writebyte(0x671340, 0x58, 21)
end