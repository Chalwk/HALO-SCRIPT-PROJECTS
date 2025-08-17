local command = {
    name = 'hash_unban',
    description = 'Unban a player\'s hash. Use /hash_bans to get the ban ID.',
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

            local hash_bans = self.bans['hash']
            local entry = admin:getBanEntryByID(hash_bans, ban_id)
            if (entry) then
                self:unban({
                    admin = admin,
                    parent = 'hash',
                    child = entry,
                })
            end
        end
    end
end

return command