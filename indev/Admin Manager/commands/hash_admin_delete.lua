local command = {
    name = 'hash_admin_delete',
    description = 'Delete a hash-admin. Use /hash_admins to get the admin ID.',
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

            local admins = self.admins['hash_admins']
            local entry = admin:getAdminByID(admins, admin_id)
            if (entry) then

                self:deleteAdmin(admins, entry.type)

                admin:send('Removed (' .. entry.type .. ') (' .. entry.name .. ') from the hash-admin list.')
                self:log(admin.name .. ' (' .. admin.ip .. ') removed (' .. entry.type .. ') (' .. entry.name .. ') from the hash-admin list.', self.logging.management)
            end
        end
    end
end

return command