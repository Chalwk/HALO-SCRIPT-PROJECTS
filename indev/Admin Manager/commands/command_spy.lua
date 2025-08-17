local command = {
    name = 'spy',
    description = 'Toggle command spy on or off (spy on player commands).',
    output = '[SPY] $name: $message',
    help = 'Syntax: /$cmd <1/0 (on/off)>'
}

function command:run(id, args)

    local admin = self.players[id]
    local toggle = tonumber(args[2])
    local enabled = (toggle) and (toggle == 1 and true or false)

    local allow, str = admin:checkLevel()

    if (id == 0) then
        admin:send('You cannot execute this command from console.')
    elseif admin:hasPermission(self.permission_level, args[1]) then
        if (args[2] == 'help') then
            admin:send(self.description)
            return
        elseif (toggle == nil) or (toggle ~= 0 and toggle ~= 1) then
            admin:send(self.help)
            return
        elseif (not allow) then
            admin:send('Insufficient Permission.')
            admin:send(str)
            return
        else
            admin:send('Command Spy: ' .. (enabled and 'Enabled' or 'Disabled'))
        end
        admin.spy = enabled
    end
end

return command