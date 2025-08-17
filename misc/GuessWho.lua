--[[
--=====================================================================================================--
Script Name: GuessWho , for SAPP (PC & CE)
Description: N/A

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.11.0.0"

local GuessWho = {

    --===== [ CONFIG STARTS ] ======--

    -- # Number of players required to set the game in motion (cannot be less than 3)
    required_players = 3,

    -- # Continuous message emitted when there aren't enough players.
    not_enough_players = "|c%current%/%required% players needed to start the game.",

    -- # Countdown delay (in seconds)
    -- This is a pre-game-start countdown initiated at the beginning of each game.
    delay = 10,

    -- # This message is the pre-game broadcast:
    pre_game_message = "|cGuessWho (v1.0) will begin in %minutes%:%seconds%",

    -- # This message is broadcast when the game begins:
    on_game_begin = "|cThe game has begun",

    -- Some functions temporarily remove the server prefix while broadcasting a message.
    -- This prefix will be restored to 'server_prefix' when the message relay is done.
    -- Enter your servers default prefix here:
    server_prefix = "** SERVER **",

    detective_weapon = { "weap", "weapons\\pistol\\pistol" },
    shooter_weapon = { "weap", "weapons\\shotgun\\shotgun" },

    maps = {
        ["bloodgulch"] = {
            r = 2.5,
            x = 65.749893188477,
            y = -120.40949249268,
            z = 0.11860413849354
        },
        -- more maps added in future updates

    }

    --===== [ CONFIG ENDS ] ======--

}

local players = { }
local coordinates = { }

local time_scale = 1 / 30
local game_started = false

local map

local gsub = string.gsub
local floor = math.floor
local format = string.format

function OnScriptLoad()

    -- Register needed event callbacks:
    register_callback(cb['EVENT_TICK'], "OnTick")

    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    register_callback(cb["EVENT_PRESPAWN"], "OnPreSpawn")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")

    if (get_var(0, '$gt') ~= "n/a") then
        game_started = false
        map = get_var(0, "$map")
    end
end

function OnScriptUnload()
    --
end

function OnTick()

    if (not game_started) then
        PreGameCountdown()
    end

    for player, v in pairs(players) do
        if (player) then
            if player_present(player) then

                -- Not Enough players
                if (GameState(player) == 1) then
                    cls(player, 25)
                    local player_count = tonumber(get_var(0, "$pn"))
                    local msg = gsub(gsub(GuessWho.not_enough_players,
                            "%%current%%", player_count),
                            "%%required%%", GuessWho.required_players)
                    Respond(player, msg, "rcon")

                    -- Show Pre Game Countdown
                elseif (GameState(player) == 2) then
                    cls(player, 25)
                    local msg = gsub(gsub(GuessWho.pre_game_message,
                            "%%minutes%%", GuessWho.minutes),
                            "%%seconds%%", GuessWho.seconds)
                    Respond(player, msg, "rcon")

                    -- Game is in play
                elseif (GameState() == 3) then
                    if (v.set_weapons) and player_alive(player) then
                        v.set_weapons = false

                        local DynamicPlayer = get_dynamic_player(player)
                        if (DynamicPlayer ~= 0) then

                            local coords = getXYZ(DynamicPlayer)
                            execute_command("wdel " .. player)

                            if (v.detective) then
                                assign_weapon(spawn_object(GuessWho.detective_weapon[1], GuessWho.detective_weapon[2], coords.x, coords.y, coords.z), player)
                            else
                                assign_weapon(spawn_object(GuessWho.shooter_weapon[1], GuessWho.shooter_weapon[2], coords.x, coords.y, coords.z), player)
                            end
                        end
                    elseif (v.shooter_hud) then
                        cls(player, 25)
                        local p = GetDetShoot()
                        if (p.detective) then
                            if (not players[p.detective].shot) then
                                rprint(player, "|c----------------------------------")
                                rprint(player, "|cSHOOT THE DETECTIVE")
                                rprint(player, "|c----------------------------------")
                            else
                                rprint(player, "|c----------------------------------")
                                rprint(player, "|cWAITING FOR DETECTIVE TO IDENTIFY YOU")
                                rprint(player, "|c----------------------------------")
                            end
                        end
                    elseif (v.detective_hud) then
                        cls(player, 25)
                        if (not v.shot) then
                            rprint(player, "|c----------------------------------")
                            rprint(player, "|cWAITING FOR PLAYER TO SHOOT YOU!")
                            rprint(player, "|c----------------------------------")
                        else
                            rprint(player, "|c----------------------------------")
                            rprint(player, "|cCORRECTLY IDENTIFY THE SHOOTER")
                            rprint(player, "|c----------------------------------")
                        end
                    else
                        local p = GetDetShoot()
                        if (p.shooter and p.detective) then
                            local s_name = get_var(p.shooter, "$name")
                            local d_name = get_var(p.detective, "$name")
                            cls(player, 25)
                            rprint(player, "|c----------------------------------")
                            rprint(player, "|cSHOOTER IS: " .. s_name .. " | DETECTIVE IS " .. d_name)
                            rprint(player, "|c----------------------------------")
                        end
                    end
                end
            end
        end
    end
end

function OnGameStart()
    if (get_var(0, '$gt') ~= "n/a") then
        GuessWho.countdown = 0
        game_started = false
        map = get_var(0, "$map")
    end
end

function OnGameEnd()
    GuessWho.countdown = 0
end

function GameState()
    local player_count = tonumber(get_var(0, "$pn"))

    -- Print the NEP message:
    if (player_count > 0 and player_count < GuessWho.required_players) and (not game_started) then
        return 1
        -- Print the Pre Game Countdown:
    elseif (player_count >= GuessWho.required_players) and (not game_started) then
        return 2
    elseif (player_count > 0) and (game_started) then
        return 3
    end
end

function OnPlayerConnect(PlayerIndex)
    initPlayer(PlayerIndex, false)
end

function OnPlayerDisconnect(PlayerIndex)
    initPlayer(PlayerIndex, true)
end

function OnPreSpawn(PlayerIndex)

    for player, v in pairs(players) do
        if (player == PlayerIndex) then
            local DynamicPlayer = get_dynamic_player(PlayerIndex)
            if (DynamicPlayer ~= 0) then
                if (v.setspawn) and (game_started) then
                    v.setspawn = false

                    local n = GetRandomUnoccupiedSpawnPoint()

                    coordinates[n].occupied[1] = true

                    if (v.detective) then
                        coordinates[n].occupied[2] = player
                        write_vector3d(DynamicPlayer + 0x5C, GuessWho.maps[map].x, GuessWho.maps[map].y, GuessWho.maps[map].z)
                    else
                        coordinates[n].occupied[2] = player
                        write_vector3d(DynamicPlayer + 0x5C, coordinates[n].x, coordinates[n].y, 0.5)
                    end

                    v.set_weapons = true
                end
            end
        end
    end
end

function initPlayer(PlayerIndex, Reset)
    if (Reset) then

        for i = 1, #coordinates do
            if (coordinates[i].occupied[2] == PlayerIndex) then
                coordinates[i].occupied[2] = 0
                coordinates[i].occupied[1] = false
            end
        end

        if (players[PlayerIndex].shooter) then
            SetRandomShooter()
        elseif (players[PlayerIndex].detective) then
            SetRandomDetective()
        end

        players[PlayerIndex] = { }
    else
        players[PlayerIndex] = {

            selected = 0,
            countdown = 0,

            shot = false,
            setspawn = true,
            shooter = false,
            detective = false,

            shooter_hud = false,
            detective_hud = false,
        }
    end
end

function cls(PlayerIndex, count)
    local count = count or 25
    for _ = 1, count do
        rprint(PlayerIndex, " ")
    end
end

function secondsToTime(seconds, bool)
    local seconds = tonumber(seconds)
    if (seconds <= 0) and (bool) then
        return "00", "00";
    else
        local hours, mins, secs = format("%02.f", floor(seconds / 3600));
        mins = format("%02.f", floor(seconds / 60 - (hours * 60)));
        secs = format("%02.f", floor(seconds - hours * 3600 - mins * 60));
        return mins, secs
    end
end

function Respond(PlayerIndex, Message, Type)
    if (Type == "rcon") then
        rprint(PlayerIndex, Message)
    else
        execute_command("msg_prefix \"\"")
        say(PlayerIndex, Message)
        execute_command("msg_prefix \" " .. GuessWho.server_prefix .. "\"")
    end
end

function SetCircle()

    coordinates = { }

    local r = GuessWho.maps[map].r
    local x, y = GuessWho.maps[map].x, GuessWho.maps[map].y

    local iterations = 0
    for i = 1, 360 do
        if (i > iterations) then
            iterations = iterations + 22.5
            local angle = i * math.pi / 180
            coordinates[#coordinates + 1] = {
                x = x + r * math.cos(angle),
                y = y + r * math.sin(angle),
                occupied = { false, 0 },
            }
        end
    end

    SetRandomShooter()
    SetRandomDetective()
end

function ResetMap()
    local kma = sig_scan("8B42348A8C28D500000084C9") + 3
    local original = read_dword(kma)
    safe_write(true)
    write_dword(kma, 0x03EB01B1)
    safe_write(false)

    execute_command("sv_map_reset")

    safe_write(true)
    write_dword(kma, original)
    safe_write(false)

    game_started = true
end

function PreGameCountdown()
    if (GameState() == 2) then
        GuessWho.countdown = GuessWho.countdown + time_scale
        GuessWho.minutes, GuessWho.seconds = secondsToTime(GuessWho.delay - GuessWho.countdown)
        if (tonumber(GuessWho.minutes) == 0 and tonumber(GuessWho.seconds) == 0) then
            SetCircle()
            ResetMap()
        end
    end
end

function GetRandomUnoccupiedSpawnPoint()

    local t = { }
    for i = 1, #coordinates do
        if (not coordinates[i].occupied[1]) then
            t[#t + 1] = i
        end
    end

    math.randomseed(os.time())
    return t[math.random(#t)]
end

function SetRandomShooter()

    local t = { }
    for i = 1, 16 do
        if player_present(i) then
            if (not players[i].shooter) and (not players[i].detective) then
                t[#t + 1] = i
            end
        end
    end

    math.randomseed(os.time())
    local n = t[math.random(#t)]
    if (n) then
        players[n].shooter = true
        players[n].shooter_hud = true
    end
end

function SetRandomDetective()

    local t = { }
    for i = 1, 16 do
        if player_present(i) then
            if (not players[i].shooter) and (not players[i].detective) then
                t[#t + 1] = i
            end
        end
    end

    math.randomseed(os.time())
    local n = t[math.random(#t)]
    if (n) then
        players[n].detective = true
        players[n].detective_hud = true

        if (game_started) then
            local DynamicPlayer = get_dynamic_player(n)
            if (DynamicPlayer ~= 0) then
                write_vector3d(DynamicPlayer + 0x5C, GuessWho.maps[map].x, GuessWho.maps[map].y, GuessWho.maps[map].z)
            end
        end
    end
end

function getXYZ(DynamicPlayer)
    local coords, x, y, z = { }

    local VehicleID = read_dword(DynamicPlayer + 0x11C)
    if (VehicleID == 0xFFFFFFFF) then
        x, y, z = read_vector3d(DynamicPlayer + 0x5c)
    else
        x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
    end

    coords.x, coords.y, coords.z = x, y, z
    return coords
end

function OnDamageApplication(VictimIndex, CauserIndex, _, _, _, _)

    local victim, causer = tonumber(VictimIndex), tonumber(CauserIndex)
    if (causer > 0) and (victim ~= causer) then
        if (players[causer].shooter) and (players[victim].detective and not players[victim].shot) then
            players[victim].shot = true
        elseif (players[causer].detective and players[causer].shot) and (players[victim].shooter) then
            for i = 1, #coordinates do
                if (coordinates[i].occupied[2] == causer) then

                    --
                    coordinates[i].occupied[2] = 0
                    coordinates[i].occupied[1] = false

                    players[causer].shot = true
                    players[causer].detective = false
                    players[causer].detective_hud = false

                    players[victim].shooter = false
                    players[victim].shooter_hud = false

                    local DynamicPlayer = get_dynamic_player(causer)
                    if (DynamicPlayer ~= 0) then
                        write_vector3d(DynamicPlayer + 0x5c, coordinates[i].x, coordinates[i].y, 0.5)
                    end
                end
            end
        end
        return false
    end
end

-- todo:
-- announce "game begun message"
-- Modify player speed
-- Write End-Game logic
-- custom team colors

function GetDetShoot()
    local t = { }
    for k, v in pairs(players) do
        if (v.shooter) then
            t.shooter = k
        elseif (v.detective) then
            t.detective = k
        end
    end
    return t
end
