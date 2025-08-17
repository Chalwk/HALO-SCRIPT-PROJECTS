local event = {}

local function getHighest(a, b)
    return (a > b and a or b)
end

function event:setLevel()

    local id = self.id
    local ip = self.ip
    local socket = self.socket
    local hash = self.hash
    local username = self.name

    local cache = self.login_session_cache
    local admins = self.admins
    local hash_admins = admins.hash_admins
    local ip_admins = admins.ip_admins
    local password_admins = admins.password_admins

    if (hash_admins[hash] and ip_admins[ip]) then
        self.level = getHighest(hash_admins[hash].level, ip_admins[ip].level)
        --cprint('Admin Manager: ' .. self.name .. ' (' .. self.ip .. ') logged in as a level ' .. self.level .. ' ip-hash-admin.')
    elseif (hash_admins[hash]) then
        self.level = hash_admins[hash].level
        --cprint('Admin Manager: ' .. self.name .. ' (' .. self.ip .. ') logged in as a level ' .. self.level .. ' hash-admin.')
    elseif (ip_admins[ip]) then
        self.level = ip_admins[ip].level
        --cprint('Admin Manager: ' .. self.name .. ' (' .. self.ip .. ') logged in as a level ' .. self.level .. ' ip-admin.')
    elseif (password_admins[username] and cache[socket]) then
        self.level = password_admins[username].level
        --cprint('Admin Manager: ' .. self.name .. ' (' .. self.ip .. ') logged in as a level ' .. self.level .. ' password-admin.')
    else
        self.level = 1 -- public
    end

    self:setLevelVariable()

    execute_command('adminadd ' .. id .. ' 4')
end

function event:newPlayer(o)

    setmetatable(o, { __index = self })
    self.__index = self

    local rejected = o:rejectPlayer()
    if (rejected) then
        return o
    elseif (o.id ~= 0) then
        o:setLevel()
        o:newAlias('IP_ALIASES', o.ip, o.name)
        o:newAlias('HASH_ALIASES', o.hash, o.name)
    end
    return o
end

function event:on_join(id)
    local ip = get_var(id, '$ip')
    self.players[id] = self:newPlayer({
        socket = self:getIPFormat(ip),
        ip = ip:match('%d+.%d+.%d+.%d+'),
        id = id,
        name = get_var(id, '$name'),
        hash = get_var(id, '$hash')
    })
    self.players[id]:vipMessages()
end

register_callback(cb['EVENT_JOIN'], 'on_join')

return event