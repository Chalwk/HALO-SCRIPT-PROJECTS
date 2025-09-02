--[[
=====================================================================================
SCRIPT NAME:      server_logger.lua
DESCRIPTION:      Advanced server logging system that replaces SAPP's default logs.
                  Tracks player activity, game events, and admin commands with
                  customizable verbosity.

FEATURES:
                  - Detailed player join/quit logging (IP, hash, piracy status)
                  - Comprehensive death tracking (PVP, suicides, betrayals, etc.)
                  - Command and chat logging (with sensitive command filtering)
                  - Game state tracking (start/end, map resets)
                  - Customizable event types and verbosity

Copyright (c) 2024-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration starts here -----------------------------------------------------------------------
local CONFIG = {
    LOG_FILE = 'server_log.txt',
    DATE_FORMAT = '!%a, %d %b %Y %H:%M:%S',
    EVENTS = {
        ['OnScriptLoad'] = {
            enabled = true,
            log = '[SCRIPT LOAD] Advanced Logger was loaded'
        },
        ['OnScriptReload'] = {
            enabled = true,
            log = '[SCRIPT RELOAD] Advanced Logger was re-loaded'
        },
        ['OnScriptUnload'] = {
            enabled = true,
            log = '[SCRIPT UNLOAD] Advanced Logger was unloaded'
        },
        ['OnStart'] = {
            enabled = true,
            log = 'A new game has started on [$map] - [$mode]'
        },
        ['OnEnd'] = {
            enabled = true,
            log = 'Game Ended - Showing Post Game Carnage report'
        },
        ['OnJoin'] = {
            enabled = true,
            log = '[JOIN] $name ID: [$id] IP: [$ip] Hash: [$hash] Pirated: [$pirated] Total Players: [$total/16]'
        },
        ['OnQuit'] = {
            enabled = true,
            log = '[QUIT] $name ID: [$id] IP: [$ip] Hash: [$hash] Pirated: [$pirated] Total Players: [$total/16]'
        },
        ['OnSpawn'] = {
            enabled = false,
            log = '[SPAWN] $name spawned'
        },
        ['OnWarp'] = {
            enabled = true,
            log = '[WARP] $name is warping'
        },
        ['OnLogin'] = {
            enabled = true,
            log = '[LOGIN] $name has logged in. Admin Level: [$level]'
        },
        ['OnReset'] = {
            enabled = true,
            log = '[MAP RESET] The map has been reset.'
        },
        ['OnSwitch'] = {
            enabled = false,
            log = '[TEAM SWITCH] $name switched teams. New team: [$team]'
        },
        ['OnCommand'] = {
            enabled = true,
            log = '[COMMAND] $name: /$command [Type: $command_type] Admin Level: [$level]'
        },
        ['OnChat'] = {
            enabled = true,
            log = '[MESSAGE] $name: $message [Type: $message_type]'
        },
        ['OnScore'] = {
            [1] = { -- CTF
                enabled = false,
                log = '[SCORE] $playerName captured the flag for the $playerTeam team! Red: $redScore, Blue: $blueScore'
            },
            [2] = { -- Team Race
                enabled = false,
                log = '[SCORE] $playerName completed a lap for $playerTeam! Lap Time: $lap_time, Team Laps: $totalTeamLaps'
            },
            [3] = { -- FFA Race
                enabled = false,
                log = '[SCORE] $playerName finished a lap. Lap Time: $lap_time, Total Laps: $playerScore'
            },
            [4] = { -- Team Slayer
                enabled = false,
                log = '[SCORE] $playerName scored for $playerTeam team! Red: $redScore, Blue: $blueScore'
            },
            [5] = { -- FFA Slayer
                enabled = false,
                log = '[SCORE] $playerName scored! Current Score: $playerScore'
            }
        },
        ['OnDeath'] = {
            [1] = { -- first_blood
                enabled = false,
                log = '[DEATH] $killer got first blood on $victim'
            },
            [2] = { -- killed_from_grave
                enabled = false,
                log = '[DEATH] $victim was killed from the grave by $killer'
            },
            [3] = { -- run_over
                enabled = false,
                log = '[DEATH] $victim was run over by $killer'
            },
            [4] = { -- pvp
                enabled = false,
                log = '[DEATH] $victim was killed by $killer'
            },
            [5] = { -- guardians
                enabled = false,
                log = '[DEATH] $victim and $killer were killed by the guardians'
            },
            [6] = { -- suicide
                enabled = false,
                log = '[DEATH] $victim committed suicide'
            },
            [7] = { -- betrayal
                enabled = false,
                log = '[DEATH] $victim was betrayed by $killer'
            },
            [8] = { -- squashed
                enabled = false,
                log = '[DEATH] $victim was squashed by a vehicle'
            },
            [9] = { -- fell
                enabled = false,
                log = '[DEATH] $victim fell and broke their leg'
            },
            [10] = { -- server
                enabled = false,
                log = '[DEATH] $victim was killed by the server'
            },
            [11] = { -- unknown
                enabled = false,
                log = '[DEATH] $victim died'
            }
        }
    },
    SENSITIVE_COMMANDS = {
        'login', 'admin_add', 'change_password', 'admin_change_pw', 'admin_add_manually'
    },
    KNOWN_PIRATED_HASHES = {
        ['388e89e69b4cc08b3441f25959f74103'] = true,
        ['81f9c914b3402c2702a12dc1405247ee'] = true,
        ['c939c09426f69c4843ff75ae704bf426'] = true,
        ['13dbf72b3c21c5235c47e405dd6e092d'] = true,
        ['29a29f3659a221351ed3d6f8355b2200'] = true,
        ['d72b3f33bfb7266a8d0f13b37c62fddb'] = true,
        ['76b9b8db9ae6b6cacdd59770a18fc1d5'] = true,
        ['55d368354b5021e7dd5d3d1525a4ab82'] = true,
        ['d41d8cd98f00b204e9800998ecf8427e'] = true,
        ['c702226e783ea7e091c0bb44c2d0ec64'] = true,
        ['f443106bd82fd6f3c22ba2df7c5e4094'] = true,
        ['10440b462f6cbc3160c6280c2734f184'] = true,
        ['3d5cd27b3fa487b040043273fa00f51b'] = true,
        ['b661a51d4ccf44f5da2869b0055563cb'] = true,
        ['740da6bafb23c2fbdc5140b5d320edb1'] = true,
        ['7503dad2a08026fc4b6cfb32a940cfe0'] = true,
        ['4486253cba68da6786359e7ff2c7b467'] = true,
        ['f1d7c0018e1648d7d48f257dc35e9660'] = true,
        ['40da66d41e9c79172a84eef745739521'] = true,
        ['2863ab7e0e7371f9a6b3f0440c06c560'] = true,
        ['34146dc35d583f2b34693a83469fac2a'] = true,
        ['b315d022891afedf2e6bc7e5aaf2d357'] = true,
        ['63bf3d5a51b292cd0702135f6f566bd1'] = true,
        ['6891d0a75336a75f9d03bb5e51a53095'] = true,
        ['325a53c37324e4adb484d7a9c6741314'] = true,
        ['0e3c41078d06f7f502e4bb5bd886772a'] = true,
        ['fc65cda372eeb75fc1a2e7d19e91a86f'] = true,
        ['f35309a653ae6243dab90c203fa50000'] = true,
        ['50bbef5ebf4e0393016d129a545bd09d'] = true,
        ['a77ee0be91bd38a0635b65991bc4b686'] = true,
        ['3126fab3615a94119d5fe9eead1e88c1'] = true,
    }
}
-- Configuration ends here -----------------------------------------------------------------------

api_version = '1.12.0.0'

local io_open = io.open
local os_date, os_time = os.date, os.time
local string_format = string.format
local tonumber, tostring = tonumber, tostring
local ipairs = ipairs

local get_var, player_present, player_alive, register_callback =
    get_var, player_present, player_alive, register_callback

local read_dword, sig_scan, lookup_tag, get_dynamic_player =
    read_dword, sig_scan, lookup_tag, get_dynamic_player

local players = {}
local current_map, current_mode, current_gametype
local ffa, falling, distance, first_blood
local log_directory

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function formatLog(log, args)
    return (log:gsub("($[%w_]+)", function(placeholder)
        return args[placeholder] or placeholder
    end))
end

local function writeToFile(content)
    local file, err = io_open(log_directory, 'a+')
    if not file then
        print("Error opening log file: " .. err)
        return false
    end
    file:write(content .. '\n')
    file:close()
    return true
end

local function formatTime(lap_time)
    local minutes = math.floor(lap_time / 60)
    local seconds = math.floor(lap_time % 60)
    local milliseconds = math.floor((lap_time * 1000) % 1000)
    return string_format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

local function logEvent(event_name, args, is_death_or_score)
    local event_config = CONFIG.EVENTS[event_name]
    if not event_config or not event_config.enabled then return end

    local log
    if is_death_or_score then
        log = event_config[args.event_type] and event_config[args.event_type].log
    else
        log = event_config.log
    end

    if log then
        local formatted = formatLog(log, args)
        local timestamp = os_date(CONFIG.DATE_FORMAT)
        local log_entry = string_format('[%s] %s', timestamp, formatted)
        writeToFile(log_entry)
    end
end

local function isSensitiveCommand(command)
    for _, cmd in ipairs(CONFIG.SENSITIVE_COMMANDS) do
        if command:find(cmd) then
            return true
        end
    end
    return false
end

local function isCommand(message)
    return message:sub(1, 1) == '/' or message:sub(1, 1) == '\\'
end

local function inVehicle(id)
    local dyn_player = get_dynamic_player(id)
    return dyn_player ~= 0 and read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF
end

local function getTotalPlayers(quit)
    local total = tonumber(get_var(0, "$pn"))
    return quit and total - 1 or total
end

function OnStart(notify_flag)
    current_gametype = get_var(0, "$gt")
    if current_gametype == 'n/a' then return end

    current_map = get_var(0, "$map")
    current_mode = get_var(0, "$mode")
    players = {}
    first_blood = true
    ffa = get_var(0, '$ffa') == '1'
    falling = getTag('jpt!', 'globals\\falling')
    distance = getTag('jpt!', 'globals\\distance')

    if not notify_flag then
        logEvent('OnStart', {
            ['$map'] = current_map,
            ['$mode'] = current_mode
        })
    end

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i, notify_flag)
        end
    end
end

function OnEnd()
    logEvent('OnEnd', {})
end

function OnJoin(id, notify_flag)
    local name = get_var(id, '$name')
    local hash = get_var(id, '$hash')
    local pirated = CONFIG.KNOWN_PIRATED_HASHES[hash] and 'YES' or 'NO'

    players[id] = {
        name = name,
        meta = 0,
        id = id,
        ip = get_var(id, '$ip'),
        team = get_var(id, '$team'),
        hash = hash,
        pirated = pirated,
        level = function()
            return tonumber(get_var(id, '$lvl'))
        end,
        lap_time = os_time()
    }

    if not notify_flag then
        logEvent('OnJoin', {
            ['$name'] = name,
            ['$id'] = tostring(id),
            ['$ip'] = get_var(id, '$ip'),
            ['$hash'] = hash,
            ['$pirated'] = pirated,
            ['$total'] = getTotalPlayers()
        })
    end
end

function OnSpawn(id)
    local player = players[id]
    player.meta = 0
    player.lap_time = os_time()
    logEvent('OnSpawn', { ['$name'] = player.name })
end

function OnQuit(id)
    local player = players[id]
    if player then
        logEvent('OnQuit', {
            ['$name'] = player.name,
            ['$id'] = tostring(id),
            ['$ip'] = player.ip,
            ['$hash'] = player.hash,
            ['$pirated'] = player.pirated,
            ['$total'] = getTotalPlayers(true)
        })
        players[id] = nil
    end
end

function OnSwitch(id)
    local player = players[id]
    player.team = get_var(id, '$team')
    logEvent('OnSwitch', {
        ['$name'] = player.name,
        ['$team'] = player.team
    })
end

function OnWarp(id)
    local player = players[id]
    logEvent('OnWarp', { ['$name'] = player.name })
end

function OnReset()
    logEvent('OnReset', {})
end

function OnLogin(id)
    local player = players[id]
    if player then
        logEvent('OnLogin', {
            ['$name'] = player.name,
            ['$level'] = player.level()
        })
    end
end

local command_types = { [0] = "CONSOLE", [1] = "RCON", [2] = "CHAT" }
function OnCommand(id, command, env)
    if not isSensitiveCommand(command) then
        local player = players[id]
        if player then
            logEvent('OnCommand', {
                ['$name'] = player.name,
                ['$command'] = command,
                ['$command_type'] = command_types[env] or "UNKNOWN",
                ['$level'] = player.level()
            })
        end
    end
end

local message_types = { [0] = "GLOBAL", [1] = "TEAM", [2] = "VEHICLE" }
function OnChat(id, message, env)
    if not isCommand(message) and not isSensitiveCommand(message) then
        local player = players[id]
        if player then
            logEvent('OnChat', {
                ['$name'] = player.name,
                ['$message'] = message,
                ['$message_type'] = message_types[env] or "UNKNOWN"
            })
        end
    end
end

function OnScore(id)
    local player = players[id]
    if player then
        local event_type = ({
            ctf = 1,
            race = not ffa and 2 or 3,
            slayer = not ffa and 4 or 5
        })[current_gametype]

        if event_type then
            local now = os_time()
            local lap_time = formatTime(now - player.lap_time)

            local blue_score = get_var(0, "$bluescore")
            local red_score = get_var(0, "$redscore")

            logEvent('OnScore', {
                ['$event_type'] = event_type,
                ['$lap_time'] = lap_time,
                ['$totalTeamLaps'] = player.team == "red" and red_score or blue_score,
                ['$playerScore'] = get_var(id, "$score"),
                ['$playerName'] = player.name,
                ['$playerTeam'] = player.team or "FFA",
                ['$redScore'] = red_score,
                ['$blueScore'] = blue_score
            }, true)

            player.lap_time = now
        end
    end
end

function OnDeath(victimId, killerId, metaId)
    local victim = tonumber(victimId)
    local victim_data = players[victim]
    if not victim_data then return end

    if metaId then
        victim_data.meta = metaId
        return true
    end

    local killer = tonumber(killerId)
    local killer_data = players[killer]

    local event_type
    if killer == 0 then
        event_type = 8  -- squashed
    elseif not killer then
        event_type = 5  -- guardians
    elseif killer == victim then
        event_type = 6  -- suicide
    elseif killer == -1 then
        event_type = 10 -- server
    else
        local betrayal = not ffa and killer_data and victim_data.team == killer_data.team
        local fell = victim_data.meta == falling or victim_data.meta == distance

        if betrayal then
            event_type = 7 -- betrayal
        elseif fell then
            event_type = 9 -- fell
        else
            if first_blood then
                first_blood = false
                event_type = 1
            elseif not player_alive(killer) then
                event_type = 2
            elseif inVehicle(killer) then
                event_type = 3
            else
                event_type = 4
            end
        end
    end

    logEvent('OnDeath', {
        ['$killer'] = killer_data and killer_data.name or "",
        ['$victim'] = victim_data.name,
        ['event_type'] = event_type or 11
    }, true)
end

function OnScriptLoad()
    local directory = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    log_directory = directory .. '\\sapp\\' .. CONFIG.LOG_FILE

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_CHAT'], 'OnChat')
    register_callback(cb['EVENT_WARP'], 'OnWarp')
    register_callback(cb['EVENT_LOGIN'], 'OnLogin')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_MAP_RESET'], 'OnReset')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDeath')
    register_callback(cb['EVENT_SCORE'], 'OnScore')

    if get_var(0, '$gt') ~= 'n/a' then
        logEvent('OnScriptReload', {})
        OnStart(true)
    else
        logEvent('OnScriptLoad', {})
    end
end

function OnScriptUnload()
    logEvent('OnScriptUnload', {})
end