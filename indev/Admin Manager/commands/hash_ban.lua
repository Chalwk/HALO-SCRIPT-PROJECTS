local command = {
    name = 'hash_ban',
    description = 'Flags: -y -mo -d -h -m -s -r "example reason"',
    help = 'Syntax: /$cmd <player> <flags> | Type ($cmd help) for more information.',
    output = '$admin hash-banned $offender until [$years/$months/$days - $hours:$minutes:$seconds] for reason: $reason'
}

local time = os.time

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
                local hash = offender.hash
                if (self.known_pirated_hashes[hash]) then
                    admin:send('[WARNING] ' .. offender.name .. ' is using a pirated copy of Halo.')
                    admin:send('Banning this hash will ban all other players using the same pirated copy.')
                    admin:send('Type /confirm to confirm.')
                    admin.confirm = {
                        output = self.output,
                        hash_ban = {offender, parsed},
                        timeout = time() + self.confirmation_timeout,
                    }
                    return false
                end
                self:hashBanProceed(offender, parsed, admin)
            else
                admin:send(self.help)
            end
        end
    end
end

return command