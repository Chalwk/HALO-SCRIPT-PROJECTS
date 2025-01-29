--[[
--=====================================================================================================--
Script Name: Spawn Fixes, for SAPP (PC & CE)
Implementing API version: 1.11.0.0
Description:    The maps listed below each have one or more broken spawn points.
                For example, the map emt_inverno has one known spawn point that spawns you on the side of a cliff - you slide down and die from fall damage.
                This script fixes that by detecting when you spawn at that location and safely teleports you elsewhere.
                This script will also take into account the gametype, i.e, Slayer, CTF, Team Slayer, etc.

--  MAPS THIS SCRIPT FIXES
    emt_inverno
    dioptase
    deadend
    municipality
    sniperbluff
    rev_savior_cave_prerelease

    TODO: REFACTOR THIS ASAP

Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

-- Known broken spawn points
BrokenCoords = {
    -- emt_inverno --
    -86.68, -16.49, 11.92, -- Side of cliff
    -- dioptase --
    -6.34, 8.5, 1.2, -- Under ground
    -- deadend --
    2.49, -4.95, -0.31, -- Spawn in the ground
    6.67, 2.11, 3.71, -- Spawn in fire
    -- municipality --
    -31.99, 35.35, -0.96, -- Under ground
    -- sniperbluff --
    19.75, -13.17, 2.44, -- Inside a rock
    -- rev_savior_cave_prerelease
    4.06, 14.78, 0.47 -- Inside a rock
}

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    if get_var(0, "$gt") ~= "n/a" then
        mapname = get_var(0, "$map")
        team_play = getteamplay()
        LoadTables()
    end
end

function OnScriptUnload()

end

function OnNewGame()
    mapname = get_var(0, "$map")
    team_play = getteamplay()
    LoadTables()
end

function OnPlayerSpawn(PlayerIndex)
    local CurrentCoords = GetPlayerCoords(PlayerIndex)
    local coord = SelectNewCoord(PlayerIndex)
    local Team = get_var(PlayerIndex, "$team")
    local player_obj_id = read_dword(get_player(PlayerIndex) + 0x34)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        if table.match(BrokenCoords, CurrentCoords) then
            if not team_play then
                if (mapname == "emt_inverno") then
                    moveobject(player_obj_id, emt_inverno_SlayerCoords[coord][1], emt_inverno_SlayerCoords[coord][2], emt_inverno_SlayerCoords[coord][3] + 0.15)
                elseif (mapname == "dioptase") then
                    moveobject(player_obj_id, dioptase_SlayerCoords[coord][1], dioptase_SlayerCoords[coord][2], dioptase_SlayerCoords[coord][3] + 0.15)
                elseif (mapname == "deadend") then
                    moveobject(player_obj_id, deadend_SlayerCoords[coord][1], deadend_SlayerCoords[coord][2], deadend_SlayerCoords[coord][3] + 0.15)
                elseif (mapname == "municipality") then
                    moveobject(player_obj_id, municipality_SlayerCoords[coord][1], municipality_SlayerCoords[coord][2], municipality_SlayerCoords[coord][3] + 0.15)
                elseif (mapname == "sniperbluff") then
                    moveobject(player_obj_id, sniperbluff_SlayerCoords[coord][1], sniperbluff_SlayerCoords[coord][2], sniperbluff_SlayerCoords[coord][3] + 0.15)
                elseif (mapname == "rev_savior_cave_prerelease") then
                    moveobject(player_obj_id, rev_savior_cave_prerelease_SlayerCoords[coord][1], rev_savior_cave_prerelease_SlayerCoords[coord][2], rev_savior_cave_prerelease_SlayerCoords[coord][3] + 0.15)
                end
            elseif team_play == true then
                if (mapname == "emt_inverno") then
                    if (Team == "red") then
                        moveobject(player_obj_id, emt_inverno_RedCoords[coord][1], emt_inverno_RedCoords[coord][2], emt_inverno_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, emt_inverno_BlueCoords[coord][1], emt_inverno_BlueCoords[coord][2], emt_inverno_BlueCoords[coord][3] + 0.15)
                    end
                elseif (mapname == "dioptase") then
                    if (Team == "red") then
                        moveobject(player_obj_id, dioptase_RedCoords[coord][1], dioptase_RedCoords[coord][2], dioptase_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, dioptase_BlueCoords[coord][1], dioptase_BlueCoords[coord][2], dioptase_BlueCoords[coord][3] + 0.15)
                    end
                elseif (mapname == "deadend") then
                    if (Team == "red") then
                        moveobject(player_obj_id, deadend_RedCoords[coord][1], deadend_RedCoords[coord][2], deadend_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, deadend_BlueCoords[coord][1], deadend_BlueCoords[coord][2], deadend_BlueCoords[coord][3] + 0.15)
                    end
                elseif (mapname == "municipality") then
                    if (Team == "red") then
                        moveobject(player_obj_id, municipality_RedCoords[coord][1], municipality_RedCoords[coord][2], municipality_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, municipality_BlueCoords[coord][1], municipality_BlueCoords[coord][2], municipality_BlueCoords[coord][3] + 0.15)
                    end
                elseif (mapname == "sniperbluff") then
                    if (Team == "red") then
                        moveobject(player_obj_id, sniperbluff_RedCoords[coord][1], sniperbluff_RedCoords[coord][2], sniperbluff_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, sniperbluff_BlueCoords[coord][1], sniperbluff_BlueCoords[coord][2], sniperbluff_BlueCoords[coord][3] + 0.15)
                    end
                elseif (mapname == "rev_savior_cave_prerelease") then
                    if (Team == "red") then
                        moveobject(player_obj_id, rev_savior_cave_prerelease_RedCoords[coord][1], rev_savior_cave_prerelease_RedCoords[coord][2], rev_savior_cave_prerelease_RedCoords[coord][3] + 0.15)
                    elseif (Team == "blue") then
                        moveobject(player_obj_id, rev_savior_cave_prerelease_BlueCoords[coord][1], rev_savior_cave_prerelease_BlueCoords[coord][2], rev_savior_cave_prerelease_BlueCoords[coord][3] + 0.15)
                    end
                end
            end
        end
    end
end

function SelectNewCoord(PlayerIndex)
    Team = get_var(PlayerIndex, "$team")
    if not team_play then
        if (mapname == "emt_inverno") then
            if #emt_inverno_SlayerCoords > 0 then
                return rand(1, #emt_inverno_SlayerCoords + 1)
            end
        elseif (mapname == "dioptase") then
            if #dioptase_SlayerCoords > 0 then
                return rand(1, #dioptase_SlayerCoords + 1)
            end
        elseif (mapname == "deadend") then
            if #deadend_SlayerCoords > 0 then
                return rand(1, #deadend_SlayerCoords + 1)
            end
        elseif (mapname == "municipality") then
            if #municipality_SlayerCoords > 0 then
                return rand(1, #municipality_SlayerCoords + 1)
            end
        elseif (mapname == "sniperbluff") then
            if #sniperbluff_SlayerCoords > 0 then
                return rand(1, #sniperbluff_SlayerCoords + 1)
            end
        elseif (mapname == "rev_savior_cave_prerelease") then
            if #rev_savior_cave_prerelease_SlayerCoords > 0 then
                return rand(1, #rev_savior_cave_prerelease_SlayerCoords + 1)
            end
        end
    elseif team_play == true then
        if (mapname == "emt_inverno") then
            if (Team == "red") then
                if #emt_inverno_RedCoords > 0 then
                    return rand(emt_inverno_RedCoords)
                end
            elseif (Team == "blue") then
                if #emt_inverno_BlueCoords > 0 then
                    return rand(1, #emt_inverno_BlueCoords + 1)
                end
            end
        elseif (mapname == "dioptase") then
            if (Team == "red") then
                if #dioptase_RedCoords > 0 then
                    return rand(dioptase_RedCoords)
                end
            elseif (Team == "blue") then
                if #dioptase_BlueCoords > 0 then
                    return rand(1, #dioptase_BlueCoords + 1)
                end
            end
        elseif (mapname == "deadend") then
            if (Team == "red") then
                if #deadend_RedCoords > 0 then
                    return rand(deadend_RedCoords)
                end
            elseif (Team == "blue") then
                if #deadend_BlueCoords > 0 then
                    return rand(1, #deadend_BlueCoords + 1)
                end
            end
        elseif (mapname == "municipality") then
            if (Team == "red") then
                if #municipality_RedCoords > 0 then
                    return rand(municipality_RedCoords)
                end
            elseif (Team == "blue") then
                if #municipality_BlueCoords > 0 then
                    return rand(1, #municipality_BlueCoords + 1)
                end
            end
        elseif (mapname == "sniperbluff") then
            if (Team == "red") then
                if #sniperbluff_RedCoords > 0 then
                    return rand(sniperbluff_RedCoords)
                end
            elseif (Team == "blue") then
                if #sniperbluff_BlueCoords > 0 then
                    return rand(1, #sniperbluff_BlueCoords + 1)
                end
            end
        elseif (mapname == "rev_savior_cave_prerelease") then
            if (Team == "red") then
                if #rev_savior_cave_prerelease_RedCoords > 0 then
                    return rand(rev_savior_cave_prerelease_RedCoords)
                end
            elseif (Team == "blue") then
                if #rev_savior_cave_prerelease_BlueCoords > 0 then
                    return rand(1, #rev_savior_cave_prerelease_BlueCoords + 1)
                end
            end
        end
    end
    return nil
end

function moveobject(ObjectID, x, y, z)
    local object = get_object_memory(ObjectID)
    if get_object_memory(ObjectID) ~= 0 then
        write_vector3d((object) + 0x5C, x, y, z)
    end
end

function GetPlayerCoords(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        local x, y, z = read_vector3d(get_dynamic_player(PlayerIndex) + 0x5C)
        return math.round(x, 2), math.round(y, 2), math.round(z, 2)
    end
    return nil
end

function math.round(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function table.match(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
end

function getteamplay()
    if get_var(0, "$ffa") == "0" then
        return true
    else
        return false
    end
end

function LoadTables()
    -- emt_inverno --
    emt_inverno_RedCoords = { }
    emt_inverno_BlueCoords = { }
    emt_inverno_SlayerCoords = { }

    emt_inverno_RedCoords[1] = { -102.66, -36.76, -5.89 }
    emt_inverno_BlueCoords[1] = { 12.78, -54.08, 4.4 }
    emt_inverno_SlayerCoords[1] = { 18.57, -34.5, 4.23 }

    -- dioptase --
    dioptase_RedCoords = { }
    dioptase_BlueCoords = { }
    dioptase_SlayerCoords = { }

    dioptase_RedCoords[1] = { -3.89, 8.11, -0.55 }
    dioptase_BlueCoords[1] = { -5.28, -4.55, -0.55 }
    dioptase_SlayerCoords[1] = { -3.67, 8.87, 0.86 }

    -- deadend --
    deadend_RedCoords = { }
    deadend_BlueCoords = { }
    deadend_SlayerCoords = { }

    deadend_RedCoords[1] = { 10.15, 0.45, -0.32 }
    deadend_BlueCoords[1] = { 1.98, 14.94, -0.31 }
    deadend_SlayerCoords[1] = { 10.15, 0.45, -0.32 }

    -- municipality --
    municipality_RedCoords = { }
    municipality_BlueCoords = { }
    municipality_SlayerCoords = { }

    municipality_RedCoords[1] = { -17.63, -16.97, 0.05 }
    municipality_BlueCoords[1] = { -19.46, 25.63, 2.06 }
    municipality_SlayerCoords[1] = { -10.35, 18.78, -0.38 }

    -- sniperbluff --
    sniperbluff_RedCoords = { }
    sniperbluff_BlueCoords = { }
    sniperbluff_SlayerCoords = { }

    sniperbluff_RedCoords[1] = { -6.65, 18.06, 3.93 }
    sniperbluff_BlueCoords[1] = { 11.71, -21.86, 2.47 }
    sniperbluff_SlayerCoords[1] = { 16.79, -7.52, 2.32 }

    -- rev_savior_cave_prerelease --
    rev_savior_cave_prerelease_RedCoords = { }
    rev_savior_cave_prerelease_BlueCoords = { }
    rev_savior_cave_prerelease_SlayerCoords = { }

    rev_savior_cave_prerelease_RedCoords[1] = { 3.43, 16.27, 0.41 }
    rev_savior_cave_prerelease_BlueCoords[1] = { 3.43, 16.27, 0.41 }
    rev_savior_cave_prerelease_SlayerCoords[1] = { 3.43, 16.27, 0.41 }
end

function OnError(Message)
    print(debug.traceback())
end
