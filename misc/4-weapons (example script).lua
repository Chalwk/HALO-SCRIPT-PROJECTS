--[[
--=====================================================================================================--
Script Name: 4-weapons (example script), for SAPP (PC & CE)
Description: Assigns 4 weapons to players on spawn

Copyright (c) 2022-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local weapons = {
    'weapons\\pistol\\pistol',
    'weapons\\sniper rifle\\sniper rifle',
    'weapons\\shotgun\\shotgun',
    'weapons\\assault rifle\\assault rifle'
}

api_version = '1.12.0.0'

-- Function to assign weapons to a player
local function assignWeapons(player)
    -- Delete the player's inventory
    execute_command('wdel ' .. player)

    -- Assign primary and secondary weapons immediately
    assign_weapon(spawn_object('weap', weapons[1], 0, 0, 0), player)
    assign_weapon(spawn_object('weap', weapons[2], 0, 0, 0), player)

    -- Assign tertiary and quaternary weapons with a delay
    timer(250, 'AssignTertiaryWeapon', player)
    timer(500, 'AssignQuaternaryWeapon', player)
end

function OnScriptLoad()
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
end

function OnSpawn(player)
    -- Get the player's object address
    local dyn = get_dynamic_player(player)

    -- Assign weapons if the player's object address is valid
    if dyn ~= 0 then
        assignWeapons(player)
    end
end

-- Assign tertiary weapon to the player
function AssignTertiaryWeapon(player)
    assign_weapon(spawn_object('weap', weapons[3], 0, 0, 0), player)
end

-- Assign quaternary weapon to the player
function AssignQuaternaryWeapon(player)
    assign_weapon(spawn_object('weap', weapons[4], 0, 0, 0), player)
end

function OnScriptUnload()
    -- N/A
end