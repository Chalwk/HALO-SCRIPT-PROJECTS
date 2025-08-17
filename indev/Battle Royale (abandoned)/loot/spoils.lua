local spoils = {}

-- Gives the player a nuke.
-- This will kill all players within a X world/unit radius.
function spoils:giveNuke(args)

    local id = self.id
    assign_weapon(self:spawnObject(self.rocket_launcher, 0, 0, 0), id)

    self.has_nuke = true
    self:newMessage('You unlocked ' .. args.label, 5)

    return true
end

function spoils:giveLife(args)

    local label = args.label
    local lives = args.lives
    self.lives = self.lives + lives

    label = label:gsub('$lives', lives)
    self:newMessage('You unlocked ' .. label, 5)
    return true
end

function spoils:giveStunGrenades(args)

    self.can_stun = true

    local id = self.id
    local dyn = get_dynamic_player(id)

    local frags = args.count[1]
    local plasmas = args.count[2]

    write_byte(dyn + 0x31E, frags)
    write_byte(dyn + 0x31F, plasmas)

    local label = args.label
    label = label:gsub('$frags', frags):gsub('$plasmas', plasmas)
    self:newMessage('You unlocked ' .. label, 5)

    return true
end

function spoils:giveGrenades(args)

    local id = self.id
    local dyn = get_dynamic_player(id)

    local frags = args.count[1]
    local plasmas = args.count[2]

    write_byte(dyn + 0x31E, frags)
    write_byte(dyn + 0x31F, plasmas)

    local label = args.label
    label = label:gsub('$frags', frags):gsub('$plasmas', plasmas)
    self:newMessage('You unlocked ' .. label, 5)

    return true
end

function spoils:giveGrenadeLauncher(args)

    local id = self.id

    local dyn = get_dynamic_player(id)
    local this_weapon = read_dword(dyn + 0x118)
    if (this_weapon == 0xFFFFFFFF) then
        self:newMessage('Picked up grenade launcher but no weapon to modify!', 5)
        return true
    end

    local object = get_object_memory(this_weapon)
    if (object ~= 0) then

        local weapon = self:getWeapon(object)
        weapon.velocity = args.velocity
        weapon.distance = args.distance
        weapon.projectile = self.frag_projectile

        weapon:setAmmoType(5)
        weapon:setAmmoDamage(100)

        self:newMessage('You unlocked ' .. args.label)
        return true
    end
    return false
end

function spoils:giveWeaponParts(args)
    self.weapon_parts = true
    self:newMessage('You unlocked ' .. args.label, 5)
    return true
end

function spoils:giveRandomWeapon(args)
    self:getRandomWeapon(args)
    return true
end

function spoils:giveSpeedBoost(args)

    local label = args.label
    local multipliers = args.multipliers

    local mult = multipliers[rand(1, #multipliers + 1)]
    local speed_multiplier = mult[1]
    local duration = mult[2]

    local new_speed = self.speed.current * speed_multiplier
    self.speed.current = new_speed
    self.speed.duration = duration

    self.speed.timer = self:new()
    self.speed.timer:start()

    new_speed = string.format('%.2f', new_speed)

    label = label:gsub('$speed', new_speed):gsub('$duration', duration)
    self:newMessage('You unlocked ' .. label, 5)
    return true
end

function spoils:giveAmmo(args)

    local id = self.id
    local ammo_types = args.types

    local type = rand(1, #ammo_types + 1)
    local multiplier = ammo_types[type][1]
    local label = ammo_types[type][2]

    local dyn = get_dynamic_player(id)
    local this_weapon = read_dword(dyn + 0x118)
    if (this_weapon == 0xFFFFFFFF) then
        self:newMessage('Picked up custom ammo but no weapon to modify!', 5)
        return true
    end

    local object = get_object_memory(this_weapon)
    if (object ~= 0) then

        local weapon = self:getWeapon(object)

        --- for explosive bullets:
        weapon.velocity = 1000
        weapon.distance = 0.5
        weapon.projectile = self.rocket_projectile
        --

        weapon:setAmmoType(type)
        weapon:setAmmoDamage(multiplier)

        local meta_id = read_dword(object) -- weapon tag id
        local clip_size = self.clip_sizes[meta_id]

        write_word(object + 0x2B8, clip_size) -- primary
        write_float(object + 0x240, clip_size) -- battery
        sync_ammo(this_weapon)

        label = label:gsub('$ammo', clip_size)

        self:newMessage('You unlocked ' .. label)
        return true
    end
    return false
end

function spoils:giveCamo(args)

    local id = self.id
    local durations = args.durations
    local duration = durations[rand(1, #durations + 1)]

    local label = args.label
    label = label:gsub('$time', duration)

    self:newMessage('You unlocked ' .. label, 5)
    execute_command('camo ' .. id .. ' ' .. duration)

    return true
end

function spoils:giveOvershield(args)

    local id = self.id

    local label = args.label
    self:newMessage('You unlocked ' .. label, 5)

    local shield = spawn_object('', '', 0, 0, 0, 0, self.overshield_object)
    powerup_interact(shield, id)

    return true
end

function spoils:giveHealthBoost(args)

    local id = self.id
    local levels = args.levels
    local level = levels[rand(1, #levels + 1)]

    execute_command('hp ' .. id .. ' ' .. level)

    local label = args.label
    label = label:gsub('$health', level)

    self:newMessage('You unlocked ' .. label, 5)
    return true
end

return spoils