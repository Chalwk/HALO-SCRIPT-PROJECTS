local command = {
    name = 'disable_command',
    description = 'Command ($cmd) | Disables a command.',
    permission_level = 6,
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
            elseif (not enabled) then
                admin:send('Command (' .. target_command .. ') is already disabled.')
            else
                self.commands[level][target_command] = false
                self:updateCommands()
                admin:send('Command (' .. target_command .. ') has been disabled.')
                self:log(admin.name .. '(' .. admin.ip .. ') disabled command (' .. target_command .. ')', self.logging.management)
            end
        end
    end
end

return command