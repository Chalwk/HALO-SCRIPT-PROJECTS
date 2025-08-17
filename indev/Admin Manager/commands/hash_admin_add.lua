local command = {
    name = 'hash_admin_add',
    description = 'Add a new hash-admin.',
    help = 'Syntax: /$cmd <ID / -u "username"> <-l level> <-h hash>'
}

function command:run(id, args)

    local admin = self.players[id]
    local admins = self.admins

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)

        else

            local pattern = '^[a-f0-9]+$'
            local parsed = self:adminSyntaxParser(args)
            local target
            local player_id = parsed.id
            local hash = parsed.hash
            local username = parsed.username
            local level = parsed.level

            if (player_id) then
                if (not player_present(player_id)) then
                    admin:send('Player #' .. player_id .. ' is not present.')
                    return
                end
                target = self.players[player_id]
                username = target.name
                hash = target.hash
            end

            if (not username or not hash or not level) then
                admin:send(self.help)
                return
            elseif (username:len() > 11) then
                admin:send('Username must be 11 characters or less.')
                return
            elseif (hash:len() ~= 32) then
                admin:send('Hash must be 32 characters long.')
                return
            elseif (not hash:match(pattern)) then
                admin:send('Hash must be a valid MD5 hash.')
                return
            elseif (not self.commands[level]) then
                admin:send('Invalid level. Must be between 1 and ' .. #self.commands)
                return
            end

            local admin_table = admins.hash_admins[hash]
            if (not admin_table) then
                if (target) then
                    target.level = level
                    target:setLevelVariable()
                    target:newAdmin('hash_admins', hash, admin)
                else
                    self:newAdmin('hash_admins', hash, admin, _, {
                        level = level,
                        name = username
                    })
                end
                admin:send('Added ' .. username .. ' to the hash-admin list. Level (' .. level .. ').')
                self:log(admin.name .. ' (' .. admin.ip .. ') added (' .. username .. ') to the hash-admin list. Level (' .. level .. ')', self.logging.management)
            else
                admin:send(username .. ' is already a hash-admin (level ' .. admin_table.level .. ')')
            end
        end
    end
end

return command