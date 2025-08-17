--[[
--======================================================================================================--
Script Name: HLN Vehicle Spawner (v1.11), for SAPP (PC & CE)
Description: This script will force you into a vehicle of your choice by
             means of a keyword typed in chat.

             Vehicle spawn settings are determined on a per-map basis.
             These settings are found in the "vehicles.json" file (needed to run this script).
             Download link: https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/Miscellaneous/HLN%20Clan/vehicles.json
	         Place this file in "cg/sapp" directory.

	         Example Map Entry:
            "bloodgulch": {
                "hog1": { <<<<<<<<<<<<<<<--------------------- Type "hog1" in chat to enter into Seat Position 0 of the Chain Gun Hog.
                    "seat": 0,
                    "vehicle": "vehicles\\warthog\\mp_warthog"
                },
                "hog2": { <<<<<<<<<<<<<<<--------------------- Type "hog2" in chat to enter into Seat Position 0 & 2 of the Chain Gun Hog (drive as gunner).
                    "seat": 7,
                    "vehicle": "vehicles\\warthog\\mp_warthog"
                },
                "rhog1": { <<<<<<<<<<<<<<<--------------------- Type "rhog1" in chat to enter into Seat Position 0 of the Rocket Hog.
                    "seat": 0,
                    "vehicle": "vehicles\\rwarthog\\rwarthog"
                },
                "rhog2": { <<<<<<<<<<<<<<<--------------------- Type "rhog2" in chat to enter into Seat Position 0 & 2 of the Rocket Hog (drive as gunner).
                    "seat": 7,
                    "vehicle": "vehicles\\rwarthog\\rwarthog"
                }
            },

FEATURES:
	* Command cooldowns
	* Auto Vehicle Despawn System
	* Limited Command uses (per game basis)
	* Customizable messages

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--======================================================================================================--
]]--

api_version = "1.12.0.0"

-- Configuration [Starts] ---------------------------------------------
local settings = {
    path = "sapp\\vehicles.json",
    spawns_per_game = 10, -- Number of vehicles the player can spawn PER GAME.
    despawn_time = 30, -- Unoccupied vehicles will despawn after this amount of time (in seconds)"
    cooldown_duration = 5, -- Command cooldown period.

    -- Custom Messages:
    on_spawn = "Vehicle entry-spawns remaining: %total%",
    please_wait = "Please wait %seconds% seconds to entry-spawn another vehicle",
    already_occupied = "You are already in a vehicle!",
    insufficient_spawns = "You have exceeded your Vehicle Entry-Spawn Limit for this game.",

    -- If enabled, this script will send a welcome message (containing command info) to the newly joined player
    -- This message appears in the RCON area.
    enable_welcome_message = true,
    -- Duration the welcome message stays on screen:
    welcome_message_duration = 10,

    -- This script will periodically announce the valid vehicle-entry commands
    -- How often should messages appear? (in seconds) 300 = 5 minutes
    command_message_duration = 180,

    -- Comma separated commands will be automatically be inserted at the end of the sentence...
    command_msg_variant_one = "Use this command to spawn a vehicle: ",
    command_msg_variant_two = "Use these commands to spawn a vehicle: ",
    server_prefix = "HLN | CE» ",
    script_version = 1.11
}
-- Configuration [Ends] ---------------------------------------------

-- Do not touch:
local map_data, valid_commands, vehicle_objects, players = {}, {}, {}, {}
local time_scale, game_started = 0.03333333333333333, nil
local gmatch, gsub, floor = string.gmatch, string.gsub, math.floor
local json = (loadfile "sapp\\json.lua")()

function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_CHAT"], "OnPlayerChat")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")

    if (get_var(0, "$gt") ~= "n/a") then
        say_all("HLN Vehicle Spawner (version " .. settings.script_version .. ") loaded.")
        CheckFile(true)
        for i = 1, 16 do
            if player_present(i) then
                InitPlayer(i, true)
            end
        end
    end
end

function OnScriptUnload()
    for k, _ in pairs(vehicle_objects) do
        if (vehicle_objects[k] ~= nil) then
            execute_command("sv_map_reset")
            destroy_object(k)
            vehicle_objects[k] = nil
        end
    end
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then
        CheckFile()
    end
end

function OnGameEnd()
    game_started, valid_commands = false, {}
    for i = 1, 16 do
        if player_present(i) then
            InitPlayer(i, false)
        end
    end
end

function OnTick()
    if (game_started) then

        for i, player in pairs(players) do
            if (i) and player_present(i) then

                if (settings.enable_welcome_message) then
                    local init_welcome_messages = (player.welcome and player.welcome.init and valid_commands.msg ~= "")
                    if (init_welcome_messages) then
                        player.welcome.timer = player.welcome.timer + time_scale
                        cls(i, 25)
                        rprint(i, player.welcome.msg)
                        if (player.welcome.timer >= settings.welcome_message_duration) then
                            player.welcome.timer, player.welcome.init = 0, false
                        end
                    end
                end

                if player_alive(i) then
                    DespawnHandler(i)
                    local init_cooldown = (player.cooldown and player.cooldown.init)
                    if (init_cooldown) then
                        player.cooldown.timer = player.cooldown.timer - time_scale
                        -- print("Cooldown ends in " .. floor(player.cooldown.timer) .. " seconds")
                        if (player.cooldown.timer <= 1) then
                            player.cooldown.timer = settings.cooldown_duration
                            player.cooldown.init = false
                        end
                    end
                end
            end
        end

        -- Periodically announce available vehicle commands:
        if (valid_commands.timer) then
            valid_commands.timer = valid_commands.timer + time_scale
            if (valid_commands.timer >= settings.command_message_duration) then
                valid_commands.timer = 0
                if (#valid_commands > 0 and valid_commands.msg ~= "") then
                    SayAll(valid_commands.msg)
                end
            end
        end
    end
end

function DespawnHandler(PlayerIndex)
    for k, v in pairs(vehicle_objects) do
        if (vehicle_objects[k] ~= nil) then
            if (v.vehicle ~= 0) then
                local occupied = false

                local player_object = get_dynamic_player(PlayerIndex)
                local VehicleID = read_dword(player_object + 0x11C)
                if (VehicleID ~= 0xFFFFFFFF) then
                    local current_vehicle = get_object_memory(VehicleID)
                    if (current_vehicle ~= 0) then
                        if (v.vehicle == current_vehicle) then
                            occupied = true
                            v.timer_reset = true
                        end
                    end
                end

                if (not occupied) then

                    if (v.timer_reset) then
                        v.timer_reset = false
                        v.timer = settings.despawn_time
                    end

                    v.timer = v.timer - time_scale
                    -- print("Vehicle [ID "..k.."] despawning in " .. floor(v.timer) .. " seconds")
                    if (vehicle_objects[k].timer <= 0) then
                        destroy_object(k)
                        vehicle_objects[k] = nil
                    end
                end
            end
        end
    end
end

function OnPlayerChat(PlayerIndex, Message, Type)
    local Str = stringSplit(Message)

    if (Type ~= 6) then
        if (#Str == 0) then
            return false
        else
            for _, Map in pairs(map_data) do
                for command, Vehicle in pairs(Map) do
                    if (Str[1] == command) then
                        if (game_started) then
                            if player_alive(PlayerIndex) then
                                if GetTag(Vehicle.vehicle) then
                                    local t = players[PlayerIndex].cooldown
                                    if (t.uses > 0) then
                                        if (not t.init) then

                                            local player_object = get_dynamic_player(PlayerIndex)
                                            local coords = getXYZ(PlayerIndex, player_object)

                                            if not (coords.invehicle) then
                                                t.init = true
                                                t.uses = t.uses - 1

                                                local vehicle = spawn_object("vehi", Vehicle.vehicle, coords.x, coords.y, coords.z)
                                                local vehicle_object_memory = get_object_memory(vehicle)

                                                if (vehicle_object_memory ~= 0) then
                                                    vehicle_objects[vehicle] = {
                                                        timer_reset = false,
                                                        vehicle = vehicle_object_memory,
                                                        timer = settings.despawn_time,
                                                    }
                                                end

                                                if (tonumber(Vehicle.seat) == 7) then
                                                    enter_vehicle(vehicle, PlayerIndex, 0)
                                                    enter_vehicle(vehicle, PlayerIndex, 2)
                                                else
                                                    enter_vehicle(vehicle, PlayerIndex, 0)
                                                end

                                                local msg = gsub(settings.on_spawn, "%%total%%", tostring(t.uses))
                                                rprint(PlayerIndex, msg)
                                            else
                                                rprint(PlayerIndex, settings.already_occupied)
                                            end
                                        else
                                            local msg = gsub(settings.please_wait, "%%seconds%%", tostring(floor(t.timer)))
                                            rprint(PlayerIndex, msg)
                                        end
                                    else
                                        rprint(PlayerIndex, settings.insufficient_spawns)
                                    end
                                else
                                    rprint(PlayerIndex, "Invalid Vehicle Tag Address")
                                    rprint(PlayerIndex, "Please Contact an Administrator. Map Name: " .. get_var(0, "$map"))
                                end
                            else
                                rprint(PlayerIndex, "Please wait until you respawn")
                            end
                        else
                            rprint(PlayerIndex, "Please wait until the next game begins.")
                        end
                        return false
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

function OnPlayerDeath(PlayerIndex)
    players[PlayerIndex].cooldown.init = false
    players[PlayerIndex].cooldown.duration = settings.cooldown_duration
end

function stringSplit(Command)
    local t, i = {}, 1
    for Args in gmatch(Command, "([^%s]+)") do
        t[i] = Args
        i = i + 1
    end
    return t
end

function InitPlayer(PlayerIndex, Init)
    if (Init) then
        players[PlayerIndex] = {
            welcome = {
                timer = 0,
                init = true,
                msg = valid_commands.msg,
            },
            cooldown = {
                init = false,
                timer = settings.cooldown_duration,
                uses = settings.spawns_per_game
            }
        }
    else
        players[PlayerIndex] = {}
    end
end

-- Receives a string and executes SAPP function 'say_all' without the **HLN | CE** prefix.
-- Restores the prefix when relay is done.
function SayAll(Message)
    execute_command("msg_prefix \"\"")
    say_all(Message)
    execute_command("msg_prefix \" " .. settings.server_prefix .. "\"")
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

function GetTag(Object)
    local tag = lookup_tag("vehi", Object)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function cls(PlayerIndex, Count)
    for _ = 1, Count do
        rprint(PlayerIndex, " ")
    end
end

function CheckFile(broadcast)
    local path = settings.path
    local file = io.open(path, "a")
    if (file ~= nil) then
        io.close(file)
    end

    local info
    local file = io.open(settings.path, "r")
    if (file ~= nil) then
        local data = file:read("*all")
        info = json:decode(data)
        io.close(file)
    end

    map_data, players, valid_commands = {}, {}, {}
    valid_commands.msg = ""
    valid_commands.timer = 0
    local current_map = get_var(0, "$map")
    if (info) then
        for map, v in pairs(info) do
            if (map) and (map == current_map) then
                map_data[#map_data + 1] = v
            end
        end
        if (#map_data > 0) then
            for _, Tab in pairs(map_data) do
                for Command, _ in pairs(Tab) do
                    valid_commands[#valid_commands + 1] = Command
                end
            end

            local count, separator = 0, ", "
            for _, Tab in pairs(map_data) do
                for Command, _ in pairs(Tab) do
                    count = count + 1
                    if (count < #valid_commands) then
                        valid_commands.msg = valid_commands.msg .. Command .. separator
                    else
                        valid_commands.msg = valid_commands.msg .. Command
                    end
                end
            end

            if (#valid_commands == 1) then
                valid_commands.msg = settings.command_msg_variant_one .. valid_commands.msg
            else
                valid_commands.msg = settings.command_msg_variant_two .. valid_commands.msg
            end
            if (broadcast) then
                say_all("HLN Vehicle Spawner successfully loaded vehicle data from database.")
            end
        end
    end
    game_started = true
end
