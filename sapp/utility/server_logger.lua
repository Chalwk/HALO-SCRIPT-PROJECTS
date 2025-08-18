--[[
=====================================================================================
SCRIPT NAME:      server_logger.lua
DESCRIPTION:      An advanced custom server logger designed to replace
                  SAPP's built-in logging functionality.

Copyright (c) 2024 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = '1.12.0.0'

local Logger = {
    log_file = 'Server Log.txt',
    date_format = '!%a, %d %b %Y %H:%M:%S',
    events = {
        ['ScriptLoad'] = { '[SCRIPT LOAD] Advanced Logger was loaded', true },
        ['ScriptReload'] = { '[SCRIPT RELOAD] Advanced Logger was re-loaded', true },
        ['ScriptUnload'] = { '[SCRIPT UNLOAD] Advanced Logger was unloaded', true },
        ['Start'] = { 'A new game has started on [$map] - [$mode]', true },
        ['End'] = { 'Game Ended - Showing Post Game Carnage report', true },
        ['Join'] = { '[JOIN] $name ID: [$id] IP: [$ip] Hash: [$hash] Pirated: [$pirated] Total Players: [$total/16]', true },
        ['Quit'] = { '[QUIT] $name ID: [$id] IP: [$ip] Hash: [$hash] Pirated: [$pirated] Total Players: [$total/16]', true },
        ['Spawn'] = { '[SPAWN] $name spawned', false },
        ['Warp'] = { '[WARP] $name is warping', true },
        ['Login'] = { '[LOGIN] $name has logged in. Admin Level: [$level]', true },
        ['Reset'] = { '[MAP RESET] The map has been reset.', true },
        ['Switch'] = { '[TEAM SWITCH] $name switched teams. New team: [$team]', false },
        ['Command'] = { '[COMMAND] $name: /$command [Type: $command_type] Admin Level: [$level]', true },
        ['Message'] = { '[MESSAGE] $name: $message [Type: $message_type]', true },
        ['unknown'] = { '[DEATH] $victim died', false },
        ['pvp'] = { '[DEATH] $victim was killed by $killer', false },
        ['suicide'] = { '[DEATH] $victim committed suicide', false },
        ['fell'] = { '[DEATH] $victim fell and broke their leg', false },
        ['server'] = { '[DEATH] $victim was killed by the server', false },
        ['run_over'] = { '[DEATH] $victim was run over by $killer', false },
        ['betrayal'] = { '[DEATH] $victim was betrayed by $killer', false },
        ['squashed'] = { '[DEATH] $victim was squashed by a vehicle', false },
        ['first_blood'] = { '[DEATH] $killer got first blood on $victim', false },
        ['guardians'] = { '[DEATH] $victim and $killer were killed by the guardians', false },
        ['killed_from_grave'] = { '[DEATH] $victim was killed from the grave by $killer', false },
    },
    sensitive_commands = {
        'login', 'admin_add', 'change_password', 'admin_change_pw', 'admin_add_manually',
    },
    players = {},
    known_pirated_hashes = {
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
        -- Add more known pirated hashes here...
    }
}

-- Formats a string by replacing placeholders with actual values.
-- @param template The string template with placeholders.
-- @param variables A table containing the placeholder values.
-- @return The formatted string.
local function format_string(template, variables)
    for key, value in pairs(variables) do
        template = template:gsub(key, value)
    end
    return template
end

-- Writes content to a file.
-- @param file_path The path to the file.
-- @param content The content to write to the file.
local function write_to_file(file_path, content)
    local file, err = io.open(file_path, 'a+')
    if not file then
        print("Error opening log file: " .. err) -- Error handling for file operations
        return
    end
    file:write(content .. '\n')
    file:close()
end

-- Logs an event to the server log file.
-- @param event The event name.
-- @param variables A table containing the placeholder values for the event message.
function Logger:log_event(event, variables)
    local event_data = self.events[event]
    if event_data and event_data[2] then
        local formatted_string = format_string(event_data[1], variables)
        local timestamp = os.date(self.date_format)
        local log_entry = string.format('[%s] %s', timestamp, formatted_string)
        write_to_file(self.log_directory, log_entry)
    end
end

-- Creates a new player object.
-- @param playerId The player's ID.
-- @param ipAddress The player's IP address.
-- @param name The player's name.
-- @param hash The player's hash.
-- @param team The player's team.
-- @return The new player object.
function Logger:new_player(playerId, ipAddress, name, hash, team)
    local player = {
        id = playerId,
        ip = ipAddress,
        name = name,
        hash = hash,
        team = team,
        pirated = self.known_pirated_hashes[hash] and 'YES' or 'NO',
        level = tonumber(get_var(playerId, '$lvl')),
    }
    setmetatable(player, self)
    self.__index = self
    return player
end

-- Called when the script is loaded.
function OnScriptLoad()

    local directory = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    Logger.log_directory = directory .. '\\sapp\\' .. Logger.log_file

    register_callback(cb['EVENT_JOIN'], 'OnPlayerJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnPlayerQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnPlayerSpawn')
    register_callback(cb['EVENT_DIE'], 'OnPlayerDeath')
    register_callback(cb['EVENT_CHAT'], 'OnPlayerChat')
    register_callback(cb['EVENT_WARP'], 'OnPlayerWarp')
    register_callback(cb['EVENT_LOGIN'], 'OnPlayerLogin')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    register_callback(cb['EVENT_MAP_RESET'], 'OnMapReset')
    register_callback(cb['EVENT_COMMAND'], 'OnPlayerCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnPlayerSwitch')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnPlayerDeath')

    if get_var(0, '$gt') == 'n/a' then
        Logger:log_event('ScriptLoad', {})
    else
        Logger:log_event('ScriptReload', {})
    end

    OnGameStart(true)
end

-- Retrieves the tag address for a given tag type and name.
-- @param tag_type The type of the tag.
-- @param tag_name The name of the tag.
-- @return The tag address or nil if not found.
local function get_tag(tag_type, tag_name)
    local tag = lookup_tag(tag_type, tag_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

-- Checks if a command is sensitive.
-- @param command The command to check.
-- @return True if the command is sensitive, false otherwise.
local function is_sensitive_command(command)
    for _, keyword in ipairs(Logger.sensitive_commands) do
        if command:find(keyword) then
            return true
        end
    end
    return false
end

-- Checks if a message is a command.
-- @param message The message to check.
-- @return True if the message is a command, false otherwise.
local function is_command(message)
    return message:sub(1, 1) == '/' or message:sub(1, 1) == '\\'
end

-- Checks if a player is in a vehicle.
-- @param playerId The player's ID.
-- @return True if the player is in a vehicle, false otherwise.
local function is_in_vehicle(playerId)
    local dynamic_player = get_dynamic_player(playerId)
    return dynamic_player ~= 0 and read_dword(dynamic_player + 0x11C) ~= 0xFFFFFFFF
end

-- Called when a new game starts.
-- @param is_script_load True if the script is being loaded, false otherwise.
function OnGameStart(is_script_load)
    if get_var(0, '$gt') ~= 'n/a' then

        Logger.map = get_var(0, '$map')
        Logger.mode = get_var(0, '$mode')
        Logger.players = {}
        Logger.first_blood = true
        Logger.is_ffa = get_var(0, '$ffa') == '1'
        Logger.falling_damage_tag = get_tag('jpt!', 'globals\\falling')
        Logger.distance_damage_tag = get_tag('jpt!', 'globals\\distance')

        if not is_script_load then
            Logger:log_event('Start', { ['$map'] = Logger.map, ['$mode'] = Logger.mode })
        end

        for playerId = 1, 16 do
            if player_present(playerId) then
                OnPlayerJoin(playerId)
            end
        end
    end
end

-- Called when a game ends.
function OnGameEnd()
    Logger:log_event('End', {})
end

-- Called when a player joins the game.
-- @param playerId The player's ID.
function OnPlayerJoin(playerId)
    local player = Logger:new_player(
            playerId,
            get_var(playerId, '$ip'),
            get_var(playerId, '$name'),
            get_var(playerId, '$hash'),
            Logger.is_ffa and 'FFA' or get_var(playerId, '$team')
    )
    Logger.players[playerId] = player
    player:log_event('Join', {
        ['$id'] = player.id,
        ['$ip'] = player.ip,
        ['$name'] = player.name,
        ['$hash'] = player.hash,
        ['$pirated'] = player.pirated,
        ['$total'] = get_var(0, '$pn')
    })
end

-- Called when a player quits the game.
-- @param playerId The player's ID.
function OnPlayerQuit(playerId)
    local player = Logger.players[playerId]
    if player then
        player:log_event('Quit', {
            ['$id'] = player.id,
            ['$ip'] = player.ip,
            ['$name'] = player.name,
            ['$hash'] = player.hash,
            ['$pirated'] = player.pirated,
            ['$total'] = get_var(0, '$pn') - 1
        })
        Logger.players[playerId] = nil
    end
end

-- Called when a player spawns.
-- @param playerId The player's ID.
function OnPlayerSpawn(playerId)
    local player = Logger.players[playerId]
    if player then
        player:log_event('Spawn', { ['$name'] = player.name })
    end
end

-- Called when a player switches teams.
-- @param playerId The player's ID.
function OnPlayerSwitch(playerId)
    local player = Logger.players[playerId]
    if player then
        player.team = get_var(playerId, '$team')
        player:log_event('Switch', { ['$name'] = player.name, ['$team'] = player.team })
    end
end

-- Called when a player warps.
-- @param playerId The player's ID.
function OnPlayerWarp(playerId)
    local player = Logger.players[playerId]
    if player then
        player:log_event('Warp', { ['$name'] = player.name })
    end
end

-- Called when the map is reset.
function OnMapReset()
    Logger:log_event('Reset', {})
end

-- Called when a player logs in.
-- @param playerId The player's ID.
function OnPlayerLogin(playerId)
    local player = Logger.players[playerId]
    if player then
        player.level = tonumber(get_var(playerId, '$lvl'))
        player:log_event('Login', { ['$name'] = player.name, ['$level'] = player.level })
    end
end

-- Called when a player executes a command.
-- @param playerId The player's ID.
-- @param command The command executed.
-- @param command_type The type of command (0: CONSOLE, 1: RCON, 2: CHAT).
function OnPlayerCommand(playerId, command, command_type)
    if not is_sensitive_command(command) then
        local player = Logger.players[playerId]
        local variables = {
            ['$command'] = command,
            ['$command_type'] = (command_type == 0 and 'CONSOLE' or command_type == 1 and 'RCON' or command_type == 2 and 'CHAT')
        }
        if player then
            variables['$level'] = player.level
            variables['$name'] = player.name
        else
            variables['$level'] = 'N/A'
            variables['$name'] = 'N/A'
        end
        Logger:log_event('Command', variables)
    end
end

-- Called when a player sends a chat message.
-- @param playerId The player's ID.
-- @param message The chat message.
-- @param message_type The type of message (0: GLOBAL, 1: TEAM, 2: VEHICLE).
function OnPlayerChat(playerId, message, message_type)
    if not is_command(message) and not is_sensitive_command(message) then
        local player = Logger.players[playerId]
        if player then
            player:log_event('Message', {
                ['$name'] = player.name,
                ['$message'] = message,
                ['$message_type'] = (message_type == 0 and 'GLOBAL' or message_type == 1 and 'TEAM' or message_type == 2 and 'VEHICLE')
            })
        end
    end
end

-- Called when a player dies.
-- @param victim_id The ID of the victim.
-- @param killer_id The ID of the killer.
-- @param meta_id The meta ID of the damage tag.
function OnPlayerDeath(victim_id, killer_id, meta_id)
    local victim = Logger.players[tonumber(victim_id)]
    local killer = Logger.players[tonumber(killer_id)]

    if victim then
        if meta_id then
            victim.meta_id = meta_id
            return true
        end

        local variables = {
            ['$victim'] = victim.name,
            ['$killer'] = killer and killer.name or 'N/A'
        }

        if killer and killer ~= victim then
            if Logger.first_blood then
                Logger.first_blood = false
                killer:log_event('first_blood', variables)
            end
            if not player_alive(killer_id) then
                killer:log_event('killed_from_grave', variables)
            elseif is_in_vehicle(killer_id) then
                killer:log_event('run_over', variables)
            else
                killer:log_event('pvp', variables)
            end
        elseif killer == victim then
            victim:log_event('suicide', variables)
        elseif killer == nil then
            victim:log_event('guardians', variables)
        elseif killer == -1 then
            victim:log_event('server', variables)
        elseif victim.meta_id == Logger.falling_damage_tag or victim.meta_id == Logger.distance_damage_tag then
            victim:log_event('fell', variables)
        else
            victim:log_event('unknown', variables)
        end
    end
end

function OnScriptUnload()
    Logger:log_event('ScriptUnload', {})
end