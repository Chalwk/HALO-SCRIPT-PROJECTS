local safe_zone = {}

function safe_zone:hurt(player)

    if (self.spectator) then
        return

        -- Another name for kill_timer is "hurt_timer" or "damage_timer" or "damage_cooldown" or "hurt_cooldown" or "hurt_delay" or "damage_delay"
    elseif (not player.hurt_cooldown) then
        player.hurt_cooldown = self:new()
        player.hurt_cooldown:start()
    end

    local time = player.hurt_cooldown:get()
    if (time >= 1) then

        player.hurt_cooldown:restart()

        local dyn = get_dynamic_player(player.id)
        if (dyn == 0 or not player_alive(player.id)) then
            return
        end

        local health = read_float(dyn + 0xE0)
        if (health <= 0) then

            self:disableDeathMessages()
            execute_command('kill ' .. player.id)
            self:say(player.name .. ' has died outside the safe zone')
            self:enableDeathMessages()

            return
        end

        local amount = self.health_reduction
        write_float(dyn + 0xE0, health - amount)

        player:setHUD("warning")
        return
    end
end

return safe_zone
