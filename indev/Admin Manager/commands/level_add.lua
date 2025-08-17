local command = {
    name = 'level_add',
    description = 'Add a new admin level.',
    help = 'Syntax: /$cmd <level>'
}

function command:run(id, args)

    local level = tonumber(args[2])
    local admin = self.players[id]

    if admin:hasPermission(self.permission_level, args[1]) then
        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not level) then
            admin:send(self.help)
        elseif (self.commands[level]) then
            admin:send('Level ' .. level .. ' already exists.')
        else
            self.commands[level] = {}
            self:updateCommands()
            admin:send('Level ' .. level .. ' added.')
            self:log(admin.name .. ' (' .. admin.ip .. ')  added level ' .. level .. ' to (' .. self.files[2] .. ')', self.logging.management)
        end
    end
end

return command