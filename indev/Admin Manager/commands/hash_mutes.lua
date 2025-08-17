local command = {
    name = 'hash_mutes',
    description = 'List all text-ban mutes by hash.',
    help = 'Syntax: /$cmd> <page>',
    header = '[Text-Bans (hash)] (Page: %s/%s)', -- page (current, total)
    output = '[$id] $offender [$years/$months/$days-$hours:$minutes:$seconds] [Pirated: $pirated]'
}

function command:run(id, args)
    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local hash_mutes = self.bans['mute']['hash']
        local results = self:showBanList(hash_mutes, page, 5, admin)

        if (not results) then
            admin:send('There are no text-bans by Hash.')
        end
        self:log(admin.name .. ' viewed the text-ban list by hash.', self.logging.management)
    end
end

return command