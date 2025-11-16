--[[
=====================================================================================
SCRIPT NAME:      discord.lua
DESCRIPTION:      Logs Halo server events and exports them
                  to a JSON file for external processing by a Discord bot.

                  This script listens for in-game callbacks and converts
                  them into structured messages or embeds that are written
                  out as JSON. Templates use dynamic placeholders
                  which are replaced at runtime.


                  ================================================================================
                  ================================================================================

                  This script REQUIRES the SAPPDiscordBot to be installed and running.
                  Download it from: https://github.com/Chalwk/SAPPDiscordBot

                  ================================================================================
                  ================================================================================


CONFIGURATION:    CHANNELS: Maps Discord channel IDs.
                    - Keys IDs used internally by the script to categorize events
                    - "GENERAL" : for general game events (start, end, join, leave, score, death, etc.)
                    - "CHAT"    : for player chat messages
                    - "COMMAND" : for commands issued by players/admins
                    - Values are Discord channel IDs where messages/embeds will be sent

                  SUPPORTED EVENTS AND AVAILABLE PLACEHOLDERS

                    $serverName         - (embed footers only)

                    event_start / event_end / event_map_reset:
                        $map            - Current map name
                        $mode           - Current mode
                        $gt             - Current game type (eg "slayer", "race")
                        $ffa            - "FFA" or "Team Play" depending on mode

                    event_join / event_leave:
                        $total          - Current number of players
                        $name           - Player name
                        $ip             - Player IP
                        $hash           - Player CD-key hash
                        $id             - Player id
                        $lvl            - Player admin level
                        $ping           - Player ping
                        $pirated        - "YES"/"NO" flag if hash matches known list

                    event_spawn:
                        $name           - Player name
                        $team           - Player team

                    event_team_switch:
                        $name           - Player name
                        $team           - New team

                    event_login:
                        $name           - Player name
                        $lvl            - Player admin level

                    event_snap:
                        $name           - Player name

                    event_command:
                        $lvl            - Player admin level
                        $name           - Player name
                        $id             - Player index
                        $type           - Command source text (RCON, CONSOLE, CHAT, UNKNOWN)
                        $cmd            - Command text

                    event_chat:
                        $type           - Chat source (GLOBAL, TEAM, VEHICLE, UNKNOWN)
                        $name           - Player name
                        $id             - Player index
                        $msg            - Message content

                    event_score (per gametype subtype):
                        $totalTeamLaps  - Team lap total (race)
                        $score          - Individual score or player laps (depends on gametype)
                        $name           - Player name who scored
                        $team           - Player team or "FFA"
                        $redScore       - Current red team score
                        $blueScore      - Current blue team score
                        $scorelimit     - Score limit

                        Subtype mapping used in code:
                          1 = CTF
                          2 = Team Race
                          3 = FFA Race
                          4 = Team Slayer
                          5 = FFA Slayer

                    event_death (per death subtype):
                        $victimName     - Name of the player who died
                        $killerName     - Name of the killer when applicable (empty string otherwise)

                        Subtype mapping used in code:
                          1  = first blood
                          2  = killed from the grave
                          3  = vehicle kill
                          4  = pvp
                          5  = suicide
                          6  = betrayal
                          7  = squashed by a vehicle
                          8  = fall damage
                          9  = killed by the server
                          10 = unknown / fallback


LAST UPDATED:     16/11/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFG START -----------------------------------------------------------------------
local CONFIG = {
    CHANNELS = {
        GENERAL = '1439547790312341584',
        CHAT = '1439547790312341584',
        COMMAND = '1439547790312341584'
    },

    EVENTS = {
        GENERAL = {
            event_start = {
                enable = true,
                embed = {
                    description = "**🗺️ Game Started** → `$map` **-** `$gt ($ffa)`",
                    color = 'green',
                    footer = true
                }
            },

            event_end = {
                enable = true,
                embed = {
                    description = "**🏁 Game Ended** → `$map` **-** `$gt ($ffa)`",
                    color = 'red',
                    footer = true
                }
            },

            event_join = {
                enable = true,
                text = "**🟢 Join** → `$name` **-** `$total/16`"
            },

            event_leave = {
                enable = true,
                text = "**🔴 Quit** → `$name` **-** `$total/16`"
            },

            event_spawn = {
                enable = false,
                text = "**✨ Spawn** → `$name` Team: `$team`"
            },

            event_team_switch = {
                enable = false,
                text = "**🔄 Team Switch** → `$name` → `$team`"
            },

            event_map_reset = {
                enable = false,
                text = "**♻️ Map Reset** → `$map` **-** `$gt ($ffa)`"
            },

            event_login = {
                enable = false,
                embed = {
                    description = "**🔐 Login** → `$name`",
                    color = 'yellow',
                    footer = true,
                    fields = {
                        {
                            name = "Admin Level",
                            value = "$lvl",
                            inline = true
                        }
                    }
                }
            },

            event_snap = {
                enable = false,
                text = "**📸 Snap** → `$name`"
            },

            event_score = {
                [1] = {
                    enable = true,
                    embed = {
                        title = "🏆 CTF Scoreboard update!",
                        description =
                        "**$name** captured the flag for the **$team** team!\n\n🟥 Red Score: **$redScore**\n🟦 Blue Score: **$blueScore**\n🏁 Scorelimit: **$scorelimit**",
                        color = 'green',
                        footer = true
                    }
                },

                [2] = {
                    enable = true,
                    embed = {
                        title = "🏆 Team RACE Scoreboard updated!",
                        description =
                        "**$name** completed a lap for **$team** team!\n🏁 Team Total Laps: **$totalTeamLaps/$scorelimit**\n🚩 Player Laps: **$score**",
                        color = 'green',
                        footer = true
                    }
                },

                [3] = {
                    enable = true,
                    embed = {
                        title = "🏆 FFA RACE Scoreboard updated!",
                        description = "**$name** finished a lap.\n🏆 Total Laps Completed: **$score/$scorelimit**",
                        color = 'green',
                        footer = true
                    }
                },

                [4] = {
                    enable = true,
                    embed = {
                        title = "🏆 Team Slayer Scoreboard updated!",
                        description =
                        "**$name** scored for **$team** team!\n\n🟥 Red Score: **$redScore**\n🟦 Blue Score: **$blueScore**\n🏁 Scorelimit: **$scorelimit**",
                        color = 'green',
                        footer = true
                    }
                },

                [5] = {
                    enable = true,
                    embed = {
                        title = "🏆 FFA Slayer Scoreboard updated!",
                        description =
                        "**$name** scored!\n\n🟥 Red Score: **$redScore**\n🟦 Blue Score: **$blueScore**\n🏁 Scorelimit: **$scorelimit**",
                        color = 'green',
                        footer = true
                    }
                }
            },

            event_death = {
                [1]  = { enable = true, text = "**☠️ Death:** `$killerName` drew first blood on `$victimName`" },
                [2]  = { enable = true, text = "**☠️ Death:** `$victimName` was killed from the grave by `$killerName`" },
                [3]  = { enable = true, text = "**☠️ Death:** `$victimName` was run over by `$killerName`" },
                [4]  = { enable = true, text = "**☠️ Death:** `$victimName` was killed by `$killerName`" },
                [5]  = { enable = true, text = "**☠️ Death:** `$victimName` committed suicide" },
                [6]  = { enable = true, text = "**☠️ Death:** `$victimName` was betrayed by `$killerName`" },
                [7]  = { enable = true, text = "**☠️ Death:** `$victimName` was squashed by a vehicle" },
                [8]  = { enable = true, text = "**☠️ Death:** `$victimName` fell to their death" },
                [9]  = { enable = true, text = "**☠️ Death:** `$victimName` was killed by the server" },
                [10] = { enable = true, text = "**☠️ Death:** `$victimName` died" }
            }
        },

        CHAT = {
            enable = true,
            text = "**💬 Chat** → `$name`: *$msg*"
        },

        COMMAND = {
            enable = true,
            embed = {
                description = "**⌘ Command** → `$name`: `$cmd`",
                color = 'green',
                footer = true
            }
        }
    },

    COLORS = {
        red = 0xFF0000,
        green = 0x00FF00,
        blue = 0x0000FF,
        yellow = 0xFFFF00,
        orange = 0xFFA500,
        purple = 0x800080,
        cyan = 0x00FFFF,
        pink = 0xFFC0CB,
        white = 0xFFFFFF,
        black = 0x000000,
        grey = 0x808080
    },

    PIRATED_HASHES = {
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
        ['3126fab3615a94119d5fe9eead1e88c1'] = true
    }
}
-- CONFG ENDS -----------------------------------------------------------------------

api_version = '1.12.0.0'

-- Standard Lua functions
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local io_open = io.open
local os_remove = os.remove
local table_insert = table.insert
local concat = table.concat
local char = string.char

-- SAPP API functions
local get_var = get_var
local player_present = player_present
local player_alive = player_alive
local register_callback = register_callback
local read_byte = read_byte
local read_dword = read_dword
local sig_scan = sig_scan
local lookup_tag = lookup_tag
local get_dynamic_player = get_dynamic_player

-- JSON handling
local json
local log_path

-- Game/server state
local players
local server_name
local map
local mode
local gametype
local gametype_base
local score_limit
local ffa
local first_blood
local falling_tag
local distance_tag

-- Constants
local COMMAND_TYPE = { [0] = "RCON", [1] = "CONSOLE", [2] = "CHAT", [3] = "UNKNOWN" }
local CHAT_TYPE = { [0] = "GLOBAL", [1] = "TEAM", [2] = "VEHICLE", [3] = "UNKNOWN" }
local GAMETYPE_MAP = { ctf = 1, race = 2, slayer = 4 }
local CALLBACKS = {
    [cb['EVENT_CHAT']] = 'OnChat',
    [cb['EVENT_COMMAND']] = 'OnCommand',
    [cb['EVENT_DIE']] = 'OnDeath',
    [cb['EVENT_SCORE']] = 'OnScore',
    [cb['EVENT_DAMAGE_APPLICATION']] = 'OnDamage',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_GAME_END']] = 'OnEnd',
    [cb['EVENT_GAME_START']] = 'OnStart',
    [cb['EVENT_SNAP']] = 'OnSnap',
    [cb['EVENT_SPAWN']] = 'OnSpawn',
    [cb['EVENT_LOGIN']] = 'OnLogin',
    [cb['EVENT_MAP_RESET']] = "OnReset",
    [cb['EVENT_TEAM_SWITCH']] = 'OnSwitch'
}

local function clearLog()
    local file = io_open(log_path, "w")
    if file then
        file:write("[]"); file:close()
    end
end

local function WriteToJSON(eventData, attempt)
    attempt = attempt or 1
    local lockPath = log_path .. ".lock"

    local success, result = pcall(function()
        local lockFile = io_open(lockPath, "w")
        if not lockFile then return false end
        lockFile:close()

        local events = {}
        local file = io_open(log_path, "r")
        if file then
            local content = file:read("*a")
            file:close()
            if content ~= "" and content ~= " " then
                events = json:decode(content) or {}
            end
        end

        table_insert(events, eventData)

        file = io_open(log_path, "w")
        if not file then
            os_remove(lockPath); return false
        end
        file:write(json:encode(events))
        file:close()

        os_remove(lockPath)
        return true
    end)

    pcall(function() os_remove(lockPath) end)

    if not success and attempt < 3 then
        timer(100, "RetryWriteToJSON", json:encode(eventData), attempt + 1)
    end

    return success and result
end

function RetryWriteToJSON(jsonString, attempt)
    attempt = tonumber(attempt) or 1
    local success = WriteToJSON(json:decode(jsonString), attempt)
    if not success and attempt < 3 then
        timer(100, "RetryWriteToJSON", jsonString, attempt + 1)
    end
end

local function parseTemplate(template, args) return (template:gsub("($%w+)", args)) end

local function getEventConfig(event, subtype)
    if event == "event_chat" then return CONFIG.EVENTS.CHAT end
    if event == "event_command" then return CONFIG.EVENTS.COMMAND end

    local general = CONFIG.EVENTS.GENERAL[event]
    return subtype and general[subtype] or general
end

local function getChannelID(event)
    return CONFIG.CHANNELS[event == "event_chat" and "CHAT" or event == "event_command" and "COMMAND" or "GENERAL"]
end

local function logEvent(event, args, subtype)
    local config = getEventConfig(event, subtype)
    if not config or not config.enable then return end

    local channel_id = getChannelID(event)
    args["$serverName"] = server_name

    if config.embed then
        local embed = {
            title = parseTemplate(config.embed.title or "", args),
            description = parseTemplate(config.embed.description or "", args),
            color = CONFIG.COLORS[config.embed.color],
            channel_id = channel_id
        }

        if config.embed.footer then embed.footer = server_name end
        if config.embed.fields then
            embed.fields = {}
            for _, field in ipairs(config.embed.fields) do
                embed.fields[#embed.fields + 1] = {
                    name = parseTemplate(field.name, args),
                    value = parseTemplate(field.value, args),
                    inline = field.inline
                }
            end
        end

        WriteToJSON({ embed = embed })
    else
        WriteToJSON({
            message = {
                channel_id = channel_id,
                text = parseTemplate(config.text, args)
            }
        })
    end
end

local function readWideString(address, length)
    local bytes = {}
    for i = 1, length do
        local byte = read_byte(address + (i - 1) * 2)
        if byte == 0 then break end
        bytes[#bytes + 1] = char(byte)
    end
    return concat(bytes)
end

local function getServerName()
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    return readWideString(network_struct + 0x8, 0x42)
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function newPlayer(id)
    return {
        id = id,
        last_damage = 0,
        switched = false,
        ip = get_var(id, '$ip'),
        name = get_var(id, '$name'),
        team = get_var(id, '$team'),
        hash = get_var(id, '$hash'),
        level = function() return tonumber(get_var(id, '$lvl')) end
    }
end

local function getPlayerData(player, isQuit)
    local total = tonumber(get_var(0, '$pn'))
    return {
        ["$total"] = isQuit and total - 1 or total,
        ["$name"] = player.name,
        ["$ip"] = player.ip,
        ["$hash"] = player.hash,
        ["$id"] = player.id,
        ["$lvl"] = player.level(),
        ["$ping"] = get_var(player.id, "$ping"),
        ["$pirated"] = CONFIG.PIRATED_HASHES[player.hash] and 'YES' or 'NO'
    }
end

local function inVehicle(id)
    local dyn_player = get_dynamic_player(id)
    return dyn_player ~= 0 and read_dword(dyn_player + 0x11C) ~= 0xFFFFFFFF
end

function OnStart(notifyFlag)
    gametype = get_var(0, "$gt")
    if gametype == 'n/a' then return end

    if not server_name then
        server_name = getServerName()
        log_path = "./discord_events/" .. server_name .. ".json"
        clearLog()
    end

    players, first_blood = {}, true
    ffa = get_var(0, '$ffa') == '1'
    mode, map = get_var(0, "$mode"), get_var(0, "$map")
    falling_tag, distance_tag = getTag('jpt!', 'globals\\falling'), getTag('jpt!', 'globals\\distance')
    score_limit = read_byte(gametype_base + 0x58)

    if not notifyFlag or notifyFlag == 0 then
        logEvent("event_start", {
            ["$map"] = map,
            ["$mode"] = mode,
            ["$gt"] = gametype,
            ["$ffa"] = ffa and "FFA" or "Team Play"
        })
    end

    for i = 1, 16 do
        if player_present(i) then OnJoin(i, notifyFlag) end
    end
end

function OnEnd()
    logEvent("event_end", {
        ["$map"] = map,
        ["$mode"] = mode,
        ["$gt"] = gametype,
        ["$ffa"] = ffa and "FFA" or "Team Play"
    })
end

function OnJoin(id, notifyFlag)
    players[id] = newPlayer(id)
    if not notifyFlag then
        logEvent("event_join", getPlayerData(players[id]))
    end
end

function OnQuit(id)
    local player = players[id]
    if player then
        logEvent("event_leave", getPlayerData(player, true))
        players[id] = nil
    end
end

function OnSpawn(id)
    local player = players[id]
    if player then
        player.last_damage, player.switched = 0, nil
        logEvent("event_spawn", { ["$name"] = player.name, ["$team"] = player.team })
    end
end

function OnSwitch(id)
    local player = players[id]
    if player then
        player.team, player.switched = get_var(id, '$team'), true
        logEvent("event_team_switch", { ["$name"] = player.name, ["$team"] = player.team })
    end
end

function OnReset()
    logEvent("event_map_reset", {
        ["$map"] = map,
        ["$mode"] = mode,
        ["$gt"] = gametype,
        ["$ffa"] = ffa and "FFA" or "Team Play"
    })
end

function OnLogin(id)
    local player = players[id]
    if player then
        logEvent("event_login", { ["$name"] = player.name, ["$lvl"] = player.level() })
    end
end

function OnSnap(id)
    local player = players[id]
    if player then logEvent("event_snap", { ["$name"] = player.name }) end
end

function OnCommand(id, command, env)
    local player = players[id]
    if player then
        logEvent("event_command", {
            ["$lvl"] = player.level(),
            ["$name"] = player.name,
            ["$id"] = tostring(id),
            ["$type"] = COMMAND_TYPE[env],
            ["$cmd"] = command
        })
    end
    return true
end

function OnChat(id, msg, env)
    local player = players[id]
    if player and msg:sub(1, 1) ~= "/" and msg:sub(1, 1) ~= "\\" and msg:sub(1, 1) ~= "@" then
        logEvent("event_chat", {
            ["$type"] = CHAT_TYPE[env],
            ["$name"] = player.name,
            ["$id"] = id,
            ["$msg"] = msg
        })
    end
end

function OnScore(id)
    local player = players[id]
    if not player then return end

    local event_type = GAMETYPE_MAP[gametype] or (gametype == "race" and (ffa and 3 or 2))
    if not event_type then return end

    logEvent("event_score", {
        ["$totalTeamLaps"] = player.team == "red" and get_var(0, "$redscore") or get_var(0, "$bluescore"),
        ["$score"] = get_var(id, "$score"),
        ["$name"] = player.name,
        ["$team"] = player.team or "FFA",
        ["$redScore"] = get_var(0, "$redscore"),
        ["$blueScore"] = get_var(0, "$bluescore"),
        ["$scorelimit"] = score_limit
    }, event_type)
end

function OnDamage(victim, _, metaId)
    local player = players[tonumber(victim)]
    if player then player.last_damage = metaId end
end

function OnDeath(victim, killer)
    victim, killer = tonumber(victim), tonumber(killer)
    local victim_data, killer_data = players[victim], players[killer]
    if not victim_data then return end

    local event_type = 10
    if killer == -1 and not victim_data.switched then
        event_type = (victim_data.last_damage == falling_tag or victim_data.last_damage == distance_tag) and 8 or 9
    elseif killer == 0 then
        event_type = 7
    elseif killer > 0 then
        if killer == victim then
            event_type = 5
        elseif not ffa and killer_data and victim_data.team == killer_data.team then
            event_type = 6
        elseif first_blood then
            first_blood = false; event_type = 1
        elseif not player_alive(killer) then
            event_type = 2
        elseif inVehicle(victim) then
            event_type = 3
        else
            event_type = 4
        end
    end

    logEvent("event_death", {
        ["$killerName"] = killer_data and killer_data.name or "",
        ["$victimName"] = victim_data.name
    }, event_type)
end

function OnScriptLoad()
    local success, result = pcall(function() return loadfile('json.lua')() end)
    if not success then
        error("Failed to load json.lua")
        return
    end

    json = result
    gametype_base = read_dword(sig_scan("B9360000008BF3BF78545F00") + 0x8)
    for event, handler in pairs(CALLBACKS) do
        register_callback(event, handler)
    end

    OnStart(1)
end

function OnScriptUnload() end
