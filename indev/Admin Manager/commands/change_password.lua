local command = {
    name = 'change_password',
    description = 'Change your own password.',
    help = 'Syntax: /$cmd <"old password"> <"new password">'
}

local function parser(args)
    for i = 1, #args do
        if (args[i]:match('^".+"$')) then
            args[i] = args[i]:gsub('"', '')
        end
    end
    return args
end

function command:run(id, args)

    local admin = self.players[id]
    local admins = self.admins

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not args[2]) then
            admin:send(self.help)
        else

            args = parser(args)
            local old_password = args[2]
            local new_password = args[3]
            if (not old_password or old_password == '') then
                admin:send('You must specify the old password')
                return
            elseif (not new_password or new_password == '') then
                admin:send('You must specify the new password')
                return
            end

            local min = self.password_length_limit[1]
            local max = self.password_length_limit[2]

            if (new_password:len() < min or new_password:len() > max) then
                admin:send('Password must be ' .. min .. ' to ' .. max .. ' characters')
                return
            end

            local username = admin.name
            local admin_table = admins.password_admins[username]

            if (admin_table) then

                old_password = self:getSHA2Hash(old_password)
                local new_password_hash = self:getSHA2Hash(new_password)

                if (old_password == new_password_hash) then
                    admin:send('New password cannot be the same as the old password.')
                    return
                end

                admin_table.password = new_password_hash
                admin_table.date = 'Changed on ' .. self:getDate() .. ' by ' .. admin.name .. ' (' .. admin.ip .. ')'
                self:updateAdmins()

                admin:send('Password changed successfully.')
                self:log(admin.name .. ' (' .. admin.ip .. ') changed ' .. username .. '\'s password.', self.logging.management)
            else
                admin:send('Username (' .. username .. ') is not a registered admin name.')
            end
        end
    end
end

return command