local command = {
    name = 'ip_alias',
    description = 'View a player\'s aliases by IP.',
    help = 'Syntax: /$cmd <player/ip> <page>',
    header = 'Aliases for [%s]: Page %d/%d', -- type ip, page, total pages
    output = '$name  |  Level: [$level]'

    -- Valid placeholders for output: $name, $level, $date_joined, $last_activity
}

function command:run(id, args)

    local target = args[2]
    local page = tonumber(args[3])
    local admin = self.players[id]
    local pattern = '^%d+%.%d+%.%d+%.%d+$'

    if admin:hasPermission(self.permission_level, args[1]) then

        if (target == 'help') then
            admin:send(self.description)
            return
        elseif (target == nil) then
            admin:send(self.help)
            return
        elseif (tonumber(target)) then
            target = tonumber(target)
            if (not player_present(target)) then
                admin:send('Player #' .. target .. ' is not online.')
                return
            end
            target = self.players[target].ip
        elseif (not target:match(pattern)) then
            admin:send('Invalid ip address or player id.')
            return
        end

        page = page or 1
        local found = self:showAliases({
            target = target,
            page = page,
            admin = admin,
            header = self.header,
            type = 'IP_ALIASES',
            number_to_show = 10
        })

        if (not found) then
            admin:send('No aliases found for [' .. target .. '] on page ' .. page .. ')')
        end
        self:log(admin.name .. ' viewed the ip-alias list for [' .. target .. ']' , self.logging.management)
    end
end

return command