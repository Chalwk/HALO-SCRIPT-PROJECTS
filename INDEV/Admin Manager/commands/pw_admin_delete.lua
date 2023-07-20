local command = {
    name = 'pw_admin_delete',
    description = 'Command (pw_admin_delete) | Deletes a username & password admin.',
    help = 'Syntax: /$cmd <player>'
}

function command:run(id, args)

    local target = tonumber(args[2])
    local admin = self.players[id]

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not target) then
            admin:send(self.help)
        elseif not player_present(target) then
            admin:send('Player #' .. target .. ' is not present.')
        else

            target = self.players[target]
            local admins = self.admins
            local username = target.name

            if (admins.password_admins[username]) then
                admins.password_admins[username] = nil
                self:updateAdmins()

                admin:send('Removed (' .. username .. ') from the password-admin list.')
                self:log(admin.name .. ' (' .. admin.ip .. ') removed (' .. username .. ') from the password-admin list.', self.logging.management)
            else
                admin:send('Username (' .. username .. ') is not a registered admin name.')
            end
        end
    end
end

return command