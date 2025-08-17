local stock_tags = {

    -- bipd --
    "characters\\cyborg_mp\\cyborg_mp",

    -- !jpt
    "characters\\cyborg\\melee",
    "weapons\\assault rifle\\melee",
    "weapons\\assault rifle\\melee_response",
    "weapons\\assault rifle\\bullet",
    "weapons\\assault rifle\\trigger",
    "weapons\\pistol\\melee",
    "weapons\\pistol\\melee_response",
    "weapons\\pistol\\bullet",
    "weapons\\pistol\\trigger",
    "vehicles\\warthog\\bullet",
    "vehicles\\warthog\\trigger",
    "vehicles\\scorpion\\shell explosion",
    "weapons\\frag grenade\\shock wave",
    "vehicles\\scorpion\\shell shock wave",
    "vehicles\\scorpion\\bullet",
    "vehicles\\scorpion\\secondary trigger",
    "vehicles\\ghost\\ghost bolt",
    "vehicles\\ghost\\trigger",
    "weapons\\rocket launcher\\explosion",
    "vehicles\\rwarthog\\effects\\trigger",
    "vehicles\\banshee\\banshee bolt",
    "vehicles\\banshee\\trigger",
    "vehicles\\banshee\\mp_fuel rod explosion",
    "vehicles\\banshee\\fuel rod trigger",
    "weapons\\shotgun\\melee",
    "weapons\\shotgun\\melee_response",
    "weapons\\shotgun\\pellet",
    "weapons\\shotgun\\trigger",
    "weapons\\plasma rifle\\melee",
    "weapons\\plasma rifle\\melee_response",
    "weapons\\plasma rifle\\bolt",
    "weapons\\plasma rifle\\trigger",
    "weapons\\plasma rifle\\misfire",
    "weapons\\frag grenade\\explosion",
    "weapons\\rocket launcher\\melee",
    "weapons\\rocket launcher\\melee_response",
    "weapons\\rocket launcher\\trigger",
    "weapons\\sniper rifle\\melee",
    "weapons\\sniper rifle\\melee_response",
    "weapons\\sniper rifle\\sniper bullet",
    "weapons\\sniper rifle\\trigger",
    "weapons\\plasma grenade\\shock wave",
    "weapons\\plasma grenade\\explosion",
    "weapons\\flamethrower\\melee",
    "weapons\\flamethrower\\melee_response",
    "weapons\\flamethrower\\explosion",
    "weapons\\flamethrower\\impact damage",
    "weapons\\flamethrower\\burning",
    "weapons\\flamethrower\\trigger",
    "weapons\\plasma_cannon\\effects\\plasma_cannon_melee",
    "weapons\\plasma_cannon\\effects\\plasma_cannon_melee_response",
    "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion",
    "weapons\\plasma_cannon\\impact damage",
    "weapons\\plasma_cannon\\effects\\plasma_cannon_trigger",
    "weapons\\plasma_cannon\\effects\\plasma_cannon_misfire",
    "weapons\\plasma pistol\\melee",
    "weapons\\plasma pistol\\melee_response",
    "weapons\\plasma pistol\\bolt",
    "weapons\\plasma pistol\\trigger",
    "weapons\\plasma pistol\\misfire",
    "weapons\\plasma rifle\\charged bolt",
    "weapons\\plasma pistol\\trigger overcharge",
    "weapons\\plasma grenade\\attached",
    "weapons\\needler\\melee",
    "weapons\\needler\\melee_response",
    "weapons\\needler\\shock wave",
    "weapons\\needler\\explosion",
    "weapons\\needler\\detonation damage",
    "weapons\\needler\\impact damage",
    "weapons\\needler\\trigger",
    "weapons\\ball\\melee",
    "weapons\\ball\\melee_response",
    "weapons\\flag\\melee",
    "weapons\\flag\\melee_response",
    "vehicles\\c gun turret\\mp bolt",
    "globals\\falling",
    "globals\\distance",
    "globals\\vehicle_hit_environment",
    "globals\\vehicle_killed_unit",
    "globals\\vehicle_collision",
    "globals\\flaming_death",

    -- equipment --
    "powerups\\active camouflage",
    "powerups\\health pack",
    "powerups\\over shield",
    "powerups\\double speed",
    "powerups\\full-spectrum vision",
    "weapons\\frag grenade\\frag grenade",
    "weapons\\plasma grenade\\plasma grenade",
    "powerups\\assault rifle ammo\\assault rifle ammo",
    "powerups\\needler ammo\\needler ammo",
    "powerups\\pistol ammo\\pistol ammo",
    "powerups\\rocket launcher ammo\\rocket launcher ammo",
    "powerups\\shotgun ammo\\shotgun ammo",
    "powerups\\sniper rifle ammo\\sniper rifle ammo",
    "powerups\\flamethrower ammo\\flamethrower ammo",

    -- vehicles --
    "vehicles\\warthog\\mp_warthog",
    "vehicles\\ghost\\ghost_mp",
    "vehicles\\rwarthog\\rwarthog",
    "vehicles\\banshee\\banshee_mp",
    "vehicles\\scorpion\\scorpion_mp",
    "vehicles\\c gun turret\\c gun turret_mp",

    -- weapons --
    "weapons\\assault rifle\\assault rifle",
    "weapons\\ball\\ball",
    "weapons\\flag\\flag",
    "weapons\\flamethrower\\flamethrower",
    "weapons\\gravity rifle\\gravity rifle",
    "weapons\\needler\\mp_needler",
    "weapons\\pistol\\pistol",
    "weapons\\plasma pistol\\plasma pistol",
    "weapons\\plasma rifle\\plasma rifle",
    "weapons\\plasma_cannon\\plasma_cannon",
    "weapons\\rocket launcher\\rocket launcher",
    "weapons\\shotgun\\shotgun",
    "weapons\\sniper rifle\\sniper rifle",
    "weapons\\energy sword\\energy sword",
}

api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
end

function IsStock(TAG)
    for i = 1, #stock_tags do
        if (TAG == stock_tags[i]) then
            return true
        end
    end
    return false
end

function OnGameStart()

    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)

    cprint("!jpt", 10)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657) then
            cprint('{"' .. tag_name:gsub("\\", "\\\\") .. '"},')
        end
    end
    cprint(" ")

    cprint("eqip", 10)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1701931376 and not IsStock(tag_name)) then
            cprint('{"' .. tag_name:gsub("\\", "\\\\") .. '"},')
        end
    end
    cprint(" ")

    cprint("vehicles", 10)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1986357353 and not IsStock(tag_name)) then
            cprint('{"' .. tag_name:gsub("\\", "\\\\") .. '"},')
        end
    end
    cprint(" ")

    cprint("weap", 10)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and not IsStock(tag_name)) then
            cprint('{"' .. tag_name:gsub("\\", "\\\\") .. '"},')
        end
    end
    cprint(" ")

    cprint("proj", 10)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and not IsStock(tag_name)) then
            cprint('{"' .. tag_name:gsub("\\", "\\\\") .. '"},')
        end
    end
end

function OnScriptUnload()
    -- N/A
end