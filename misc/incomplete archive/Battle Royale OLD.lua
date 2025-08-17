--[[
--=====================================================================================================--
Script Name: Battle Royale (beta v1.0), for SAPP (PC & CE)
Description: N/A

[!] NOT READY FOR DOWNLOAD

Planned Features:
* Sky Spawning System
* Backpacks
* Weapon Generation
* Loot Crates

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
local boundary = { }

-- ==== Battle Royale Configuration [starts] ==== --

boundary.settings = {

    spectator_running_speed = 2,

    -- IMPORTANT: (1 world unit = 10 feet or ~3.048 meters)
    maps = {
        ["timberland"] = {
            -- boundary: x,y,z, Min Size, Max Size:
            1.245, -1.028, -21.186, 50, 4700,
            -- End the game this many minutes after the boundary reaches its smallest possible size of 'Min Size':
            extra_time = 2,
            -- How often does the boundary reduce in size (in seconds):
            duration = 30,
            -- How many world units does the boundary reduce in size:
            reduction_amount = 500,
            -- Players needed to start the game:
            players_needed = 2,
            -- When enough players are present, the game will start in this many seconds:
            gamestart_delay = 30,

            -- Players will be auto-killed if outside combat zone:
            -- * The non-combat-zone is any area outside the boundary start coordinates (x,y,z).
            -- * This is different from the playable boundary that has shrunk.
            time_until_kill = 5,

        },
        ["carousel"] = {
            0.012, -0.029, -0.856, 30, 270,
            extra_time = 2, duration = 30, reduction_amount = 30, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["ratrace"] = {
            8.340, -10.787, 0.222, 50, 415,
            extra_time = 2, duration = 30, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["sidewinder"] = {
            2.051, 55.220, -2.801, 150, 5500,
            extra_time = 2, duration = 25, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["beavercreek"] = {
            14.015, 14.238, -0.911, 10, 415,
            extra_time = 2, duration = 30, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["dangercanyon"] = {
            -0.477, 55.331, 0.239, 60, 6500,
            extra_time = 2, duration = 20, reduction_amount = 500, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["bloodgulch"] = {
            65.749, -120.409, 0.118, 40, 7100,
            extra_time = 2, duration = 30, reduction_amount = 900, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["boardingaction"] = {
            18.301, -0.573, 0.420, 30, 4500,
            extra_time = 2, duration = 3, reduction_amount = 500, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["gephyrophobia"] = {
            26.735, -72.359, -16.996, 40, 6200,
            extra_time = 2, duration = 20, reduction_amount = 500, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["deathisland"] = {
            -30.282, 31.312, 16.601, 30, 5000,
            extra_time = 2, duration = 25, reduction_amount = 500, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["icefields"] = {
            -26.032, 32.365, 9.007, 30, 7500,
            extra_time = 2, duration = 30, reduction_amount = 500, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["infinity"] = {
            9.631, -64.030, 7.776, 100, 11500,
            extra_time = 2, duration = 30, reduction_amount = 1000, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["hangemhigh"] = {
            21.020, -4.632, -4.229, 10, 605,
            extra_time = 2, duration = 30, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["damnation"] = {
            6.298, 0.047, 3.400, 15, 600,
            extra_time = 2, duration = 15, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["putput"] = {
            -3.751, -20.800, 0.902, 15, 1600,
            extra_time = 2, duration = 30, reduction_amount = 100, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["prisoner"] = {
            0.902, 0.088, 1.392, 15, 400,
            extra_time = 2, duration = 30, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["wizard"] = {
            -5.035, -5.064, -2.750, 20, 350,
            extra_time = 2, duration = 15, reduction_amount = 30, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
        ["longest"] = {
            -0.840, -14.540, 2.410, 20, 300,
            extra_time = 2, duration = 30, reduction_amount = 50, players_needed = 2, time_until_kill = 5, gamestart_delay = 30
        },
    },
}

-- Several functions temporarily remove the "** SERVER **" prefix when certain messages are broadcast.
-- The prefix will be restored to 'server_prefix' when the relay has finished.
local server_prefix = "**LNZ**"
-- ==== Battle Royale Configuration [ends] ==== --

local bX, bY, bZ, bR
local min_size, max_size, extra_time, reduction_rate, reduction_amount
local start_trigger, game_in_progress, game_time = true, false, 0
local monitor_coords, time_until_kill, gamestart_delay
local time_scale = 0.03333333333333333

local spawn_coordinates
local invincibility, godmode_countdown = { }, { }

local console_paused, paused = { }, { }
local out_of_bounds = { }

local last_man_standing = { }
last_man_standing.count = 0
last_man_standing.player = nil

local spectator, health_trigger, health, health_bool = { }, { }, { }, { }
local spectator_running_speed
local zone_transition = { }
local flag_table = { }

local gamestart_countdown, init_countdown
local init_victory_timer, victory_timer = false, 0
local current_players = 0

local globals = nil
local red_flag, blue_flag
local kill_message_addresss, originl_kill_message
local floor, format = math.floor, string.format
local gmatch, sub = string.gmatch, string.sub

function OnScriptLoad()
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    local gp = sig_scan("8B3C85????????3BF9741FE8????????8B8E2C0200008B4610") + 3
    if (gp == 3) then
        return
    end
    globals = read_dword(gp)

    kill_message_addresss = sig_scan("8B42348A8C28D500000084C9") + 3
    originl_kill_message = read_dword(kill_message_addresss)
end

function OnScriptUnload()
    --
end

function enableKillMessages()
    safe_write(true)
    write_dword(kill_message_addresss, originl_kill_message)
    safe_write(false)
end

function disableKillMessages()
    safe_write(true)
    write_dword(kill_message_addresss, 0x03EB01B1)
    safe_write(false)
end

local function set(reset_scores)
    for i = 1, 16 do
        if player_present(i) then

            -- Ensure all players have full health
            execute_command("hp " .. i .. " 1")
            health_trigger[i] = 0
            health_bool[i] = false

            -- Save current health to an array:
            health[i] = get_var(i, "$hp")

            if (reset_scores) then
                execute_command("score " .. i .. " 0")
                execute_command("kills " .. i .. " 0")
                execute_command("assists " .. i .. " 0")
                execute_command("deaths " .. i .. " 0")
            end
        end
    end
end

local function SpawnFlag(x, y, z)
    local tag_name, tag_id = "weap", "weapons\\flag\\flag"
    if TagInfo(tag_name, tag_id) then

        if (#flag_table > 0) then
            for i = 1, #flag_table do
                local _flag_ = flag_table[i]
                if get_object_memory(_flag_) then
                    DestroyObject(_flag_)
                end
            end
        end

        local flag = spawn_object(tag_name, tag_id, x, y, z + 0.5)
        flag_table[#flag_table + 1] = flag
    end
end

-- Initialize start up parameters:
local expected_reductions
local function init_params(reset)
    local mapname = get_var(0, "$map")
    local coords = boundary.settings.maps[mapname]
    if (coords ~= nil) then

        -- Declare boundary Minimum/Maximum size
        min_size, max_size = coords[4], coords[5]

        -- Declare boundary reduction rate/size
        reduction_rate, reduction_amount = coords.duration, coords.reduction_amount

        -- Calculated total game time:
        local radius = max_size
        for i = 1, max_size do
            if (radius <= max_size) then
                radius = (radius - reduction_amount)
                if (radius < min_size) then

                    -- If 'radius' is negative:
                    -- Calculate the difference between the current radius and 'min_size'.
                    local offset = math.abs(radius)
                    local calculated_max = (max_size + offset)

                    -- Extra time allocated when the boundary reaches its smallest possible size:
                    extra_time = (coords.extra_time * 60)

                    game_time = (reduction_rate * (calculated_max / reduction_amount) + extra_time)
                    expected_reductions = (i)
                    break
                end
            end
        end

        -- Init boundary coordinates and Radius
        bX, bY, bZ, bR = coords[1], coords[2], coords[3], max_size

        time_until_kill, gamestart_delay = coords.time_until_kill, coords.gamestart_delay

        -- Set initial timers to ZERO.
        game_timer, boundary_timer = 0, 0

        -- Init boundary checker:
        monitor_coords = true

        spectator_running_speed = (boundary.settings.spectator_running_speed)

        if (reset) then
            set(false)
            stopTimer()
            last_man_standing.count = 0
            last_man_standing.player = nil
            unregister_callback(cb['EVENT_DIE'])
            unregister_callback(cb['EVENT_TICK'])
            unregister_callback(cb['EVENT_CHAT'])
            unregister_callback(cb['EVENT_SPAWN'])
            unregister_callback(cb['EVENT_COMMAND'])
            unregister_callback(cb['EVENT_PRESPAWN'])
            unregister_callback(cb['EVENT_GAME_END'])
            unregister_callback(cb['EVENT_DAMAGE_APPLICATION'])
        else
            set(true)
            startTimer()
            -- Register hooks into SAPP Events:
            register_callback(cb["EVENT_TICK"], "OnTick")
            register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
            register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
            register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
            register_callback(cb['EVENT_COMMAND'], "OnServerCommand")
        end
    end
end

function OnGameStart()
    setupSpawns()
    enableKillMessages()
    red_flag, blue_flag = read_dword(globals + 0x8), read_dword(globals + 0xC)
end

function OnGameEnd()
    if (game_timer ~= nil) and (game_timer > 0) then
        game_timer = nil
        boundary_timer = nil
        monitor_coords = nil
        start_trigger, game_in_progress, game_time = true, false, 0
        init_params(true)
        cls(0, 25, true, "rcon")
    elseif (gamestart_countdown ~= nil) and (gamestart_countdown > 0) then
        start_trigger, game_in_progress, game_time = true, false, 0
        stopTimer()
        init_params(true)
        cls(0, 25, true, "rcon")
    end
end

-- Receives a string and executes SAPP function 'say_all' without the **SERVER** prefix.
-- Restores the prefix when relay is done.
local SayAll = function(Message)
    if (Message) then
        execute_command("msg_prefix \"\"")
        say_all(Message)
        execute_command("msg_prefix \" " .. server_prefix .. "\"")
    end
end

-- This function returns the total number of players currently online.
local player_count = function(alternative)
    if (alternative) then
        return tonumber(current_players)
    else
        return tonumber(get_var(0, "$pn"))
    end
end

local players_needed = function()
    local mapname = get_var(0, "$map")
    local coords = boundary.settings.maps[mapname]
    if (coords ~= nil) then
        return tonumber(coords.players_needed)
    end
end

function OnPlayerConnect(PlayerIndex)
    local p = tonumber(PlayerIndex)
    current_players = current_players + 1

    local enough_players = (player_count(false) >= players_needed())

    local function player_setup(player, in_progress)
        console_paused[player] = false

        out_of_bounds[player] = { }
        out_of_bounds[player].yes, out_of_bounds[player].timer = false, 0

        paused[player] = { }
        paused[player].start, paused[player].timer, paused[player].duration = false, 0, 0

        spectator[player] = { }
        spectator[player].enabled, spectator[player].timer = false, 0

        zone_transition[player] = false

        invincibility[player] = 0
        godmode_countdown[player] = 0

        if (in_progress) then
            spectator[player].enabled = true
        end
    end

    if (start_trigger) and (enough_players) then
        last_man_standing.count = last_man_standing.count + 1
        start_trigger = false

        -- Initialize game parameters:
        init_params(false)

        -- Setup player parameters:
        player_setup(p, false)

    elseif (start_trigger and not enough_players) then
        last_man_standing.count = last_man_standing.count + 1
        player_setup(p, false)
    elseif (game_in_progress and enough_players) then
        player_setup(p, true)
    elseif not (game_in_progress) and (enough_players) then
        last_man_standing.count = last_man_standing.count + 1
        player_setup(p, false)
    end
end

function OnPlayerDisconnect(PlayerIndex)
    current_players = current_players - 1

    local enough_players = (player_count(true) >= players_needed())
    if (init_countdown) and not (enough_players) then
        stopTimer()
        game_timer, boundary_timer, monitor_coords = nil, nil, nil
        start_trigger, game_in_progress, game_time = true, false, 0
        init_params(true)
        cls(0, 25, true, "rcon")
    end

    local p = tonumber(PlayerIndex)

    if (spectator[p] ~= nil and not spectator[p].enabled) then
        spectator[p] = nil
        last_man_standing.count = last_man_standing.count - 1
    end

    local count = last_man_standing.count

    if (count < 1) then
        -- Initialize game parameters:
        init_params(true)
    elseif (count == 1) then
        for i = 1, 16 do
            if player_present(i) and (tonumber(i) ~= p) then
                last_man_standing.player = tonumber(i)
            end
        end
    end
end

local function getRandomCoord()
    local mapname = get_var(0, "$map")
    local t = spawn_coordinates[mapname]
    if (t) then
        for i = 1, #t do
            if (t[i] ~= nil) then
                local rn = rand(1, #t)
                if (t[rn] ~= "in_use") then
                    local x, y, z, h, time = t[rn][1], t[rn][2], t[rn][3], t[rn][4], t[rn][5]
                    t[rn] = "in_use"
                    return x, y, z, h, time
                end
            end
        end
    end
end

function Teleport(TargetID)
    local player_object = get_dynamic_player(TargetID)
    if (player_object ~= 0) then
        execute_command("god " .. TargetID)

        local x, y, z, h, time = getRandomCoord()
        if (x) then
            invincibility[TargetID] = time
            write_vector3d(player_object + 0x5C, x, y, z + h)
        end
    end
end

function OnPlayerPrespawn(PlayerIndex)
    local t = godmode_countdown[PlayerIndex]
    if (t ~= nil and t ~= "null") then
        Teleport(PlayerIndex)
        return false
    end
end

function OnPlayerSpawn(PlayerIndex)
    -- Not currently used.
end

function boundary:shrink()
    if (bR ~= nil) then
        bR = (bR - reduction_amount)
        expected_reductions = expected_reductions - 1
        if (bR <= min_size) then
            bR, reduction_timer = min_size, nil
            SayAll("BOUNDARY IS NOW AT ITS SMALLEST POSSIBLE SIZE!", 4 + 8)
        else
            SayAll("[ BOUNDARY REDUCTION ] Radius now (" .. bR .. ") world units", 4 + 8)
        end
    end
end

local function reduceHealth(p, bool)

    if not (health_bool[p]) then
        health_bool[p] = true
        health[p] = get_var(p, "$hp")
    end

    if not (bool) then
        health_trigger[p] = health_trigger[p] + time_scale

        if (zone_transition[p]) then
            zone_transition[p] = false
            local old_health = health[p]
            execute_command("hp " .. p .. " " .. old_health)
        end

        if (health_trigger[p] ~= nil and health_trigger[p] >= 2) then
            health_trigger[p] = 0

            local new_health = (get_var(p, "$hp") - 0.10)
            execute_command("hp " .. p .. " " .. new_health)

            local current_health = tonumber(get_var(p, "$hp"))
            if (current_health <= 0) then
                killPlayer(p)
                spectator[p].enabled = true
                last_man_standing.count = last_man_standing.count - 1
                local name = get_var(p, "$name")
                SayAll(name .. " has perished! " .. last_man_standing.count .. " players remain.")
            end
        end
    else
        execute_command("hp " .. p .. " 0.10")
    end
end

local function restoreHealth(p)
    health_trigger[p] = 0
    if (health_bool[p]) then
        health_bool[p] = false
        local old_health = health[p]
        execute_command("hp " .. p .. " " .. old_health)
    end
end

function boundary:inSphere(p, px, py, pz, x, y, z, r)
    local coords = ((px - x) ^ 2 + (py - y) ^ 2 + (pz - z) ^ 2)
    if (coords < r) then
        console_paused[p], out_of_bounds[p].yes = false, false
        restoreHealth(p)
        return true
    elseif (coords > r) and (coords < max_size) then
        console_paused[p] = false
        reduceHealth(p, false)
        return false
    elseif (coords > max_size) and not (console_paused[p]) then
        zone_transition[p] = true
        console_paused[p] = true
        reduceHealth(p, true)
        return false
    end
end

function checkForPause()
    for i = 1, 16 do
        if player_present(i) then
            if (paused[i] ~= nil) then
                if (paused[i].start) then
                    paused[i].timer = paused[i].timer + time_scale
                    if (paused[i].timer >= paused[i].duration) then
                        paused[i].start, paused[i].timer = false, 0
                        cls(i, 25)
                    end
                end
            end
        end
    end
end

local function hide_player(p, coords)
    local xOff, yOff, zOff = 1000, 1000, 1000
    write_float(get_player(p) + 0x100, coords.z - zOff)
    write_float(get_player(p) + 0xF8, coords.x - xOff)
    write_float(get_player(p) + 0xFC, coords.y - yOff)
end

local function DispayHUD(params)
    local time_remaining = params.time_remaining
    if (time_remaining ~= nil) then

        local shrink_time_msg = params.shrink_time_msg
        local until_next_shrink = params.until_next_shrink

        local boundary_timer = params.boundary_timer
        if (boundary_timer ~= nil and until_next_shrink ~= nil) then
            shrink_time_msg = " | Time Until boundary Reduction: " .. until_next_shrink
        else
            shrink_time_msg = ""
        end

        local time_stamp = params.time_stamp
        local _extra_time = params.extra_time

        local header, send_timestamp = ""
        if (time_remaining > _extra_time) then
            send_timestamp = true
            header = "Game Time Remaining: " .. time_stamp
        elseif (time_remaining > 0) and (time_remaining <= _extra_time) then
            send_timestamp = true
            header = "FINAL MINUTES: " .. time_stamp
        elseif (time_remaining <= 0) then
            send_timestamp = false
            game_timer = nil
            monitor_coords = false
            GameOver()
        end

        if (send_timestamp) and (monitor_coords) then
            local player = params.player
            if not (spectator[player].enabled) then
                out_of_bounds[player].timer = 0
            end
            rprint(player, "|c" .. header .. shrink_time_msg)
            rprint(player, "|cReductions Left: " .. expected_reductions)
        end
    end
end

function endGameCheck()
    if (last_man_standing.count <= 1) then
        GameOver()
    end
end

function OnTick()
    if (init_countdown) then
        GameStartCountdown()
    elseif not (init_countdown) and not (init_victory_timer) then

        endGameCheck()

        local time_stamp, until_next_shrink
        local time_remaining

        if (game_timer ~= nil) then
            game_timer = game_timer + time_scale

            local time = ((game_time + 1) - (game_timer))
            time_remaining = time

            local GTmins, GTsecs = select(1, secondsToTime(time, true)), select(2, secondsToTime(time, true))
            time_stamp = (GTmins .. ":" .. GTsecs)

            -- BOUNDARY REDUCTION TIMER:

            if (boundary_timer ~= nil) then
                boundary_timer = boundary_timer + time_scale

                local time_left = ((reduction_rate + 1) - (boundary_timer))
                local mins, secs = select(1, secondsToTime(time_left)), select(2, secondsToTime(time_left))
                until_next_shrink = (mins .. ":" .. secs)

                if (boundary_timer >= (reduction_rate + 1)) then
                    if (bR > min_size and bR <= max_size) then
                        boundary_timer = 0
                        boundary:shrink()
                    end
                end
            end
        end

        for i = 1, 16 do
            if player_present(i) then

                local player_object = get_dynamic_player(i)
                if (player_object ~= 0) then

                    -- Invincibility Timer:
                    if (godmode_countdown[i] ~= nil and godmode_countdown[i] ~= "null") then

                        godmode_countdown[i] = godmode_countdown[i] + time_scale
                        execute_command("god " .. i)

                        if (godmode_countdown[i] >= invincibility[i]) then
                            godmode_countdown[i], invincibility[i] = "null", 0
                            execute_command_sequence("ungod " .. i .. ";hp " .. i .. " 1")
                        end
                    end

                    checkForPause()

                    if (not paused[i].start) then
                        cls(i, 25)
                    end

                    local p = { }
                    p.player = tonumber(i)
                    p.boundary_timer = boundary_timer
                    p.shrink_time_msg = shrink_time_msg
                    p.until_next_shrink = until_next_shrink
                    p.time_remaining = time_remaining
                    p.extra_time, p.time_stamp = extra_time, time_stamp

                    if (spectator[i] ~= nil) and (spectator[i].enabled) then
                        local count = last_man_standing.count
                        rprint(i, "|cYOU ARE IN SPECTATOR MODE")
                        rprint(i, "|c--- Players Remaining --- ")
                        rprint(i, "|c" .. count)

                        DispayHUD(p)

                        local coords = getXYZ(i)
                        if (coords) then
                            execute_command("camo " .. i)
                            execute_command("s " .. tonumber(i) .. " " .. tonumber(spectator_running_speed))
                            hide_player(i, coords)
                        end

                    elseif (spectator[i] ~= nil) and not (spectator[i].eanbled) then

                        local px, py, pz, rUnits
                        local coords = getXYZ(i)

                        if (coords) then
                            px, py, pz = coords.x, coords.y, coords.z
                        else
                            px, py, pz = read_vector3d(player_object + 0x5c)
                        end

                        if (px) then
                            rUnits = ((px - bX) ^ 2 + (py - bY) ^ 2 + (pz - bZ) ^ 2)
                            rUnits = format("%0.2f", rUnits)
                        end

                        -- boundary CROSSOVER CHECKS:
                        if boundary:inSphere(i, px, py, pz, bX, bY, bZ, bR) and (monitor_coords) then
                            if (not console_paused[i]) and (not paused[i].start) then
                                rprint(i, "|c--  I N S I D E   S A F E   Z O N E --")
                                rprint(i, "|cUNITS FROM CENTER: " .. rUnits .. "/" .. bR .. " (Final Size: " .. min_size .. " | Reduction Rate: " .. reduction_amount .. ")")
                                DispayHUD(p)
                            end

                        elseif (monitor_coords) then
                            execute_command("camo " .. i .. " 1")
                            if (not console_paused[i]) and (not paused[i].start) then

                                rprint(i, "|cWARNING:")
                                rprint(i, "|cYOU ARE OUTSIDE THE boundary!")
                                rprint(i, "|cUNITS FROM CENTER: " .. rUnits .. "/" .. bR)
                                out_of_bounds[i].yes = true

                            elseif (not paused[i].start) and console_paused[i] then

                                out_of_bounds[i].yes = true
                                out_of_bounds[i].timer = out_of_bounds[i].timer + time_scale

                                local _time_remaining = ((time_until_kill + 1) - out_of_bounds[i].timer)
                                local seconds = select(2, secondsToTime(_time_remaining, true))

                                rprint(i, "|c--------- WARNING ---------")
                                rprint(i, "|cYOU ARE LEAVING THE COMBAT AREA!")
                                rprint(i, "|cRETURN NOW OR YOU WILL BE SHOT!")
                                rprint(i, "|c(" .. seconds .. ")")

                                if (out_of_bounds[i].timer >= time_until_kill) then
                                    out_of_bounds[i].timer = 0
                                    killPlayer(i)
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif (init_victory_timer) then
        victory_timer = victory_timer + time_scale
        if (victory_timer < 5) then
            for i = 1, 16 do
                if player_present(i) then
                    local last_man = last_man_standing.player
                    if (last_man ~= nil) then
                        cls(i, 25)
                        if tonumber(i) == last_man then
                            rprint(i, "|c ----- V I C T O R Y -----")
                            rprint(i, "|cY O U   W O N   T H E   G A M E!")
                        else
                            rprint(i, "|cBetter Luck Next Time!")
                            rprint(i, "|c________________________________________")
                            rprint(i, "|c" .. get_var(last_man, "$name") .. " won the game!")
                        end
                        for _ = 1, 7 do
                            rprint(i, " ")
                        end
                    end
                end
            end
        else
            init_params(true)
            init_victory_timer, victory_timer = false, 0
        end
    end
end

local function getKDR(p)
    local kills, deaths = get_var(p, "$kills"), get_var(p, "$deaths")
    local kdr = (kills / deaths)
    return kdr
end

local function saveKDRs()
    local kdr_table = { }
    for i = 1, 16 do
        if player_present(i) then
            getKDR(i)
            kdr_table[#kdr_table + 1] = kdr
        end
    end
    table.sort(kdr_table)
    return kdr_table
end

local function bestKDR()
    local KDRTab = saveKDRs()
    local highest_score = tonumber(KDRTab[#KDRTab])

    for i = 1, 16 do
        if player_present(i) then
            local kdr = getKDR(i)
            if (kdr == highest_score) then
                last_man_standing.player = tonumber(i)
            end
        end
    end
end

function GameOver()
    local scores = { }

    local function end_game()
        init_victory_timer = true
        victory_timer = victory_timer or 0
        execute_command('sv_map_next')
        enableKillMessages()
    end

    game_timer = nil
    boundary_timer = nil
    monitor_coords = nil

    start_trigger, game_in_progress, game_time = true, false, 0

    cls(0, 25, true, "rcon")

    -- Time ran out - Calculate best score:
    if (game_timer == nil) then
        for i = 1, 16 do
            if player_present(i) then
                local score = tonumber(get_var(i, '$score'))
                if (score > 0) then
                    scores[#scores + 1] = score
                end
            end
        end

        -- Check who has the highest score:
        if (#scores >= 1) then
            table.sort(scores)
            local highest_score = tonumber(scores[#scores])
            local count = 0
            for i = 1, 16 do
                if player_present(i) then
                    local score = tonumber(get_var(i, '$score'))
                    if (score == highest_score) then
                        last_man_standing.player = tonumber(i)
                        count = count + 1
                    end
                end
            end
            -- Only one player has the highest score (no duplicate scores)
            if (count == 1) then
                end_game()
                -- More than one player have the same score. Calcuate who has the best KDR instead:
            elseif (count > 1) then
                bestKDR()
                end_game()
            end
        else
            -- No players have any score points. Calcuate who has the best KDR instead:
            bestKDR()
            end_game()
        end
    else
        end_game()
    end
end

function OnPlayerDeath(PlayerIndex, KillerIndex)

    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)
    local v_name, k_name = get_var(victim, "$name"), get_var(killer, "$name")

    if (killer > 0) then

        last_man_standing.count = last_man_standing.count - 1
        spectator[victim].enabled = true

        local response

        -- More than 1 player remaining:
        if (last_man_standing.count > 1) then
            response = true
            -- Killer is the Victor. End the Game.
        elseif (last_man_standing.count <= 1) then
            response = false
            last_man_standing.player = killer
        end

        -- PvP:
        if (killer ~= victim) and (response) then
            SayAll(v_name .. " was killed by " .. k_name .. ". " .. last_man_standing.count .. " players remain!")
            -- Suicide:
        elseif (victim == killer) and (response) then
            SayAll(v_name .. " committed suicide. " .. last_man_standing.count .. " players remain!")
        end

    elseif (killer == -1) or (killer == nil) or (killer == 0) then
        SayAll(v_name .. " died")
    end

end

function cls(PlayerIndex, count, clear_chat, type)
    count = count or 25
    if (PlayerIndex) and not (clear_chat) then
        for _ = 1, count do
            rprint(PlayerIndex, " ")
        end
    elseif (clear_chat) then
        if (type == "chat") then
            SayAll(" ")
        elseif (type == "rcon") then
            for i = 1, 16 do
                if player_present(i) then
                    for _ = 1, count do
                        rprint(i, " ")
                    end
                end
            end
        end
    end
end

function OnPlayerChat(PlayerIndex, Message, type)
    local msg = stringSplit(Message)
    local p = tonumber(PlayerIndex)

    if (#msg == 0) then
        return false
    elseif (sub(msg[1], 1, 1) == "/" or sub(msg[1], 1, 1) == "\\") then
        if (paused[p].start ~= true) then
            cls(p, 25)
            paused[p].duration, paused[p].start = 3, true
        end
    end
end

function OnServerCommand(PlayerIndex, Command, Environment, Password)
    local msg = stringSplit(Command)
    local p = tonumber(PlayerIndex)

    if (#msg == 0) then
        return false
    elseif (paused[p].start ~= true) then
        cls(p, 25)
        paused[p].duration, paused[p].start = 3, true
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

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    local shooter, victim = tonumber(CauserIndex), tonumber(PlayerIndex)

    if (shooter > 0 and shooter ~= victim) then
        if (out_of_bounds[shooter].yes) or (spectator[shooter].enabled) or (spectator[victim].enabled) then
            return false
        end
    end

    -- Prevent fall damage during free free (Sky Spawning System)
    local t = godmode_countdown[PlayerIndex]
    if (t ~= nil and t ~= "null") then
        return false
    end
end

function DestroyObject(object)
    if (object) then
        destroy_object(object)
    end
end

local function DeleteWeapons(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        write_word(player_object + 0x31E, 0)
        write_word(player_object + 0x31F, 0)
        local weaponId = read_dword(player_object + 0x118)
        if (weaponId ~= 0) then
            for j = 0, 3 do
                local weapon = read_dword(player_object + 0x2F8 + 4 * j)
                if (weapon ~= red_flag) and (weapon ~= blue_flag) then
                    DestroyObject(weapon)
                end
            end
        end
        return true
    end
end

function killPlayer(PlayerIndex)
    if DeleteWeapons(PlayerIndex) then
        execute_command("kill " .. tonumber(PlayerIndex))
        write_dword(get_player(PlayerIndex) + 0x2C, 0 * 33)
        -- Deduct one death
        local deaths = tonumber(get_var(PlayerIndex, "$deaths"))
        execute_command("deaths " .. tonumber(PlayerIndex) .. " " .. deaths - 1)
    end
end

function GameStartCountdown()
    if (gamestart_countdown ~= nil) then

        gamestart_countdown = gamestart_countdown + time_scale
        local gamestart_delay = gamestart_delay + 1
        local time = ((gamestart_delay + time_scale) - (gamestart_countdown))

        if (time < 1) then

            disableKillMessages()
            stopTimer()
            set(true)
            cls(0, 25, true, "rcon")
            game_in_progress = true

            -- Must be registered before the map is reset:
            register_callback(cb['EVENT_PRESPAWN'], "OnPlayerPrespawn")

            execute_command("sv_map_reset")

            local function spawn_flag()
                local tag_name, tag_id = "weap", "weapons\\flag\\flag"
                if TagInfo(tag_name, tag_id) then
                    spawn_object(tag_name, tag_id, bX, bY, bZ + 0.5)
                    execute_command("disable_object " .. tag_id)
                end
            end

            spawn_flag()

            register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
            register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")

        elseif (init_countdown) then
            checkForPause()

            local minutes, seconds = select(1, secondsToTime(time, true)), select(2, secondsToTime(time, true))
            local time_stamp = (minutes .. ":" .. seconds)

            for i = 1, 16 do
                if player_present(i) then
                    if (paused[i] ~= nil) and (not paused[i].start) then
                        cls(i, 25)
                        rprint(i, "|c________________________________________________________________", 4 + 8)
                        rprint(i, "|cA", 4 + 8)
                        rprint(i, "|cBATTLE ROYALE MOD", 4 + 8)
                        rprint(i, "|cBeta (v1.0)", 4 + 8)
                        rprint(i, "|cCreated by Chalwk", 4 + 8)
                        rprint(i, "|cGame will begin in " .. time_stamp, 4 + 8)
                        rprint(i, "|c________________________________________________________________", 4 + 8)
                    end
                end
            end
        end
    end
end

function startTimer()
    gamestart_countdown = 0
    init_countdown = true
end

function stopTimer()
    init_countdown = false
    gamestart_countdown = 0
end

function PlayerInVehicle(p)
    if (get_dynamic_player(p) ~= 0) then
        local VehicleID = read_dword(get_dynamic_player(p) + 0x11C)
        if VehicleID == 0xFFFFFFFF then
            return false
        else
            return true
        end
    else
        return false
    end
end

function getXYZ(p)
    local x, y, z
    local player_object = get_dynamic_player(p)
    if (player_object ~= 0 and player_alive(p)) then
        local coords = { }
        if PlayerInVehicle(p) then
            local VehicleID = read_dword(player_object + 0x11C)
            local vehicle = get_object_memory(VehicleID)
            x, y, z = read_vector3d(vehicle + 0x5c)
        else
            x, y, z = read_vector3d(player_object + 0x5c)
        end
        coords.x, coords.y, coords.z = x, y, z
        return coords
    end
end

-- Receives number - determines whether to pluralize.
-- Returns string 's' if the input is greater than 1.
function getChar(input)
    local char = ""
    if (tonumber(input) > 1) then
        char = "s"
    elseif (tonumber(input) <= 1) then
        char = ""
    end
    return char
end

function stringSplit(inp, sep)
    if (sep == nil) then
        sep = "%s"
    end
    local t, i = {}, 1
    for str in gmatch(inp, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function TagInfo(obj_type, obj_name)
    local tag = lookup_tag(obj_type, obj_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function setupSpawns()

    -- x,y,z, height, invincibility time

    spawn_coordinates = {
        ["timberland"] = {
            [1] = { 23.853, -3.156, -19.601, 35, 10 },
            [2] = { -14.193, -29.984, -16.286, 35, 10 },
            [3] = { -8.662, -1.849, -18.705, 35, 10 },
            [4] = { 10.762, 1.374, -19.138, 35, 10 },
            [5] = { 24.903, -49.360, -17.249, 35, 10 },
            [6] = { -23.794, 2.237, -19.261, 35, 10 },
            [7] = { 38.812, 34.449, -21.074, 35, 10 },
            [8] = { 20.434, 27.411, -15.943, 35, 10 },
            [9] = { -15.200, 46.523, -17.872, 35, 10 },
            [10] = { -23.846, 50.052, -17.228, 35, 10 },
            [11] = { -34.927, 25.201, -17.614, 35, 10 },
            [12] = { 6.466, -42.868, -16.648, 35, 10 },
            [13] = { 17.330, -1.847, -21.144, 35, 10 },
            [14] = { -22.583, 17.942, -19.094, 35, 10 },
            [15] = { -17.401, -23.458, -16.643, 35, 10 },
            [16] = { -30.540, -39.588, -20.926, 35, 10 },
        },
        ["carousel"] = {
            [1] = { -5.744, -3.427, -2.683, 0.1, 1.5 },
            [2] = { -3.665, -5.637, -2.709, 0.1, 1.5 },
            [3] = { 3.404, -5.899, -2.709, 0.1, 1.5 },
            [4] = { 5.613, -3.612, -2.694, 0.1, 1.5 },
            [5] = { 5.809, 3.603, -2.729, 0.1, 1.5 },
            [6] = { 3.616, 5.839, -2.738, 0.1, 1.5 },
            [7] = { -3.570, 5.878, -2.736, 0.1, 1.5 },
            [8] = { -5.711, 3.648, -2.719, 0.1, 1.5 },
            [9] = { -9.828, -9.998, -0.855, 0.1, 1.5 },
            [10] = { -14.048, 0.008, -0.855, 0.1, 1.5 },
            [11] = { 9.717, 9.762, -0.855, 0.1, 1.5 },
            [12] = { 13.811, -0.175, -0.855, 0.1, 1.5 },
            [13] = { 7.495, -7.560, -0.855, 0.1, 1.5 },
            [14] = { -7.419, 7.481, -0.855, 0.1, 1.5 },
            [15] = { -0.016, 10.579, -0.855, 0.1, 1.5 },
            [16] = { 0.013, -10.802, -0.855, 0.1, 1.5 },
        },
        ["ratrace"] = {
            [1] = { 18.637, -16.210, -3.611, 0.1, 1.5 },
            [2] = { 18.613, -22.653, -3.400, 0.1, 1.5 },
            [3] = { 20.576, -1.483, -2.123, 0.1, 1.5 },
            [4] = { 4.907, -3.483, -0.590, 0.1, 1.5 },
            [5] = { 4.898, 1.798, -0.590, 0.1, 1.5 },
            [6] = { -4.228, -0.856, -0.400, 0.1, 1.5 },
            [7] = { -3.937, -8.287, -1.379, 0.1, 1.5 },
            [8] = { -8.097, -13.995, -2.131, 0.1, 1.5 },
            [9] = { -8.438, -15.456, -2.132, 0.1, 1.5 },
            [10] = { 10.767, -22.723, -3.611, 0.1, 1.5 },
            [11] = { 4.303, -21.044, -3.611, 0.1, 1.5 },
            [12] = { 4.309, -24.391, -3.605, 0.1, 1.5 },
            [13] = { -4.884, 2.705, -0.591, 0.1, 1.5 },
            [14] = { 12.680, -11.364, 0.229, 0.1, 1.5 },
            [15] = { 6.315, -8.379, 0.223, 0.1, 1.5 },
            [16] = { -2.745, -12.952, 0.223, 0.1, 1.5 },
        },
        ["sidewinder"] = {
            [1] = { 33.732, -5.751, -3.433, 35, 10 },
            [2] = { 10.031, -10.273, 0.238, 35, 10 },
            [3] = { 42.062, -27.355, -3.809, 35, 10 },
            [4] = { 22.562, -26.696, -3.828, 35, 10 },
            [5] = { 39.179, 29.980, 0.159, 35, 10 },
            [6] = { 3.473, 25.565, -3.841, 35, 10 },
            [7] = { 1.800, 54.512, -2.801, 35, 10 },
            [8] = { -40.542, 32.890, 0.159, 35, 10 },
            [9] = { -43.366, 41.473, 0.159, 35, 10 },
            [10] = { -5.949, -12.701, 0.174, 35, 10 },
            [11] = { -25.107, -27.639, -3.841, 35, 10 },
            [12] = { -41.707, -28.023, -3.745, 35, 10 },
            [13] = { -33.038, -32.997, -3.841, 0.5, 1.5 },
            [14] = { -31.259, -43.977, -3.841, 0.5, 1.5 },
            [15] = { 30.985, -41.122, -3.841, 0.5, 1.5 },
            [16] = { 30.243, -36.759, 0.559, 0.5, 1.5 },
        },
        ["beavercreek"] = {
            [1] = { 23.545, 5.686, -0.215, 15, 5 },
            [2] = { 32.880, 13.790, -0.216, 15, 5 },
            [3] = { 25.627, 19.867, -0.216, 15, 5 },
            [4] = { 29.044, 13.812, 0.837, 15, 5 },
            [5] = { -1.052, 13.804, 0.837, 15, 5 },
            [6] = { -4.882, 13.785, -0.216, 15, 5 },
            [7] = { 1.691, 7.904, -0.215, 15, 5 },
            [8] = { 8.442, 13.851, -0.216, 15, 5 },
            [9] = { 17.050, 19.866, 5.059, 15, 5 },
            [10] = { 15.329, 5.374, 3.549, 15, 5 },
            [11] = { 15.649, 12.651, -0.216, 15, 5 },
            [12] = { 24.873, 13.704, -1.355, 0.1, 1.5 },
            [13] = { 21.987, 13.837, -1.355, 0.1, 1.5 },
            [14] = { 24.507, 10.438, -1.354, 0.1, 1.5 },
            [15] = { 3.052, 13.687, -1.355, 0.1, 1.5 },
            [16] = { 5.764, 17.051, -0.154, 0.1, 1.5 },
        },
        ["dangercanyon"] = {
            [1] = { 0.010, 53.516, -8.445, 35, 10 },
            [2] = { 0.650, 40.452, -6.000, 35, 10 },
            [3] = { -0.043, 45.401, -8.365, 0.5, 1.5 },
            [4] = { -0.059, 34.151, 0.268, 35, 10 },
            [5] = { -26.836, 26.680, 0.180, 35, 10 },
            [6] = { -52.490, 17.600, -8.651, 35, 10 },
            [7] = { -12.104, -3.447, -1.800, 35, 10 },
            [8] = { -14.092, -12.291, -4.159, 35, 10 },
            [9] = { 16.192, 20.354, 0.301, 0.5, 1.5 },
            [10] = { -16.217, 20.228, 0.301, 0.5, 1.5 },
            [11] = { -0.040, 21.241, -1.130, 0.5, 1.5 },
            [12] = { -2.594, 24.616, -1.130, 0.5, 1.5 },
            [13] = { 2.504, 24.643, -1.130, 0.5, 1.5 },
            [14] = { -10.427, 54.557, 0.366, 35, 10 },
            [15] = { -32.052, 24.135, -6.223, 35, 10 },
            [16] = { 19.053, 55.171, -8.898, 35, 10 },
        },
        ["bloodgulch"] = {
            [1] = { 59.785, -121.995, 0.268, 35, 10 },
            [2] = { 92.817, -120.450, 3.050, 35, 10 },
            [3] = { 95.455, -152.498, 0.162, 35, 10 },
            [4] = { 119.995, -183.364, 6.667, 35, 10 },
            [5] = { 63.867, -178.989, 4.220, 35, 10 },
            [6] = { 69.359, -166.153, 1.239, 35, 10 },
            [7] = { 45.309, -151.119, 4.174, 35, 10 },
            [8] = { 73.372, -103.286, 4.088, 35, 10 },
            [9] = { 95.799, -96.746, 4.009, 35, 10 },
            [10] = { 29.371, -71.100, 0.902, 35, 10 },
            [11] = { 63.116, -70.796, 1.302, 35, 10 },
            [12] = { 40.241, -79.123, -0.100, 35, 10 },
            [13] = { 95.688, -159.449, -0.100, 35, 10 },
            [14] = { 98.390, -113.589, 4.178, 0.5, 1.5 },
            [15] = { 109.061, -108.281, 2.059, 0.5, 1.5 },
            [16] = { 69.833, -88.165, 5.660, 0.5, 1.5 },
        },
        ["boardingaction"] = {
            [1] = { 68.911, -173.686, 1.755, 35, 10 },
            [2] = { 92.484, -169.559, 0.128, 35, 10 },
            [3] = { 110.137, -173.322, 0.616, 35, 10 },
            [4] = { 105.493, -157.454, 0.203, 35, 10 },
            [5] = { 91.894, -157.781, 1.704, 35, 10 },
            [6] = { 85.243, -157.767, -0.019, 35, 10 },
            [7] = { 100.961, -146.249, 0.292, 35, 10 },
            [8] = { 105.493, -157.454, 0.203, 35, 10 },
            [9] = { 52.061, -82.221, 0.118, 35, 10 },
            [10] = { 41.102, -90.282, 0.175, 35, 10 },
            [11] = { 30.554, -89.436, 0.128, 35, 10 },
            [12] = { 23.010, -65.879, 1.693, 35, 10 },
            [13] = { 32.593, -65.859, 0.367, 35, 10 },
            [14] = { 42.910, -67.763, 0.516, 35, 10 },
            [15] = { 61.292, -65.713, 1.693, 35, 10 },
            [16] = { 41.878, -81.025, 1.705, 35, 10 },
        },
        ["gephyrophobia"] = {
            [1] = { 26.797, -101.776, -14.473, 35, 10 },
            [2] = { 26.821, -42.317, -14.473, 35, 10 },
            [3] = { 16.717, -71.695, -12.711, 35, 10 },
            [4] = { 36.779, -71.654, -12.711, 35, 10 },
            [5] = { 34.156, -124.022, -15.898, 35, 10 },
            [6] = { 19.488, -124.003, -15.898, 35, 10 },
            [7] = { 19.479, -20.510, -15.898, 35, 10 },
            [8] = { 34.064, -20.488, -15.897, 35, 10 },
            [9] = { 63.287, -74.010, -1.061, 35, 10 },
            [10] = { 65.945, -37.155, -1.061, 35, 10 },
            [11] = { 65.994, -111.834, -1.061, 35, 10 },
            [12] = { -19.107, -107.084, -1.254, 35, 10 },
            [13] = { -16.489, -31.847, -1.254, 35, 10 },
            [14] = { 26.808, -77.912, -20.315, 35, 10 },
            [15] = { 26.735, -2.917, -17.733, 5, 3 },
            [16] = { 26.813, -141.687, -17.733, 5, 3 },
        },
        ["deathisland"] = {
            [1] = { -33.084, -10.344, 9.417, 35, 10 },
            [2] = { -33.291, -3.496, 9.417, 35, 10 },
            [3] = { -40.657, -7.237, 4.922, 35, 10 },
            [4] = { 37.433, 18.928, 8.050, 35, 10 },
            [5] = { 37.229, 12.687, 8.050, 35, 10 },
            [6] = { 43.623, 16.372, 4.555, 35, 10 },
            [7] = { -27.528, 28.333, 14.403, 35, 10 },
            [8] = { -22.667, -7.122, 22.686, 35, 10 },
            [9] = { 25.656, 16.048, 21.191, 35, 10 },
            [10] = { 47.797, -35.781, 13.986, 35, 10 },
            [11] = { 36.759, -18.843, 4.130, 35, 10 },
            [12] = { 51.606, 42.879, 1.978, 35, 10 },
            [13] = { 27.119, 62.588, 1.621, 35, 10 },
            [14] = { -51.014, 51.562, 6.718, 35, 10 },
            [15] = { -26.576, -6.976, 9.663, 5, 3 },
            [16] = { 29.843, 15.971, 8.295, 5, 3 },
        },
        ["icefields"] = {
            [1] = { -26.061, 32.583, 9.008, 35, 10 },
            [2] = { -77.860, 86.550, 2.111, 35, 10 },
            [3] = { 24.850, -22.110, 2.111, 35, 10 },
            [4] = { 2.678, 1.036, 2.151, 35, 10 },
            [5] = { -50.430, 41.690, 0.681, 35, 10 },
            [6] = { -43.600, 47.621, 8.663, 35, 10 },
            [7] = { -31.056, 29.798, 0.709, 35, 10 },
            [8] = { -1.240, 23.425, 0.682, 35, 10 },
            [9] = { -8.035, 17.422, 8.665, 35, 10 },
            [10] = { 17.216, -19.172, 0.774, 35, 10 },
            [11] = { 30.052, -16.684, 0.890, 35, 10 },
            [12] = { 23.444, -14.022, 0.610, 35, 10 },
            [13] = { -70.109, 83.208, 0.604, 35, 10 },
            [14] = { -85.127, 83.385, 0.724, 35, 10 },
            [15] = { -76.637, 78.730, 0.747, 35, 10 },
            [16] = { -26.614, 46.170, 8.893, 35, 10 },
        },
        ["infinity"] = {
            [1] = { -30.227, -72.462, 11.954, 35, 10 },
            [2] = { -35.213, -49.208, 11.697, 35, 10 },
            [3] = { 45.088, -43.998, 10.903, 35, 10 },
            [4] = { 45.328, -84.965, 11.468, 35, 10 },
            [5] = { 9.638, -64.105, 7.787, 35, 10 },
            [6] = { -57.138, -114.103, 17.439, 35, 10 },
            [7] = { 50.149, -12.256, 10.468, 35, 10 },
            [8] = { 41.487, -8.284, 18.565, 35, 10 },
            [9] = { -1.976, 39.102, 10.584, 35, 10 },
            [10] = { -1.858, 47.780, 11.791, 35, 10 },
            [11] = { -51.514, 9.674, 23.542, 35, 10 },
            [12] = { -52.901, -9.987, 20.921, 35, 10 },
            [13] = { -57.508, -37.314, 14.864, 35, 10 },
            [14] = { 18.857, -64.249, 27.971, 35, 10 },
            [15] = { -15.438, -64.418, 27.971, 35, 10 },
            [16] = { 0.603, -154.172, 15.971, 35, 10 },
        },
        ["hangemhigh"] = {
            [1] = { 15.919, -7.201, -3.468, 5, 2 },
            [2] = { 15.428, -18.394, -5.582, 5, 2 },
            [3] = { 23.353, 14.958, -5.129, 5, 2 },
            [4] = { 33.673, 7.359, -7.949, 5, 2 },
            [5] = { 28.017, -2.481, -7.949, 5, 2 },
            [6] = { 10.314, -4.983, -6.435, 5, 2 },
            [7] = { 28.017, -2.481, -7.949, 5, 2 },
            [8] = { 34.286, -7.358, -3.909, 5, 2 },
            [9] = { 32.089, -1.843, -5.582, 0.1, 1.5 },
            [10] = { 34.506, -8.883, -5.582, 0.1, 1.5 },
            [11] = { 10.689, -5.989, -7.949, 0.1, 1.5 },
            [12] = { 29.066, -15.450, -5.509, 0.1, 1.5 },
            [13] = { 32.374, -18.473, -5.473, 0.1, 1.5 },
            [14] = { 12.016, 8.057, -5.756, 0.1, 1.5 },
            [15] = { 35.157, 4.972, -7.949, 0.1, 1.5 },
            [16] = { 11.083, -16.747, -7.949, 0.1, 1.5 },
        },
        ["damnation"] = {
            [1] = { -9.872, 1.443, -0.199, 5, 2 },
            [2] = { 2.220, 3.039, -0.010, 5, 2 },
            [3] = { 0.749, -1.505, -0.006, 5, 2 },
            [4] = { 4.383, -2.247, 3.401, 5, 2 },
            [5] = { 4.163, 3.995, 3.401, 5, 2 },
            [6] = { -7.984, 7.801, 3.401, 5, 2 },
            [7] = { -5.707, 12.579, 3.401, 5, 2 },
            [8] = { -10.668, 12.071, -0.399, 5, 2 },
            [9] = { -12.179, 14.983, -0.200, 5, 2 },
            [10] = { 2.563, -7.057, 6.701, 5, 2 },
            [11] = { 9.693, -13.340, 6.800, 5, 2 },
            [12] = { 5.590, -13.261, 6.701, 5, 2 },
            [13] = { -0.615, -0.036, 8.201, 5, 2 },
            [14] = { -10.482, -5.906, 3.010, 5, 2 },
            [15] = { -9.946, -10.675, -0.199, 5, 2 },
            [16] = { -1.998, -4.382, 3.401, 5, 2 },
        },
        ["putput"] = {
            [1] = { 33.093, -10.074, 1.303, 0.1, 1.5 },
            [2] = { 33.938, -12.327, 0.904, 0.1, 1.5 },
            [3] = { 31.783, -29.286, 1.001, 0.1, 1.5 },
            [4] = { 29.156, -28.209, 0.001, 0.1, 1.5 },
            [5] = { 12.136, -35.556, 0.903, 0.1, 1.5 },
            [6] = { 15.558, -36.189, 1.503, 0.1, 1.5 },
            [7] = { 14.233, -18.243, 0.001, 0.1, 1.5 },
            [8] = { 13.979, -20.295, 0.001, 0.1, 1.5 },
            [9] = { 11.309, -33.451, 1.504, 0.1, 1.5 },
            [10] = { 13.562, -32.037, 2.829, 0.1, 1.5 },
            [11] = { -3.845, -34.529, 3.403, 0.1, 1.5 },
            [12] = { -2.666, -32.918, 2.303, 0.1, 1.5 },
            [13] = { -5.318, -22.303, 0.904, 0.1, 1.5 },
            [14] = { -3.091, -18.093, 0.904, 0.1, 1.5 },
            [15] = { -5.135, -20.192, 0.904, 0.1, 1.5 },
            [16] = { -5.280, -32.926, 2.303, 0.1, 1.5 },
        },
        ["prisoner"] = {
            [1] = { -7.218, 0.004, 1.553, 35, 10 },
            [2] = { 7.056, 0.034, 3.386, 35, 10 },
            [3] = { -3.618, -3.679, 3.193, 3, 1.5 },
            [4] = { 3.736, 2.368, 3.328, 3, 1.5 },
            [5] = { 3.342, -5.180, 3.193, 0.1, 1.5 },
            [6] = { -0.583, -6.166, -0.407, 0.1, 1.5 },
            [7] = { -8.069, 1.383, -0.300, 0.1, 1.5 },
            [8] = { -3.039, 3.011, -0.300, 0.1, 1.5 },
            [9] = { 2.813, 1.096, -0.406, 0.1, 1.5 },
            [10] = { -7.190, -4.966, 5.593, 0.1, 1.5 },
            [11] = { 7.227, 4.987, 5.593, 0.1, 1.5 },
            [12] = { -1.199, -4.641, 3.193, 0.1, 1.5 },
            [13] = { -2.696, 4.629, 3.193, 0.1, 1.5 },
            [14] = { -9.406, -2.364, 2.412, 0.1, 1.5 },
            [15] = { 4.025, -5.597, 1.393, 0.1, 1.5 },
            [16] = { 0.842, 0.016, -0.527, 0.1, 1.5 },
        },
        ["wizard"] = {
            [1] = { 6.001, 5.995, -2.631, 4, 2.5 },
            [2] = { -5.982, -5.969, -2.640, 4, 2.5 },
            [3] = { 5.978, -6.026, -2.645, 4, 2.5 },
            [4] = { -6.000, 5.985, -2.645, 4, 2.5 },
            [5] = { -7.469, 11.140, -2.749, 4, 2.5 },
            [6] = { -11.300, 7.512, -2.749, 4, 2.5 },
            [7] = { 11.090, -7.385, -2.749, 4, 2.5 },
            [8] = { 7.340, -11.118, -2.749, 4, 2.5 },
            [9] = { -7.204, -10.863, -2.749, 4, 2.5 },
            [10] = { -10.239, -7.827, -2.749, 4, 2.5 },
            [11] = { -9.889, 7.180, -2.749, 4, 2.5 },
            [12] = { -7.420, 9.807, -2.749, 4, 2.5 },
            [13] = { 1.033, -0.090, -2.299, 0.1, 1.5 },
            [14] = { -5.262, 5.288, -4.499, 0.1, 1.5 },
            [15] = { 5.168, 5.178, -4.499, 0.1, 1.5 },
            [16] = { 5.250, -5.207, -4.499, 0.1, 1.5 },
        },
        ["longest"] = {
            [1] = { 13.403, -16.591, 0.001, 4, 2.5 },
            [2] = { 13.320, -15.239, 0.001, 4, 2.5 },
            [3] = { 11.505, -16.725, 0.001, 4, 2.5 },
            [4] = { 7.267, -15.361, 0.001, 4, 2.5 },
            [5] = { -11.853, -21.532, -0.599, 0.1, 1.5 },
            [6] = { -13.912, -21.747, -0.599, 0.2, 1.5 },
            [7] = { -0.481, -15.320, 2.105, 0.1, 1.5 },
            [8] = { -1.269, -13.700, 2.105, 0.1, 1.5 },
            [9] = { -12.904, -20.676, -0.599, 0.1, 1.5 },
            [10] = { -12.975, -11.158, 0.001, 0.1, 1.5 },
            [11] = { -0.904, -14.556, 0.168, 0.1, 1.5 },
            [12] = { 4.983, -18.751, 2.057, 0.1, 1.5 },
            [13] = { -0.673, -13.928, 0.001, 0.1, 1.5 },
            [14] = { -8.193, -10.014, 2.057, 0.1, 1.5 },
            [15] = { -17.104, -12.617, 0.001, 0.1, 1.5 },
            [16] = { 2.182, -10.833, 2.057, 0.1, 1.5 },
        },
    }
end

