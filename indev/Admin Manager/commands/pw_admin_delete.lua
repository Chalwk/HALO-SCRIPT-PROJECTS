local command = {
    name = 'pw_admin_delete',
    description = 'Delete a password-admin. Use /pw_admins to get the admin ID.',
    help = 'Syntax: /$cmd <admin id>'
}

function command:run(id, args)

    local admin_id = tonumber(args[2])
    local admin = self.players[id]

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not admin_id) then
            admin:send(self.help)
        else

            local admins = self.admins['password_admins']
            local entry = admin:getAdminByID(admins, admin_id)
            if (entry) then

                self:deleteAdmin(admins, entry.type)

                admin:send('Removed username (' .. entry.type .. ') from the password-admin list.')
                self:log(admin.name .. ' (' .. admin.ip .. ') removed username (' .. entry.type .. ') from the password-admin list.', self.logging.management)
            end
        end
    end
end

return command