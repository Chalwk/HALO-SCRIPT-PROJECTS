--[[
--=====================================================================================================--
Script Name: T-Slayer Team Spawns, for SAPP (PC & CE)
Description: This mod will enforce team spawning on Team-Slayer based game types.

Copyright (c) 2020-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = '1.12.0.0'

local spawns = {}

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local insert = table.insert
local function LoadSpawns()

    local tag_array = read_dword(0x40440000)
    local scenario_tag_index = read_word(0x40440004)
    local scenario_tag = tag_array + scenario_tag_index * 0x20
    local scenario_tag_data = read_dword(scenario_tag + 0x14)

    local starting_location_reflexive = scenario_tag_data + 0x354
    local starting_location_count = read_dword(starting_location_reflexive)
    local starting_location_address = read_dword(starting_location_reflexive + 0x4)

    for i = 0, starting_location_count do
        local starting_location = starting_location_address + 52 * i
        local x, y, z = read_vector3d(starting_location)
        local team = read_word(starting_location + 0x10)
        insert(spawns[team], {
            x = x,
            y = y,
            z = z
        })
    end
end

function OnStart()
    spawns = { [0] = {}, [1] = {} }
    local game_type = get_var(0, '$gt')
    local team_play = (get_var(0, '$ffa') == '0')
    if (game_type ~= 'n/a' and game_type == 'slayer' and team_play) then
        LoadSpawns()
        register_callback(cb['EVENT_PRESPAWN'], 'PreSpawn')
        return
    end
    unregister_callback(cb['EVENT_PRESPAWN'])
end

function PreSpawn(Ply)
    local dyn = get_dynamic_player(Ply)
    if (dyn ~= 0) then

        local team = get_var(dyn, '$team')
        team = ('red' and 0 or 1)

        local pos = spawns[team][rand(1, #spawns[team] + 1)]
        write_vector3d(dyn + 0x5C, pos.x, pos.y, pos.z)
    end
end

function OnScriptUnload()
    -- N/A
end