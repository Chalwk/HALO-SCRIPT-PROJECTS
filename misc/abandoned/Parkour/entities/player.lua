local player = {}

function player:newPlayer(playerTable)

    setmetatable(playerTable, { __index = self })
    self.__index = self

    playerTable.stats = playerTable:loadStats()

    return playerTable
end

function player:isValidPlayer()
    local id = self.id
    local dyn = get_dynamic_player(id)
    return player_present(id) and dyn ~= 0 and player_alive(id)
end

function player:getPlayerPosition(dyn)

    dyn = dyn or get_dynamic_player(self.id)
    local crouch = read_float(dyn + 0x50C)
    local x, y, z = read_vector3d(dyn + 0x5C)
    z = crouch == 0 and z + 0.65 or z + 0.35 * crouch

    return { x = x, y = y, z = z }
end

return player