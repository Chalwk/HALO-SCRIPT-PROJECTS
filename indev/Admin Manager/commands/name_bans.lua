local command = {
    name = 'name_bans',
    description = 'List all name-bans.',
    help = 'Syntax: /$cmd> <page>',
    header = '[Name-Bans] (Page: %s/%s)', -- page (current, total)
    output = '[%s] %s' -- ban id, name
}

function command:run(id, args)

    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local results = self:showNameBans(page, 5, admin)
        if (not results) then
            admin:send('There are no name-bans.')
        end
        self:log(admin.name .. ' viewed the name-ban list.', self.logging.management)
    end
end

return command