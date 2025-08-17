local event = {}

-- Prevent spectators from damaging (or being damaged) by other players:
function event:on_damage(victim, killer, meta_id, damage)

    local v = tonumber(victim)
    local k = tonumber(killer)

    if (k == 0 or k == v) then
        return true
    end

    victim = self.players[v]
    killer = self.players[k]

    if (victim.spectator or killer.spectator) then
        return false
    end

    --
    -- Stun grenades:
    if (self.stuns[meta_id] and killer and killer.can_stun and not victim.stun) then
        victim:newMessage('You have been stunned!')
        local grenade = self.stuns[meta_id]
        victim.stun = {
            interval = os.time() + grenade[1],
            speed = grenade[2]
        }
        return true, damage
    end

    --
    -- Custom ammo:
    local dyn = get_dynamic_player(killer.id)
    local weapon = read_dword(dyn + 0x118)
    local object = get_object_memory(weapon)

    weapon = self:getWeapon(object)
    if (weapon) then
        local mult = weapon.damage_multiplier
        return true, (mult > 0 and damage * mult) or damage
    end

    return true, damage
end

register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'on_damage')

return event