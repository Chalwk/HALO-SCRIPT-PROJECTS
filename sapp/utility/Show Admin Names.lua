--=====================================================================================================--
-- SCRIPT NAME: Show Admin Names for SAPP (PC & CE)
-- Description: Prints the name and level of admins who are currently online.
--
-- Copyright (c) 2021-2022, Jericho Crosby <jericho.crosby227@gmail.com>
-- Notice: You can use this script subject to the following conditions:
--         https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

-- Command used to check for admins
local command = 'whois'
api_version = '1.12.0.0'

-- Event handlers
function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], 'checkAdmins')
end

-- Checks if a player is an admin
local function isAdmin(playerIndex)
    local playerLevel = tonumber(get_var(playerIndex, "$lvl"))
    return playerLevel and playerLevel > 0
end

-- Lists the admins currently online
function checkAdmins(playerIndex, cmd)
    if cmd:sub(1, command:len()):lower() == command then
        for i = 1, 16 do
            if player_present(i) then
                local adminLevel = isAdmin(i)
                if adminLevel then
                    rprint(playerIndex, get_var(i, '$name') .. ' [level: ' .. adminLevel .. ']')
                end
            end
        end
        return false
    end
end

-- No action is required when the script is unloaded
function OnScriptUnload()
    -- N/A
end