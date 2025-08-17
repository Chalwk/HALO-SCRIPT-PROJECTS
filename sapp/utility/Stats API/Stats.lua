-- Stats API (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local time = os.time
local date = os.date
local open = io.open
local floor = math.floor
local diff = os.difftime

local Stats = { }

-- Creates a new player table (.players[ip])
-- that stores a copy of their stats and inherits the Stats object:
function Stats:New(t)
    setmetatable(t, self)
    self.__index = self

    t.logged_in = false
    return t
end

function Stats:respond(msg)
    rprint(self.pid, msg)
end

function Stats:CheckFile(ScriptLoad)

    self.players = { }
    self.db = (ScriptLoad and nil or self.db)

    if (get_var(0, '$gt') ~= 'n/a' and self.db == nil) then
        local content = ''
        local file = open(self.settings.file, 'r')
        if (file) then
            content = file:read('*all')
            file:close()
        end
        local data = self.json:decode(content)
        if (not data) then
            self:Update({})
        end
        self.db = data or {}
    end
end

function Stats:Update(t)
    local file = open(self.settings.file, 'w')
    if (file) then
        file:write(self.json:encode_pretty(t))
        file:close()
    end
end

function Stats:GetIP(Ply)
    return get_var(Ply, '$ip')
end

function Stats:PTableGet(t, ip)
    for k, v in pairs(t) do
        self.players[ip][k] = v
    end
    return self.players[ip]
end

function Stats:OnJoin(Ply)
    local ip = self:GetIP(Ply)

    local name = get_var(Ply, '$name')
    local hash = get_var(Ply, '$hash')
    local team = get_var(Ply, '$team')

    local defaults = { pid = Ply, hash = hash, team = team, name = name }
    self.players[ip] = (self.players[ip] and self:PTableGet(defaults, ip)) or self:New(defaults)
end

function Stats:Expired(acc)
    local day = acc.last_login.day
    local month = acc.last_login.month
    local year = acc.last_login.year
    local reference = time { day = day, month = month, year = year }
    local days_from = diff(time(), reference) / (24 * 60 * 60)
    return (floor(days_from) >= self.settings.stale_Stats_period)
end

function Stats:CheckStale()
    if (self.settings.delete_stale_accounts) then
        for username, acc in pairs(self.db) do
            if (username and self:Expired(acc)) then
                self.db[username] = nil
            end
        end
    end
end

function Stats:Push(Ply, Key, Value, Update)
    local ip = self:GetIP(Ply)
    local t = self.players[ip]
    if (t and t.logged_in) then
        t[Key] = Value
        self.db[t.username][Key] = Value
        if (Update) then
            self:Update(self.db)
        end
    end
end

function Stats:Get(Ply, Key)
    local ip = self:GetIP(Ply)
    local t = self.players[ip]
    return (t and t.logged_in and t[Key]) or nil
end

local exclude = {
    ["pid"] = true,
    ["hash"] = true,
    ["name"] = true,
    ["team"] = true,
    ["username"] = true,
    ["logged_in"] = true
}

function Stats:Cache(name, password)

    local day = date('*t').day
    local month = date('*t').month
    local year = date('*t').year

    self.logged_in = true
    self.username = name

    self.db[name] = self.db[name] or {}
    self.db[name].password = password
    self.db[name].last_login = { day = day, month = month, year = year }

    local ip = self:GetIP(self.pid)
    local t = self.players[ip]
    for k, v in pairs(t) do
        if (not exclude[k]) then
            self.db[name][k] = v
        end
    end

    self:Update(self.db)
end

local function StrSplit(str)
    local args = { }
    for arg in str:gmatch('([^%s]+)') do
        args[#args + 1] = arg
    end
    return args
end

function Stats:OnCommand(Ply, CMD)
    if (Ply > 0) then

        local args = StrSplit(CMD)
        if (#args > 0) then

            local ip = self:GetIP(Ply)
            local t = self.players[ip]

            args[1], args[2] = args[1]:lower(), (args[2] and args[2]:lower() or '')

            local management = self.settings.account_management_syntax
            if (args[1] == management[1]) then

                local name = args[3]
                local password = args[4]

                local acc = t.db[name]
                if (args[2] == management[2] and args[3]) then
                    if (#args > 4) then
                        t:respond('Too many arguments!')
                        t:respond('Make sure username & password do not contain spaces.')
                    elseif (not t.logged_in) then
                        if (acc) then
                            t:respond('Username already exists.')
                        else
                            t:Cache(name, password)
                            t:respond('Stats account successfully created.')
                        end
                    else
                        t:respond('You already have a stats account.')
                    end
                elseif (args[2] == management[3] and args[3]) then
                    if (#args > 4) then
                        t:respond('Too many arguments!')
                        t:respond('Make sure username & password do not contain spaces.')
                    elseif (acc) then
                        if (t.logged_in) then
                            t:respond('You are already logged in.')
                        elseif (password == acc.password) then
                            t:Cache(name, password)
                            t:respond('Successfully logged in.')
                        else
                            t:respond('Invalid password. Please try again.')
                        end
                    else
                        t:respond('Stats account does not exist.')
                    end
                end
                return false
            end
        end
    end
end

return Stats