local sky_spawn = {}

function sky_spawn:landed(dynamic_player)
    local state = read_byte(dynamic_player + 0x2A3)
    if (state == 21 or state == 22) then

        execute_command('ungod ' .. self.id)
        write_word(dynamic_player + 0x104, 0) -- force shield to regenerate immediately
        write_float(dynamic_player + 0x424, 0) -- stun ??

        -- important, otherwise players will be put into spectator mode when the map resets:
        self.can_spectate = true
        return true
    end
    return false
end

function sky_spawn:landing()

    if (not self.game or not self.game.started) then
        return
    end

    for i, v in pairs(self.players) do
        local dyn = get_dynamic_player(i)
        if (v.god and dyn ~= 0 and v:landed(dyn)) then
            v.god = nil
        end
    end
end

return sky_spawn