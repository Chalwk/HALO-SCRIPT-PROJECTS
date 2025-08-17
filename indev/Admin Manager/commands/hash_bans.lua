local command = {
    name = 'hash_bans',
    description = 'List all hash-bans.',
    help = 'Syntax: /$cmd> <page>',
    header = '[Hash-Bans] (Page: %s/%s)', -- page (current, total)
    output = '[$id] $offender [$years/$months/$days-$hours:$minutes:$seconds] [Pirated: $pirated]'
}

function command:run(id, args)
    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local hash_bans = self.bans['hash']
        local results = self:showBanList(hash_bans, page, 5, admin)

        if (not results) then
            admin:send('There are no hash-bans.')
        end
        self:log(admin.name .. ' viewed the hash-ban list.', self.logging.management)
    end
end

return command