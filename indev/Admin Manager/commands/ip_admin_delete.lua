local command = {
    name = 'ip_admin_delete',
    description = 'Delete an IP-admin. Use /ip_admins to get the admin ID.',
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

            local admins = self.admins['ip_admins']
            local entry = admin:getAdminByID(admins, admin_id)
            if (entry) then

                self:deleteAdmin(admins, entry.type)

                admin:send('Removed (' .. entry.type .. ') (' .. entry.name .. ') from the IP-admin list.')
                self:log(admin.name .. ' (' .. admin.ip .. ') removed (' .. entry.type .. ') (' .. entry.name .. ') from the IP-admin list.', self.logging.management)
            end
        end
    end
end

return command