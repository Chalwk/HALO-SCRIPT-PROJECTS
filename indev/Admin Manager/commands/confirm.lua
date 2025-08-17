local command = {
    name = 'confirm',
    description = 'Confirm the deletion of an admin level or hash ban.',
    help = 'Syntax: /$cmd'
}

function command:run(id, args)

    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not admin.confirm) then
            admin:send('You have nothing to confirm.')
        else

            local confirmation = admin.confirm
            if (confirmation.level) then
                local level = confirmation.level
                self.commands[level] = nil
                admin:send('Level (' .. level .. ') has been deleted.')
                self:updateCommands()
                self:log(admin.name .. ' (' .. admin.ip .. ')  deleted level ' .. level .. ' from (' .. self.files[2] .. ')', self.logging.management)
            elseif (confirmation.hash_ban) then
                local offender = confirmation.hash_ban[1]
                local parsed = confirmation.hash_ban[2]
                local output = confirmation.output
                admin:hashBanProceed(offender, parsed, output)
            end

            admin.confirm = nil
        end
    end
end

return command