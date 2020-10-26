--[[
--=====================================================================================================--
Script Name: Loadout (Alpha 1.0), for SAPP (PC & CE)
Description: N/A

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local Loadout = {

    default_class = "Regeneration",
    starting_level = 1,

    -- Command Syntax: /level_cmd [number: 1-16] | */all | me <level>
    level_cmd = "level",
    level_cmd_permission = 1,
    level_cmd_permission_others = 4,

    -- Command Syntax: /credits_cmd [number: 1-16] | */all | me <credits>
    credits_cmd = "credits",
    credits_cmd_permission = 1,
    credits_cmd_permission_others = 4,

    -- Command Syntax: /bounty_cmd [number: 1-16] | */all | me <bounty>
    bounty_cmd = "bounty",
    bounty_cmd_permission = 1,
    bounty_cmd_permission_others = 4,

    -- if true, a player's credits will be able to fall into the negatives.
    allow_negatives = false,

    -- Enable or disable rank HUD:
    show_rank_hud = true,

    -- If a player types any command, the rank_hud info will disappear to prevent it from overwriting other information.
    -- How long should rank_hud info disappear for?
    rank_hud_pause_duration = 5,
    rank_hud = "Class: [%class%] Level: [%lvl%/%total_levels%] Credits: [%credits%/%req_exp%] Kills: [%kills%]",

    -- Command used to display information about your current class:
    info_command = "help",

    -- If a player types /info_command, how long should the information be on screen for? (in seconds)
    help_hud_duration = 5,

    -- Time (in seconds) a player must return to the server before their credits are reset.
    disconnect_cooldown = 120,

    -- If enabled, a player will receive spawn protection:
    death_sprees_bonus = true,

    messages = {
        [1] = "Class [%class%] Level: [%level%] Credits: [%credits%/%cr_req%]",
        [2] = "n/a",
        [3] = "You do not have permission to execute this command.",
        [4] = "You do not have permission to execute this command on other players",
        [5] = "%name% has a bounty of +%bounty% cR! - Kill to claim!",
        [6] = "%name% collected the bounty of %bounty% credits on %victim%!",
        [7] = {
            "Your level has been set to %level%",
            "Setting %name% to level %level%",
        },
        -- /level command feedback:
        [8] = "Invalid level!",

        --/credits command feedback:
        [9] = "Credits cannot be higher than %max%",
        [10] = {
            "Your credits have been set to %credits%",
            "Setting %name%'s credits to %credits%",
        },
        [11] = {
            "Adding +%bounty% bounty points. Total: %total_bounty%cR",
            "Adding +%bounty% bounty points to %name%. Total: %total_bounty%",
            "%target% has a bounty of %total_bounty%cR - Kill to Claim!",
        },
    },

    classes = {
        ["Regeneration"] = {
            command = "regen",
            info = {
                "Regeneration: Good for players who want the classic Halo experience. This is the Default.",
                "Level 1 - Health regenerates 3 seconds after shields recharge, at 20%/second.",
                "Level 2 - 2 Second Delay after shields recharge, at 25%/second. Unlocks Weapon 3.",
                "Level 3 - 1 Second Delay after shields recharge, at 30%/second. Melee damage is increased to 200%",
                "Level 4 - Health regenerates as soon as shields recharge, at 35%/second. You now spawn with full grenade count.",
                "Level 5 - Shields now charge 1 second sooner as well.",
            },
            levels = {
                [1] = {
                    -- Health will start regenerating this many seconds after shields are full:
                    regen_delay = 5,
                    -- Amount of health regenerated. (1 is full health)
                    increment = 0.0300,
                    -- Time (in seconds) between each incremental increase in health:
                    regen_rate = 1,
                    -- Credits required to level up:
                    until_next_level = 200,
                    -- GRENADES | <frag/plasma> (set to nil to use default grenade settings)
                    grenades = { 2, 0 },
                    -- WEAPONS | Slot 1, Slot 2 Slot 3, Slot 4
                    weapons = { 1, 7, nil, nil },
                    shield_regen_delay = nil,
                },
                [2] = {
                    regen_delay = 4,
                    increment = 0.0550,
                    regen_rate = 1,
                    until_next_level = 500,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                    shield_regen_delay = nil,
                },
                [3] = {
                    regen_delay = 3,
                    increment = 0.750,
                    regen_rate = 1,
                    until_next_level = 1000,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                    shield_regen_delay = nil,
                },
                [4] = {
                    regen_delay = 2,
                    increment = 0.950,
                    regen_rate = 1,
                    until_next_level = 2000,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                    shield_regen_delay = nil,
                },
                [5] = {
                    regen_delay = 0,
                    increment = 0.1100,
                    regen_rate = 1,
                    until_next_level = nil,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                    shield_regen_delay = 50,
                }
            },
        },

        ["Armor Boost"] = {
            command = "armor",
            info = {
                "Armor Boost: Good for players who engage vehicles or defend.",
                "Level 1 - 1.20x durability.",
                "Level 2 - 1.30x durability. Unlocks Weapon 3.",
                "Level 3 - 1.40x durability. Melee damage is increased to 200%",
                "Level 4 - 1.50x durability. You now spawn with full grenades.",
                "Level 5 - 1.55x durability. You are now immune to falling damage in addition to all other perks in this class.",
            },
            levels = {
                [1] = {
                    until_next_level = 200,
                    -- Set to 0 to use default damage resistance:
                    damage_resistance = 1.20,
                    -- Set to true to enable fall damage immunity:
                    fall_damage_immunity = false,
                    melee_damage_multiplier = 0,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, nil, nil },
                },
                [2] = {
                    until_next_level = 500,
                    damage_resistance = 1.30,
                    fall_damage_immunity = false,
                    melee_damage_multiplier = 0,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [3] = {
                    until_next_level = 1000,
                    damage_resistance = 1.40,
                    fall_damage_immunity = false,
                    melee_damage_multiplier = 200,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [4] = {
                    until_next_level = 2000,
                    damage_resistance = 1.50,
                    fall_damage_immunity = false,
                    melee_damage_multiplier = 200,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                },
                [5] = {
                    until_next_level = nil,
                    damage_resistance = 1.55,
                    fall_damage_immunity = true,
                    melee_damage_multiplier = 200,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                }
            }
        },

        ["Cloak"] = {
            command = "cloak",
            info = {
                "Partial Camo: Good for players who prefer stealth and quick kills or CQB.",
                "Level 1 - Camo works until you fire your weapon or take damage. Reinitialize delays are 3s/Weapon, 5s/Damage",
                "Level 2 - Reinitialize delays are 2s/Weapon, 5s/Damage. Unlocks Weapon 3.",
                "Level 3 - Reinitialize delays are 2s/Weapon, 3s/Damage. Melee damage is increased to 200%",
                "Level 4 - Reinitialize delays are 1s/Weapon, 3s/Damage. You now spawn with full grenades.",
                "Level 5 - Reinitialize delays are 0.5s/Weapon, 2s/Damage.",
            },
            levels = {
                [1] = {
                    duration = 10,
                    reinitialize_delay = 8,
                    until_next_level = 200,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, nil, nil },
                },
                [2] = {
                    duration = 15,
                    reinitialize_delay = 8,
                    until_next_level = 500,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [3] = {
                    duration = 20,
                    reinitialize_delay = 8,
                    until_next_level = 1000,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [4] = {
                    duration = 25,
                    reinitialize_delay = 0,
                    until_next_level = 2000,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                },
                [5] = {
                    duration = 25,
                    reinitialize_delay = 0,
                    until_next_level = nil,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                }
            }
        },

        ["Recon"] = {
            command = "recon",
            info = {
                "Recon: Good for players who don't use vehicles. Also good for capturing.",
                "Level 1 - Default speed raised to 1.5x. Sprint duration is 200%.",
                "Level 2 - Default speed raised to 1.6x. Sprint duration is 225%. Unlocks Weapon 3.",
                "Level 3 - Default speed raised to 1.7x. Sprint duration is 250%. Melee damage is increased to 200%.",
                "Level 4 - Default speed raised to 1.8x. Sprint duration is 300%. You now spawn with full grenades.",
                "Level 5 - Sprint speed is raised from 2.5x to 3x in addition to all other perks in this class.",
            },
            levels = {
                [1] = {
                    speed = 1.5,
                    speed_duration = 10,
                    until_next_level = 200,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, nil, nil },
                },
                [2] = {
                    speed = 1.6,
                    speed_duration = 10,
                    until_next_level = 500,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [3] = {
                    speed = 1.7,
                    speed_duration = 10,
                    until_next_level = 1000,
                    grenades = { 2, 0 },
                    weapons = { 1, 7, 2, nil },
                },
                [4] = {
                    speed = 1.8,
                    speed_duration = 10,
                    until_next_level = 2000,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                },
                [5] = {
                    speed = 2.5,
                    speed_duration = 10,
                    until_next_level = nil,
                    grenades = { 4, 4 },
                    weapons = { 1, 7, 2, nil },
                }
            }
        }
    },

    credits = {

        -- If true, players will receive bonus credits based on their victim's KDR
        use_pvp_bonus = true,
        pvp_bonus = function(EnemyKDR)
            local cr = tonumber((10 * EnemyKDR))
            return { cr, "+%credits% (PvP Bonus)" }
        end,

        -- Bonus credits for killing the flag carrier
        flag_carrier_kill_bonus = { 10, "+10cR (Flag Carrier Kill Bonus)" },

        -- Score (credits added):
        score = { 25, "+25cR (Flag Cap)" },

        head_shot = { 5, "+5cR (head shot!)" },

        -- Killed by Server (credits deducted):
        server = { -0, "0cR (Killed by Server)" },

        -- killed by guardians (credits deducted):
        guardians = { -5, "-5cR (Killed by Guardians)" },

        -- suicide (credits deducted):
        suicide = { -10, "-10cR (Suicide)" },

        -- betrayal (credits deducted):
        betrayal = { -15, "-15cR (Betrayal)" },

        -- Killed from the grave (credits added to killer)
        killed_from_the_grave = { 5, "+5cR (Killed From Grave)" },

        -- Bonus Credits given to someone when they capture the flag:
        bounty_on_score = 1,

        -- Bonus Credits per bounty level:
        bounty_bonus = 25,

        -- {consecutive kills, xp rewarded}
        spree = {
            { 5, 5, "+5cR (spree)", 1 },
            { 10, 10, "+10cR (spree)", 2 },
            { 15, 15, "+15cR (spree)", 3 },
            { 20, 20, "+20cR (spree)", 4 },
            { 25, 25, "+25cR (spree)", 5 },
            { 30, 30, "+30cR (spree)", 6 },
            { 35, 35, "+35cR (spree)", 7 },
            { 40, 40, "+40cR (spree)", 8 },
            { 45, 45, "+45cR (spree)", 9 },
            -- Award 50 credits for every 5 kills at or above 50 and +10 bounty level
            { 50, 50, "+50cR (spree)", 10 },
        },

        -- kill-combo required, credits awarded
        multi_kill = {
            { 2, 8, "+8cR (multi-kill)" },
            { 3, 10, "+10cR (multi-kill)" },
            { 4, 12, "+12cR (multi-kill)" },
            { 5, 14, "+14cR (multi-kill)" },
            { 6, 16, "+16cR (multi-kill)" },
            { 7, 18, "+18cR (multi-kill)" },
            { 8, 20, "+20cR (multi-kill)" },
            { 9, 23, "+23cR (multi-kill)" },
            -- Award 25 credits every 2 kills at or above 10 kill-combos
            { 10, 25, "+25cR (multi-kill)" },
        },

        tags = {

            --
            -- tag {type, name, credits}
            --

            -- FALL DAMAGE --
            [1] = { "jpt!", "globals\\falling", -3, "-3cR (Fall Damage)" },
            [2] = { "jpt!", "globals\\distance", -4, "-4cR (Distance Damage)" },

            -- VEHICLE PROJECTILES --
            [3] = { "jpt!", "vehicles\\ghost\\ghost bolt", 7, "+7cR (Ghost Bolt)" },
            [4] = { "jpt!", "vehicles\\scorpion\\bullet", 6, "+6cR (Tank Bullet)" },
            [5] = { "jpt!", "vehicles\\warthog\\bullet", 6, "+6cR (Warthog Bullet)" },
            [6] = { "jpt!", "vehicles\\c gun turret\\mp bolt", 7, "+7cR (Turret Bolt)" },
            [7] = { "jpt!", "vehicles\\banshee\\banshee bolt", 7, "+7cR (Banshee Bolt)" },
            [8] = { "jpt!", "vehicles\\scorpion\\shell explosion", 10, "+10cR (Tank Shell)" },
            [9] = { "jpt!", "vehicles\\banshee\\mp_fuel rod explosion", 10, "+10cR (Banshee Fuel-Rod Explosion)" },

            -- WEAPON PROJECTILES --
            [10] = { "jpt!", "weapons\\pistol\\bullet", 50, "+5cR (Pistol Bullet)" },
            [11] = { "jpt!", "weapons\\shotgun\\pellet", 6, "+6cR (Shotgun Pallet)" },
            [12] = { "jpt!", "weapons\\plasma rifle\\bolt", 4, "+4cR (Plasma Rifle Bolt)" },
            [13] = { "jpt!", "weapons\\needler\\explosion", 8, "+8cR (Needler Explosion)" },
            [14] = { "jpt!", "weapons\\plasma pistol\\bolt", 4, "+4cR (Plasma Bolt)" },
            [15] = { "jpt!", "weapons\\assault rifle\\bullet", 5, "+5cR (Assault Rifle Bullet)" },
            [16] = { "jpt!", "weapons\\needler\\impact damage", 4, "+4cR (Needler Impact Damage)" },
            [17] = { "jpt!", "weapons\\flamethrower\\explosion", 5, "+5cR (Flamethrower)" },
            [18] = { "jpt!", "weapons\\rocket launcher\\explosion", 8, "+8cR (Rocket Launcher Explosion)" },
            [19] = { "jpt!", "weapons\\needler\\detonation damage", 3, "+3cR (Needler Detonation Damage)" },
            [20] = { "jpt!", "weapons\\plasma rifle\\charged bolt", 4, "+4cR (Plasma Rifle Bolt)" },
            [21] = { "jpt!", "weapons\\sniper rifle\\sniper bullet", 6, "+6cR (Sniper Rifle Bullet)" },
            [22] = { "jpt!", "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion", 8, "+8cR (Plasma Cannon Explosion)" },

            -- GRENADES --
            [23] = { "jpt!", "weapons\\frag grenade\\explosion", 8, "+8cR (Frag Explosion)" },
            [24] = { "jpt!", "weapons\\plasma grenade\\attached", 7, "+7cR (Plasma Grenade - attached)" },
            [25] = { "jpt!", "weapons\\plasma grenade\\explosion", 5, "+5cR (Plasma Grenade explosion)" },

            -- MELEE --
            [26] = { "jpt!", "weapons\\flag\\melee", 5, "+5cR (Melee: Flag)" },
            [27] = { "jpt!", "weapons\\ball\\melee", 5, "+5cR (Melee: Ball)" },
            [28] = { "jpt!", "weapons\\pistol\\melee", 4, "+4cR (Melee: Pistol)" },
            [29] = { "jpt!", "weapons\\needler\\melee", 4, "+4cR (Melee: Needler)" },
            [30] = { "jpt!", "weapons\\shotgun\\melee", 5, "+5cR (Melee: Shotgun)" },
            [31] = { "jpt!", "weapons\\flamethrower\\melee", 5, "+5cR (Melee: Flamethrower)" },
            [32] = { "jpt!", "weapons\\sniper rifle\\melee", 5, "+5cR (Melee: Sniper Rifle)" },
            [33] = { "jpt!", "weapons\\plasma rifle\\melee", 4, "+4cR (Melee: Plasma Rifle)" },
            [34] = { "jpt!", "weapons\\plasma pistol\\melee", 4, "+4cR (Melee: Plasma Pistol)" },
            [35] = { "jpt!", "weapons\\assault rifle\\melee", 4, "+4cR (Melee: Assault Rifle)" },
            [36] = { "jpt!", "weapons\\rocket launcher\\melee", 10, "+10cR (Melee: Rocket Launcher)" },
            [37] = { "jpt!", "weapons\\plasma_cannon\\effects\\plasma_cannon_melee", 10, "+10cR (Melee: Plasma Cannon)" },

            -- VEHICLE COLLISION --
            vehicles = {
                collision = { "jpt!", "globals\\vehicle_collision" },
                { "vehi", "vehicles\\ghost\\ghost_mp", 5, "+5cR (Vehicle Squash: GHOST)" },
                { "vehi", "vehicles\\rwarthog\\rwarthog", 6, "+6cR (Vehicle Squash: R-Hog)" },
                { "vehi", "vehicles\\warthog\\mp_warthog", 7, "+7cR (Vehicle Squash: Warthog)" },
                { "vehi", "vehicles\\banshee\\banshee_mp", 8, "+8cR (Vehicle Squash: Banshee)" },
                { "vehi", "vehicles\\scorpion\\scorpion_mp", 10, "+10cR (Vehicle Squash: Tank)" },
                { "vehi", "vehicles\\c gun turret\\c gun turret_mp", 1000, "+1000R (Vehicle Squash: Turret)" },
            }
        }
    },

    --
    -- Advanced users only:
    --
    --

    weapon_tags = {
        -- ============= [ STOCK WEAPONS ] ============= --
        [1] = "weapons\\pistol\\pistol",
        [2] = "weapons\\sniper rifle\\sniper rifle",
        [3] = "weapons\\plasma_cannon\\plasma_cannon",
        [4] = "weapons\\rocket launcher\\rocket launcher",
        [5] = "weapons\\plasma pistol\\plasma pistol",
        [6] = "weapons\\plasma rifle\\plasma rifle",
        [7] = "weapons\\assault rifle\\assault rifle",
        [8] = "weapons\\flamethrower\\flamethrower",
        [9] = "weapons\\needler\\mp_needler",
        [10] = "weapons\\shotgun\\shotgun",

        -- ============= [ CUSTOM WEAPONS ] ============= --
        [11] = "some_random\\epic\\weapon",

        -- repeat the structure to add more weapon tags:
        [12] = "a tag\\will go\\here",
    },

    -- A message relay function temporarily removes the server prefix
    -- and will restore it to this when the relay is finished
    server_prefix = "**SAPP**",
    --
}

local time_scale = 1 / 30
local gmatch, gsub = string.gmatch, string.gsub
local lower, upper = string.lower, string.upper

local function Init()
    execute_command('sv_map_reset')

    Loadout.players = { }
    Loadout.gamestarted = true

    for i = 1, 16 do
        if player_present(i) then
            Loadout:InitPlayer(i)
        end
    end
end

function OnScriptLoad()

    register_callback(cb["EVENT_TICK"], "OnTick")

    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb["EVENT_SCORE"], "OnPlayerScore")

    register_callback(cb["EVENT_SPAWN"], "OnPlayerSpawn")
    register_callback(cb["EVENT_PRESPAWN"], "OnPlayerPreSpawn")

    register_callback(cb["EVENT_COMMAND"], "OnServerCommand")
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")

    if (get_var(0, "$gt") ~= "n/a") then
        Init()
    end
end

function OnScriptUnload()
    -- N/A
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then
        Init()
    end
end

function OnGameEnd()
    Loadout.gamestarted = false
end

function OnPlayerConnect(Ply)
    Loadout:InitPlayer(Ply)
end

function OnPlayerPreSpawn(Ply)
    local t = Loadout.players[Ply]
    if (t.switch_on_respawn[1]) then
        t.switch_on_respawn[1] = false
        t.class = t.switch_on_respawn[2]
    end
end

local function SetGrenades(DyN, Class, Level)
    local frag_count = Class.levels[Level].grenades[1]
    local plasma_count = Class.levels[Level].grenades[2]
    if (frag_count ~= nil) then
        write_word(DyN + 0x31E, frag_count)
    end
    if (plasma_count ~= nil) then
        write_word(DyN + 0x31F, plasma_count)
    end
end

function DelaySecQuat(Ply, Weapon, x, y, z)
    assign_weapon(spawn_object("weap", Weapon, x, y, z), Ply)
end

local floor, format = math.floor, string.format
local function SecondsToClock(seconds)
    seconds = tonumber(seconds)
    if (seconds <= 0) then
        return "00:00:00";
    else
        local hours, mins, secs
        hours = format("%02.f", floor(seconds / 3600));
        mins = format("%02.f", floor(seconds / 60 - (hours * 60)));
        secs = format("%02.f", floor(seconds - hours * 3600 - mins * 60));
        return hours .. ":" .. mins .. ":" .. secs
    end
end

function Loadout:OnTick()
    for i, v in pairs(self.players) do
        if (player_present(i)) then
            if player_alive(i) then

                local DyN = get_dynamic_player(i)
                if (DyN ~= 0) then

                    -- Check for level up:
                    self:UpdateLevel(i)

                    local level = v.levels[v.class].level
                    local current_class = self.classes[v.class]

                    if (v.assign) then
                        local coords = GetXYZ(DyN)
                        if (not coords.invehicle) then

                            local flag = self:hasObjective(DyN)
                            if (flag) then
                                v.assign_delay = true
                                v.assign_delay_timer = v.assign_delay_timer - time_scale
                                if (v.assign_delay_timer <= 0) then
                                    v.assign_delay = false
                                end
                            end

                            if (not v.assign_delay) then

                                if (flag) then
                                    drop_weapon(i)
                                end

                                v.assign = false
                                v.assign_delay_timer = 1
                                v.assign_delay = false

                                SetGrenades(DyN, current_class, level)
                                execute_command("wdel " .. i)
                                local weapon_table = current_class.levels[level].weapons
                                for Slot, WI in pairs(weapon_table) do
                                    if (Slot == 1 or Slot == 2) then
                                        assign_weapon(spawn_object("weap", self.weapon_tags[WI], coords.x, coords.y, coords.z), i)
                                    elseif (Slot == 3 or Slot == 4) then
                                        timer(250, "DelaySecQuat", i, self.weapon_tags[WI], coords.x, coords.y, coords.z)
                                    end
                                end
                            end
                        end
                    elseif (v.class == "Regeneration") then

                        local health = read_float(DyN + 0xE0)
                        local shield = read_float(DyN + 0xE4)

                        local delay = tonumber(current_class.levels[level].shield_regen_delay)
                        if (shield < 1 and delay ~= nil and v.regen_shield) then
                            v.regen_shield = false
                            write_word(DyN + 0x104, delay)
                        end

                        if (health < 1 and shield == 1) then
                            v.time_until_regen_begin = v.time_until_regen_begin - time_scale
                            if (v.time_until_regen_begin <= 0) and (not v.begin_regen) then
                                v.time_until_regen_begin = current_class.levels[level].regen_delay
                                v.begin_regen = true
                            elseif (v.begin_regen) then
                                v.regen_timer = v.regen_timer + time_scale
                                if (v.regen_timer >= current_class.levels[level].regen_rate) then
                                    v.regen_timer = 0
                                    write_float(DyN + 0xE0, health + current_class.levels[level].increment)
                                end
                            end
                        elseif (v.begin_regen and health >= 1) then
                            v.begin_regen = false
                            v.regen_timer = 0
                        end

                    elseif (v.class == "Cloak") then

                        local invisible = read_float(DyN + 0x37C)
                        local flashlight_state = read_bit(DyN + 0x208, 4)

                        -- Pause CAMO:
                        if (v.camo_pause) then
                            v.camo_pause_timer = v.camo_pause_timer + time_scale
                            if (v.camo_pause_timer >= current_class.levels[level].reinitialize_delay) then
                                v.camo_pause = false
                            end
                        else
                            local case = (v.flashlight_state ~= flashlight_state and flashlight_state == 1)
                            if (case) and (not v.active_camo) and (invisible == 0) then
                                v.active_camo = true
                            elseif (case) and (v.active_camo) and (invisible ~= 0) then
                                self:ResetCamo(i)
                            elseif (not case) and (v.active_camo) and (not v.camo_pause) then
                                execute_command("camo " .. i .. " 1")
                                v.active_camo_timer = v.active_camo_timer + time_scale
                                if (v.active_camo_timer >= current_class.levels[level].duration) then
                                    self:ResetCamo(i)
                                end
                            end
                            v.flashlight_state = flashlight_state
                        end
                        local shooting = read_float(DyN + 0x490)
                        if (shooting ~= v.shooting and shooting == 1) then
                            v.camo_pause = true
                        end
                        v.shooting = shooting

                    elseif (v.class == "Recon") then
                        local key = read_byte(DyN + 0x2A3)

                        -- RESET CASE --
                        --
                        local case1 = (key == 0 and v.key_released == 3)
                        local case2 = (v.button_press_delay >= .10) and (key == 0 or key == 4)
                        local case3 = (v.press_count == 1 and key == 0) and (v.button_press_delay >= .10)
                        local case4 = (v.button_press_delay >= .10) and (key == 0 and v.key_released == 2)

                        -- press 1:
                        if (key == 4 and v.press_count == 0 and v.key_released == 0) then
                            v.press_count = v.press_count + 1

                            -- release:
                        elseif (key == 0 and v.press_count == 1 and v.key_released == 0) then
                            v.key_released = 2

                            -- checking for press 2:
                        elseif (key == 0 and v.key_released == 2 and v.button_press_delay < .10) and (v.press_count == 1) then
                            v.button_press_delay = v.button_press_delay + time_scale

                            -- press 2:
                        elseif (key == 4 and v.key_released == 2 and v.button_press_delay < .10) and (v.press_count == 1) then
                            v.press_count = v.press_count + 1
                            v.key_released = 3

                            -- apply speed:
                        elseif (key == 4 and v.key_released == 3) then
                            v.speed_timer = v.speed_timer + time_scale
                            Loadout:cls(i, 25)
                            local time_remaining = SecondsToClock(current_class.levels[level].speed_duration - v.speed_timer)
                            self:Respond(i, "Boost Time: " .. time_remaining, rprint, 10)
                            if (v.speed_timer <= current_class.levels[level].speed_duration) then
                                execute_command("s" .. " " .. i .. " " .. current_class.levels[level].speed)
                            else
                                v.speed_timer = 0
                                v.speed_cooldown = 0
                                self:ResetSpeed(i)
                            end
                            -- reset
                        elseif (case1 or case2 or case3 or case4) then
                            self:ResetSpeed(i)
                            v.regen = true

                            -- begin regenerating time:
                        elseif (v.regen) then
                            v.speed_cooldown = v.speed_cooldown + time_scale
                            --local time_remaining = SecondsToClock(current_class.levels[level].speed_duration - v.speed_timer)
                            --self:Respond(i, "Boost Time: " .. time_remaining, rprint, 10)
                            if (math.floor(v.speed_cooldown % 4) == 3) and (v.speed_timer > 0) then
                                v.speed_timer = v.speed_timer - 1 / 30
                                if (v.speed_timer < 0) then
                                    v.speed_timer = 0
                                end
                            end
                        end
                    end

                    -- ======================================= --
                    -- HUD LOGIC --
                    -- ======================================= --
                    if (self.show_rank_hud) then
                        if (v.rank_hud_pause) then
                            v.rank_hud_pause_duration = v.rank_hud_pause_duration - time_scale
                            if (v.rank_hud_pause_duration <= 0) then
                                v.rank_hud_pause = false
                                v.rank_hud_pause_duration = self.rank_hud_pause_duration
                            end
                        elseif (self.gamestarted) then
                            self:PrintRank(i)
                        end
                    end
                    if (v.show_help and self.gamestarted) then
                        v.help_hud_duration = v.help_hud_duration - time_scale
                        self:PrintHelp(i, self.classes[v.class].info)
                        if (v.help_hud_duration <= 0) then
                            v.help_page = nil
                            v.show_help = false
                            v.help_hud_duration = self.help_hud_duration
                        end
                    end
                end
            end
        else

            -- todo:        Find alternative to this method:
            -- todo:        This wont work as another player could join within the cooldown period and
            -- todo:        be assigned the previous player's ID!
            -- Player's have X seconds to return to the server, otherwise their stats are cleared:
            --v.disconnect_timer = v.disconnect_timer - time_scale
            --if (v.disconnect_timer <= 0) then
            --    self.players[i] = nil
            --end
        end
    end
end

function Loadout:PauseRankHUD(Ply, Clear)
    local p = self.players[Ply]
    if (Clear) then
        self:cls(Ply, 25)
    end
    p.rank_hud_pause = true
    p.rank_hud_pause_duration = self.rank_hud_pause_duration
end

function Loadout:PrintHelp(Ply, InfoTab)
    Loadout:cls(Ply, 25)
    for i = 1, #InfoTab do
        Loadout:Respond(Ply, InfoTab[i], rprint, 10)
    end
end

function Loadout:PrintRank(Ply)
    local t = self.players[Ply]
    if (not t.rank_hud_pause) then

        local info = self:GetLevelInfo(Ply)

        self:cls(Ply, 25)
        local str = self.rank_hud

        local words = {
            ["%%credits%%"] = info.credits,
            ["%%lvl%%"] = info.level,
            ["%%class%%"] = info.class,
            ["%%req_exp%%"] = info.cr_req,
            ["%%total_levels%%"] = #self.classes[t.class].levels,
            ["%%kills%%"] = get_var(Ply, "$kills"),
        }
        for k, v in pairs(words) do
            str = gsub(str, k, v)
        end
        self:Respond(Ply, str, rprint, 10, _, true)
    end
end

local function CMDSplit(CMD)
    local Args, index = { }, 1
    for Params in gmatch(CMD, "([^%s]+)") do
        Args[index] = Params
        index = index + 1
    end
    return Args
end

function Loadout:OnServerCommand(Executor, Command)
    local Args = CMDSplit(Command)
    if (Args == nil) then
        return
    else

        if (Executor > 0) then

            Args[1] = lower(Args[1]) or upper(Args[1])

            local etab
            if (Executor > 0) then
                etab = self.players[Executor]
                self:PauseRankHUD(Executor, true)
            end

            for class, v in pairs(self.classes) do
                if (Args[1] == v.command) then
                    if (etab.class == class) then
                        self:Respond(Executor, "You already have " .. class .. " class", rprint, 12)
                    else
                        etab.switch_on_respawn[1] = true
                        etab.switch_on_respawn[2] = class
                        self:Respond(Executor, "You will switch to " .. class .. " when you respawn", rprint, 12)
                    end
                    return false
                end
            end

            local lvl = tonumber(get_var(Executor, "$lvl"))
            if (Args[1] == self.level_cmd) then
                if (lvl >= self.level_cmd_permission or (Executor == 0)) then
                    local pl = self:GetPlayers(Executor, Args)
                    if (pl) then
                        for i = 1, #pl do
                            local TargetID = tonumber(pl[i])
                            if (TargetID ~= Executor and lvl < self.level_cmd_permission_others) then
                                self:Respond(Executor, self.messages[4], rprint, 10)
                            elseif (Args[3]:match("^%d+$")) then

                                local t = self.players[TargetID]
                                local level = tonumber(Args[3])

                                if (level == t.levels[t.class].level) then
                                    self:Respond(Executor, "s2", rprint, 10)

                                elseif (level <= #self.classes[t.class].levels) then
                                    t.assign = true
                                    t.levels[t.class].level = level
                                    if (TargetID == Executor) then
                                        local s = gsub(self.messages[7][1], "%%level%%", level)
                                        self:Respond(TargetID, s, rprint, 10)
                                    else
                                        local s1 = gsub(self.messages[7][1], "%%level%%", level)
                                        self:Respond(TargetID, s1, rprint, 10)
                                        local s2 = gsub(gsub(self.messages[7][2], "%%level%%", level), "%%name%%", t.name)
                                        self:Respond(Executor, s2, rprint, 10)
                                    end
                                else
                                    self:Respond(Executor, self.messages[8], rprint, 10)
                                end
                            end
                        end
                    end
                else
                    self:Respond(Executor, self.messages[3], rprint, 10)
                end
                return false
            elseif (Args[1] == self.credits_cmd) then
                if (lvl >= self.credits_cmd_permission or (Executor == 0)) then
                    local pl = self:GetPlayers(Executor, Args)
                    if (pl) then
                        for i = 1, #pl do
                            local TargetID = tonumber(pl[i])
                            if (TargetID ~= Executor and lvl < self.credits_cmd_permission_others) then
                                self:Respond(Executor, self.messages[4], rprint, 10)
                            elseif (Args[3]:match("^%d+$")) then

                                local t = self.players[TargetID]
                                local credits = tonumber(Args[3])
                                local info = self:GetLevelInfo(TargetID)
                                local max_credits = self.classes[t.class].levels[info.level].until_next_level

                                if (credits <= max_credits or max_credits == nil) then

                                    t.levels[t.class].credits = t.levels[t.class].credits + credits

                                    if (TargetID == Executor) then
                                        local s = gsub(self.messages[10][1], "%%credits%%", credits)
                                        self:Respond(TargetID, s, rprint, 10)
                                    else
                                        local s1 = gsub(self.messages[10][1], "%%credits%%", credits)
                                        self:Respond(TargetID, s1, rprint, 10)
                                        local s2 = gsub(gsub(self.messages[10][2], "%%credits%%", credits), "%%name%%", t.name)
                                        self:Respond(Executor, s2, rprint, 10)
                                    end
                                else
                                    local s = gsub(self.messages[9], "%%max%%", max_credits)
                                    self:Respond(Executor, s, rprint, 10)
                                end
                            end
                        end
                    end
                else
                    self:Respond(Executor, self.messages[3], rprint, 10)
                end
                return false
            elseif (Args[1] == self.bounty_cmd) then
                if (lvl >= self.bounty_cmd_permission or (Executor == 0)) then
                    local pl = self:GetPlayers(Executor, Args)
                    if (pl) then
                        for i = 1, #pl do
                            local TargetID = tonumber(pl[i])
                            if (TargetID ~= Executor and lvl < self.bounty_cmd_permission_others) then
                                self:Respond(Executor, self.messages[4], rprint, 10)
                            elseif (Args[3]:match("^%d+$")) then

                                local t = self.players[TargetID]
                                local bounty = tonumber(Args[3])

                                t.bounty = t.bounty + bounty
                                local m = self.messages[11]
                                if (TargetID == Executor) then
                                    local s = gsub(gsub(m[1], "%%bounty%%", bounty), "%%total_bounty%%", t.bounty)
                                    self:Respond(TargetID, s, rprint, 10)
                                else

                                    local s1 = gsub(m[1], "%%bounty%%", bounty)
                                    self:Respond(TargetID, s1, rprint, 10)
                                    local s2 = gsub(gsub(gsub(m[2],
                                            "%%name%%", t.name),
                                            "%%bounty%%", bounty),
                                            "%%bounty_total%%", t.bounty)
                                    self:Respond(Executor, s2, rprint, 10)
                                end

                                local s = gsub(gsub(m[3], "%%total_bounty%%", t.bounty), "%%target%%", t.name)
                                self:Respond(Executor, s, say, 10, Executor, _)
                            end
                        end
                    end
                else
                    self:Respond(Executor, self.messages[3], rprint, 10)
                end
                return false
            elseif (Args[1] == self.info_command) then
                etab.help_page, etab.show_help = etab.class, true
                return false
            end
        end
    end
end

function OnPlayerScore(Ply)
    Loadout.players[Ply].bounty = self.players[Ply].bounty + self.credits.bounty_on_score
    Loadout:UpdateCredits(Ply, { Loadout.credits.score[1], Loadout.credits.score[2] })
end

function Loadout:ResetSpeed(Ply)
    self.players[Ply].regen = false
    self.players[Ply].press_count = 0
    self.players[Ply].key_released = 0
    self.players[Ply].button_press_delay = 0
    execute_command("s" .. " " .. Ply .. " 1")
end

function Loadout:ResetCamo(Ply, SpawnTrigger)
    self.players[Ply].shooting = 0
    self.players[Ply].active_camo = false
    self.players[Ply].flashlight_state = 0
    self.players[Ply].active_camo_timer = 0
    self.players[Ply].camo_pause = false
    self.players[Ply].camo_pause_timer = 0
    if (not SpawnTrigger) then
        execute_command("camo " .. Ply .. " 1")
    end
end

function Loadout:InitPlayer(Ply)
    self.players[Ply] = {
        levels = { },

        bounty = 0,
        class = self.default_class,
        name = get_var(Ply, "$name"),

        -- Recon Class --
        speed_timer = 0,
        speed_cooldown = 0,
        button_press_delay = 0,

        deaths = 0,

        camo_pause = false,
        camo_pause_timer = 0,

        -- OnPlayerDisconnect() --
        --disconnect_timer = self.disconnect_cooldown,

        switch_on_respawn = { false, nil },

        help_page = nil,
        show_help = false,
        help_hud_duration = self.help_hud_duration,

        rank_hud_pause = false,
        rank_hud_pause_duration = self.rank_hud_pause_duration,

    }
    for k, _ in pairs(self.classes) do
        self.players[Ply].levels[k] = {
            credits = 0,
            level = self.starting_level,
        }
    end
end

-- Returns and array: {exp, level}
function GetLvlInfo(Ply)
    local p = Loadout.players[Ply]
    return p.levels[p.class]
end

function OnPlayerSpawn(Ply)
    local t = Loadout.players[Ply]
    local info = Loadout:GetLevelInfo(Ply)

    -- Weapon Assignment Variables
    t.assign = true

    -- Health regeneration Variables --
    t.regen_timer = 0
    t.begin_regen = false

    t.head_shot = nil
    t.last_damage = nil
    t.regen_shield = false

    Loadout:ResetSpeed(Ply)
    Loadout:ResetCamo(Ply, true)

    t.time_until_regen_begin = Loadout.classes["Regeneration"].levels[info.level].regen_delay

    t.assign_delay = false
    t.assign_delay_timer = 1

    if (Loadout.death_sprees_bonus) then
        if (t.deaths >= 5 and t.deaths < 10) then
            powerup_interact(spawn_object("eqip", "powerups\\over shield"), Ply)
        elseif (t.deaths >= 10) then
            powerup_interact(spawn_object("eqip", "powerups\\over shield"), Ply)
            powerup_interact(spawn_object("eqip", "powerups\\active camouflage"), Ply)
        end
    end
end

local function GetTag(ObjectType, ObjectName)
    if type(ObjectType) == "string" then
        local Tag = lookup_tag(ObjectType, ObjectName)
        return Tag ~= 0 and read_dword(Tag + 0xC) or nil
    else
        return nil
    end
end

local function CheckDamageTag(DamageMeta)
    for _, d in pairs(Loadout.credits.tags) do
        local tag = GetTag(d[1], d[2])
        if (tag ~= nil) and (tag == DamageMeta) then
            return { d[3], d[4] }
        end
    end
    return 0
end

function Loadout:KillingSpree(Ply)
    local player = get_player(Ply)
    if (player ~= 0) then
        local t = self.credits.spree
        local k = read_word(player + 0x96)

        for _, v in pairs(t) do
            if (k == v[1]) or (k >= t[#t][1] and k % 5 == 0) then
                self:UpdateCredits(Ply, { v[2], v[3] })

                local bonus = self.credits.bounty_bonus + v[4]

                self.players[Ply].bounty = self.players[Ply].bounty + bonus

                local str = gsub(gsub(self.messages[5], "%%name%%", self.players[Ply].name), "%%bounty%%", self.players[Ply].bounty)
                self:Respond(_, str, say_all, 10)
            end
        end
    end
end

function Loadout:MultiKill(Ply)
    local player = get_player(Ply)
    if (player ~= 0) then
        local k = read_word(player + 0x98)
        local t = self.credits.multi_kill
        for _, v in pairs(t) do
            if (k == v[1]) or (k >= t[#t][1] and k % 2 == 0) then
                self:UpdateCredits(Ply, { v[2], v[3] })
            end
        end
    end
end

function Loadout:InVehicle(Ply)
    local DyN = get_dynamic_player(Ply)
    if (DyN ~= 0) then
        local VehicleID = read_dword(DyN + 0x11C)
        if (VehicleID ~= 0xFFFFFFFF) then
            local VehicleObject = get_object_memory(VehicleID)
            local name = GetVehicleTag(VehicleObject)
            if (name ~= nil) then
                return name
            end
        end
    end
    return false
end

function Loadout:cls(Ply, Count)
    Count = Count or 25
    for _ = 1, Count do
        rprint(Ply, " ")
    end
end

function Loadout:OnPlayerDeath(VictimIndex, KillerIndex)
    local killer, victim = tonumber(KillerIndex), tonumber(VictimIndex)

    local last_damage = self.players[victim].last_damage
    local kteam = get_var(killer, "$team")
    local vteam = get_var(victim, "$team")

    local server = (killer == -1)
    local guardians = (killer == nil)
    local suicide = (killer == victim)
    local pvp = ((killer > 0) and killer ~= victim)
    local betrayal = ((kteam == vteam) and killer ~= victim)

    if (pvp) then

        local v = self.players[victim]
        local k = self.players[killer]

        k.deaths = 0
        v.deaths = v.deaths + 1

        if (v.bounty > 0) then
            local str = self.messages[6]
            str = gsub(gsub(gsub(str, "%%name%%", k.name), "%%bounty%%", v.bounty), "%%victim%%", v.name)
            self:UpdateCredits(killer, { v.bounty, str })
        end

        self:MultiKill(killer)
        self:KillingSpree(killer)

        local DyN = get_dynamic_player(victim)
        if (DyN ~= 0) then
            if self:hasObjective(DyN) then
                self:UpdateCredits(killer, { self.credits.flag_carrier_kill_bonus[1], self.credits.flag_carrier_kill_bonus[2] })
            end
        end

        if (not player_alive(killer)) then
            self:UpdateCredits(killer, { self.credits.killed_from_the_grave[1], self.credits.killed_from_the_grave[2] })
        elseif (self.players[victim].head_shot) then
            self:UpdateCredits(killer, { self.credits.head_shot[1], self.credits.head_shot[2] })
        end

        -- Calculate PvP Bonus:
        if (self.credits.use_pvp_bonus) then
            local enemy_kills = tonumber(get_var(victim, "$kills"))
            local enemy_deaths = tonumber(get_var(victim, "$deaths"))
            local krd = (enemy_kills / enemy_deaths)
            local pvp_bonus = self.credits.pvp_bonus(krd)
            if (pvp_bonus[1] > 0) then
                local str = gsub(pvp_bonus[2], "%%credits%%", pvp_bonus[1])
                self:UpdateCredits(killer, { pvp_bonus[1], str })
            end
        end

        -- Vehicle check logic:
        local vehicle = self:InVehicle(killer)
        if (vehicle) then
            local t = self.credits.tags.vehicles
            for _, v in pairs(t) do
                -- validate vehicle tag:
                if (vehicle == v[2]) then
                    -- vehicle squash:
                    if (last_damage == GetTag(t.collision[1], t.collision[2])) then
                        return self:UpdateCredits(killer, { v[3], v[4] })
                    else
                        -- vehicle weapon:
                        return self:UpdateCredits(killer, CheckDamageTag(last_damage))
                    end
                end
            end
        end
        return self:UpdateCredits(killer, CheckDamageTag(last_damage))

    elseif (server) then
        if (last_damage == GetTag(self.credits.tags[1][1], self.credits.tags[1][2])) then
            self:UpdateCredits(victim, { self.credits.tags[1][3], self.credits.tags[1][4] })
        elseif (last_damage == GetTag(self.credits.tags[2][1], self.credits.tags[2][2])) then
            self:UpdateCredits(victim, { self.credits.tags[2][3], self.credits.tags[2][4] })
        else
            self:UpdateCredits(victim, { self.credits.server[1], self.credits.server[2] })
        end
    elseif (guardians) then
        self:UpdateCredits(victim, { self.credits.guardians[1], self.credits.guardians[2] })
    elseif (suicide) then
        self:UpdateCredits(victim, { self.credits.suicide[1], self.credits.suicide[2] })
    elseif (betrayal) then
        self:UpdateCredits(victim, { self.credits.betrayal[1], self.credits.betrayal[2] })
    else
        self:UpdateCredits(victim, CheckDamageTag(last_damage))
    end
end

function Loadout:GetLevelInfo(Ply)
    local t = self.players[Ply]

    local c = t.class
    local l = t.levels[c].level
    local cr = t.levels[c].credits

    local crR = self.classes[c].levels[l].until_next_level

    return { class = c, level = l, credits = cr, cr_req = crR }
end

function Loadout:UpdateLevel(Ply)
    local t = self.players[Ply]
    local cr_req = self.classes[t.class].levels[t.levels[t.class].level].until_next_level
    if (cr_req ~= nil and t.levels[t.class].credits >= cr_req) then

        t.levels[t.class].level = t.levels[t.class].level + 1
    end
end

function Loadout:UpdateCredits(Ply, Params)
    local t = self.players[Ply]
    t.levels[t.class].credits = t.levels[t.class].credits + Params[1]

    self:Respond(Ply, Params[2], rprint, 10)
    execute_command("score " .. Ply .. " " .. t.levels[t.class].credits)

    if (not self.allow_negatives) and (t.levels[t.class].credits < 0) then
        t.levels[t.class].credits = 0
        if (tonumber(get_var(Ply, "$score")) < 0) then
            execute_command('score ' .. Ply .. " 0")
        end
    end
end

function Loadout:IsMelee(MetaID)
    for i = 26, 37 do
        local Type, Name = self.credits.tags[i][1], self.credits.tags[i][2]
        if (MetaID == GetTag(Type, Name)) then
            return true
        end
    end
    return false
end

function Loadout:OnDamageApplication(VictimIndex, KillerIndex, MetaID, Damage, HitString, Backtap)
    local killer, victim = tonumber(KillerIndex), tonumber(VictimIndex)
    local hurt = true

    if player_present(victim) then

        local v = self.players[victim]
        local v_info = self:GetLevelInfo(victim)

        if (killer > 0) then

            local k = self.players[killer]
            local k_info = self:GetLevelInfo(killer)

            local HeadShot = OnDamageLookup(victim, killer)
            if (HeadShot ~= nil) then
                if (HitString == "head") then
                    v.head_shot = true
                else
                    v.head_shot = false
                end
            else
                v.head_shot = false
            end

            if (k.class == "Armor Boost") and (killer ~= victim) then
                if (not self:IsMelee(MetaID)) then
                    Damage = Damage - (10 * self.classes[k.class].levels[k_info.level].damage_resistance)
                else
                    Damage = Damage + (self.classes[k.class].levels[k_info.level].melee_damage_multiplier)
                end
                hurt = true
            elseif (v.class == "Cloak") then
                local DyN = get_dynamic_player(victim)
                if (DyN ~= 0) then
                    local invisible = read_float(DyN + 0x37C)
                    if (v.active_camo) and (invisible ~= 0) then
                        v.camo_pause = true
                    end
                end
            end

            k.last_damage = MetaID
        end

        if (v.class == "Armor Boost") and (self.classes[v.class].levels[v_info.level].fall_damage_immunity) then
            if (MetaID == self.credits.tags[1] or MetaID == self.credits.tags[2]) then
                hurt = false
            end
        end
        v.regen_shield = true
        v.last_damage = MetaID
        return hurt, Damage
    end
end

function Loadout:Respond(Ply, Message, Type, Color, Exclude, HUD)
    Color = Color or 10
    execute_command("msg_prefix \"\"")
    if (Ply == 0) then
        cprint(Message, Color)
    else

        if (not HUD and Ply) then
            self:PauseRankHUD(Ply)
        end

        if (not Exclude) then
            if (Type ~= say_all) then
                Type(Ply, Message)
            else
                Type(Message)
            end
        else
            for i = 1, 16 do
                if player_present(i) and (i ~= Ply) then
                    self:PauseRankHUD(i)
                    Type(i, Message)
                end
            end
        end
    end
    execute_command("msg_prefix \" " .. self.server_prefix .. "\"")
end

function Loadout:GetPlayers(Executor, Args)
    local pl = { }
    if (Args[2] == "me") then
        if (Executor ~= 0) then
            table.insert(pl, Executor)
        else
            self:Respond(Executor, "Please enter a valid player id", rprint, 10)
        end
    elseif (Args[2] ~= nil) and (Args[2]:match("^%d+$")) then
        if player_present(Args[2]) then
            table.insert(pl, Args[2])
        else
            self:Respond(Executor, "Player #" .. Args[2] .. " is not online", rprint, 10)
        end
    elseif (Args[2] == "all" or Args[2] == "*") then
        for i = 1, 16 do
            if player_present(i) then
                table.insert(pl, i)
            end
        end
        if (#pl == 0) then
            self:Respond(Executor, "There are no players online!", rprint, 10)
        end
    else
        self:Respond(Executor, "Invalid Command Syntax. Please try again!", rprint, 10)
    end
    return pl
end

function GetXYZ(DyN)
    local coords, x, y, z = { }

    local VehicleID = read_dword(DyN + 0x11C)
    if (VehicleID == 0xFFFFFFFF) then
        coords.invehicle = false
        x, y, z = read_vector3d(DyN + 0x5c)
    else
        coords.invehicle = true
        x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
    end

    coords.x, coords.y, coords.z = x, y, z
    return coords
end

function OnServerCommand(P, C)
    return Loadout:OnServerCommand(P, C)
end

function OnPlayerDeath(V, K)
    return Loadout:OnPlayerDeath(V, K)
end

function OnTick()
    return Loadout:OnTick()
end

function OnDamageApplication(V, K, M, D, H, B)
    return Loadout:OnDamageApplication(V, K, M, D, H, B)
end

function GetVehicleTag(Vehicle)
    if (Vehicle ~= nil and Vehicle ~= 0) then
        return read_string(read_dword(read_word(Vehicle) * 32 + 0x40440038))
    end
    return nil
end

function Loadout:hasObjective(DyN)
    for i = 0, 3 do
        local WeaponID = read_dword(DyN + 0x2F8 + 0x4 * i)
        if (WeaponID ~= 0xFFFFFFFF) then
            local Weapon = get_object_memory(WeaponID)
            if (Weapon ~= 0) then
                local tag_address = read_word(Weapon)
                local tag_data = read_dword(read_dword(0x40440000) + tag_address * 0x20 + 0x14)
                if (read_bit(tag_data + 0x308, 3) == 1) then
                    return true
                end
            end
        end
    end
    return false
end

--======================================================
--======================================================
-- Credits to H® Shaft for this function:
-- Taken from https://pastebin.com/edZ82aWn
function OnDamageLookup(ReceiverIndex, CauserIndex)
    local response
    if get_var(0, "$gt") ~= "n/a" then
        if (CauserIndex and ReceiverIndex ~= CauserIndex) then
            if (CauserIndex ~= 0) then
                local r_team = read_word(get_player(ReceiverIndex) + 0x20)
                local c_team = read_word(get_player(CauserIndex) + 0x20)
                if (r_team ~= c_team) then
                    local tag_address = read_dword(0x40440000)
                    local tag_count = read_word(0x4044000C)
                    for A = 0, tag_count - 1 do
                        local tag_id = tag_address + A * 0x20
                        if (read_dword(tag_id) == 1785754657) then
                            local tag_data = read_dword(tag_id + 0x14)
                            if (tag_data ~= nil) then
                                if (read_word(tag_data + 0x1C6) == 5) or (read_word(tag_data + 0x1C6) == 6) then
                                    if (read_bit(tag_data + 0x1C8, 1) == 1) then
                                        response = true
                                    else
                                        response = false
                                    end
                                end
                            end
                        end
                    end
                end
            else
                response = false
            end
        end
    end
    return response
end
--