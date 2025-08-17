--[[
--=====================================================================================================--
Script Name: Kill Cooldown (BlAcK 2316), for SAPP (PC & CE)
Description: When a player begins killing excessively (within a specified time period), they will be warned to slow down.
             If they reach a certain kill threshold before that period elapses, they will be assigned a plasma pistol. 
             If the player is holding the flag, they will be forced to drop it.

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
local players, game_over = {}

-- Configuration Starts --

local cooldown_period = 30   -- In seconds
local kill_threshold = 15    -- Player must have >= this many kills to take their weapons away.

-- Players will be warned to slow down if they have (>= kill_threshold/2) kills.
local warning_message = "Please slow down! You are killing excessively!"

local on_punish = "Your inventory was modified for excessive killing (cooldown %seconds% seconds)"
local weapon_tag = "weapons\\plasma pistol\\plasma pistol"
-- Configuration Ends --


-- # Do Not Touch # --
-- Variables for String Library:
local gsub = string.gsub
-- Variables for Math Library:
local floor = math.floor
-- Game Variabes:
local delta_time = 0.03333333333333333

function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_DIE"], "OnPlayerKill")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    if get_var(0, "$gt") ~= "n/a" then
        game_over, players = false, {}
        for i = 1, 16 do
            if player_present(i) then
                InitPlayer(i, true)
            end
        end
    end
end

function OnGameStart()
    if get_var(0, "$gt") ~= "n/a" then
        game_over, players = false, {}
    end
end

function OnGameEnd()
    game_over = true
end

function OnPlayerKill(VictimIndex, KillerIndex)
    if (not game_over) then

        local killer = tonumber(KillerIndex)
        local victim = tonumber(VictimIndex)

        for i, player in pairs(players) do
            if (i == killer) then
                player.kills = player.kills + 1
                if (player.kills >= kill_threshold / 2) then
                    player.warn = true
                end
                if (not player.init_timer) then
                    player.init_timer = true
                end
            elseif (i == victim) then
                InitPlayer(i, true)
            end
        end
    end
end

function OnTick()
    for i, player in pairs(players) do
        if (player) and player_present(i) then
            local player_object = get_dynamic_player(i)
            if (player_object ~= 0) then

                if (player.init_timer) then
                    player.timer = player.timer + delta_time
                    local cooldown = cooldown_period - floor(player.timer % 60)
                    if (cooldown > 0) then
                        if (player.kills < kill_threshold) then
                            if (player.warn) then
                                player.warn = false
                                cls(i, 25)
                                rprint(i, warning_message)
                            end
                        else
                            player.assign = true
                        end
                    elseif (cooldown <= 0) then
                        InitPlayer(i, true)
                    end
                end

                if (player.assign) then
                    local coords = getXYZ(i, player_object)
                    if (not coords.invehicle) then
                        InitPlayer(i, true)

                        cls(i, 25)
                        rprint(i, gsub(on_punish, "%%seconds%%", cooldown_period))

                        if hasFlag(i, player_object) then
                            drop_weapon(i)
                        end

                        execute_command("wdel " .. i)
                        local weapon = spawn_object("weap", weapon_tag, coords.x, coords.y, coords.z)
                        assign_weapon(weapon, i)
                    end
                end
            end
        end
    end
end

function OnPlayerConnect(PlayerIndex)
    InitPlayer(PlayerIndex, true)
end

function OnPlayerDisconnect(PlayerIndex)
    InitPlayer(PlayerIndex, false)
end

function InitPlayer(PlayerIndex, Init)
    if (Init) then
        players[PlayerIndex] = {
            init_timer = false,
            assign = false,
            warn = false,
            kills = 0,
            timer = 0,
        }
    else
        players[PlayerIndex] = nil
    end
end

function getXYZ(PlayerIndex, PlayerObject)
    local coords, x, y, z = { }
    if player_alive(PlayerIndex) then
        local VehicleID = read_dword(PlayerObject + 0x11C)
        if (VehicleID == 0xFFFFFFFF) then
            coords.invehicle = false
            x, y, z = read_vector3d(PlayerObject + 0x5c)
        else
            coords.invehicle = true
            x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
        end

        if (coords.invehicle) then
            z = z + 1
        end
        coords.x, coords.y, coords.z = x, y, z
    end
    return coords
end

function hasFlag(PlayerIndex, PlayerObject)
    if player_alive(PlayerIndex) then
        for i = 0, 3 do
            local weapon_id = read_dword(PlayerObject + 0x2F8 + 0x4 * i)
            if (weapon_id ~= 0xFFFFFFFF) then
                local weap_object = get_object_memory(weapon_id)
                if (weap_object ~= 0) then
                    local tag_address = read_word(weap_object)
                    local tagdata = read_dword(read_dword(0x40440000) + tag_address * 0x20 + 0x14)
                    if (read_bit(tagdata + 0x308, 3) == 1) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function cls(PlayerIndex, count)
    count = count or 25
    for _ = 1, count do
        rprint(PlayerIndex, " ")
    end
end
