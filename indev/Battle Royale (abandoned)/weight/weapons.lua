local weight = {}

function weight:getWeight(weapon)

    local object = get_object_memory(weapon)
    if (object == 0 or weapon == 0xFFFFFFFFF) then
        return 0
    end

    local meta_id = read_dword(object)
    local weight_to_add = self.weapon_weights[meta_id]
    if (not weight_to_add) then
        return 0
    end

    return weight_to_add
end

function weight:getSpeed()

    local speed = self.default_running_speed
    local dyn = get_dynamic_player(self.id)
    if (dyn == 0 or not player_alive(self.id) or self.spectator) then
        return speed
    end

    local weapon_in_hand = read_dword(dyn + 0x118)
    if (not self.weight.combined) then
        return self:getWeight(weapon_in_hand)
    end

    for i = 0, 3 do
        local weapon = read_dword(dyn + 0x2F8 + i * 4)
        speed = speed - self:getWeight(weapon)
    end

    return (speed < 0 and 0 or speed)
end

return weight