local event = {}

function event:on_spawn(id)

    local player = self.players[id]
    if (not player) then
        return
    elseif (self.game and self.game.started and player.god) then
        execute_command('god ' .. id)
    end

    execute_command('hp ' .. id .. ' ' .. self.health)
    execute_command('wdel ' .. id)
    execute_command('s ' .. id .. ' ' .. self.default_running_speed)

    --
    -- Prevents players from spawning outside the safe zone:
    -- Only in effect during game play.
    --

    local game_started = (self.game and self.game.started)
    if (not player.god and game_started) then

        local dyn = get_dynamic_player(id)
        local px, py, pz = player:getXYZ(dyn)

        local radius = self.safe_zone.size
        local bX, bY, bZ = self.safe_zone.x, self.safe_zone.y, self.safe_zone.z
        local distance = self:getDistance(px, py, pz, bX, bY, bZ)

        if (distance <= radius) then
            return
        end

        local spawns = self:getSpawns()
        local closest
        local closest_distance
        for i = 1, #spawns do

            local point = spawns[i]
            local x = point[1]
            local y = point[2]
            local z = point[3]

            distance = self:getDistance(x, y, z, bX, bY, bZ)
            if (not closest or distance < closest_distance) then
                closest = point
                closest_distance = distance
            end
        end

        player.spawn = closest
        player:teleport(false, false)
    end
end

register_callback(cb['EVENT_SPAWN'], 'on_spawn')

return event