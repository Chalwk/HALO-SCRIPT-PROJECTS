local command = {
    name = 'ip_unmute',
    description = 'Unmute a player by IP. Use /ip_mutes to get the mute ID.',
    help = 'Syntax: /$cmd <ban id>',
    output = '(%s) (%s) unmuted.',
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

            local ip_mutes = self.bans['mute']['ip']
            local entry = admin:getBanEntryByID(ip_mutes, ban_id)
            if (entry) then
                self:unban({
                    admin = admin,
                    parent = 'mute',
                    child = 'ip',
                    sub = entry,
                })
            end
        end
    end
end

return command