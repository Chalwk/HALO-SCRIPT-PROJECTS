local weapons = {}

local floor = math.floor

local function reloading(dynamic_player)
    return (read_byte(dynamic_player + 0x2A4) == 5)
end

function weapons:newWeapon()

    local id = self.id
    local dyn = get_dynamic_player(id)
    if (not self.game or not self.game.started) then
        return
    elseif (self.spectator or not player_alive(id) or dyn == 0) then
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

    -- Constructor for new weapon object:
    if (not self.weapons[object]) then

        local meta_id = read_dword(object)
        local energy = self.energy_weapons[meta_id]

        self.weapons[object] = {
            energy = energy,
            weapon = this_weapon, -- weapon tag
            damage_multiplier = 0, -- default damage multiplier
            ammo_type = 1, -- default ammo type
            object = object,
            timer = self:new(),
            durability = self.weapon_degradation.max_durability, -- 0% = broken, 100% = new
            notify = true
        }

        setmetatable(self.weapons[object], self)
        self.__index = self

        if (self.has_nuke) then
            self.has_nuke = false
            self.weapons[object]:setAmmoType(6) -- nuke
            self.weapons[object]:setAmmoDamage(100) -- damage multiplier
            write_word(object + 0x2B8, 1) -- primary
            write_word(object + 0x2B6, 0) -- reserve
            sync_ammo(this_weapon)
        end
    end
end

-- Gets the weapon object table:
function weapons:getWeapon(object)
    return self.weapons[object]
end

function weapons:getWeaponObject()
    return self.object
end

-- Sets the weapon ammo type:
-- 1 = normal bullets
-- 2 = armour piercing bullets
-- 3 = explosive bullets
-- 4 = golden bullets (one-shot kill)
-- 5 = grenade launcher
function weapons:setAmmoType(type)
    self.ammo_type = type
end

-- Gets the weapon ammo type:
function weapons:getAmmoType()
    return self.ammo_type
end

-- Sets the weapon ammo damage multiplier:
function weapons:setAmmoDamage(mult)
    self.damage_multiplier = mult
end

-- Gets the weapon ammo damage multiplier:
function weapons:getAmmoDamage()
    return self.damage_multiplier
end

function weapons:getAmmunition(object)

    object = self.object or object

    -- non-energy weapons:
    local primary = read_word(object + 0x2B8) -- primary
    local reserve = read_word(object + 0x2B6) -- reserve

    -- energy weapons:
    local battery = read_float(object + 0x240)
    local energy_bullets = floor(battery * 100)

    local no_battery = (read_byte(object + 0x261) == 7)

    return {
        primary = primary,
        reserve = reserve,
        no_battery = no_battery,
        energy_bullets = energy_bullets
    }
end

function weapons:customAmmo()

    local id = self.id
    local dyn = get_dynamic_player(id)
    if (not self.game or not self.game.started or not player_alive(id) or dyn == 0) then
        return
    end

    local weapon = read_dword(dyn + 0x118)
    local object = get_object_memory(weapon)

    if (weapon == 0xFFFFFFFF) then
        return
    elseif (object == 0) then
        self.weapons[object] = nil
        return
    end

    local frags = read_byte(dyn + 0x31E)
    local plasmas = read_byte(dyn + 0x31F)

    if (self.can_stun and frags == 0 and plasmas == 0) then
        self.can_stun = false
        self:newMessage('You ran out of stun grenades', 5)
    end

    -- weapon object:
    weapon = self:getWeapon(object)

    -- normal ammo, ignore:
    if (weapon:getAmmoType() == 1) then
        return
    end

    local primary = read_dword(object + 0x2B8) -- primary
    if (primary == 0 or reloading(dyn)) then
        weapon:setAmmoType(1) -- reset ammo type
        weapon:setAmmoDamage(0) -- reset damage multiplier
        self:newMessage('Ammo returned to normal', 8)
        return
    end
end

function weapons:checkDurability(rate, reload, is_firing, melee)

    if (not rate) then
        return
    elseif (not self.timer:isStarted()) then
        self.timer:start()
    end

    local ammunition = self:getAmmunition()
    local primary = ammunition.primary

    if (not reload and is_firing or melee) then
        if (not self.energy and primary == 0) then
            return
        elseif (self.energy and ammunition.no_battery) then
            return
        end
    end

    self.durability = self.durability - (rate / 30)

    local time = self.timer:get()
    local durability = self.durability
    local frequency = (durability / 100) ^ 2 * 100

    --cprint('Jam when: ' .. time .. ' / ' .. frequency)

    if (time >= frequency) then
        self.ammo = ammunition
        self.jammed = true
        self.timer:restart()
        return true
    end
end

function weapons:jamWeapon(player, dyn)

    if (not self.jammed) then
        return false
    end

    local melee = player:meleeButton(dyn)
    if (not melee) then
        write_word(self.object + 0x2B8, 0) -- primary
        write_word(self.object + 0x2B6, 0) -- reserve
        write_float(self.object + 0x240, 0) -- battery
        sync_ammo(self.weapon)
        return true
    end

    local ammunition = self.ammo
    local primary = ammunition.primary
    local reserve = ammunition.reserve
    local battery = ammunition.energy_bullets / 100

    write_word(self.object + 0x2B8, primary)
    write_word(self.object + 0x2B6, reserve)
    write_float(self.object + 0x240, battery)
    sync_ammo(self.weapon)

    self.jammed = nil
    self.ammo = nil

    player:newMessage('[WEAPON UNJAMMED]', 5)
    return false
end

local function hasThisWeapon(self, meta_id)

    local id = self.id
    local dyn = get_dynamic_player(id)

    if (not player_alive(id) or dyn == 0) then
        return false
    end

    local count = 0
    for i = 0, 3 do
        local weapon = read_dword(dyn + 0x2F8 + i * 4)
        local object = get_object_memory(weapon)
        if (weapon ~= 0xFFFFFFFF and object ~= 0) then
            count = count + 1
            local tag_id = read_dword(object)
            if (tag_id == meta_id) then
                return true, count
            end
        end
    end

    return false, count
end

local function giveWeapon(self, key, weapon, args)

    local id = self.id
    local primary = weapon[1]
    local reserve = weapon[2]

    weapon = spawn_object('', '', 0, 0, 0, 0, key)
    assign_weapon(weapon, id)

    local object = get_object_memory(weapon)
    write_word(object + 0x2B8, primary) -- primary

    -- This is not working for some reason:
    --write_float(object + 0x240, primary) -- battery
    execute_command('battery ' .. id .. ' ' .. primary .. ' 0')

    if (reserve) then
        write_word(object + 0x2B6, reserve) -- reserve
    end

    sync_ammo(weapon)

    self:newMessage('[Unlocked] ' .. args.label, 5)
end

local function getRandomKey(t)
    local keys = {}
    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys[rand(1, #keys + 1)]
end

function weapons:getRandomWeapon(args)

    local random_weapons = self.random_weapons

    local key = getRandomKey(random_weapons)
    local weapon = random_weapons[key]

    local has_weapon, count = hasThisWeapon(self, key)
    if (count == 4) then
        self:newMessage('[Unlocked] ' .. args.label .. ' | But you have too many weapons!', 5)
        return
    end

    while (has_weapon) do
        key = getRandomKey(random_weapons)
        weapon = random_weapons[key]
        has_weapon = hasThisWeapon(self, key)
    end

    giveWeapon(self, key, weapon, args)
end

function weapons:createProjectile(dyn, weapon)

    local id = self.id
    local px, py, pz = self:getXYZ(dyn)

    local xAim = math.sin(read_float(dyn + 0x230))
    local yAim = math.sin(read_float(dyn + 0x234))
    local zAim = math.sin(read_float(dyn + 0x238))

    local xVel = weapon.velocity * xAim
    local yVel = weapon.velocity * yAim
    local zVel = weapon.velocity * zAim

    local distance = weapon.distance
    local x = px + (distance * xAim)
    local y = py + (distance * yAim)
    local z = pz + (distance * zAim)

    if (weapon.projectile) then

        local rocket = spawn_projectile(weapon.projectile, id, x, y, z)
        local object = get_object_memory(rocket)

        if (rocket and object ~= 0) then
            write_float(object + 0x68, xVel)
            write_float(object + 0x6C, yVel)
            write_float(object + 0x70, zVel)
        end
    end
end

return weapons