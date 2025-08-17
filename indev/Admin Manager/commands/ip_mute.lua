local command = {
    name = 'ip_mute',
    description = 'Flags: -y -mo -d -h -m -s -r "example reason"',
    help = 'Syntax: /$cmd <player> <flags> | Type ($cmd help) for more information.',
    output = '$admin IP-muted $offender until [$years/$months/$days - $hours:$minutes:$seconds] for reason: $reason',
}

function command:run(id, args)

    local offender = tonumber(args[2])
    local admin = self.players[id]

    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            admin:send(self.description)
        elseif (not offender) then
            admin:send(self.help)
        elseif (not player_present(offender)) then
            admin:send('Player #' .. offender .. ' is not online.')
        else

            local parsed = admin:banSyntaxParser(args)
            if (parsed) then

                offender = self.players[offender]

                local name = offender.name
                local child = offender.ip
                local reason = parsed.reason or 'No reason given.'
                local expiration = self:generateExpiration(parsed)

                offender:mute('ip', child, reason, expiration, admin)
                local stdout = self:banSTDOUT({
                    admin_name = admin.name,
                    offender_name = name,
                    reason = reason,
                    expiration = expiration
                })

                admin:send(stdout)
                self:log(stdout, self.logging.management)
            else
                admin:send(self.help)
            end
        end
    end
end

return command