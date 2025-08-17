local command = {
    name = 'enable_command',
    description = 'Enable a command.',
    help = 'Syntax: /$cmd <command>'
}

function command:run(id, args)

    local target_command = args[2]
    local admin = self.players[id]

    if admin:hasPermission(self.permission_level, args[1]) then

        if (not target_command) then
            admin:send(self.help)
        elseif (target_command == 'help') then
            admin:send(self.description)
        else

            local level, enabled = self:findCommand(target_command)
            if (level == nil) then
                admin:send('Command (' .. target_command .. ') does not exist.')
            elseif (enabled) then
                admin:send('Command (' .. target_command .. ') is already enabled.')
            else
                self.commands[level][target_command] = true
                self:updateCommands()
                admin:send('Command (' .. target_command .. ') has been enabled.')
                self:log(admin.name .. '(' .. admin.ip .. ') enabled command (' .. target_command .. ')', self.logging.management)
            end
        end
    end
end

return command