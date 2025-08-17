local Command = {}

local function repair(self)

    local id = self.id
    local dyn = get_dynamic_player(id)
    if (dyn == 0 or not player_alive(id)) then
        self:newMessage('[DEAD] Unable to repair weapons.', 5)
        return
    end

    local repaired
    for i = 0, 3 do

        local this_weapon = read_dword(dyn + 0x2F8 + i * 4)
        local object = get_object_memory(this_weapon)

        if (this_weapon ~= 0xFFFFFFFF and object ~= 0) then

            local weapon = self.weapons[object]
            local max = self.weapon_degradation.max_durability

            if (weapon and weapon.durability < max) then
                weapon.durability = max
                weapon.jammed = nil
                weapon.ammo = nil
                weapon.timer:stop()
                repaired = true
            end
        end
    end

    if (repaired) then
        self.weapon_parts = nil
        self:newMessage('Weapons repaired!', 5)
    else
        self:newMessage('Nothing was repaired!', 5)
    end
end

-- Executes this command.
-- @param id = player id (number)
-- @param args (table of command strings)
--
function Command:run(id)

    local player = self.players[id]
    if not player:commandEnabled(self.enabled, self.name) then
        return
    elseif not player:hasPermission(self.level) then
        return
    elseif (not player.weapon_parts) then
        player:newMessage("[COMMAND FAILED] You don't have weapon parts!", 5)
        return
    end

    repair(player)
end

return Command