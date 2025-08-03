--=====================================================================================--
-- SCRIPT NAME:      Notify Me
-- DESCRIPTION:      Beautifies the SAPP server terminal by printing formatted, color-coded
--                   notifications for a wide range of player and game events.
--                   Includes a customizable ASCII art logo on script load, and a fully
--                   configurable system for chat, join, leave, death events, and more.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
-- NOTICE:           You may use this script subject to the following license:
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--
-- Configuration starts here -----------------------------------------------------------------------

-- Notification configuration
local config = {

    -- General settings:
    prefix = "", -- A prefix that can be added to all notifications. Default is empty.

    -- The format for timestamps in notifications.
    -- Use the following format for custom timestamps:
    timeStampFormat = "%A %d %B %Y - %X",

    -- Breakdown of the format:
    -- %A  - Full weekday name (e.g., "Monday", "Tuesday").
    -- %d  - Day of the month as a decimal number (01-31).
    -- %B  - Full month name (e.g., "January", "February").
    -- %Y  - Year with century as a decimal number (e.g., "2024").
    -- %X  - Time in the locale's format (HH:MM:SS).
    --
    -- Example output for the format: "Monday 16 October 2024 - 14:30:15"
    -- The timestamp will be formatted according to the specified elements
    -- and will provide a clear, human-readable date and time for events.

    sapp_colors = { -- Table of SAPP colors and their corresponding numeric values.
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

    -- Console logo:
    logo = {
        enabled = true, -- Determines whether the logo should be printed on script load.
        text = { -- Array of logo lines with the corresponding color for each line.
            { "================================================================================", 'green' },
            { "$timeStamp", 'yellow' }, -- Will be replaced by the current timestamp.
            { "", 'black' },
            { "     '||'  '||'     |     '||'       ..|''||           ..|'''.| '||''''|  ", 'red' },
            { "      ||    ||     |||     ||       .|'    ||        .|'     '   ||  .    ", 'red' },
            { "      ||''''||    |  ||    ||       ||      ||       ||          ||''|    ", 'red' },
            { "      ||    ||   .''''|.   ||       '|.     ||       '|.      .  ||       ", 'red' },
            { "     .||.  .||. .|.  .||. .||.....|  ''|...|'         ''|....'  .||.....| ", 'red' },
            { "               ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-", 'gray' },
            { "                             $serverName", 'green' }, -- Will be replaced by the server name.
            { "               ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-", 'gray' },
            { "", 'black' },
            { "================================================================================", 'green' }
        }
    },

    -- Event-specific settings
    events = {
        ["OnStart"] = {
            enabled = true,
            message = "A new game has started on $map - $mode",
            color = 'green'
        },
        ["OnEnd"] = {
            enabled = true,
            message = "The game has ended.",
            color = 'red'
        },
        ["OnPreJoin"] = {
            enabled = true,
            message = "________________________________________________________________________________\nPlayer attempting to connect to the server...\nPlayer: $playerName\nCD Hash: $cdHash\nIP Address: $ipAddress\nIndex ID: $indexID\nPrivilege Level: $privilegeLevel",
            color = 'green'
        },
        ["OnJoin"] = {
            enabled = true,
            message = "Status: $playerName connected successfully.\nJoin Time: $joinTime\n________________________________________________________________________________",
            color = 'green'
        },
        ["OnQuit"] = {
            enabled = true,
            message = "________________________________________________________________________________\nPlayer: $playerName\nCD Hash: $cdHash\nIP Address: $ipAddress\nIndex ID: $indexID\nPrivilege Level: $privilegeLevel\nPing: $ping\n________________________________________________________________________________",
            color = 'red'
        },
        ["OnSpawn"] = {
            enabled = true,
            message = "$playerName spawned",
            color = 'light_yellow'
        },
        ["OnSwitch"] = {
            enabled = true,
            message = "$playerName switched teams. New team: [$team]",
            color = 'light_yellow'
        },
        ["OnWarp"] = {
            enabled = true,
            message = "$playerName is warping",
            color = 'light_yellow'
        },
        ["OnReset"] = {
            enabled = true,
            message = "The map [$map / $mode] has been reset.",
            color = 'light_yellow'
        },
        ["OnLogin"] = {
            enabled = true,
            message = "$playerName logged in",
            color = 'light_yellow'
        },
        ["OnSnap"] = {
            enabled = true,
            message = "$playerName snapped",
            color = 'light_yellow'
        },
        ["OnCommand"] = {
            enabled = true,
            message = "[$type] $name ($id): $cmd",
            color = 'light_yellow'
        },
        ["OnChat"] = {
            enabled = true,
            message = "[$type] $name ($id): $msg",
            color = 'light_yellow'
        },
        ["OnDeath"] = {
            [1] = { -- first blood
                enabled = true,
                message = "$killerName drew first blood",
                color = 'green'
            },
            [2] = { -- killed from the grave
                enabled = true,
                message = "$victimName was killed from the grave by $killerName",
                color = 'green'
            },
            [3] = { -- vehicle kill
                enabled = true,
                message = "$victimName was run over by $killerName",
                color = 'green'
            },
            [4] = { -- pvp
                enabled = true,
                message = "$victimName was killed by $killerName",
                color = 'green'
            },
            [5] = { -- guardians
                enabled = true,
                message = "$victimName was killed by the guardians",
                color = 'green'
            },
            [6] = { -- suicide
                enabled = true,
                message = "$victimName committed suicide",
                color = 'green'
            },
            [7] = { -- betrayal
                enabled = true,
                message = "$victimName was betrayed by $killerName",
                color = 'green'
            },
            [8] = { -- squashed by a vehicle
                enabled = true,
                message = "$victimName was squashed by a vehicle",
                color = 'green'
            },
            [9] = { -- fall damage
                enabled = true,
                message = "$victimName fell and broke their leg",
                color = 'green'
            },
            [10] = { -- killed by the server
                enabled = true,
                message = "$victimName was killed by the server",
                color = 'green'
            },
            [11] = { -- unknown
                enabled = true,
                message = "$victimName died",
                color = 'green'
            }
        }
    }
}

api_version = '1.12.0.0'

-- Configuration ends here -----------------------------------------------------------------------
--

local players = {}
local date = os.date
local char = string.char
local concat = table.concat
local ffa, falling, distance, first_blood

function OnScriptLoad()

    register_callback(cb['EVENT_CHAT'], 'OnChat')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')

    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDeath')

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_PREJOIN'], 'OnPreJoin')

    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    register_callback(cb['EVENT_SNAP'], 'OnSnap')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_LOGIN'], 'OnLogin')
    register_callback(cb['EVENT_MAP_RESET'], "OnReset")
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')

    OnStart()
    timer(50, "printLogo")
end

local function parseMessageTemplate(messageTemplate, args)
    local message = messageTemplate

    for placeholder, value in pairs(args) do
        message = message:gsub(placeholder, value)
    end

    return message
end

local function getColor(colorString)
    return config.sapp_colors[colorString]
end

local function notify(eventName, args)

    if config.events[eventName] then

        local eventConfig = config.events[eventName]
        local messageTemplate

        if eventName == "OnDeath" then
            local deathEvent = config.events["OnDeath"][args.eventType]
            if deathEvent and deathEvent.enabled then
                eventConfig = deathEvent
                messageTemplate = eventConfig.message
                goto next
            end
        end
        messageTemplate = eventConfig.message

        :: next ::

        local message = parseMessageTemplate(messageTemplate, args)
        local notification = config.prefix .. message
        cprint(notification, getColor(eventConfig.color))
    end
end

local function handlePlayerEvent(id, eventFunction)
    local player = players[id]
    if player then
        eventFunction(player)
    end
end

local function getTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return Tag ~= 0 and read_dword(Tag + 0xC) or nil
end

local function readWideString(Address, Length)
    local count = 0
    local byte_table = {}
    for i = 1, Length do
        if (read_byte(Address + count) ~= 0) then
            byte_table[i] = char(read_byte(Address + count))
        end
        count = count + 2
    end
    return concat(byte_table)
end

local function getServerName()
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    return readWideString(network_struct + 0x8, 0x42)
end

function printLogo()
    local logo = config.logo
    if not logo.enabled then
        return
    end

    for _, line in ipairs(logo.text) do
        local message, color = line[1], getColor(line[2])
        if message then
            message = message:gsub("$timeStamp", date(config.timeStampFormat))
                             :gsub("$serverName", getServerName())

            cprint(message, color)
        end
    end
end

local function initializePlayers()
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnStart()

    if (get_var(0, "$gt") ~= "n/a") then

        players = { }
        first_blood = true

        ffa = (get_var(0, '$ffa') == '1')

        falling = getTag('jpt!', 'globals\\falling')
        distance = getTag('jpt!', 'globals\\distance')

        local map = get_var(0, "$map")
        local mode = get_var(0, "$mode")

        notify("OnStart", {
            ["$map"] = map,
            ["$mode"] = mode
        })

        initializePlayers()
    end
end

function OnEnd()
    notify("OnEnd", {
        ["$map"] = get_var(0, "$map"),
        ["$mode"] = get_var(0, "$mode")
    })
end

function OnPreJoin(id)
    local player = {
        level = tonumber(get_var(id, '$lvl')),
        id = id,
        meta = 0,
        switched = false,
        ip = get_var(id, '$ip'),
        name = get_var(id, '$name'),
        team = get_var(id, '$team'),
        hash = get_var(id, '$hash')
    }

    players[id] = player

    notify("OnPreJoin", {
        ["$playerName"] = player.name,
        ["$ipAddress"] = player.ip,
        ["$cdHash"] = player.hash,
        ["$indexID"] = player.id,
        ["$privilegeLevel"] = player.level,
        ["$joinTime"] = date(config.timeStampFormat)
    })
end

function OnJoin(id)
    handlePlayerEvent(id, function(player)
        notify("OnJoin", {
            ["$playerName"] = player.name,
            ["$joinTime"] = date(config.timeStampFormat)
        })
    end)
end

function OnSpawn(id)
    handlePlayerEvent(id, function(player)
        player.meta = 0
        player.switched = nil
        notify("OnSpawn", {
            ["$playerName"] = player.name
        })
    end)
end

function OnQuit(id)
    handlePlayerEvent(id, function(player)
        notify("OnQuit", {
            ["$playerName"] = player.name,
            ["$ipAddress"] = player.ip,
            ["$cdHash"] = player.hash,
            ["$indexID"] = player.id,
            ["$privilegeLevel"] = player.level,
            ["$ping"] = get_var(id, "$ping")
        })
        players[id] = nil
    end)
end

function OnSwitch(id)
    handlePlayerEvent(id, function(player)
        player.team = get_var(id, '$team')
        player.switched = true
        notify("OnSwitch", {
            ["$playerName"] = player.name,
            ["$team"] = player.team
        })
    end)
end

function OnWarp(id)
    handlePlayerEvent(id, function(player)
        notify("OnWarp", {
            ["$playerName"] = player.name
        })
    end)
end

function OnReset()
    notify("OnReset", {
        ["$map"] = get_var(0, "$map"),
        ["$mode"] = get_var(0, "$mode")
    })
end

function OnLogin(id)
    handlePlayerEvent(id, function(player)
        notify("OnLogin", {
            ["$playerName"] = player.name
        })
    end)
end

function OnSnap(id)
    handlePlayerEvent(id, function(player)
        notify("OnSnap", {
            ["$playerName"] = player.name
        })
    end)
end

local command_type = {
    [0] = "rcon command",
    [1] = "console command",
    [2] = "chat command",
    [3] = "unknown command type"
}

function OnCommand(id, command, environment)
    handlePlayerEvent(id, function(player)
        local cmd = command:match("^(%S+)")
        notify("OnCommand", {
            ["$type"] = command_type[environment],
            ["$name"] = player.name,
            ["$id"] = id,
            ["$cmd"] = cmd
        })
    end)
end

local chat_type = {
    [0] = "GLOBAL",
    [1] = "TEAM",
    [2] = "VEHICLE",
    [3] = "UNKNOWN"
}

local function isCommand(str)
    return (str:sub(1, 1) == "/" or str:sub(1, 1) == "\\")
end

function OnChat(id, message, environment)
    handlePlayerEvent(id, function(player)
        local msg = message:match("^(%S+)")
        if not isCommand(msg) then
            notify("OnChat", {
                ["$type"] = chat_type[environment],
                ["$name"] = player.name,
                ["$id"] = id,
                ["$msg"] = message
            })
        end
    end)
end

function OnDeath(victimIndex, killerIndex, metaID)

    victimIndex = tonumber(victimIndex)
    killerIndex = tonumber(killerIndex)

    local victimPlayer = players[victimIndex]
    local killerPlayer = players[killerIndex]

    if victimPlayer then

        if metaID then
            victimPlayer.meta = metaID
            return true
        end

        local squashed = (killerIndex == 0)
        local guardians = (killerIndex == nil)
        local suicide = (killerIndex == victimIndex)
        local pvp = (killerIndex > 0 and killerIndex ~= victimIndex)
        local server = (killerIndex == -1 and not victimPlayer.switched)
        local fell = (victimPlayer.meta == falling or victimPlayer.meta == distance)
        local betrayal = (killerPlayer and not ffa and victimPlayer.team == killerPlayer.team and killerIndex ~= victimIndex)

        local eventType
        if pvp and not betrayal then

            if first_blood then
                first_blood = false
                eventType = 1
                goto done
            end

            -- killed from the grave
            if not player_alive(killerIndex) then
                eventType = 2
                goto done
            end

            -- vehicle kill
            local dyn = get_dynamic_player(killerIndex)
            if dyn ~= 0 then
                local vehicle = read_dword(dyn + 0x11C)
                if vehicle ~= 0xFFFFFFFF then
                    eventType = 3
                    goto done
                end
            end

            -- pvp
            eventType = 4

        elseif guardians then
            eventType = 5
        elseif suicide then
            eventType = 6
        elseif betrayal then
            eventType = 7
        elseif squashed then
            eventType = 8
        elseif fell then
            eventType = 9
        elseif server then
            eventType = 10
        else
            eventType = 11
        end

        :: done ::

        notify("OnDeath", {
            ["eventType"] = eventType,
            ["$killerName"] = killerPlayer and killerPlayer.name or "",
            ["$victimName"] = victimPlayer.name
        })
    end
end

function OnScriptUnload()
    -- N/A
end