local Command = {}

-- Executes this command.
-- @param id = player id (number)
-- @param args (table of command strings)
--
function Command:run(id, args)

    local player = self.players[id] -- admin
    if not player:commandEnabled(self.enabled, self.name) then
        return
    elseif not player:hasPermission(self.level) then
        return
    end

    self:reset()
end

return Command