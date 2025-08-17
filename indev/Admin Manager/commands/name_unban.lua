local command = {
    name = 'name_unban',
    description = 'Unban a name. Use /name_bans to view all name-bans.',
    help = 'Syntax: /$cmd <ban id>',
    output = 'Name (%s) has been unbanned.',
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

            local name_bans = self.bans['name']
            local entry = admin:getBanEntryByID(name_bans, ban_id)
            if (entry) then
                self:unban({
                    admin = admin,
                    parent = 'name',
                    child = entry
                })
            end
        end
    end
end

return command