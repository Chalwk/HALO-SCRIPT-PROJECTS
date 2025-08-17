local command = {
    name = 'ip_admin_add',
    description = 'Add a new IP-admin.',
    help = 'Syntax: /$cmd <ID / -u "username"> <-l level> <-ip IP>'
}

function command:run(id, args)

    local admin = self.players[id]
    local admins = self.admins

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)

        else

            local pattern = '(%d+%.%d+%.%d+%.%d+)'
            local parsed = self:adminSyntaxParser(args)
            local target
            local player_id = parsed.id
            local ip = parsed.ip
            local username = parsed.username
            local level = parsed.level

            if (player_id) then
                if (not player_present(player_id)) then
                    admin:send('Player #' .. player_id .. ' is not present.')
                    return
                end
                target = self.players[player_id]
                username = target.name
                ip = target.ip
            end

            if (not username or not ip or not level) then
                admin:send(self.help)
                return
            elseif (username:len() > 11) then
                admin:send('Username must be 11 characters or less.')
                return
            elseif (not ip:match(pattern)) then
                admin:send('IP address not valid.')
                return
            elseif (not self.commands[level]) then
                admin:send('Invalid level. Must be between 1 and ' .. #self.commands)
                return
            end

            local admin_table = admins.ip_admins[ip]
            if (not admin_table) then
                if (target) then
                    target.level = level
                    target:setLevelVariable()
                    target:newAdmin('ip_admins', ip, admin)
                else
                    self:newAdmin('ip_admins', ip, admin, _, {
                        level = level,
                        name = username
                    })
                end
                admin:send('Added ' .. username .. ' to the IP-admin list. Level (' .. level .. ').')
                self:log(admin.name .. ' (' .. admin.ip .. ') added (' .. username .. ') to the IP-admin list. Level (' .. level .. ')', self.logging.management)
            else
                admin:send(username .. ' is already an IP-admin (level ' .. admin_table.level .. ')')
            end
        end
    end
end

return command