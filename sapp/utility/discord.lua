--[[
=====================================================================================
SCRIPT NAME:      discord.lua
DESCRIPTION:      Logs Halo server events and exports them
                  to a JSON file for external processing by a Discord bot.

                  This script listens for in-game callbacks and converts
                  them into structured messages or embeds that are written
                  out as JSON. Templates use dynamic placeholders
                  which are replaced at runtime.

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


LAST UPDATED:     23/9/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- Configuration starts here -----------------------------------------------------------------------
local CONFIG = {
    CHANNELS = {
        ['GENERAL'] = 'xxxxxxxxxxxxxxxxxxx',
        ['CHAT'] = 'xxxxxxxxxxxxxxxxxxx',
        ['COMMAND'] = 'xxxxxxxxxxxxxxxxxxx'
    },
    EVENTS = {
        GENERAL = {
            event_start = {
                enable = true,
                embed = {
                    description = "**🗺️ Game Started** → `$map` **-** `$gt ($ffa)`",
                    color = 'green',
                    footer = "$serverName"
                }
            },
            event_end = {
                enable = true,
                embed = {
                    description = "**🏁 Game Ended** → `$map` **-** `$gt ($ffa)`",
                    color = 'red',
                    footer = "$serverName"
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
                    footer = "$serverName",
                    fields = {
                        { name = "Admin Level", value = "$lvl", inline = true }
                    }
                }
            },
            event_snap = {
                enable = false,
                text = "**📸 Snap** → `$name`"
            },
            event_score = {
                [1] = { -- CTF
                    enable = true,
                    embed = {
                        title = "🏆 CTF Scoreboard update!",
                        description = [[
**$name** captured the flag for the **$team** team!

🟥 Red Score: **$redScore**
🟦 Blue Score: **$blueScore**
🏁 Scorelimit: **$scorelimit**
]],
                        color = 'green',
                        footer = "$serverName"
                    }
                },
                [2] = { -- Team Race
                    enable = true,
                    embed = {
                        title = "🏆 Team RACE Scoreboard updated!",
                        description = [[
**$name** completed a lap for **$team** team!
🏁 Team Total Laps: **$totalTeamLaps/$scorelimit**
🚩 Player Laps: **$score**
]],
                        color = 'green',
                        footer = "$serverName"
                    }
                },
                [3] = { -- FFA Race
                    enable = true,
                    embed = {
                        title = "🏆 FFA RACE Scoreboard updated!",
                        description = [[
**$name** finished a lap.
🏆 Total Laps Completed: **$score/$scorelimit**
]],
                        color = 'green',
                        footer = "$serverName"
                    }
                },
                [4] = { -- Team Slayer
                    enable = true,
                    embed = {
                        title = "🏆 Team Slayer Scoreboard updated!",
                        description = [[
**$name** scored for **$team** team!

🟥 Red Score: **$redScore**
🟦 Blue Score: **$blueScore**
🏁 Scorelimit: **$scorelimit**
]],
                        color = 'green',
                        footer = "$serverName"
                    }
                },
                [5] = { -- FFA Slayer
                    enable = true,
                    embed = {
                        title = "🏆 FFA Slayer Scoreboard updated!",
                        description = [[
**$name** scored!

🟥 Red Score: **$redScore**
🟦 Blue Score: **$blueScore**
🏁 Scorelimit: **$scorelimit**
]],
                        color = 'green',
                        footer = "$serverName"
                    }
                }
            },
            event_death = {
                [1] = { -- first blood
                    enable = true,
                    text = "**☠️ Death:** `$killerName` drew first blood on `$victimName`"
                },
                [2] = { -- killed from the grave
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was killed from the grave by `$killerName`"
                },
                [3] = { -- vehicle kill
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was run over by `$killerName`"
                },
                [4] = { -- pvp
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was killed by `$killerName`"
                },
                [5] = { -- suicide
                    enable = true,
                    text = "**☠️ Death:** `$victimName` committed suicide"
                },
                [6] = { -- betrayal
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was betrayed by `$killerName`"
                },
                [7] = { -- squashed by a vehicle
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was squashed by a vehicle"
                },
                [8] = { -- fall damage
                    enable = true,
                    text = "**☠️ Death:** `$victimName` fell to their death"
                },
                [9] = { -- killed by the server
                    enable = true,
                    text = "**☠️ Death:** `$victimName` was killed by the server"
                },
                [10] = { -- unknown death
                    enable = true,
                    text = "**☠️ Death:** `$victimName` died"
                }
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
                footer = "$serverName"
            }
        }
    },

    -- HEX color codes for embed messages
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

    -- Known CD-key hashes from pirated/cracked Halo copies.
    -- Used to flag players with "$pirated = YES".
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

local json, log_path

local pcall = pcall
local io_open = io.open
local os_remove = os.remove
local tonumber, tostring = tonumber, tostring
local table_insert, pairs, ipairs = table.insert, pairs, ipairs
local char, concat = string.char, table.concat

local get_var, player_present, player_alive, register_callback =
    get_var, player_present, player_alive, register_callback

local read_byte, read_dword, sig_scan, lookup_tag, get_dynamic_player, timer =
    read_byte, read_dword, sig_scan, lookup_tag, get_dynamic_player, timer

local players = {}
local server_name
local map, mode, gametype
local gametype_base, score_limit
local ffa, falling, distance, first_blood

local command_type = {
    [0] = "RCON",
    [1] = "CONSOLE",
    [2] = "CHAT",
    [3] = "UNKNOWN",
}

local chat_type = {
    [0] = "GLOBAL",
    [1] = "TEAM",
    [2] = "VEHICLE",
    [3] = "UNKNOWN",
}

local function registerServer()
    local serverFilePath = "./servers.json"
    local servers = {}

    -- Try to read existing servers
    local file = io_open(serverFilePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and content ~= "" then
            local ok, decoded = pcall(function() return json:decode(content) end)
            if ok and type(decoded) == "table" then
                servers = decoded
            else
                return false, "Failed to decode existing servers.json"
            end
        end
    end

    -- Check if server is already registered
    if servers[server_name] then return true end

    -- Add this server's entry
    servers[server_name] = log_path

    -- Write back
    file = io_open(serverFilePath, "w")
    if not file then
        return false, "Failed to open servers.json for writing"
    end

    local ok, err = pcall(function()
        file:write(json:encode(servers))
    end)
    file:close()

    if not ok then
        return false, "Failed to write to servers.json: " .. tostring(err)
    end

    return true
end

local function clearLog()
    local file = io_open(log_path, "w")
    if file then
        file:write("[]")
        file:close()
    end
end

function WriteToJSON(eventData, attempt)
    attempt = attempt or 1
    local maxRetries = 3
    local retryDelay = 100

    -- Create a lock file path
    local lockPath = log_path .. ".lock"

    local success, result = pcall(function()
        -- Create lock file
        local lockFile = io_open(lockPath, "w")
        if not lockFile then return false, "Could not create lock file" end
        lockFile:close()

        -- Read existing events
        local events = {}
        local file = io_open(log_path, "r")
        if file then
            local content = file:read("*a")
            file:close()
            if content and content ~= "" and content ~= " " then
                events = json:decode(content) or {}
            end
        end

        table_insert(events, eventData)

        -- Write back
        file = io_open(log_path, "w")
        if not file then
            os_remove(lockPath)
            return false, "Failed to open file for writing"
        end
        file:write(json:encode(events))
        file:close()

        -- Remove lock file
        os_remove(lockPath)
        return true
    end)

    -- Clean up lock file if it still exists
    pcall(function() os_remove(lockPath) end)

    if success and result then return true end

    -- Retry if failed
    if attempt < maxRetries then -- todo: fix this
        timer(retryDelay, "WriteToJSON", eventData, attempt + 1)
        return false
    end

    return false
end

local function parseTemplate(template, args)
    return (template:gsub("($[%w_]+)", function(placeholder)
        return args[placeholder] or placeholder
    end))
end

local function getEmbedColor(embed)
    if not embed.color then return nil end
    return CONFIG.COLORS[embed.color] or embed.color
end

local function parseEmbedTemplate(embedTemplate, args)
    local embed = {}
    embed.title = parseTemplate(embedTemplate.title or " ", args)
    embed.description = parseTemplate(embedTemplate.description or "", args)
    embed.color = getEmbedColor(embedTemplate)
    embed.footer = embedTemplate.footer

    if embedTemplate.fields then
        embed.fields = {}
        for i, field in ipairs(embedTemplate.fields) do
            embed.fields[i] = {
                name = parseTemplate(field.name or "", args),
                value = parseTemplate(field.value or "", args),
                inline = field.inline
            }
        end
    end

    return embed
end

local function getEvent(event_name, event_type)
    -- Handle special cases for CHAT and COMMAND
    if event_name == "event_chat" then
        return CONFIG.EVENTS.CHAT
    elseif event_name == "event_command" then
        return CONFIG.EVENTS.COMMAND
    end

    -- Handle GENERAL events
    local general_events = CONFIG.EVENTS.GENERAL[event_name]
    if not general_events then return nil end

    -- Handle events with subtypes (event_score, event_death)
    if event_type and general_events[event_type] then
        return general_events[event_type]
    end

    return general_events
end

local function getChannelForEvent(event_name)
    if event_name == "event_chat" then
        return "CHAT"
    elseif event_name == "event_command" then
        return "COMMAND"
    else
        return "GENERAL"
    end
end

local function log(event_name, args)
    local event_type = args and args.event_type
    local event = getEvent(event_name, event_type)
    if not event or not event.enable then return end

    local channel_id = CONFIG.CHANNELS[getChannelForEvent(event_name)]

    if event.embed then
        local embed = parseEmbedTemplate(event.embed, args)
        embed.channel_id = channel_id
        WriteToJSON({ embed = embed })
    else
        -- Fallback to regular message
        local text = parseTemplate(event.text, args)
        WriteToJSON({
            message = {
                channel_id = channel_id,
                text = text,
            }
        })
    end
end

local function readWideString(address, length)
    local count = 0
    local byte_table = {}
    for i = 1, length do
        if read_byte(address + count) ~= 0 then
            byte_table[i] = char(read_byte(address + count))
        end
        count = count + 2
    end
    return concat(byte_table)
end

local function getServerName()
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    return readWideString(network_struct + 0x8, 0x42)
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function getTeamPlay()
    return ffa and "FFA" or "Team Play"
end

local function getscorelimit()
    return read_byte(gametype_base + 0x58)
end

local function isPirated(hash)
    return CONFIG.KNOWN_PIRATED_HASHES[hash] and 'YES' or 'NO'
end

local function getPlayerData(player, quit)
    local total = tonumber(get_var(0, '$pn'))
    total = (quit and total - 1) or total

    return {
        ["$total"] = total,
        ["$name"] = player.name,
        ["$ip"] = player.ip,
        ["$hash"] = player.hash,
        ["$id"] = player.id,
        ["$lvl"] = player.level(),
        ["$ping"] = get_var(player.id, "$ping"),
        ["$pirated"] = isPirated(player.hash)
    }
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
        level = function()
            return tonumber(get_var(id, '$lvl'))
        end
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

local function replaceServerNameInEmbeds(configTable)
    for _, value in pairs(configTable) do
        if type(value) == "table" then
            -- Check if this is an event with an embed that has a footer
            if value.embed and value.embed.footer then
                value.embed.footer = value.embed.footer:gsub("%$serverName", server_name)
            end

            -- Recursively process nested tables
            replaceServerNameInEmbeds(value)
        end
    end
end

function OnStart(notifyFlag)
    gametype = get_var(0, "$gt")
    if gametype == 'n/a' then return end

    if server_name == nil then
        server_name = getServerName()
        replaceServerNameInEmbeds(CONFIG.EVENTS)
        log_path = "./discord_events/" .. server_name .. ".json"

        local reg_success, err = registerServer()
        if not reg_success then
            error("registerServer failed: " .. tostring(err))
        end
        clearLog() -- ensure file is clean
    end

    players = {}
    first_blood = true
    ffa = get_var(0, '$ffa') == '1'
    mode = get_var(0, "$mode")
    map = get_var(0, "$map")
    falling = getTag('jpt!', 'globals\\falling')
    distance = getTag('jpt!', 'globals\\distance')
    score_limit = getscorelimit()

    if not notifyFlag or notifyFlag == 0 then
        log("event_start", {
            ["$map"] = map,
            ["$mode"] = mode,
            ["$gt"] = gametype,
            ["$ffa"] = getTeamPlay()
        })
    end

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i, notifyFlag)
        end
    end
end

function OnEnd()
    log("event_end", {
        ["$map"] = map,
        ["$mode"] = mode,
        ["$gt"] = gametype,
        ["$ffa"] = getTeamPlay()
    })
end

function OnJoin(id, notifyFlag)
    players[id] = newPlayer(id)

    if not notifyFlag or notifyFlag == 0 then
        log("event_join", getPlayerData(players[id]))
    end
end

function OnQuit(id)
    local player = players[id]
    if not player then return end

    log("event_leave", getPlayerData(player, true))
    players[id] = nil
end

function OnSpawn(id)
    local player = players[id]
    if not player then return end

    player.last_damage = 0
    player.switched = nil
    log("event_spawn", { ["$name"] = player.name, ["$team"] = player.team })
end

function OnSwitch(id)
    local player = players[id]
    if not player then return end

    player.team = get_var(id, '$team')
    player.switched = true
    log("event_team_switch", { ["$name"] = player.name, ["$team"] = player.team })
end

function OnReset()
    log("event_map_reset", {
        ["$map"] = map,
        ["$mode"] = mode,
        ["$gt"] = gametype,
        ["$ffa"] = getTeamPlay()
    })
end

function OnLogin(id)
    local player = players[id]
    if not player then return end

    log("event_login", {
        ["$name"] = player.name,
        ["$lvl"] = player.level()
    })
end

function OnSnap(id)
    local player = players[id]
    if not player then return end

    log("event_snap", { ["$name"] = player.name })
end

function OnCommand(id, command, environment)
    local player = players[id]
    if not player then return true end

    log("event_command", {
        ["$lvl"] = player.level(),
        ["$name"] = player.name,
        ["$id"] = tostring(id),
        ["$type"] = command_type[environment],
        ["$cmd"] = command
    })
end

function OnChat(id, message, environment)
    local player = players[id]
    if not player or isCommand(message) then return end

    if message:sub(1, 1) == "@" then return end

    log("event_chat", {
        ["$type"] = chat_type[environment],
        ["$name"] = player.name,
        ["$id"] = id,
        ["$msg"] = message
    })
end

function OnScore(id)
    local player = players[id]
    if not player then return end

    local event_type = ({
        ctf = 1,
        race = not ffa and 2 or 3,
        slayer = not ffa and 4 or 5
    })[gametype]

    local score = get_var(id, "$score")
    local blue_score = get_var(0, "$bluescore")
    local red_score = get_var(0, "$redscore")

    log("event_score", {
        event_type = event_type,
        ["$totalTeamLaps"] = player.team == "red" and red_score or blue_score,
        ["$score"] = score,
        ["$name"] = player.name,
        ["$team"] = player.team or "FFA",
        ["$redScore"] = red_score,
        ["$blueScore"] = blue_score,
        ["$scorelimit"] = score_limit
    })
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

    log("event_death", {
        event_type = event_type,
        ["$killerName"] = killer_data and killer_data.name or "",
        ["$victimName"] = victim_data.name
    })
end

function OnScriptLoad()
    local success, result = pcall(function()
        return loadfile('json.lua')()
    end)

    if not success or not result then
        error("Failed to load json.lua. Make sure the file exists and is valid.")
        return
    end
    json = result
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

    OnStart(1) -- in case script is loaded mid-game
end

function OnScriptUnload() end
