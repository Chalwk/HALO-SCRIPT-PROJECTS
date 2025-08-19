--[[
=====================================================================================
SCRIPT NAME:      player_vanish.lua
DESCRIPTION:      Advanced player vanishing system with multiple stealth features
                  - Complete invisibility from other players
                  - Optional vehicle/radar hiding
                  - Built-in invincibility and speed boosts
                  - Persistent vanish state across sessions
                  - Admin-controlled permissions

                  Core Features:
                  - /vanish command with on/off toggle
                  - Multiple identification methods (IP/hash/name)
                  - Configurable speed boost (default 2x)
                  - Optional teleport-to-target function
                  - Automatic or manual cleanup options

                  Admin Controls:
                  - Permission level requirements
                  - Per-player vanish management
                  - Global vanish settings
                  - Customizable messages

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- todo: Rewrite this script!

api_version = "1.12.0.0"
local vanish = {}

-- Player Vanish Configuration [starts] --

-- Base Command: 
vanish.command = "vanish" -- /command on|off [me | id | */all]
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

-- If this is true, you will be camouflaged.
-- Despite the fact that players wont be able to see you anyway, this feature doubles as a visual reminder to the player that they are vanished.
vanish.camouflage = true

-- If this is true, vanish will be auto-disabled (for all players) when the game ends, thus, players will not be in vanish when the next game begins.
-- They will have to turn it back on.
vanish.auto_off = false

-- If this is true, your vehicle will disappear too!
vanish.hide_vehicles = true

-- If this is true, you will be hidden from radar.
vanish.hide_from_radar = true

-- If this is true, the player will have a speed boost:
vanish.speed_boost = true
-- Speed boost applied (default running speed is 1):
vanish.running_speed = 2
-- Speed the player returns to when they exit out of Vanish Mode:
vanish.default_running_speed = 1


-- =============== ENABLE | DISABLE Messages =============== --
-- Let players know when someone goes into Player Vanish mode:
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

-- Tell other players that PlayerX joined in vanish? (requires vanish.keep to be enabled) 
vanish.join_tell_others = true
vanish.join_others_msg = "%name% joined vanished!"
--==================================================================================================--
-- Vanish Configuration [ends] --

local script_version, weapon_status = 1.5, { }
local lower, upper, format, gsub = string.lower, string.upper, string.format, string.gsub
local dir = 'sapp\\vanish.tmp'
local globals = nil

local function getip(p)
    if (p) then
        return get_var(p, "$ip")--:match("(%d+.%d+.%d+.%d+)")
    end
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
                    rprint(i, "SAPP Reloaded.", "rcon", 4 + 8)
                else
                    rprint(i, "GAME OVER.", "rcon", 4 + 8)
                end
                remove_data_log(i)
                rprint(i, "Your vanish has been deactivated.", "rcon", 4 + 8)
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

        if (tonumber(get_var(0, "$pn")) > 0) then
            reset()
        end
    end
end

function OnScriptUnload()
    --
end

-- Stores Player IP to an array...
-- Because SAPP cannot retrieve the player IP on 'event_leave' if playing on PC.
-- This table is only accessed when 'event_leave' is called.
local ip_table = { }

function OnGameStart()
    game_over = false
end

function OnGameEnd()
    game_over = true
    if (vanish.auto_off) and (tonumber(get_var(0, "$pn")) > 0) then
        reset()
    end
end

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

    local function tell(p, bool)
        vanish[ip] = vanish[ip] or {}
        if (vanish.join_tell) then
            local join_message = gsub(vanish.join_msg, "%%name%%", get_var(p, "$name"))
            respond(p, join_message, "rcon", 2 + 8)
        end

        if (vanish.join_tell_others) then
            local msg = gsub(vanish.join_others_msg, "%%name%%", get_var(p, "$name"))
            announceExclude(p, msg, "rcon", 2 + 8)
        end
        if (bool) then
            vanish[ip].enabled = true
            if (vanish.invincibility) then
                execute_command("god " .. p)
            end
        end
    end

    local status = vanish[ip]
    local was_vanished = isVanished(ip)

    if (status ~= nil and status.enabled) then
        tell(p)
    elseif (status == nil) and (was_vanished) then
        tell(p, true)
    end
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
            vanish[ip(p)] = nil
            weapon_status[p] = nil
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
            local status = vanish[getip(i)]
            if (status ~= nil) and (status.enabled) then

                local coords = getXYZ(i)
                if (coords) then
                    if ((coords.invehicle and vanish.hide_vehicles) or not coords.invehicle) then
                        hide_player(i, coords)
                    end
                end

                if (vanish.camouflage) then
                    execute_command("camo " .. i .. " 1")
                end

                -- Speed seems to decrease over time on SAPP, so continuously updating player speed here seems to fix that.
                if (vanish.speed_boost) then
                    execute_command("s " .. tonumber(i) .. " " .. tonumber(vanish.running_speed))
                end

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

            for i,_ in pairs(players) do
                if (executor ~= tonumber(players[i])) then
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
                    validate_params(2) -- /command <args> [me | id | */all]
                    if not (target_all_players) then
                        if not (is_error) and isOnline(TargetID, executor) then
                            vanish:set(params)
                        end
                    end
                else
                    respond(executor, "Invalid Syntax: Usage: /" .. vanish.command .. " on|off [me | id | */all] ", "rcon", 4 + 8)
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

    local is_self
    if (eid == tid) then
        is_self = true
    end

    if isConsole(eid) then
        en = "SERVER"
    end

    vanish[tip] = vanish[tip] or { }

    local function Enable()
        vanish[tip].enabled = true
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
        vanish[tip].enabled = false
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
    end

    local eLvl = tonumber(get_var(eid, "$lvl"))
    if (executeOnOthers(eid, is_self, isConsole(eid), eLvl)) then
        local status, already_set, is_error
        if (option == "on") or (option == "1") or (option == "true") then
            if (vanish[tip].enabled ~= true) then
                status, already_set, is_error = "Enabled", false, false
                Enable(tid, tn)
            else
                status, already_set, is_error = "Enabled", true, false
            end
        elseif (option == "off") or (option == "0") or (option == "false") then
            if (vanish[tip].enabled ~= false and vanish[tip].enabled ~= nil) then
                status, already_set, is_error = "Disabled", false, false
                Disable(tid, tn)
            else
                status, already_set, is_error = "Disabled", true, false
            end
        else
            is_error = true
            respond(eid, "Invalid Syntax: Usage: /" .. vanish.command .. " on|off [me | id | */all] ", "rcon", 4 + 8)
        end
        if not (is_error) and not (already_set) then
            if not (is_self) then
                respond(eid, "Invisibility " .. status .. " for " .. tn, "rcon", 2 + 8)
                respond(tid, "Invisibility Mode was " .. status .. " by " .. en, "rcon")
            else
                respond(eid, "Invisibility Mode " .. status, "rcon", 2 + 8)
            end
        elseif (already_set) then
            respond(eid, "[SERVER] -> " .. tn .. ", Invisibility already " .. status, "rcon", 4 + 8)
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

-- In the event of an error, the script will trigger these two functions: OnError(), report()
function report()
    local script_version = format("%0.2f", script_version)
    cprint("--------------------------------------------------------", 5 + 8)
    cprint("Please report this error on github:", 7 + 8)
    cprint("https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/issues", 7 + 8)
    cprint("Script Version: " .. script_version, 7 + 8)
    cprint("--------------------------------------------------------", 5 + 8)
end

-- This function will return a string with a traceback of the stack call...
-- ...and call function 'report' after 50 milliseconds.
function OnError()
    cprint(debug.traceback(), 4 + 8)
    timer(50, "report")
end

--[[ =================== Change Log ===================
[24/05/19]
1). First release (v1.0)

[25/05/19]
1). Bug fixes
2). New setting: 'vanish.auto_off'.
If this is true, vanish will be auto-disabled (for all players) when the game ends, thus, players will not be in vanish when the next game begins.
Script Updated to (v1.2)

[26/05/19]
1). New setting: 'vanish.hide_vehicles' -> If this is true, your vehicle will disappear too!
2). You will now be hidden from the radar!
Script Updated to (v1.3)

3). New setting: 'vanish.camouflage' -> If this is true, you will be camouflaged.
Despite the fact that players won't be able to see you anyway, this feature doubles
as a visual reminder to the player that they are vanished.

5). Vanish status is now saved to a temp file called 'vanish.tmp', located in 'server root/sapp/vanish.tmp'.
- The first reason for this: To overcome a problem when the script is reloaded.
- The second reason: Should the server crash, returning players who were previously in vanish will have their vanish restored,
because their vanish status was saved and loaded to/from that file.
Script Updated to (v1.4)

[28/05/19]
1). New setting: 'vanish.hide_from_radar' -> If this is true, you will be hidden from radar.
2). Documentation edits.
3). Bug fix.
Script Updated to (v1.5)

]]
