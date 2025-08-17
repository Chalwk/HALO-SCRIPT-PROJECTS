local misc = {
    flags = { -- used when adding admins
        ['-u'] = 'username',
        ['-p'] = 'password',
        ['-l'] = 'level',
        ['-ip'] = 'ip',
        ['-h'] = 'hash'
    }
}

local _time = os.time
local _date = os.date
local _sort = table.sort
local _require = require
local _tonumber = tonumber
local _setmetatable = setmetatable
local _pairs = pairs

local function loadCommandTable(file_path)
    local command_table = _require(file_path)
    return command_table
end

local function setCommandString(original_string, cmd)
    return original_string:gsub('$cmd', cmd)
end

local function setCommandAttributes(cmd, command_table, enabled, level, self)
    local new_command_table = {}

    new_command_table.enabled = enabled
    new_command_table.permission_level = _tonumber(level)
    new_command_table.help = setCommandString(command_table.help, cmd)
    new_command_table.description = setCommandString(command_table.description, cmd)

    _setmetatable(new_command_table, { __index = self })

    return new_command_table
end


function misc:setManagementCMDS()
    local t, commands = {}, self.management_commands

    for level, v in pairs(commands) do
        for file_name, enabled in _pairs(v) do
            local command_table = loadCommandTable(self.commands_dir .. file_name)
            local cmd = command_table.name

            t[cmd] = setCommandAttributes(cmd, command_table, enabled, level, self)
        end
    end

    self.management = t
end
--function misc:setManagementCMDS()
--    local t, commands = {}, self.management_commands
--    for level, v in pairs(commands) do
--        for file_name, enabled in _pairs(v) do
--            local dir = self.commands_dir
--            local command_table = _require(dir .. file_name)
--            local cmd = command_table.name
--            t[cmd] = command_table
--            t[cmd].enabled = enabled
--            t[cmd].permission_level = tonumber(level)
--            t[cmd].help = command_table.help:gsub('$cmd', cmd)
--            t[cmd].description = command_table.description:gsub('$cmd', cmd)
--            _setmetatable(t[cmd], { __index = self })
--        end
--    end
--    self.management = t
--end

function misc:setAdminID(admin_table)
    local id = 0
    for _, entry in _pairs(admin_table) do
        if (entry.id > id) then
            id = entry.id
        end
    end
    return id + 1
end

function misc:hasPermission(level, command)

    local id = self.id
    local current_level = self.level

    if (id == 0 or current_level >= level) then
        return true
    end

    self:send('Insufficient Permission.')
    self:send('You must be level (' .. level .. ') or higher.')
    self:log(self.name .. ' is attempting to execute (' .. command
            .. ') but is not a high enough level (current level: '
            .. current_level .. ') (Required level: '
            .. level .. ')', self.logging.management)

    return false
end

function misc:send(msg)
    if (msg == nil or msg == '') then
        return
    end
    return (self.id == 0 and cprint(msg) or rprint(self.id, msg))
end

function misc:getSHA2Hash(raw_password)
    return self.sha.sha256(raw_password)
end

function misc:sort(t)
    _sort(t, function(a, b)
        return a.level > b.level
    end)
    return t
end

function misc:stringSplit(string)
    local t = { }
    for param in string:gmatch('([^%s]+)') do
        t[#t + 1] = param
    end
    return t
end

function misc:adminChat(message)

    local name = self.name
    local their_level = self.level
    local players = self.players
    local levels = self.admin_chat

    for i, v in pairs(players) do
        local level = v.level
        local console = (i == 0)
        local enabled = v.a_chat
        local show = (their_level >= level and levels[level])
        if (enabled and not console and show) then
            local output = self.management['admin_chat'].output
            v:send(output:gsub('$name', name):gsub('$message', message))
        end
    end
end

function misc:commandSpy(msg)

    local name = self.name
    local their_level = self.level
    local players = self.players
    local levels = self.command_spy

    for i, v in pairs(players) do
        local level = v.level
        local console = (i == 0)
        local enabled = v.spy
        local show = (their_level >= level and levels[level])
        if (enabled and not console and show) then
            local output = self.management['command_spy'].output
            v:send(output:gsub('$name', name):gsub('$message', msg))
        end
    end
end

-- Used by admin chat and command spy:
function misc:checkLevel()

    local level = self.level
    local levels = self.admin_chat

    if (levels[level]) then
        return true
    end

    local str = 'Required levels:'
    for i = 1, #levels do
        if (levels[i]) then
            if (i == #levels) then
                str = str .. ' and ' .. i .. '.'
            else
                str = str .. ' ' .. i .. ','
            end
        end
    end

    return false, str
end

function misc:findCommand(command)
    for level, commands in _pairs(self.commands) do
        if (commands[command] ~= nil) then
            return level, commands[command]
        end
    end
    return nil
end

function misc:getDate(log)
    return _date(log and '%Y/%m/%d %H:%M:%S' or '%Y/%m/%d at %I:%M %p (%z)')
end

function misc:kick(reason)
    self:send(reason)
    execute_command('sv_kick ' .. self.id)
end

function misc:vipMessages()

    local vip = self.admin_join_messages
    local message_table = vip[self.level]

    if (not vip.enabled or not message_table or (message_table and not message_table[2])) then
        return
    end

    local str = message_table[1]:format(self.name)
    for i, v in pairs(self.players) do
        if (i ~= 0) then
            v:send(str)
        end
    end
end

local function convert(table)
    local t = {}
    for _, v in _pairs(table) do
        t[#t + 1] = v
    end
    return t
end

function misc:getPageResults(bans, page, number_to_show)
    local total_pages = math.ceil(#bans / number_to_show)
    local start_index = (page - 1) * number_to_show + 1
    local end_index = start_index + number_to_show - 1
    if (start_index > #bans) then
        return false
    elseif (end_index > #bans) then
        end_index = #bans
    end
    local results = {}
    for i = start_index, end_index do
        results[#results + 1] = bans[i]
    end
    return results, total_pages
end

function misc:showBanList(bans, page, number_to_show, admin)

    local ban_table = convert(bans)
    local results, total_pages = self:getPageResults(ban_table, page, number_to_show)
    if (not results or #results == 0) then
        return false
    end

    admin:send(self.header:format(page, total_pages))
    for _, v in pairs(results) do
        local id = v.id
        local offender = v.offender
        local time = v.time
        local pirated = v.pirated
        local result = self:banSTDOUT({
            id = id,
            offender_name = offender,
            expiration = time,
            pirated = pirated
        })
        admin:send(result)
    end

    return true
end

function misc:showAdminList(type, page, number_to_show, admin)

    local admins = convert(self.admins[type])
    local results, total_pages = self:getPageResults(admins, page, number_to_show)
    if (not results or #results == 0) then
        return false
    end

    admin:send(self.header:format(page, total_pages))
    for _, v in pairs(results) do
        admin:send(self.output:format(v.id, v.name, v.level))
    end

    return true
end

function misc:getAdminByID(admin_table, id)
    for type, v in _pairs(admin_table) do
        if (v.id == id) then
            return {
                type = type,
                id = v.id,
                ip = v.ip,
                hash = v.hash,
                name = v.name
            }
        end
    end
    self:send('Admin ID not found.')
    return nil
end

function misc:showNameBans(page, number_to_show, admin)

    local names = convert(self.bans['name'])

    local results, total_pages = self:getPageResults(names, page, number_to_show)
    if (not results or #results == 0) then
        return false
    end

    admin:send(self.header:format(page, total_pages))
    for _, v in pairs(results) do
        admin:send(self.output:format(v.id, v.name))
    end

    return true
end

function misc:showAliases(args)

    local page = args.page
    local group = args.type
    local admin = args.admin
    local header = args.header
    local target = args.target -- ip or hash
    local number_to_show = args.number_to_show

    local t = self.aliases[group][target]
    if (not t) then
        return false
    end

    local aliases = {}
    for name, v in _pairs(t) do
        aliases[#aliases + 1] = { [name] = v }
    end

    local results, total_pages = self:getPageResults(aliases, page, number_to_show)
    if (not results or #results == 0) then
        return false
    end

    admin:send(header:format(target, page, total_pages))

    -- 'results' is the table entry for this ip/hash:
    for i = 1, #results do

        -- results[i] = table of aliases for this ip/hash
        local result = results[i]
        for name, v in _pairs(result) do
            local level = v.level
            local joined = v.joined
            local last_activity = v.last_activity
            admin:send(self.output
                           :gsub('$name', name)
                           :gsub('$level', level)
                           :gsub('$date_joined', joined)
                           :gsub('$last_activity', last_activity))
        end
    end

    return true
end

function misc:newAlias(parent, child, name)

    local records = self.aliases
    local date = self:getDate(true)

    records[parent][child] = records[parent][child] or {}

    if (not records[parent][child][name]) then
        records[parent][child][name] = { joined = date }
    end

    records[parent][child][name].level = self.level
    records[parent][child][name].last_activity = date
end

function misc:newAdmin(parent, child, admin, password, args)

    local name = (args and args.name) or self.name
    local level = (args and args.level) or self.level
    local date = self:getDate()
    password = (password) and self:getSHA2Hash(password) or nil

    local admin_table = self.admins[parent]
    admin_table[child] = {
        password = password,
        name = name, -- for username & password admins, this is redundant but necessary.
        level = level,
        added_on = 'Added on ' .. date .. ' by ' .. admin.name .. ' (' .. admin.ip .. ')',
        id = self:setAdminID(admin_table)
    }

    self:updateAdmins()
end

function misc:deleteAdmin(admin_table, child)
    admin_table[child] = nil
    self:updateAdmins()
end

function misc:getIPFormat(IP)
    local index = self.cache_session_index
    if (index == 1) then
        return IP -- IP:port
    elseif (index == 2) then
        return IP:match('%d+.%d+.%d+.%d+')
    end
end

function misc:setLoginTimeout()
    return _time() + (self.login_timeout * 60) * 60
end

local function getString(args, i)
    local index = i + 1
    local string = args[index]
    local num = tonumber(string)
    if (num) then
        return num
    end
    local j = i + 2
    local end_quote = string:sub(-1)
    while (args[j] and end_quote ~= '"') do
        string = string .. ' ' .. args[j]
        end_quote = args[j]:sub(-1)
        j = j + 1
    end
    index = j - 1
    return string:gsub('"', '')
end

function misc:adminSyntaxParser(args)
    local parsed = {}
    for i = 1, #args do
        local arg = args[i]
        local flag = self.flags[arg]
        if (i == 2 and _tonumber(arg)) then
            parsed['id'] = _tonumber(arg)
        elseif (flag == 'hash' or flag == 'ip') then
            parsed[flag] = args[i + 1]
        elseif (flag) then
            parsed[flag] = getString(args, i)
            i = i + 1
        end
    end
    return parsed
end

return misc