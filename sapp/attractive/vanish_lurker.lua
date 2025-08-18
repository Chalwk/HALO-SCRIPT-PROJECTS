--[[
=====================================================================================
SCRIPT NAME:      vasnish_lurker.lua
DESCRIPTION:      Allows players to turn on Vanish Mode.

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]


api_version = "1.12.0.0"
local vanish = {}

-- Player Vanish Configuration [starts] --

-- Base Command: 
vanish.command = "vanish" -- /command on|off [me | id | */all] <cmd_flag>

vanish.cmd_flags = { "-c", "-h", "-ch" } -- Command flag parameters.
-- If '-c' (short for camouflage) command parameter is specified, you will only have camo!
-- If '-h' (short for hidden) command parameter is specified, you will only be hidden!
-- If '-ch' (short for camouflage + hidden) command parameter is specified, you will be both hidden and camouflaged!
-- If neither are specified, the script will revert to default settings, i.e, 'vanish.hide', 'vanish.camouflage'
-- If Player ID parameter ([me | id | */all]) is not specified, Vanish will default to the executor.

-- Minimum Permission level required to execute /vanish.command
vanish.permission_level = 1

-- Minimum Permission level required to turn on vanish for other players.
vanish.execute_on_others = 4

-- Global Server Prefix:
-- local function 'Say' temporarily removes the **SERVER** prefix when it announces messges.
-- The prefix will be restored to 'vanish.serverprefix' when the relay has finished.
vanish.serverprefix = "** SERVER ** "

-- If this is enabled, you will teleport to the nearest object that you are aiming directly at:
vanish.boost = true
-- What action triggers boost? (see below for a list of valid actions):
vanish.boost_trigger = "crouch_and_shoot"
-- VALID ACTIONS:
-- crouch_and_shoot  (crouch and shoot to activate boost)
-- crouch            (crouch only, to activate boost)

-- If this is true, the player will have invincibility (god mode):
vanish.invincibility = true

-- If this is true, you will be hidden from all players.
vanish.hide = true

-- If this is true, you will be camouflaged.
-- Despite the fact that players wont be able to see you anyway, this feature doubles as a visual reminder to the player that they are vanished.
vanish.camouflage = true

-- If this is true, vanish will be auto-disabled (for all players) when the game ends, thus, players will not be in vanish when the next game begins, They will have to turn it back on.
vanish.auto_off = false

-- If this is true, your vehicle will disappear too!
vanish.hide_vehicles = true

-- If this is true, you will be hidden from radar.
vanish.hide_from_radar = true

-- If this is true, players in vanish will not be able to inflict (or receive) damage.
vanish.block_damage = true

-- If this is true, the player wlll have a speed boost:
vanish.speed_boost = true
-- Speed boost applied (default running speed is 1):
vanish.running_speed = 2
-- Speed the player returns to when they exit out of Vanish Mode:
vanish.default_running_speed = 1

-- Time (in seconds) until the player is killed after picking up the objective (flag or oddball)
vanish.time_until_death = 5

-- You lose one warning point every time you pick up the objective (flag or oddball).
-- If you have no warnings left, your vanish privileges will be revoked (until the server is restarted)
vanish.warnings = 4

-- =============== ENABLE | DISABLE Messages =============== --
-- Let players know when someone goes into (or out of) Vanish mode:
vanish.announce = true
-- (optional) -> Use "%name%" variable to output the joining players name.
vanish.onEnableMsg = "%name% is now invisible. Poof!"
vanish.onDisabeMsg = "%name% is no longer invisible!"
--==================================================================================================--


-- =============== JOIN/QUIT SETTINGS =============== --
-- Keep vanish on quit? (When the player returns, they will still be in vanish).
vanish.keep = true

-- Remind the newly joined player that they are in vanish? (requires vanish.keep to be enabled) 
vanish.join_tell = true
-- (optional) -> Use "%name%" variable to output the joining players name.
vanish.join_msg = "%name%, You have joined vanished."

-- If this is true, the player will be informed of how many warnings remain.
vanish.announce_warnings = true
vanish.join_warnings_left_msg = "Vanish Warnings left: %warnings%"

-- Tell other players that PlayerX joined in vanish? (requires vanish.keep to be enabled) 
vanish.join_tell_others = true
vanish.join_others_msg = "%name% joined vanished!"
--==================================================================================================--

-- Vanish Configuration [ends] --

local weapon_status = { }

-- Store Player IP to an array...
-- Because SAPP cannot retrieve the player IP on 'event_leave' if playing on PC.
-- This table is only accessed when 'event_leave' is called.
local ip_table = { }

local lower, upper, format, gsub, floor = string.lower, string.upper, string.format, string.gsub, math.floor
local dir = 'sapp\\vanish.tmp'
local globals = nil
local red_flag, blue_flag

local function getip(p)
    if (p) then
        return get_var(p, "$ip")--:match("(%d+.%d+.%d+.%d+)")
    end
end

local function getChar(input)
    local char = ""
    if (tonumber(input) > 1) then
        char = "s"
    elseif (tonumber(input) <= 1) then
        char = ""
    end
    return char
end

-- Return the number of warnings this player has remaining.
local function getWarnings(ip)
    return ((vanish[ip].warnings) or vanish.warnings)
end

local game_over
function reset()
    for i = 1, 16 do
        if player_present(i) then
            local ip = getip(i)
            local is_vanished = isVanished(ip)
            if ((vanish[ip] ~= nil) or is_vanished) then
                vanish[ip] = nil
                weapon_status[i] = nil
                if (vanish.speed_boost) then
                    execute_command("s " .. tonumber(i) .. " " .. tonumber(vanish.default_running_speed))
                end
                if not (game_over) then
                    rprint(i, "SAPP Reloaded.")
                else
                    rprint(i, "GAME OVER.")
                end
                remove_data_log(i)
                rprint(i, "Your vanish has been deactivated.")
            end
        end
    end
end

function OnScriptLoad()
    local gp = sig_scan("8B3C85????????3BF9741FE8????????8B8E2C0200008B4610") + 3
    if (gp == 3) then
        return
    end
    globals = read_dword(gp)
    if (globals) then
        checkFile(dir)
        register_callback(cb["EVENT_TICK"], "OnTick")
        register_callback(cb['EVENT_COMMAND'], "OnServerCommand")

        register_callback(cb['EVENT_JOIN'], "OnPlayerConnect")
        register_callback(cb['EVENT_LEAVE'], "OnPlayerDisconnect")

        register_callback(cb['EVENT_GAME_START'], "OnGameStart")
        register_callback(cb['EVENT_GAME_END'], "OnGameEnd")

        register_callback(cb['EVENT_WEAPON_PICKUP'], "OnWeaponPickup")
        register_callback(cb['EVENT_WEAPON_DROP'], "OnWeaponDrop")

        register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamageApplication")

        register_callback(cb['EVENT_DIE'], "OnPlayerKill")

        if (tonumber(get_var(0, "$pn")) > 0) then
            reset()
        end
    end
end

function OnScriptUnload()
    --
end

function OnGameStart()
    game_over = false
    red_flag, blue_flag = read_dword(globals + 0x8), read_dword(globals + 0xC)
end

function OnGameEnd()
    game_over = true
    if (vanish.auto_off) and (tonumber(get_var(0, "$pn")) > 0) then
        reset()
    end
end

-- Check if the command was executed by a player or from server console.
local function isConsole(e)
    if (e) then
        if (e ~= -1 and e >= 1 and e < 16) then
            return false
        else
            return true
        end
    end
end

local execute_on_others_error = { }
local function executeOnOthers(e, self, is_console, level)
    if not (self) and not (is_console) then
        if tonumber(level) >= vanish.execute_on_others then
            return true
        elseif (execute_on_others_error[e]) then
            execute_on_others_error[e] = false
            respond(e, "You are not allowed to execute this command on other players.", "rcon", 4 + 8)
            return false
        end
    else
        return true
    end
end

local Say = function(Player, Message)
    if (Player) and (Message) then
        execute_command("msg_prefix \"\"")
        say(Player, Message)
        execute_command("msg_prefix \" " .. vanish.serverprefix .. "\"")
    end
end

local function announceExclude(PlayerIndex, message)
    for i = 1, 16 do
        if (player_present(i) and i ~= PlayerIndex) then
            Say(i, message)
        end
    end
end

-- Custom message handler.
local function respond(executor, message, environment, color)
    if (executor) then
        color = color or 4 + 8
        if not (isConsole(executor)) then
            if (environment == "chat") then
                Say(executor, message)
            elseif (environment == "rcon") then
                rprint(executor, message)
            end
        else
            cprint(message, color)
        end
    end
end

function OnPlayerConnect(p)

    local ip = getip(p)

    ip_table[p] = ip_table[p] or { }
    ip_table[p] = ip

    vanish[ip] = vanish[ip] or nil
    local status = vanish[ip]
    local score = get_var(p, "$score")

    local function tell(p, bool)
        if (bool) then
            vanish[ip] = { } -- Initialize an array for this player.
            status = vanish[ip]

            -- ENABLE VANISH
            status.enabled = true

            -- APPLY GOD MDOE
            if (vanish.invincibility) then
                execute_command("god " .. p)
            end
        end

        -- JOIN MESSAGES:
        if (vanish.join_tell) then
            local join_message_1 = gsub(vanish.join_msg, "%%name%%", get_var(p, "$name"))
            respond(p, join_message_1, "rcon", 2 + 8)
            if (vanish.announce_warnings) then
                local join_message_2 = gsub(vanish.join_warnings_left_msg, "%%warnings%%", status.warnings)
                respond(p, join_message_2, "rcon", 2 + 8)
            end
        end

        if (vanish.join_tell_others) then
            local msg = gsub(vanish.join_others_msg, "%%name%%", get_var(p, "$name"))
            announceExclude(p, msg, "rcon", 2 + 8)
        end
    end

    local was_vanished = isVanished(ip)
    if (status ~= nil and status.enabled) then
        -- no need to declare `vanish[ip].enable`
        tell(p)
    elseif (status == nil) and (was_vanished) then
        -- must declare `vanish[ip] = {}` and `vanish[ip].enable`
        tell(p, true)
    elseif (status == nil) and not (was_vanished) then
        vanish[ip] = { } -- Initialize an array for this player.
        status = vanish[ip]
    end

    status.teleport, status.warn, status.timer, status.score, status.warnings, status.mode = false, false, 0, score, getWarnings(ip), "default"
end

function OnPlayerSpawn(PlayerIndex)
    if (weapon_status[PlayerIndex] ~= nil) then
        weapon_status[PlayerIndex] = 0
    end
end

function OnPlayerDisconnect(p)
    local ip = function(pid)
        if (pid) then
            local ip_address
            if (halo_type == "PC") then
                ip_address = ip_table[pid]
            else
                ip_address = getip(pid)
            end
            return ip_address
        end
    end

    local status = vanish[ip(p)]
    if (status ~= nil) then
        if not (status.enabled) or not (vanish.keep) then
            remove_data_log(p)
        end
    end
    ip_table[p] = nil
end

local function hide_player(p, coords)
    local xOff, yOff, zOff = 1000, 1000, 1000
    write_float(get_player(p) + 0x100, coords.z - zOff)
    if (vanish.hide_from_radar) then
        write_float(get_player(p) + 0xF8, coords.x - xOff)
        write_float(get_player(p) + 0xFC, coords.y - yOff)
    end
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local ip = getip(i)
            local status = vanish[ip]
            if (status ~= nil) and (status.enabled) then

                -- HIDE PLAYER
                if (vanish.hide) and (status.mode == "hide" or status.mode == "camouflage_and_hide" or status.mode == "default") then
                    local coords = getXYZ(i)
                    if (coords) then
                        if ((coords.invehicle and vanish.hide_vehicles) or not coords.invehicle) then
                            hide_player(i, coords)
                        end
                    end
                end

                -- APPLY CAMO
                if (vanish.camouflage) and (status.mode == "camouflage" or status.mode == "camouflage_and_hide" or status.mode == "default") then
                    execute_command("camo " .. i .. " 1")
                end

                -- APPLY SPEED
                if not (status.warn) and (vanish.speed_boost) then
                    execute_command("s " .. tonumber(i) .. " " .. tonumber(vanish.running_speed))

                    -- WARN PLAYER
                elseif (status.warn) then
                    status.timer = status.timer + 0.030
                    cls(i, 25)
                    local days, hours, minutes, seconds = secondsToTime(status.timer, 4)
                    rprint(i, "|cWarning! Drop the " .. status.objective)
                    local char = getChar(vanish.time_until_death - floor(seconds))
                    rprint(i, "|cYou will be killed in " .. vanish.time_until_death - floor(seconds) .. " second" .. char)
                    rprint(i, "|c[ warnings left ] ")
                    rprint(i, "|c" .. status.warnings)
                    rprint(i, "|c ")
                    rprint(i, "|c ")
                    rprint(i, "|c ")

                    -- Check player warnings
                    if (getWarnings(ip) <= 0) then
                        status.warn, status.enabled = false, false
                        execute_command("s " .. tonumber(i) .. " " .. tonumber(vanish.default_running_speed))
                        killSilently(i) -- KILL PLAYER
                        rprint(i, "Your vanish mode was auto-revoked! [no warnings left]")
                        if (vanish.announce) then
                            announceExclude(i, get_var(i, "$name") .. "'s vanish (spectator) privileges have been auto-revoked.")
                        end
                    end

                    if (status.timer >= vanish.time_until_death) then
                        status.warn, status.teleport, status.timer = false, false, 0
                        killSilently(i)
                        cls(i, 25)
                        rprint(i, "|c=========================================================")
                        rprint(i, "|cYou were killed!")
                        rprint(i, "|c=========================================================")
                        rprint(i, "|c ")
                        rprint(i, "|c ")
                        rprint(i, "|c ")
                        rprint(i, "|c ")
                        status.object = "" -- just in case
                    end
                end

                local score = tonumber(get_var(i, "$score"))
                if (score < 0) then
                    execute_command("score " .. tonumber(i) .. " " .. status.score)
                end

                -- BOOST HANDLER
                if (vanish.boost) then
                    local player = get_dynamic_player(i)
                    if (player ~= 0) then
                        local couching = read_float(player + 0x50C)
                        local is_crouching, shot_fired
                        if (couching == 0) then
                            is_crouching = false
                        else
                            is_crouching = true
                        end
                        if (vanish.boost_trigger == "crouch_and_shoot") then
                            shot_fired = read_float(player + 0x490)
                            if (shot_fired ~= weapon_status[i] and shot_fired == 1 and is_crouching) then
                                execute_command("boost " .. i)
                            end
                            weapon_status[i] = shot_fired
                        elseif (vanish.boost_trigger == "crouch" and is_crouching) then
                            execute_command("boost " .. i)
                        end
                    end
                end
            end
        end
    end
end

function OnServerCommand(PlayerIndex, Command, Environment, Password)
    local command, args = cmdsplit(Command)
    local executor = tonumber(PlayerIndex)
    local TargetID, target_all_players, is_error
    local name = get_var(executor, "$name")
    if (command == nil) then
        return
    end
    command = lower(command) or upper(command)

    local function checkAccess(e)
        local access
        if not isConsole(e) then
            if (tonumber(get_var(e, "$lvl")) >= vanish.permission_level) then
                access = true
            else
                rprint(e, "Command failed. Insufficient Permission.")
                access = false
            end
        else
            access = true
        end
        return access
    end

    local function isOnline(t, e)
        if (t) then
            if (t > 0 and t < 17) then
                if player_present(t) then
                    return true
                else
                    respond(e, "Command failed. Player not online.", "rcon", 4 + 8)
                    return false
                end
            else
                respond(e, "Invalid player id. Please enter a number between 1-16", "rcon", 4 + 8)
            end
        end
    end

    local params = { }
    local function validate_params(pos)
        local function getplayers(arg)
            local players = { }
            if (arg == nil) or (arg == "me") then
                TargetID = executor
                table.insert(players, executor)
            elseif (arg:match("%d+")) then
                TargetID = tonumber(arg)
                table.insert(players, arg)
            elseif (arg == "*" or arg == "all") then
                for i = 1, 16 do
                    if player_present(i) then
                        target_all_players = true
                        table.insert(players, i)
                    end
                end
            else
                respond(executor, "Invalid player id. Usage: [number: 1-16] | */all | me", "rcon", 4 + 8)
                is_error = true
                return false
            end

            for _,enabled in pairs(players) do
                if (executor ~= enabled) then
                    execute_on_others_error[executor] = { }
                    execute_on_others_error[executor] = true
                end
            end
            if players[1] then
                return players
            end
            players = nil
            return false
        end
        local pl = getplayers(args[tonumber(pos)])
        if pl then
            for i = 1, #pl do
                if pl[i] == nil then
                    break
                end

                params.eid, params.en = executor, name
                params.tid, params.tn = tonumber(pl[i]), get_var(pl[i], "$name")
                params.tip = getip(pl[i])

                if (args[1] ~= nil) then
                    params.option = args[1]
                end

                if (args[3] ~= nil) then
                    params.flag = args[3]
                end

                if (target_all_players) then
                    vanish:set(params)
                end
            end
        end
    end

    local gameover = function()
        if (game_over) then
            rprint(executor, "Command Failed -> Game has Ended.")
            rprint(executor, "Please wait until the next game has started.")
            return true
        end
    end

    if (command == vanish.command) then
        if not gameover() then
            if (checkAccess(executor)) then
                if (args[1] ~= nil) then
                    validate_params(2) -- /command <args> [me | id | */all] <flag>
                    if not (target_all_players) then
                        if not (is_error) and isOnline(TargetID, executor) then
                            vanish:set(params)
                        end
                    end
                else
                    respond(executor, "Invalid Syntax: Usage: /" .. vanish.command .. " on|off [me | id | */all] <flag>", "rcon", 4 + 8)
                end
            end
        end
        return false
    end
end

function remove_data_log(p)
    local params = { }
    local ip = getip(p)
    params.ip, params.save = ip, nil
    vanish:savetofile(params)
end

function vanish:set(params)
    local params = params or { }

    local en = params.en or nil
    local eid = params.eid or nil
    if (eid == nil) then
        eid = 0
    end

    local tn = params.tn or nil
    local tip = params.tip or nil

    local tid = params.tid or nil
    if (tid == nil and eid ~= nil) then
        tid = eid
    end

    local option = params.option or nil
    local flag = params.flag or nil

    local is_self
    if (eid == tid) then
        is_self = true
    end

    if isConsole(eid) then
        en = "SERVER"
    end

    vanish[tip] = vanish[tip] or { }
    local status = vanish[tip]
    status.warnings = (status.warnings) or getWarnings(tip)
    local warnings = status.warnings

    local function Enable()
        status.enabled, status.teleport, status.warn = true, false, false
        status.score, status.timer = get_var(tid, "$score"), 0

        local p = { }
        p.ip, p.save = tip, true
        vanish:savetofile(p)

        if (vanish.invincibility) then
            execute_command("god " .. tid)
        end
        if (vanish.announce) then
            announceExclude(tid, gsub(vanish.onEnableMsg, "%%name%%", tn))
        end
    end

    local function Disable(tid)
        status.enabled = false
        if (vanish.invincibility) then
            execute_command("ungod " .. tid)
        end
        if (vanish.announce) then
            announceExclude(tid, gsub(vanish.onDisabeMsg, "%%name%%", tn))
        end
        if (vanish.speed_boost) then
            execute_command("s " .. tonumber(tid) .. " " .. tonumber(vanish.default_running_speed))
        end
        remove_data_log(tid)
        killSilently(tid)
    end

    local cmd_flags, is_error, on_off = vanish.cmd_flags
    local function flag_check()
        local disabled_error, _error_
        if (flag ~= nil) then
            if (flag == cmd_flags[1]) then
                -- camo only
                if (vanish.camouflage) then
                    status.mode = "camouflage"
                    on_off = "Enabled (with Camouflage)"
                else
                    disabled_error, _error_ = true, "vanish.camouflage is disabled internally"
                end
            elseif (flag == cmd_flags[2]) then
                -- hidden only
                if (vanish.hide) then
                    status.mode = "hide"
                    on_off = "Enabled (hidden only)"
                else
                    disabled_error, _error_ = true, "vanish.hide is disabled internally"
                end
            elseif (flag == cmd_flags[3]) then
                -- camouflage + hidden
                if (vanish.camouflage) and (vanish.hide) then
                    status.mode = "camouflage_and_hide"
                    on_off = "Enabled (Hidden with Camouflage)"
                else
                    disabled_error, _error_ = true, "vanish.camouflage & vanish.hide are disabled internally"
                end
            else
                is_error, disabled_error = true, true
                respond(eid, "Invalid Syntax: Usage: /" .. vanish.command .. " on|off [me | id | */all] <flag>", "rcon", 4 + 8)
            end
            if not (disabled_error) then
                return true
            elseif not (is_error) then
                is_error = true
                respond(eid, "Command failed! (" .. _error_ .. ")", "rcon", 4 + 8)
                return false
            end
        else
            status.mode = "default"
            on_off = "Enabled"
            return true
        end
    end

    local eLvl = tonumber(get_var(eid, "$lvl"))
    if (executeOnOthers(eid, is_self, isConsole(eid), eLvl)) then
        if (tonumber(warnings) > 0) then
            local already_set
            if (option == "on") or (option == "1") or (option == "true") then
                if (status.enabled ~= true) then
                    if flag_check() then
                        already_set, is_error = false, false
                        Enable(tid, tn)
                    end
                else
                    on_off, already_set, is_error = "Enabled", true, false
                end
            elseif (option == "off") or (option == "0") or (option == "false") then
                if (status.enabled ~= false and status.enabled ~= nil) then
                    on_off, already_set, is_error = "Disabled", false, false
                    Disable(tid, tn)
                else
                    on_off, already_set, is_error = "Disabled", true, false
                end
            else
                is_error = true
                respond(eid, "Invalid Syntax: Usage: /" .. vanish.command .. " on|off [me | id | */all] <flag>", "rcon", 4 + 8)
            end
            if not (is_error) and not (already_set) then
                if not (is_self) then
                    respond(eid, "Invisibility " .. on_off .. " for " .. tn, "rcon", 2 + 8)
                    respond(tid, "Invisibility Mode was " .. on_off .. " by " .. en, "rcon")
                else
                    respond(eid, "Invisibility Mode " .. on_off, "rcon", 2 + 8)
                end
            elseif (already_set) then
                respond(eid, "[SERVER] -> " .. tn .. ", Invisibility already " .. on_off, "rcon", 4 + 8)
            end
        else
            if not (is_self) then
                respond(eid, tn .. "'s vanish has been revoked! [no warnings left]", "rcon", 2 + 8)
            else
                respond(tid, "Your vanish mode was auto-revoked! [no warnings left]", "rcon", 2 + 8)
            end
        end
    end
    return false
end

function getXYZ(p)
    local player_object = get_dynamic_player(p)
    if (player_object ~= 0) and player_alive(p) then

        local function isInVehicle(p)
            if (player_object) then
                local VehicleID = read_dword(player_object + 0x11C)
                if VehicleID == 0xFFFFFFFF then
                    return false
                else
                    return true
                end
            else
                return false
            end
        end

        local coords, x, y, z = { }
        if isInVehicle(p) then
            coords.invehicle = true
            local VehicleID = read_dword(player_object + 0x11C)
            local vehicle = get_object_memory(VehicleID)
            x, y, z = read_vector3d(vehicle + 0x5c)
        else
            coords.invehicle = false
            x, y, z = read_vector3d(player_object + 0x5c)
        end
        x, y, z = format("%0.3f", x), format("%0.3f", y), format("%0.3f", z)
        coords.x, coords.y, coords.z = x, y, z
        return coords
    end
end

function hasObjective(PlayerIndex, WeaponIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    local weaponId = read_dword(player_object + 0x118)
    if (weaponId ~= 0) then
        local ip = getip(PlayerIndex)
        local status = vanish[ip]

        local weapon_object = get_object_memory(read_dword(player_object + 0x2F8 + (tonumber(WeaponIndex) - 1) * 4))
        local tag_name = read_string(read_dword(read_word(weapon_object) * 32 + 0x40440038))

        for j = 0, 3 do
            local weapon = read_dword(player_object + 0x2F8 + 4 * j)
            if (weapon == red_flag) or (weapon == blue_flag) then
                status.objective = "flag"
                return true
            elseif (tag_name ~= nil and tag_name == "weapons\\ball\\ball") then
                status.objective = "oddball"
                return true
            end
        end
    end
end

function OnWeaponPickup(PlayerIndex, WeaponIndex, Type)
    local ip = getip(PlayerIndex)
    local status = vanish[ip]

    if (status ~= nil and status.enabled) then
        if (tonumber(Type) == 1) then
            if hasObjective(PlayerIndex, WeaponIndex) then

                -- Every time you pick up the flag, you will lose one warning point.
                status.warnings = (status.warnings - 1)
                status.warn = true
                execute_command("s " .. tonumber(PlayerIndex) .. " 0")

                if (status.warnings <= 0) then
                    status.warnings = 0
                end
            end
        end
    end
end

function OnWeaponDrop(PlayerIndex)
    local ip = getip(PlayerIndex)
    local status = vanish[ip]

    if (status ~= nil and status.enabled) and (status.warn) then
        status.warn, status.timer = false, 0
        -- APPLY SPEED - player was frozen when `OnWeaponPickup()` was called.
        execute_command("s " .. tonumber(PlayerIndex) .. " " .. tonumber(vanish.running_speed))
    end
end

function cmdsplit(str)
    local subs = {}
    local sub = ""
    local ignore_quote, inquote, endquote
    for i = 1, string.len(str) do
        local bool
        local char = string.sub(str, i, i)
        if char == " " then
            if (inquote and endquote) or (not inquote and not endquote) then
                bool = true
            end
        elseif char == "\\" then
            ignore_quote = true
        elseif char == "\"" then
            if not ignore_quote then
                if not inquote then
                    inquote = true
                else
                    endquote = true
                end
            end
        end

        if char ~= "\\" then
            ignore_quote = false
        end

        if bool then
            if inquote and endquote then
                sub = string.sub(sub, 2, string.len(sub) - 1)
            end

            if sub ~= "" then
                table.insert(subs, sub)
            end
            sub = ""
            inquote = false
            endquote = false
        else
            sub = sub .. char
        end

        if i == string.len(str) then
            if string.sub(sub, 1, 1) == "\"" and string.sub(sub, string.len(sub), string.len(sub)) == "\"" then
                sub = string.sub(sub, 2, string.len(sub) - 1)
            end
            table.insert(subs, sub)
        end
    end

    local cmd = subs[1]
    local args = subs
    table.remove(args, 1)

    return cmd, args
end

function lines_from(file)
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

function delete(dir, start_index, end_index)
    local fp = io.open(dir, "r")
    local t = {}
    i = 1;
    for line in fp:lines() do
        if i < start_index or i >= start_index + end_index then
            t[#t + 1] = line
        end
        i = i + 1
    end
    fp:close()
    fp = io.open(dir, "w+")
    for i = 1, #t do
        fp:write(format("%s\n", t[i]))
    end
    fp:close()
end

function isVanished(ip)
    local lines = lines_from(dir)
    for _, v in pairs(lines) do
        if (v:match(ip)) then
            return true
        end
    end
end

function vanish:savetofile(params)
    local params = params or { }
    local ip = params.ip or nil
    local save = params.save
    local lines, proceed = lines_from(dir), true
    for k, v in pairs(lines) do
        if (v:match(ip)) then
            if not (save) then
                delete(dir, k, 1)
                proceed = false
            else
                proceed = false
                local fRead = io.open(dir, "r")
                local content = fRead:read("*all")
                fRead:close()
                content = gsub(content, v, ip)
                local fWrite = io.open(dir, "w")
                fWrite:write(content)
                fWrite:close()
            end
        end
    end
    if (proceed) then
        local file = assert(io.open(dir, "a+"))
        file:write(ip .. "\n")
        file:close()
    end
end

function checkFile(directory)
    local file = io.open(directory, "rb")
    if file then
        file:close()
    else
        local file = io.open(directory, "a+")
        if file then
            file:close()
        end
    end
end

function secondsToTime(seconds, places)

    local years = floor(seconds / (60 * 60 * 24 * 365))
    seconds = seconds % (60 * 60 * 24 * 365)
    local weeks = floor(seconds / (60 * 60 * 24 * 7))
    seconds = seconds % (60 * 60 * 24 * 7)
    local days = floor(seconds / (60 * 60 * 24))
    seconds = seconds % (60 * 60 * 24)
    local hours = floor(seconds / (60 * 60))
    seconds = seconds % (60 * 60)
    local minutes = floor(seconds / 60)
    seconds = seconds % 60

    if (places == 6) then
        return format("%02d:%02d:%02d:%02d:%02d:%02d", years, weeks, days, hours, minutes, seconds)
    elseif (places == 5) then
        return format("%02d:%02d:%02d:%02d:%02d", weeks, days, hours, minutes, seconds)
    elseif not (places) or (places == 4) then
        return days, hours, minutes, seconds
    elseif (places == 3) then
        return format("%02d:%02d:%02d", hours, minutes, seconds)
    elseif (places == 2) then
        return format("%02d:%02d", minutes, seconds)
    elseif (places == 1) then
        return format("%02", seconds)
    end
end

function cls(PlayerIndex, count)
    if (PlayerIndex) then
        for _ = 1, count do
            respond(PlayerIndex, " ", "rcon")
        end
    end
end

function DestroyObject(object)
    if (object) then
        destroy_object(object)
    end
end

function DeleteWeapons(PlayerIndex)
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

function killSilently(PlayerIndex)
    if DeleteWeapons(PlayerIndex) then
        local kill_message_addresss = sig_scan("8B42348A8C28D500000084C9") + 3
        local original = read_dword(kill_message_addresss)
        safe_write(true)
        write_dword(kill_message_addresss, 0x03EB01B1)
        safe_write(false)
        execute_command("kill " .. tonumber(PlayerIndex))
        safe_write(true)
        write_dword(kill_message_addresss, original)
        safe_write(false)
        write_dword(get_player(PlayerIndex) + 0x2C, 0 * 33)
        -- Deduct one death
        local deaths = tonumber(get_var(PlayerIndex, "$deaths"))
        execute_command("deaths " .. tonumber(PlayerIndex) .. " " .. deaths - 1)
    end
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    if (vanish.block_damage) then
        if (tonumber(CauserIndex) > 0 and PlayerIndex ~= CauserIndex) then
            local vip, kip = getip(PlayerIndex), getip(CauserIndex)

            -- 22/04/20 [Fixed nil check error]:
            local v, k = vanish[vip] or nil, vanish[kip] or nil
            if (v ~= nil or k ~= nil) then
                if (v.enabled or k.enabled) then
                    return false
                end
            end
            --
        end
    end
end

function OnPlayerKill(PlayerIndex)
    local ip = getip(PlayerIndex)
    local status = vanish[ip]
    if (status ~= nil) then
        status.scores, status.timer, status.warn, status.has_objective = 0, 0, false, false
    end
end
