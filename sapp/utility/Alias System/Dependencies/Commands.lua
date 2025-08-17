-- Alias System [Commands File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local Alias = {
    ip_pattern = '^%d+.%d+.%d+.%d+$',
    hash_pattern = '^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$'
}

function Alias:HasPermission()

    if not (self.pid) then
        return true
    end

    local lvl = tonumber(get_var(self.pid, '$lvl'))
    local level = self.permission
    return (lvl >= level) or self:Send('Insufficient Permission') and false
end

local function StrSplit(str)
    local t = { }
    for arg in str:gmatch("([^%s]+)") do
        t[#t + 1] = arg:lower()
    end
    return t
end

function Alias:Query(CMD)

    local args = StrSplit(CMD)
    if (#args > 0 and args[1] == self.command and self:HasPermission()) then

        if (not args[2]) then
            self:CmdHelp()
            return false
        end

        local ip_pattern = args[2]:match(self.ip_pattern)
        local hash_pattern = args[2]:match(self.hash_pattern)

        local player = tonumber((args[2]:match('%d+')))
        if (not ip_pattern and not hash_pattern and player and not player_present(player)) then
            self:Send('Player #' .. player .. ' is not online.')
            return false
        elseif (args[2] == 'me') then
            player = self.pid
        end

        -- /alias <pid>
        local player_lookup = (player and not args[3])

        -- /alias <pid> <-ip> <opt page>
        local player_ip_lookup = (player and args[3] == self.ip_lookup_flag)

        -- /alias <pid> <-hash> <opt page>
        local player_hash_lookup = (player and args[3] == self.hash_lookup_flag)

        -- /alias <ip> <opt page>
        local ip_lookup = (ip_pattern)

        -- /alias <32x char hash> <opt page>
        local hash_lookup = (hash_pattern)

        local t = self.players[player]
        local page = (args[4] and args[4]:match('^%d+$') or 1)

        if (player_lookup) then
            if (self.default_table == 'ip_addresses') then
                self:ShowResults('ip_addresses', 1, t.ip)
            else
                self:ShowResults('hashes', 1, t.hash)
            end
        elseif (player_ip_lookup) then
            self:ShowResults('ip_addresses', page, t.ip)
        elseif (player_hash_lookup) then
            self:ShowResults('hashes', page, t.hash)
        elseif (ip_lookup) then
            page = (args[3] and args[3]:match('^%d+$') or 1)
            self:ShowResults('ip_addresses', page, ip_pattern)
        elseif (hash_lookup) then
            page = (args[3] and args[3]:match('^%d+$') or 1)
            self:ShowResults('hashes', page, hash_pattern)
        else
            self:CmdHelp()
        end

        return false
    end
end

function Alias:CmdHelp()
    self:Send('Invalid Command Syntax or Lookup Parameter.')
    self:Send('Usage:')
    self:Send('/' .. self.command .. ' <pid>')
    self:Send('/' .. self.command .. ' <pid> -ip <opt page>')
    self:Send('/' .. self.command .. ' <pid> -hash <opt page>')
    self:Send('/' .. self.command .. ' <32 char hash> <opt page>')
    self:Send('/' .. self.command .. ' <ip address> <opt page>')
end

return Alias