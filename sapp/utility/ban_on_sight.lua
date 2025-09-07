--[[
===============================================================================
SCRIPT NAME:      ban_on_sight.lua
DESCRIPTION:      Instant player banning system with:
                  - IP-based enforcement
                  - Persistent ban storage
                  - Admin command controls

FEATURES:
                  - /bos [id] - Ban player immediately
                  - /boslist - View all banned players
                  - Pre-join ban checking
                  - Admin permission levels

CONFIGURATION:    Adjustable settings:
                  - MIN_ADMIN_LEVEL:    Required admin level
                  - BASE_COMMAND:       Primary ban command
                  - LIST_COMMAND:       Ban list command
                  - BAN_FILE:           Ban file name

Copyright (c) 2016-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = '1.11.0.0'

-- Configuration [Starts] --
local MIN_ADMIN_LEVEL = 1      -- Minimum admin level to use commands
local BASE_COMMAND = "bos"     -- Ban command
local LIST_COMMAND = "boslist" -- List command
local BAN_FILE = "bos.txt"
-- Configuration [Ends] --

-- Internal State --
local ban_file
local players = {}     -- Current player data: { [slot] = {name, hash, ip} }
local ban_entries = {} -- Sorted list of bans: { {name, hash, ip}, ... }
local banned_ips = {}  -- IP lookup table: { [ip] = true }

-- Helper Functions --
local function isAdmin(id)
    return id == 0 or tonumber(get_var(id, "$lvl")) >= MIN_ADMIN_LEVEL
end

local function writeBanFile()
    local file = io.open(ban_file, 'w')
    if file then
        for _, entry in ipairs(ban_entries) do
            file:write(entry.name .. ',' .. entry.hash .. ',' .. entry.ip .. '\n')
        end
        file:close()
    end
end

local function parseArgs(input)
    local result = {}
    for substring in input:gmatch("([^%s]+)") do
        result[#result + 1] = substring
    end
    return result
end

local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

-- Event Handlers --
function OnScriptLoad()
    local config_path = getConfigPath()
    ban_file = config_path .. "\\sapp\\" .. BAN_FILE

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_PREJOIN'], 'OnPreJoin')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')

    -- Initialize current players
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end

    -- Load ban list
    local file = io.open(ban_file, 'r')
    if file then
        for line in file:lines() do
            local name, hash, ip = line:match('^([^,]+),([^,]+),([^,]+)$')
            if name and hash and ip then
                ban_entries[#ban_entries + 1] = { name = name, hash = hash, ip = ip }
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

function OnJoin(id)
    players[id] = {
        name = get_var(id, '$name'),
        hash = get_var(id, '$hash'),
        ip = get_var(id, '$ip')
    }
end

function OnPreJoin(id)
    local ip_address = get_var(id, '$ip')
    if banned_ips[ip_address] then
        -- Notify all online admins
        for i = 1, 16 do
            if player_present(i) and isAdmin(i) then
                rprint(i, 'BoS: Rejecting banned connection from ' .. ip_address)
            end
        end

        -- Kick banned player
        rprint(id, 'You are permanently banned from this server')
        execute_command('k' .. id .. ' "[Auto Ban on Sight]"')
        return false
    end
    return nil
end

-- Command Handlers --
function OnCommand(id, command)
    local args = parseArgs(command)
    if #args == 0 then return end

    local cmd = args[1]:lower()
    local arg = args[2]
    local count = #args

    if cmd == BASE_COMMAND then
        if not isAdmin(id) then
            rprint(id, 'Insufficient permissions')
            return false
        end

        if count ~= 2 or not arg then
            rprint(id, 'Syntax: /bos [player_id]')
            return false
        end

        local target = tonumber(arg)
        if not target or target < 1 or target > 16 then
            rprint(id, 'Invalid player ID (1-16)')
            return false
        end

        local data = players[target]
        if not data then
            rprint(id, 'No player data for slot ' .. target)
            return false
        end

        if banned_ips[data.ip] then
            rprint(id, data.name .. ' is already banned')
            return false
        end

        -- Add to ban system
        ban_entries[#ban_entries + 1] = {
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
        writeBanFile()

        -- Notify admin
        rprint(id, 'Banned ' .. data.name .. ' (' .. data.ip .. ')')

        -- Kick if online
        if player_present(target) then
            execute_command('k' .. target .. ' "[Ban on Sight]"')
        end

        return false
    elseif cmd == LIST_COMMAND then
        if not isAdmin(id) then
            rprint(id, 'Insufficient permissions')
            return false
        end

        if #ban_entries == 0 then
            rprint(id, 'No bans in BoS list')
            return false
        end

        rprint(id, 'BoS List (' .. #ban_entries .. ' entries):')
        for i, entry in ipairs(ban_entries) do
            rprint(id, string.format('%d. %s | %s | %s', i, entry.name, entry.hash, entry.ip))
        end
        return false
    end
end
