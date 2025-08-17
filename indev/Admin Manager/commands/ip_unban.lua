local command = {
    name = 'ip_unban',
    description = 'Unban a player\'s IP. Use /ip_bans to get the ban ID.',
    help = 'Syntax: /$cmd <ban id>',
    output = '(%s) (%s) unbanned.',
}

function command:run(id, args)

    local admin = self.players[id]
    local ban_id = tonumber(args[2])

    if admin:hasPermission(self.permission_level, args[1]) then
        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not ban_id) then
            admin:send(self.help)
        else

            local ip_bans = self.bans['ip']
            local entry = admin:getBanEntryByID(ip_bans, ban_id)
            if (entry) then
                self:unban({
                    admin = admin,
                    parent = 'ip',
                    child = entry
                })
            end
        end
    end
end

return command