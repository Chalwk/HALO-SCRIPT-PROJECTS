local weapons = {}

local floor = math.floor

local function isFiring(dynamic_player)
    return (read_float(dynamic_player + 0x490) == 1)
end

local function reloading(dynamic_player)
    return (read_byte(dynamic_player + 0x2A4) == 5)
end

local function overheating(object)
    return (read_bit(object + 0x22C, 0) == 1)
end

function weapons:notifyDurability(weapon)
    local min = self.weapon_degradation.no_jam_before
    local durability = floor(weapon.durability)
    if (durability >= min) then
        return -- do nothing
    elseif (durability % 10 == 0 and weapon.notify) then
        self:newMessage('[DURABILITY NOW ' .. durability .. '%]', 8)
        weapon.notify = false
    elseif (durability % 10 ~= 0) then
        weapon.notify = true
    end
end

function weapons:degrade()

    local id = self.id
    local dyn = get_dynamic_player(id)

    if (not self.game or not self.game.started) then
        return
    elseif (not self.weapon_degradation.enabled) then
        return
    elseif (not player_alive(id) or dyn == 0) then
        return
    end

    local this_weapon = read_dword(dyn + 0x118)
    local object = get_object_memory(this_weapon)

    if (this_weapon == 0xFFFFFFFF) then
        return
    elseif (object == 0) then
        self.weapons[object] = nil
        return
    end

    local weapon = self:getWeapon(object)

    local in_vehicle = self:inVehicle(dyn)
    local overheated = overheating(object)
    if (in_vehicle or overheated) then
        return
    elseif (weapon:jamWeapon(self, dyn)) then
        return
    end

    local melee = self:meleeButton(dyn)
    local is_firing = isFiring(dyn)
    local is_reloading = reloading(dyn)

    if (is_firing or is_reloading or melee) then

        local meta_id = read_dword(object) -- weapon tag id
        local rate = self.decay_rates[meta_id]

        if (not rate) then
            rate = 0
        else
            rate = (is_reloading and rate / 5) or rate
        end

        if (weapon.durability <= 0) then
            weapon.durability = 0
            self:newMessage('[YOUR WEAPON HAS BEEN DESTROYED]', 8)
            destroy_object(this_weapon)
        elseif (weapon:checkDurability(rate, is_reloading, is_firing, melee)) then
            self:newMessage('[WEAPON JAMMED] Press MELEE to unjam.', 5)
        else
            self:notifyDurability(weapon)
        end
    end
end

return weapons