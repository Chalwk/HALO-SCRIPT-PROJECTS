local command = {
    name = 'ip_admins',
    description = 'List all IP-admins.',
    header = '[IP-Admins] (Page: %s/%s)', -- page (current, total)
    output = '[%s] %s | Level: [%s]', -- admin id, name, level
    help = 'Syntax: /$cmd <page>'
}

function command:run(id, args)
    local admin = self.players[id]
    if admin:hasPermission(self.permission_level, args[1]) then

        if (args[2] == 'help') then
            return false, admin:send(self.description)
        end

        local page = tonumber(args[2]) or 1
        local results = self:showAdminList('ip_admins', page, 5, admin)
        if (not results) then
            admin:send('There are no ip-admins.')
        end
        self:log(admin.name .. ' viewed the ip-admin list.', self.logging.management)
    end
end

return command