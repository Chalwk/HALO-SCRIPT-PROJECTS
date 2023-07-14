local event = {}
local format = string.format

local function loadMapSettings(self)

    local map = get_var(0, '$map')
    local path = './Battle Royale/map settings/'

    -- Try stock maps first:
    local success, data = xpcall(require, function()
    end, path .. 'stock/' .. map)

    -- Try custom maps:
    if (not success) then
        success, data = xpcall(require, function()
        end, path .. 'custom/' .. map)
    end

    for k, v in pairs(data) do
        self[k] = v
    end
end

function event:getClipSizesTable()
    for _, v in pairs(self.looting.spoils) do
        if (v.clip_sizes) then
            return v.clip_sizes
        end
    end
end

function event:getStunTags()
    for _, v in pairs(self.looting.spoils) do
        if (v.grenade_tags) then
            return v.grenade_tags
        end
    end
end

function event:getRandomWeaponTags()
    local spoils = self.looting.spoils
    for _, v in pairs(spoils) do
        if (v.random_weapons) then
            return v.random_weapons
        end
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

function event:onStart()
    if (get_var(0, '$gt') ~= 'n/a') then

        loadMapSettings(self)

        self.loot = nil
        self.loot_crates = nil

        -- pre game timer:
        self.game = nil

        -- players table:
        self.players = {}

        -- weapons table:
        self.weapons = {}

        -- nuke:
        self.nukes = {}

        -- Sets initial radius of the safe zone and the total game time:
        self.total_time = self:setSafeZone()

        local h, m, s = self:secondsToTime(self.total_time)
        timer(33, 'pluginLogo', h, m, s, self.end_after)

        self.stuns = self:tagsToID(self:getStunTags(), 'jpt!')
        self.clip_sizes = self:tagsToID(self:getClipSizesTable(), 'weap')
        self.random_weapons = self:tagsToID(self:getRandomWeaponTags(), 'weap')

        self.weapon_weights = self:tagsToID(self.weight.weapons, 'weap')
        self.energy_weapons = self:tagsToID(self._energy_weapons_, 'weap')
        self.decay_rates = self:tagsToID(self.weapon_degradation.decay_rate, 'weap')

        -- For explosive bullets:
        self.rocket_projectile = self:getTag('proj', self.rocket_projectile_tag)

        -- For grenade launcher:
        self.frag_projectile = self:getTag('proj', self.frag_grenade_projectile)

        -- For nuke (weapon):
        self.rocket_launcher = self:getTag('weap', self.rocket_launcher_weapon)

        self.nuke_projectile = self:getTag('proj', self.tank_shell_projectile)
        self.nuke_tag_data = getTagData(self)

        self.overshield_object = self:getTag('eqip', self.overshield_equipment)

        -- Disable object that represents loot crates:
        for name, _ in pairs(self.looting.crates['eqip']) do
            execute_command('disable_object "' .. name .. '"')
        end
    end
end

function pluginLogo(h, m, s, b)
    cprint('=======================================================================================================================', 10)
    cprint(" ")
    cprint("'||''|.       |     |''||''| |''||''| '||'      '||''''|     '||''|.    ..|''||   '||' '|'     |     '||'      '||''''|", 12)
    cprint(" ||   ||     |||       ||       ||     ||        ||  .        ||   ||  .|'    ||    || |      |||     ||        ||  .", 12)
    cprint(" ||'''|.    |  ||      ||       ||     ||        ||''|        ||''|'   ||      ||    ||      |  ||    ||        ||''|", 12)
    cprint(" ||    ||  .''''|.     ||       ||     ||        ||           ||   |.  '|.     ||    ||     .''''|.   ||        ||", 12)
    cprint(".||...|'  .|.  .||.   .||.     .||.   .||.....| .||.....|    .||.  '|'  ''|...|'    .||.   .|.  .||. .||.....| .||.....|", 12)
    cprint(" ")
    cprint(format("This game will end in %s hours, %s minutes and %s seconds", h, m, s), 15)
    cprint(format('Crunch time: %s', b .. ' seconds'), 15)
    cprint('========================================================================================================================', 10)
end

register_callback(cb['EVENT_GAME_START'], 'OnStart')

return event