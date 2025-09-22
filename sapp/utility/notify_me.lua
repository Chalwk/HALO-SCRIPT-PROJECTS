--[[
=====================================================================================
SCRIPT NAME:      notify_me.lua
DESCRIPTION:      Enhanced console notification system for SAPP servers that provides:
                  - Color-coded event notifications (joins, quits, deaths, etc.)
                  - Customizable timestamp formatting
                  - Optional ASCII art logo display
                  - Support for all major server events

FEATURES:
                  - 16-color support using SAPP's color codes
                  - Dynamic message templates with placeholder substitution
                  - Configurable output for each event type
                  - First blood detection
                  - Detailed death cause reporting

LAST UPDATED:     22/09/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration starts here -----------------------------------------------------------------------
local CONFIG = {
    TIMESTAMP_FORMAT = '!%a %d %b %Y %H:%M:%S',

    SAPP_COLORS = {
        black = 0,
        blue = 1,
        green = 2,
        light_blue = 3,
        red = 4,
        purple = 5,
        yellow = 6,
        white = 7,
        gray = 8,
        light_gray = 9,
        light_green = 10,
        cyan = 11,
        light_red = 12,
        pink = 13,
        light_yellow = 14,
        orange = 15
    },

    LOGO = {
        enabled = true,
        text = {
            { "================================================================================", 'green' },
            { "$timeStamp",                                                                       'yellow' },
            { "",                                                                                 'black' },
            { "     '||'  '||'     |     '||'       ..|''||           ..|'''.| '||''''|  ",       'red' },
            { "      ||    ||     |||     ||       .|'    ||        .|'     '   ||  .    ",       'red' },
            { "      ||''''||    |  ||    ||       ||      ||       ||          ||''|    ",       'red' },
            { "      ||    ||   .''''|.   ||       '|.     ||       '|.      .  ||       ",       'red' },
            { "     .||.  .||. .|.  .||. .||.....|  ''|...|'         ''|....'  .||.....| ",       'red' },
            { "               ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-",               'gray' },
            { "                             $serverName",                                         'green' },
            { "               ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-",               'gray' },
            { "",                                                                                 'black' },
            { "================================================================================", 'green' }
        }
    },

    EVENTS = {
        ["OnStart"] = {
            enabled = true,
            log = "A new game has started on $map - $mode",
            color = 'green'
        },
        ["OnEnd"] = {
            enabled = true,
            log = "The game has ended.",
            color = 'red'
        },
        ["OnJoin"] = {
            enabled = true,
            log = "$name\nHash: $hash\nIP: $ip\nID: $id\nLevel: $lvl\nPirated: $pirated\n",
            color = 'green'
        },
        ["OnQuit"] = {
            enabled = true,
            log = "$name\nHash: $hash\nIP: $ip\nID: $id\nLevel: $lvl",
            color = 'red'
        },
        ["OnSpawn"] = {
            enabled = true,
            log = "$name spawned",
            color = 'light_yellow'
        },
        ["OnSwitch"] = {
            enabled = true,
            log = "$name switched teams. New team: [$team]",
            color = 'light_yellow'
        },
        ["OnWarp"] = {
            enabled = true,
            log = "$name is warping",
            color = 'light_yellow'
        },
        ["OnReset"] = {
            enabled = true,
            log = "The map [$map / $mode] has been reset.",
            color = 'light_yellow'
        },
        ["OnLogin"] = {
            enabled = true,
            log = "$name logged in",
            color = 'light_yellow'
        },
        ["OnSnap"] = {
            enabled = true,
            log = "$name snapped",
            color = 'light_yellow'
        },
        ["OnCommand"] = {
            enabled = true,
            log = "[$type CMD] $name ($id): $cmd",
            color = 'light_yellow'
        },
        ["OnChat"] = {
            enabled = true,
            log = "[$type MSG] $name ($id): $msg",
            color = 'light_yellow'
        },
        ['OnScore'] = {
            [1] = { -- CTF
                enabled = false,
                log = '[SCORE] $name captured the flag for the $team team! Red: $redScore, Blue: $blueScore',
                color = 'yellow'
            },
            [2] = { -- Team Race
                enabled = false,
                log =
                '[SCORE] $name completed a lap for $team! Lap Time: $lap_time, Team Laps: $totalTeamLaps',
                color = 'yellow'
            },
            [3] = { -- FFA Race
                enabled = false,
                log = '[SCORE] $name finished a lap. Lap Time: $lap_time, Total Laps: $score',
                color = 'yellow'
            },
            [4] = { -- Team Slayer
                enabled = false,
                log = '[SCORE] $name scored for $team team! Red: $redScore, Blue: $blueScore',
                color = 'yellow'
            },
            [5] = { -- FFA Slayer
                enabled = false,
                log = '[SCORE] $name scored! Current Score: $score',
                color = 'yellow'
            }
        },
        ["OnDeath"] = {
            [1] = { -- first blood
                enabled = true,
                log = "$killerName drew first blood on $victimName",
                color = 'green'
            },
            [2] = { -- killed from the grave
                enabled = true,
                log = "$victimName was killed from the grave by $killerName",
                color = 'green'
            },
            [3] = { -- vehicle kill
                enabled = true,
                log = "$victimName was run over by $killerName",
                color = 'green'
            },
            [4] = { -- pvp
                enabled = true,
                log = "$victimName was killed by $killerName",
                color = 'green'
            },
            [5] = { -- suicide
                enabled = true,
                log = "$victimName committed suicide",
                color = 'green'
            },
            [6] = { -- betrayal
                enabled = true,
                log = "$victimName was betrayed by $killerName",
                color = 'green'
            },
            [7] = { -- squashed by a vehicle
                enabled = true,
                log = "$victimName was squashed by a vehicle",
                color = 'green'
            },
            [8] = { -- fall damage
                enabled = true,
                log = "$victimName fell to their death",
                color = 'green'
            },
            [9] = { -- killed by the server
                enabled = true,
                log = "$victimName was killed by the server",
                color = 'green'
            },
            [10] = { -- unknown death
                enabled = true,
                log = "$victimName died",
                color = 'green'
            }
        }
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

api_version = '1.12.0.0'

-- Configuration ends here -----------------------------------------------------------------------

local players = {}
local date = os.date
local ffa, falling, distance, first_blood

local tick_rate = 1 / 30
local score_limit
local gametype_base
local current_gametype, mode, map

local chat_type = { [0] = "GLOBAL", [1] = "TEAM", [2] = "VEHICLE", [3] = "UNKNOWN" }
local command_type = { [0] = "RCON", [1] = "CONSOLE", [2] = "CHAT", [3] = "UNKNOWN" }

local tonumber, ipairs = tonumber, ipairs
local string_char, string_format, table_concat = string.char, string.format, table.concat
local math_huge, math_floor = math.huge, math.floor
local get_var, player_present, player_alive = get_var, player_present, player_alive
local read_byte, read_dword, cprint, timer = read_byte, read_dword, cprint, timer

local get_dynamic_player = get_dynamic_player

function OnScriptLoad()
    gametype_base = read_dword(sig_scan("B9360000008BF3BF78545F00") + 0x8)

    register_callback(cb['EVENT_CHAT'], 'OnChat')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_SCORE'], 'OnScore')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_SNAP'], 'OnSnap')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_LOGIN'], 'OnLogin')
    register_callback(cb['EVENT_MAP_RESET'], "OnReset")
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')

    OnStart()
    timer(50, "DisplayASCIIArt")
end

local function parseTemplate(template, args)
    return (template:gsub("($[%w_]+)", function(placeholder)
        return args[placeholder] or placeholder
    end))
end

local function isPirated(hash)
    return CONFIG.KNOWN_PIRATED_HASHES[hash] and 'YES' or 'NO'
end

local function getQuitJoinData(id, quit)
    local total = tonumber(get_var(0, '$pn'))
    total = (quit and total - 1) or total

    return {
        ["$total"] = total,
        ["$name"] = players[id].name,
        ["$ip"] = players[id].ip,
        ["$hash"] = players[id].hash,
        ["$id"] = players[id].id,
        ["$lvl"] = players[id].level,
        ["$ping"] = get_var(id, "$ping"),
        ["$pirated"] = isPirated(players[id].hash)
    }
end

local function newPlayer(id)
    return {
        level = tonumber(get_var(id, '$lvl')),
        id = id,
        last_damage = 0,
        switched = false,
        ip = get_var(id, '$ip'),
        name = get_var(id, '$name'),
        team = get_var(id, '$team'),
        hash = get_var(id, '$hash')
    }
end

local function isCommand(str)
    return str:sub(1, 1) == "/" or str:sub(1, 1) == "\\"
end

local function inVehicle(id)
    local dyn_player = get_dynamic_player(id)
    if dyn_player == 0 then return false end
    return read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF
end

local function getColor(colorString)
    return CONFIG.SAPP_COLORS[colorString]
end

local function log(eventName, args)
    local event = CONFIG.EVENTS[eventName]
    if not event or not event.enabled then return end

    local msg = parseTemplate(event.log, args)
    cprint(msg, getColor(event.color))
end

local function notifyDeathOrScore(args, source)
    local category = CONFIG.EVENTS[source]
    local event_type = args["$event_type"]
    local event = category and category[event_type]
    if not event or not event.enabled then return end

    local msg = parseTemplate(event.log, args)
    cprint(msg, getColor(event.color))
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function readWideString(Address, Length)
    local count = 0
    local byte_table = {}
    for i = 1, Length do
        if (read_byte(Address + count) ~= 0) then
            byte_table[i] = string_char(read_byte(Address + count))
        end
        count = count + 2
    end
    return table_concat(byte_table)
end

local function getServerName()
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    return readWideString(network_struct + 0x8, 0x42)
end

local function getscorelimit()
    return read_byte(gametype_base + 0x58)
end

local function formatTime(lap_time)
    if lap_time == 0 or lap_time == math_huge then return "00:00.000" end
    local total_hundredths = math_floor(lap_time * 100 + 0.5)
    local minutes = math_floor(total_hundredths / 6000)
    local remaining_hundredths = total_hundredths % 6000
    local secs = math_floor(remaining_hundredths / 100)
    local hundredths = remaining_hundredths % 100
    return string_format("%02d:%02d.%03d", minutes, secs, hundredths)
end

local function roundToHundredths(num)
    return math_floor(num * 100 + 0.5) / 100
end

local function getLapTicks(address)
    if address == 0 then return 0 end
    return read_word(address)
end

function DisplayASCIIArt()
    local logo = CONFIG.LOGO
    if not logo.enabled then return end

    for _, line in ipairs(logo.text) do
        local message, color = line[1], getColor(line[2])
        if message then
            message = message:gsub("$timeStamp", date(CONFIG.TIMESTAMP_FORMAT))
                :gsub("$serverName", getServerName())
            cprint(message, color)
        end
    end
end

function OnStart()
    current_gametype = get_var(0, "$gt")
    if current_gametype == "n/a" then return end

    players = {}
    first_blood = true
    ffa = (get_var(0, '$ffa') == '1')
    map = get_var(0, '$map')
    mode = get_var(0, '$mode')
    falling = getTag('jpt!', 'globals\\falling')
    distance = getTag('jpt!', 'globals\\distance')
    score_limit = getscorelimit()

    log("OnStart", { ["$map"] = map, ["$mode"] = mode })

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    log("OnEnd", { ["$map"] = map, ["$mode"] = mode })
end

function OnJoin(id)
    players[id] = newPlayer(id)
    log("OnJoin", getQuitJoinData(id))
end

function OnQuit(id)
    local player = players[id]
    if player then
        local data = getQuitJoinData(id, true)
        log("OnQuit", data)
        players[id] = nil
    end
end

function OnSpawn(id)
    local player = players[id]
    if player then
        player.last_damage = 0
        player.switched = nil
        log("OnSpawn", { ["$name"] = player.name })
    end
end

function OnSwitch(id)
    local player = players[id]
    if player then
        player.team = get_var(id, '$team')
        player.switched = true
        log("OnSwitch", { ["$name"] = player.name, ["$team"] = player.team })
    end
end

function OnWarp(id)
    local player = players[id]
    if player then
        log("OnWarp", { ["$name"] = player.name })
    end
end

function OnReset()
    log("OnReset", { ["$map"] = map, ["$mode"] = mode })
end

function OnLogin(id)
    local player = players[id]
    if player then
        log("OnLogin", { ["$name"] = player.name })
    end
end

function OnSnap(id)
    local player = players[id]
    if player then
        log("OnSnap", { ["$name"] = player.name })
    end
end

function OnCommand(id, command, environment)
    local player = players[id]
    if player then
        local cmd = command:match("^(%S+)")
        log("OnCommand", {
            ["$type"] = command_type[environment],
            ["$name"] = player.name,
            ["$id"] = id,
            ["$cmd"] = cmd
        })
    end
end

function OnChat(id, message, environment)
    local player = players[id]
    if player and not isCommand(message) then
        log("OnChat", {
            ["$type"] = chat_type[environment],
            ["$name"] = player.name,
            ["$id"] = id,
            ["$msg"] = message
        })
    end
end

function OnScore(id)
    local player = players[id]
    if not player then return end

    local event_type = ({
        ctf = 1,
        race = not ffa and 2 or 3,
        slayer = not ffa and 4 or 5
    })[current_gametype]

    local event_cfg = CONFIG.EVENTS["OnScore"][event_type]
    if not event_cfg or not event_cfg.enabled then return end

    local blue_score = get_var(0, "$bluescore")
    local red_score = get_var(0, "$redscore")

    local lap_time = 0
    if current_gametype == "race" then
        local static_player = get_player(id)
        local lap_ticks = getLapTicks(static_player + 0xC4)
        lap_time = roundToHundredths(lap_ticks * tick_rate)
    end

    notifyDeathOrScore({
        ["$event_type"] = event_type,
        ["$lap_time"] = formatTime(lap_time),
        ["$totalTeamLaps"] = player.team == "red" and red_score or blue_score,
        ["$score"] = get_var(id, "$score"),
        ["$name"] = player.name,
        ["$team"] = player.team or "FFA",
        ["$redScore"] = red_score,
        ["$blueScore"] = blue_score,
        ["$maxLaps"] = score_limit
    }, "OnScore")
end

function OnDamage(victimIndex, _, metaId)
    local victim = players[tonumber(victimIndex)]
    if victim then victim.last_damage = metaId end
end

function OnDeath(victimIndex, killerIndex)
    local victim = tonumber(victimIndex)
    local victim_data = players[victim]
    if not victim_data then return end

    local killer = tonumber(killerIndex)
    local killer_data = players[killer]

    local event_type = 10 -- fallback event type

    if killer == -1 and not victim_data.switched then
        if victim_data.last_damage == falling or victim_data.last_damage == distance then
            event_type = 8 -- fall damage
        else
            event_type = 9 -- server
        end
    elseif killer == 0 then
        event_type = 7  -- squashed
    elseif killer == nil then
        event_type = 10 -- unknown/guardians
    elseif killer > 0 then
        if killer == victim then
            event_type = 5 -- suicide
        elseif not ffa and killer_data and victim_data.team == killer_data.team then
            event_type = 6 -- betrayal
        elseif first_blood then
            first_blood = false
            event_type = 1 -- first blood
        elseif not player_alive(killer) then
            event_type = 2 -- killed from the grave
        elseif inVehicle(victim) then
            event_type = 3 -- vehicle kill
        else
            event_type = 4 -- pvp
        end
    end

    notifyDeathOrScore({
        ["$event_type"] = event_type,
        ["$killerName"] = killer_data and killer_data.name or "",
        ["$victimName"] = victim_data.name
    }, "OnDeath")
end

function OnScriptUnload() end
