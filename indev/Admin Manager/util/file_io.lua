local IO = {
    sha = require('./Admin Manager/libraries/sha256'),
    json = loadfile('./Admin Manager/libraries/json.lua')(),
    default = {
        hash_admins = {},
        ip_admins = {},
        password_admins = {}
    }
}

local _open = io.open
local _pairs = pairs
local _tonumber = tonumber
local _tostring = tostring

local function readFile(file)
    file = _open(file, 'r')
    if (file) then
        local contents = file:read('*all')
        file:close()
        return contents
    end
    return ''
end

local function writeFile(file, contents)
    file = _open(file, 'w')
    if (file) then
        contents = IO.json:encode_pretty(contents)
        file:write(contents)
        file:close()
    end
end

local function loadFile(file, self)
    local contents = readFile(file)

    contents = (contents and (contents == '') and nil
            or self.json:decode(contents)) or nil

    return contents
end

function IO:loadBans()

    local file = self.files[3]
    file = self.data_dir .. file
    local bans = loadFile(file, self)

    self.bans = bans or {
        ip = {},
        hash = {},
        name = {},
        mute = {
            ip = {},
            hash = {}
        }
    }
end

function IO:loadAliases()

    local file = self.files[5]
    file = self.data_dir .. file
    local aliases = loadFile(file, self)

    self.aliases = aliases or {
        IP_ALIASES = {},
        HASH_ALIASES = {},
    }
end

-- Converts the keys of a table to numbers or strings:
local function convert(commands, f)
    local t = {}
    for i, v in _pairs(commands) do
        t[f(i)] = v
    end
    return t
end

function IO:setDefaultCommands()

    local file = self.files[2]
    file = self.data_dir .. file

    local commands = loadFile(file, self)
    local default_commands = self.default_commands

    if (not commands) then
        writeFile(file, default_commands)
        commands = default_commands
    end

    self.commands = convert(commands, _tonumber)
end

function IO:setAdmins()

    local file = self.files[1]
    file = self.data_dir .. file

    local admins = loadFile(file, self)

    if (not admins) then
        writeFile(file, self.default)
    end

    self.admins = admins or self.default
end

function IO:updateAdmins()

    local file = self.files[1]
    file = self.data_dir .. file

    writeFile(file, self.admins)
end

function IO:updateCommands()

    local commands = self.commands
    commands = convert(commands, _tostring)

    local file = self.files[2]
    file = self.data_dir .. file

    writeFile(file, commands)
end

function IO:updateBans()

    local file = self.files[3]
    file = self.data_dir .. file

    writeFile(file, self.bans)
end

function IO:updateAliases()

    for i, v in pairs(self.players) do
        if (i ~= 0) then

            local ip = v.ip
            local name = v.name
            local hash = v.hash
            local level = v.level

            self.aliases['IP_ALIASES'][ip][name].level = level
            self.aliases['HASH_ALIASES'][hash][name].level = level
        end
    end

    local file = self.files[5]
    file = self.data_dir .. file

    writeFile(file, self.aliases)
end

function IO:log(entry)

    local date = self:getDate(true)

    local file = self.files[4]
    file = self.data_dir .. file

    local logs = loadFile(file, self)

    logs = logs or {}
    logs[date] = entry

    writeFile(file, logs)
end

return IO