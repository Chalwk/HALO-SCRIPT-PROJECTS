local command = {
    name = 'pw_admin_add',
    description = 'Add a new username & password admin.',
    help = 'Syntax: /$cmd <ID / -u "username"> <-l level> <-p "password">'
}

function command:run(id, args)

    local admins = self.admins
    local admin = self.players[id]
    local min = self.password_length_limit[1]
    local max = self.password_length_limit[2]

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        else

            local parsed = self:adminSyntaxParser(args)

            local target
            local player_id = parsed.id
            local username = parsed.username
            local level = parsed.level
            local password = parsed.password

            if (player_id) then
                if (not player_present(player_id)) then
                    admin:send('Player #' .. player_id .. ' is not present.')
                    return
                end
                target = self.players[player_id]
                username = target.name
            end

            if (not username or not password or not level) then
                admin:send(self.help)
                return
            elseif (username:len() > 11) then
                admin:send('Username must be 11 characters or less.')
                return
            elseif (not self.commands[level]) then
                admin:send('Invalid level. Must be between 1 and ' .. #self.commands)
                return
            elseif (password:len() < min or password:len() > max) then
                admin:send('Password must be ' .. min .. ' to ' .. max .. ' characters')
                return
            end

            local admin_table = admins.password_admins[username]
            if (not admin_table) then

                if (target) then
                    target.level = level
                    target:setLevelVariable()
                    target:newAdmin('password_admins', username, admin, password)
                    self.login_session_cache[target.socket] = self:setLoginTimeout()
                else
                    self:newAdmin('password_admins', username, admin, password, {
                        level = level,
                        name = username
                    })
                end
                admin:send('Added ' .. username .. ' to the password-admin list. Level (' .. level .. ').')
                self:log(admin.name .. ' (' .. admin.ip .. ') added (' .. username .. ') to the password-admin list. Level (' .. level .. ')', self.logging.management)
            else
                admin:send(username .. ' is already a password-admin (level ' .. admin_table.level .. ')')
            end
        end
    end
end

return command