local command = {
    name = 'ip_bans',
    description = 'List all IP-bans.',
    help = 'Syntax: /$cmd> <page>',
    header = '[IP-Bans] (Page: %s/%s)', -- page (current, total)
    output = '[$id] $offender [$years/$months/$days-$hours:$minutes:$seconds] [Pirated: $pirated]'
}

function command:run(id, args)
    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local ip_bans = self.bans['ip']
        local results = self:showBanList(ip_bans, page, 5, admin)

        if (not results) then
            admin:send('There are no ip-bans.')
        end
        self:log(admin.name .. ' viewed the ip-ban list.', self.logging.management)
    end
end

return command