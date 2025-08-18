--=====================================================================================--
-- SCRIPT NAME:      Ban On Sight
-- DESCRIPTION:      Ban players who are online or offline with efficient lookup
-- COMMANDS:         /bos [id]     - Ban player by slot ID
--                   /boslist      - List all banned players
--
-- FEATURES:
-- - Efficient IP-based banning with O(1) lookup
-- - Persistent storage in sorted format
-- - Admin-level permission control
-- - Real-time notifications for banned connections
-- - Optimized data structures and file I/O
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2016-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

api_version = '1.11.0.0'

-- Configuration [Starts] --
local MIN_ADMIN_LEVEL = 1       -- Minimum admin level to use commands
local BASE_COMMAND = "bos"      -- Ban command
local LIST_COMMAND = "boslist"  -- List command
-- Configuration [Ends] --

-- Internal State --
local player_data = {}        -- Current player data: { [slot] = {name, hash, ip} }
local ban_entries = {}        -- Sorted list of bans: { {name, hash, ip}, ... }
local banned_ips = {}         -- IP lookup table: { [ip] = true }

-- Helper Functions --
local function is_admin(player_idx)
    return player_idx == 0 or tonumber(get_var(player_idx, "$lvl")) >= MIN_ADMIN_LEVEL
end

local function write_ban_file()
    local file = io.open('sapp\\bos.data', 'w')
    if file then
        for _, entry in ipairs(ban_entries) do
            file:write(entry.name .. ',' .. entry.hash .. ',' .. entry.ip .. '\n')
        end
        file:close()
    end
end

local function tokenize_string(input)
    local args = {}
    for arg in input:gmatch('[^%s]+') do
        args[#args+1] = arg
    end
    return args
end

-- Event Handlers --
function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], 'OnServerCommand')
    register_callback(cb['EVENT_JOIN'], 'OnPlayerJoin')
    register_callback(cb['EVENT_PREJOIN'], 'OnPlayerPrejoin')

    -- Initialize current players
    for i = 1, 16 do
        if player_present(i) then
            player_data[i] = {
                name = get_var(i, '$name'),
                hash = get_var(i, '$hash'),
                ip = get_var(i, '$ip')
            }
        end
    end

    -- Load ban list
    local file = io.open('sapp\\bos.data', 'r')
    if file then
        for line in file:lines() do
            local name, hash, ip = line:match('^([^,]+),([^,]+),([^,]+)$')
            if name and hash and ip then
                ban_entries[#ban_entries+1] = {name = name, hash = hash, ip = ip}
                banned_ips[ip] = true
            end
        end
        file:close()

        -- Sort alphabetically by name
        table.sort(ban_entries, function(a, b)
            return a.name:lower() < b.name:lower()
        end)
    end
end

function OnPlayerJoin(player_idx)
    player_data[player_idx] = {
        name = get_var(player_idx, '$name'),
        hash = get_var(player_idx, '$hash'),
        ip = get_var(player_idx, '$ip')
    }
end

function OnPlayerPrejoin(player_idx)
    local ip_address = get_var(player_idx, '$ip')
    if banned_ips[ip_address] then
        -- Notify all online admins
        for i = 1, 16 do
            if player_present(i) and is_admin(i) then
                rprint(i, 'BoS: Rejecting banned connection from ' .. ip_address)
            end
        end

        -- Kick banned player
        rprint(player_idx, 'You are permanently banned from this server')
        execute_command('k' .. player_idx .. ' "[Auto Ban on Sight]"')
        return false
    end
    return nil
end

-- Command Handlers --
function OnServerCommand(player_idx, command)
    local tokens = tokenize_string(command)
    local cmd = tokens[1]:lower()
    local arg = tokens[2]
    local count = #tokens

    if cmd == BASE_COMMAND then
        if not is_admin(player_idx) then
            rprint(player_idx, 'Insufficient permissions')
            return false
        end

        if count ~= 2 or not arg then
            rprint(player_idx, 'Syntax: /bos [player_id]')
            return false
        end

        local target = tonumber(arg)
        if not target or target < 1 or target > 16 then
            rprint(player_idx, 'Invalid player ID (1-16)')
            return false
        end

        local data = player_data[target]
        if not data then
            rprint(player_idx, 'No player data for slot ' .. target)
            return false
        end

        if banned_ips[data.ip] then
            rprint(player_idx, data.name .. ' is already banned')
            return false
        end

        -- Add to ban system
        ban_entries[#ban_entries+1] = {
            name = data.name,
            hash = data.hash,
            ip = data.ip
        }
        banned_ips[data.ip] = true

        -- Maintain sorted order
        table.sort(ban_entries, function(a, b)
            return a.name:lower() < b.name:lower()
        end)

        -- Persist to disk
        write_ban_file()

        -- Notify admin
        rprint(player_idx, 'Banned ' .. data.name .. ' (' .. data.ip .. ')')

        -- Kick if online
        if player_present(target) then
            execute_command('k' .. target .. ' "[Ban on Sight]"')
        end

        return false

    elseif cmd == LIST_COMMAND then
        if not is_admin(player_idx) then
            rprint(player_idx, 'Insufficient permissions')
            return false
        end

        if #ban_entries == 0 then
            rprint(player_idx, 'No bans in BoS list')
            return false
        end

        rprint(player_idx, 'BoS List (' .. #ban_entries .. ' entries):')
        for i, entry in ipairs(ban_entries) do
            rprint(player_idx, string.format('%d. %s | %s | %s', i, entry.name, entry.hash, entry.ip))
        end
        return false
    end
end