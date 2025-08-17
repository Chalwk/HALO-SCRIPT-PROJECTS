local command = {
    name = 'ip_mutes',
    description = 'List all text-ban mutes by IP.',
    help = 'Syntax: /$cmd> <page>',
    header = '[Text-Bans (IP)] (Page: %s/%s)', -- page (current, total)
    output = '[$id] $offender [$years/$months/$days-$hours:$minutes:$seconds] [Pirated: $pirated]'
}

function command:run(id, args)
    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local ip_mutes = self.bans['mute']['ip']
        local results = self:showBanList(ip_mutes, page, 5, admin)

        if (not results) then
            admin:send('There are no text-bans by IP.')
        end
        self:log(admin.name .. ' viewed the text-ban list by IP.', self.logging.management)
    end
end

return command