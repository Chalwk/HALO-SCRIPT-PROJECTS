local command = {
    name = 'hash_admins',
    description = 'List all hash-admins.',
    header = '[Hash-Admins] (Page: %s/%s)', -- page (current, total)
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
        local results = self:showAdminList('hash_admins', page, 5, admin)
        if (not results) then
            admin:send('There are no hash-admins.')
        end
        self:log(admin.name .. ' viewed the hash-admin list.', self.logging.management)
    end
end

return command