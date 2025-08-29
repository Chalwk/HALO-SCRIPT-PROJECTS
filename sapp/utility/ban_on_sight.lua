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
                  - MIN_ADMIN_LEVEL: Required admin level
                  - BASE_COMMAND: Primary ban command
                  - LIST_COMMAND: Ban list command

Copyright (c) 2016-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

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
local function isAdmin(playerIndex)
    return playerIndex == 0 or tonumber(get_var(playerIndex, "$lvl")) >= MIN_ADMIN_LEVEL
end

local function writeBanFile()
    local file = io.open('sapp\\bos.data', 'w')
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

function OnPlayerJoin(playerIndex)
    player_data[playerIndex] = {
        name = get_var(playerIndex, '$name'),
        hash = get_var(playerIndex, '$hash'),
        ip = get_var(playerIndex, '$ip')
    }
end

function OnPlayerPrejoin(playerIndex)
    local ip_address = get_var(playerIndex, '$ip')
    if banned_ips[ip_address] then
        -- Notify all online admins
        for i = 1, 16 do
            if player_present(i) and isAdmin(i) then
                rprint(i, 'BoS: Rejecting banned connection from ' .. ip_address)
            end
        end

        -- Kick banned player
        rprint(playerIndex, 'You are permanently banned from this server')
        execute_command('k' .. playerIndex .. ' "[Auto Ban on Sight]"')
        return false
    end
    return nil
end

-- Command Handlers --
function OnServerCommand(playerIndex, command)
    local args = parseArgs(command)
    if #args == 0 then return end

    local cmd = args[1]:lower()
    local arg = args[2]
    local count = #args

    if cmd == BASE_COMMAND then
        if not isAdmin(playerIndex) then
            rprint(playerIndex, 'Insufficient permissions')
            return false
        end

        if count ~= 2 or not arg then
            rprint(playerIndex, 'Syntax: /bos [player_id]')
            return false
        end

        local target = tonumber(arg)
        if not target or target < 1 or target > 16 then
            rprint(playerIndex, 'Invalid player ID (1-16)')
            return false
        end

        local data = player_data[target]
        if not data then
            rprint(playerIndex, 'No player data for slot ' .. target)
            return false
        end

        if banned_ips[data.ip] then
            rprint(playerIndex, data.name .. ' is already banned')
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
        writeBanFile()

        -- Notify admin
        rprint(playerIndex, 'Banned ' .. data.name .. ' (' .. data.ip .. ')')

        -- Kick if online
        if player_present(target) then
            execute_command('k' .. target .. ' "[Ban on Sight]"')
        end

        return false

    elseif cmd == LIST_COMMAND then
        if not isAdmin(playerIndex) then
            rprint(playerIndex, 'Insufficient permissions')
            return false
        end

        if #ban_entries == 0 then
            rprint(playerIndex, 'No bans in BoS list')
            return false
        end

        rprint(playerIndex, 'BoS List (' .. #ban_entries .. ' entries):')
        for i, entry in ipairs(ban_entries) do
            rprint(playerIndex, string.format('%d. %s | %s | %s', i, entry.name, entry.hash, entry.ip))
        end
        return false
    end
end