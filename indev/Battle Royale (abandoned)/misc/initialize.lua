local plugin = {}
local format = string.format
local req = require
local call = xpcall
local pairs = pairs

local function loadMapSettings(self)

    local map = get_var(0, '$map')
    local path = './Battle Royale/map settings/'

    -- Try stock maps first:
    local success, data = call(req, function()
    end, path .. 'stock/' .. map)

    -- Try custom maps:
    if (not success) then
        success, data = call(req, function()
        end, path .. 'custom/' .. map)
    end

    for k, v in pairs(data) do
        self[k] = v
    end
end

local function getTagData(self)
    local jpt = self.tank_shell_jpt_tag
    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == jpt) then
            return read_dword(tag + 0x14)
        end
    end
    return nil
end

local function getClipSizesTable(self)
    for _, v in pairs(self.looting.spoils) do
        if (v.clip_sizes) then
            return v.clip_sizes
        end
    end
end

local function getStunTags(self)
    for _, v in pairs(self.looting.spoils) do
        if (v.grenade_tags) then
            return v.grenade_tags
        end
    end
end

local function getRandomWeaponTags(self)
    local spoils = self.looting.spoils
    for _, v in pairs(spoils) do
        if (v.random_weapons) then
            return v.random_weapons
        end
    end
end

function plugin:initialize()

    loadMapSettings(self)

    self:reset()

    local stuns = getStunTags(self)
    local clip_sizes = getClipSizesTable(self)
    local random_weapons = getRandomWeaponTags(self)

    local weights = self.weight.weapons
    local energy_weapons = self._energy_weapons_
    local decay_rates = self.weapon_degradation.decay_rate

    self.nuke_tag_data = getTagData(self)
    self.stuns = self:tagsToID(stuns, 'jpt!')
    self.clip_sizes = self:tagsToID(clip_sizes, 'weap')
    self.random_weapons = self:tagsToID(random_weapons, 'weap')

    self.weapon_weights = self:tagsToID(weights, 'weap')
    self.energy_weapons = self:tagsToID(energy_weapons, 'weap')
    self.decay_rates = self:tagsToID(decay_rates, 'weap')

    self.rocket_projectile = self:getTag('proj', self.rocket_projectile_tag)
    self.frag_projectile = self:getTag('proj', self.frag_grenade_projectile)
    self.rocket_launcher = self:getTag('weap', self.rocket_launcher_weapon)
    self.nuke_projectile = self:getTag('proj', self.tank_shell_projectile)
    self.overshield_object = self:getTag('eqip', self.overshield_equipment)

    for name, _ in pairs(self.looting.crates['eqip']) do
        execute_command('disable_object "' .. name .. '"')
    end

    local h, m, s = self:secondsToTime(self.total_time)
    cprint('=======================================================================================================================', 10)
    cprint(" ")
    cprint("'||''|.       |     |''||''| |''||''| '||'      '||''''|     '||''|.    ..|''||   '||' '|'     |     '||'      '||''''|", 12)
    cprint(" ||   ||     |||       ||       ||     ||        ||  .        ||   ||  .|'    ||    || |      |||     ||        ||  .", 12)
    cprint(" ||'''|.    |  ||      ||       ||     ||        ||''|        ||''|'   ||      ||    ||      |  ||    ||        ||''|", 12)
    cprint(" ||    ||  .''''|.     ||       ||     ||        ||           ||   |.  '|.     ||    ||     .''''|.   ||        ||", 12)
    cprint(".||...|'  .|.  .||.   .||.     .||.   .||.....| .||.....|    .||.  '|'  ''|...|'    .||.   .|.  .||. .||.....| .||.....|", 12)
    cprint(" ")
    cprint(format("This game will end in %s hours, %s minutes and %s seconds", h, m, s), 15)
    cprint(format('Crunch time: %s', self.end_after .. ' seconds'), 15)
    cprint('========================================================================================================================', 10)
end

function plugin:reset()

    self.game = nil
    self.nukes = {}
    self.players = {}
    self.weapons = {}
    self.loot = { crates = {}, random = {} }

    self.total_time = self:setSafeZone()

    for i = 1, 16 do
        if player_present(i) then
            self.players[i] = self:onJoin(i)
        end
    end
end

return plugin