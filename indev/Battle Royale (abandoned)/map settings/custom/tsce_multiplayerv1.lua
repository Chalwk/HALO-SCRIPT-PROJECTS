return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = 1.806,
        y = -15.757,
        z = 10.892,
        min = 5, -- default (5 world/units)
        max = 150 -- default (100 world/units)
    },


    --- Reduction rate:
    -- How often the safe zone will shrink (in seconds):
    -- Default (30)
    --
    duration = 30,


    --- Reduction amount:
    -- How much the safe zone will shrink by (in world units):
    -- Default (5)
    --
    shrink_amount = 5,


    --- End after:
    -- The game will end this many seconds after
    -- the safe zone has shrunk to its minimum size:
    -- Default (30)
    --
    end_after = 30,


    --- Required players:
    -- The minimum amount of players required to start the game:
    -- Default: (2)
    --
    required_players = 2,


    --- Game start delay:
    -- The amount of time (in seconds) to wait before starting the game:
    -- The start delay will not begin until the required players have joined.
    -- Default (30)
    --
    start_delay = 30,


    --- Lives:
    -- When a player's lives have been depleted, they will be eliminated from the game.
    -- An eliminated player will be forced to spectate the remaining players.
    -- Default: 3
    max_lives = 3,


    --- Health:
    -- The amount of health that players will spawn with.
    -- Full health = 1
    -- Default (1) = 100% health
    --
    health = 1,


    --- Health reduction:
    -- The amount of health that players will lose every second if they
    -- are outside the safe zone:
    -- Default (1/30) = 0.033% health every 1 second.
    -- The default value will kill the player in '30' seconds.
    --
    health_reduction = 1 / 30,


    --- Default running speed:
    -- Default (1)
    default_running_speed = 1,


    --- Sky spawn coordinates:
    -- When the game begins, players will be randomly assigned to one of these coordinates.
    -- Coordinates are in the format: {x, y, z, rotation, height}.
    -- The 'rotation' value is the direction that the player will face (in radians, not degrees).
    -- The 'height' value is the height above the ground that the player will spawn at.
    -- [Note]: Make sure there are at least 16 sets of coordinates.
    --
    sky_spawn_coordinates = {

        --- red base:
        { -77.675, -6.244, 13.695, 6.271, 20 },
        { -103.628, -15.827, 13.676, 6.273, 20 },
        { -77.810, -26.053, 13.695, 6.236, 20 },
        { -89.377, -3.657, 0.178, 5.823, 20 },
        { -84.937, -27.452, 0.153, 0.855, 20 },

        --- blue base:
        { 144.170, -25.646, 25.504, 3.809, 20 },
        { 144.306, -14.896, 25.504, 2.388, 20 },
        { 136.788, -36.380, 20.153, 2.437, 20 },
        { 136.751, -7.535, 20.136, 4.997, 20 },
        { 126.851, -16.115, 20.133, 6.109, 20 },
        { 126.582, -24.417, 20.133, 0.176, 20 },

        --- random locations:
        { 134.330, -32.701, 15.344, 2.902, 20 },
        { 132.329, -20.330, 14.035, 3.191, 20 },
        { 134.539, -7.473, 14.737, 3.996, 20 },
        { 108.956, -28.441, 13.449, 2.680, 20 },
        { 98.991, -10.425, 15.257, 0.564, 20 },
        { 99.191, -0.754, 20.909, 4.702, 20 },
        { 102.264, -20.573, 23.475, 1.242, 20 },
        { 116.074, -39.340, 24.623, 0.960, 20 },
        { 63.159, -25.815, 13.585, 3.393, 20 },
        { 40.699, -30.475, 13.220, 4.158, 20 },
        { 62.182, -48.633, 10.276, 4.553, 20 },
        { 35.652, -71.148, 7.599, 4.752, 20 },
        { 53.457, -93.681, 0.847, 3.286, 20 },
        { 15.307, -103.340, 2.145, 0.657, 20 },
        { -20.704, -58.845, 4.039, 5.419, 20 },
        { -61.322, -68.757, 1.240, 2.408, 20 },
        { -57.683, -58.814, 6.000, 5.388, 20 },
        { -37.537, -68.410, 8.248, 5.823, 20 },
        { -69.359, 7.105, 5.362, 3.114, 20 },
        { -79.311, 25.592, 0.817, 0.401, 20 },
        { -49.095, 20.836, 2.997, 5.807, 20 },
    },


    --- Weapon weight:
    --
    weight = {

        enabled = true,

        -- Combine:
        -- If true, your speed will be the sum of the
        -- combined weight of all the weapons in your inventory.
        -- Otherwise the speed will be based on weight of the weapon currently held.
        --
        combined = true,

        -- Format: ['tag name'] = weight reduction value
        weapons = {
            ["cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp"] = 0.042,
            ["cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops"] = 0.061,
            ["cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp"] = 0.042,
            ["cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp"] = 0.036,
            ["cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle"] = 0.042,
            ["cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun"] = 0.047,
            ["cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle"] = 0.075,
            ["cmt\\weapons\\evolved\\human\\dmr\\dmr"] = 0.061,
            ["cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle"] = 0.061,
            ["cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher"] = 0.104,
            ["dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle"] = 0.061,
            ["cmt\\weapons\\evolved\\covenant\\carbine\\carbine"] = 0.061,
            ["cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle"] = 0.061
        }
    },


    --- Weapon degradation (durability):
    -- Weapons will jam over time, as the durability decreases.
    -- They will progressively jam more often as they get closer to breaking.
    --
    -- When a weapon jams, it will not fire until it is unjammed.
    -- The player will have to unjam the weapon by pressing the melee button.
    --
    -- Durability will decrease when: You shoot, reload or melee.
    -- Durability will decrease faster when the weapon is fired and reloading, the former being the most significant.

    weapon_degradation = {

        -- If enabled, weapons will degrade over time.
        -- Default (true)
        --
        enabled = true,

        -- Maximum durability value:
        max_durability = 100,

        -- Jamming will never occur above this value:
        no_jam_before = 90,

        --- Durability decay rates:
        -- Format: ['tag name'] = durability decay rate
        -- Be careful not to set the decay rate too high!
        -- Max recommended decay rate: 50
        -- Do not set values lower than 0.1
        --
        -- Durability is decremented by rate/30 when shooting and (rate/5)/30 when reloading.
        -- The frequency of jamming is: (durability / 100) ^ 2 * 100
        --
        decay_rate = {
            ["cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp"] = 4.20,
            ["cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops"] = 1.4,
            ["cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp"] = 1.2,
            ["cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp"] = 4.10,
            ["cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle"] = 1.2,
            ["cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun"] = 8.0,
            ["cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle"] = 23.0,
            ["cmt\\weapons\\evolved\\human\\dmr\\dmr"] = 1.4,
            ["cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle"] = 1.4,
            ["cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher"] = 40.0,
            ["dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle"] = 1.4,
            ["cmt\\weapons\\evolved\\covenant\\carbine\\carbine"] = 1.4,
            ["cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle"] = 1.4
        }
    },


    --- Loot:
    -- The loot system will spawn items at pre-defined locations.
    -- [!] These locations may be randomised in a later update.
    --
    looting = {

        enabled = true,

        --- Spoils found in loot crates:
        -- Format: [chance] = { label = 'Spoil label (seen in game)' }
        -- To disable a spoil, set its chance to 0.
        -- [!] Do not touch the '_function_' value. It is used internally.
        --
        spoils = {

            --- BONUS LIFE:
            [1] = {
                label = '$lives Bonus lives',
                lives = 1,
                _function_ = 'giveLife'
            },

            --- NUKE:
            [10000000] = {
                label = 'Nuke',
                radius = 10, -- kills all players within this radius
                _function_ = 'giveNuke'
            },

            --- GRENADE LAUNCHER:
            -- Turns any weapon into a grenade launcher.
            [10] = {

                label = 'Grenade Launcher',

                -- How far (in world units) in front of the player the frag will spawn:
                distance = 1.5,

                -- Grenade launcher projectile velocity:
                velocity = 0.6,

                _function_ = 'giveGrenadeLauncher'
            },

            --- STUN GRENADES:
            -- Grenade stunning is simulated by reducing the player's speed.
            -- Placeholders: $frags, $plasmas
            [15] = {

                label = 'Stun Grenade(s)',

                -- How many of each grenade (frags, plasmas) to give:
                count = { 2, 2 },

                -- Format: { 'tag name', stun time, speed }
                grenade_tags = {
                    ['cmt\\weapons\\evolved_h1-spirit\\frag_grenade\\damage_effects\\frag_grenade_explosion'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved_h1-spirit\\plasma_grenade\\damage_effects\\plasma_grenade_explosion'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\human\\frag_grenade\\damage_effects\\frag_grenade_explosion'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\human\\frag_grenade\\damage_effects\\frag_grenade_bounce'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_explosion'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_attached'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_stick_flash'] = { 5, 0.5 },
                    ['cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_stick_hunter'] = { 5, 0.5 },
                },
                _function_ = 'giveStunGrenades'
            },

            --- WEAPON PARTS:
            [20] = {
                label = 'Weapon Parts! Use /repair',
                _function_ = 'giveWeaponParts'
            },

            --- RANDOM WEAPON:
            [25] = {
                label = 'Random Weapon',
                random_weapons = {
                    -- format: ['tag name'] = {primary ammo, reserve ammo}
                    ["cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp"] = { 20, 60 },
                    ["cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops"] = { 36, 36 },
                    ["cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp"] = { 100 },
                    ["cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp"] = { 12, 48 },
                    ["cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle"] = { 36, 60 },
                    ["cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun"] = { 12, 12 },
                    ["cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle"] = { 4, 8 },
                    ["cmt\\weapons\\evolved\\human\\dmr\\dmr"] = { 12, 48 },
                    ["cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle"] = { 60, 180 },
                    ["cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher"] = { 2, 2 },
                    ["dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle"] = { 36, 72 },
                    ["cmt\\weapons\\evolved\\covenant\\carbine\\carbine"] = { 18, 54 },
                    ["cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle"] = { 36, 72 },
                },
                _function_ = 'giveRandomWeapon'
            },

            --- SPEED BOOST:
            -- Format: { { multiplier, duration (in seconds) }, ... }
            -- Placeholders: $speed, $duration
            [30] = {
                label = '$speedX Speed Boost for $duration seconds',
                multipliers = { { 1.2, 10 }, { 1.3, 15 }, { 1.4, 20 }, { 1.5, 25 } },
                _function_ = 'giveSpeedBoost'
            },


            --- AMMO:
            -- When you pick up custom ammo, you will receive 1 clip of that ammo type.
            -- Ammo types:
            --  * 1 = normal bullets
            --  * 2 = armour piercing bullets
            --  * 3 = explosive bullets
            --  * 4 = golden bullets (one-shot kill)
            --
            [35] = {
                types = {
                    -- Format: { [type] = {multiplier, label}, ...}
                    -- Placeholders: $ammo
                    [1] = { 0, '$ammoX normal bullets' },
                    [2] = { 1.5, '$ammoX armour piercing bullets' },
                    [3] = { 5, '$ammoX explosive bullets' },
                    [4] = { 100, '$ammoX golden bullets' }
                },
                -- Format: [tag name] = clip size
                clip_sizes = {
                    ["cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp"] = 20,
                    ["cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops"] = 36,
                    ["cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp"] = 100,
                    ["cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp"] = 12,
                    ["cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle"] = 36,
                    ["cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun"] = 12,
                    ["cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle"] = 4,
                    ["cmt\\weapons\\evolved\\human\\dmr\\dmr"] = 12,
                    ["cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle"] = 60,
                    ["cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher"] = 2,
                    ["dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle"] = 36,
                    ["cmt\\weapons\\evolved\\covenant\\carbine\\carbine"] = 18,
                    ["cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle"] = 36
                },
                _function_ = 'giveAmmo'
            },

            --- FRAG GRENADES:
            -- Placeholders: $frags, $plasmas
            [40] = {
                label = '$fragsX frags, $plasmasX plasmas',
                count = { 4, 4 },
                _function_ = 'giveGrenades'
            },

            --- CAMOUFLAGE:
            -- Placeholders: $time
            [45] = {
                label = 'Camo for $time seconds',
                durations = { 30, 45, 60, 75, 90, 105, 120 },
                _function_ = 'giveCamo'
            },

            --- OVERSHIELD:
            -- Placeholders: $shield
            [50] = {
                label = '$shieldX Overshield',
                _function_ = 'giveOvershield'
            },

            --- HEALTH BOOST:
            -- Placeholders: $health
            [55] = {
                label = '$healthX Health Boost',
                levels = { 1.2, 1.3, 1.4, 1.5 },
                _function_ = 'giveHealthBoost'
            }
        },

        --- Loot crate locations:
        crates = {
            ['eqip'] = { -- do not touch 'eqip'!

                -- Object to represent 'loot crates':
                ['cmt\\powerups\\human\\ammo_box\\powerups\\rocket_launcher_ammo_box'] = {

                    -- Format: { x, y, z, respawn time (in seconds) }
                    -- example locations:
                    -- {0,0,0,0},
                    -- {0,0,0,0}

                    { -14.110, -64.008, 2.868, 30 },
                    { 5.792, -60.481, 5.350, 35 },
                    { -80.016, -49.869, 1.103, 40 },
                    { -75.188, -15.920, 1.938, 45 },
                    { -73.318, -0.299, 3.382, 30 },
                    { -55.399, 2.519, 8.831, 35 },
                    { -55.969, 15.841, 5.187, 40 },
                    { -10.380, 0.674, 11.208, 45 },
                    { 5.453, -29.187, 12.710, 30 },
                    { 13.498, -15.646, 10.905, 35 },
                    { -8.923, -35.221, 8.991, 40 },
                    { 64.416, -19.975, 19.624, 45 },
                    { 155.752, 12.054, 24.061, 30 },
                    { 44.747, -94.189, 1.419, 35 },
                    { 142.604, -18.447, 13.633, 40 },
                }
            }
        },

        --- Random weapon/power up spawns:
        -- Format: ['tag class'] = { ['tag name'] = { { x, y, z, respawn time (in seconds)}, ... } }
        objects = {

            ['weap'] = {
                ["cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp"] = {
                    -- example locations:
                    -- {0,0,0,0},
                    -- {0,0,0,0}
                },
                ["cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp"] = { },
                ["cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle"] = {},
                ["cmt\\weapons\\evolved\\human\\dmr\\dmr"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher"] = {},
                ["dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle"] = {},
                ["cmt\\weapons\\evolved\\covenant\\carbine\\carbine"] = {},
                ["cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle"] = {},
            },


            ['eqip'] = {
                ["cmt\\weapons\\evolved_h1-spirit\\plasma_grenade\\plasma_grenade"] = {},
                ["cmt\\powerups\\human\\ammo_pack\\powerups\\battle_rifle_ammo_pack"] = {},
                ["cmt\\weapons\\evolved_h1-spirit\\frag_grenade\\frag_grenade"] = {},
                ["cmt\\powerups\\human\\ammo_pack\\powerups\\pistol_ammo_pack"] = {},
                ["cmt\\powerups\\human\\ammo_box\\powerups\\shotgun_ammo_box"] = {},
                ["cmt\\powerups\\human\\ammo_box\\powerups\\sniper_rifle_ammo_box"] = {},
                ["cmt\\powerups\\human\\ammo_pack\\powerups\\dmr_ammo_pack"] = {},
                ["cmt\\powerups\\human\\ammo_pack\\powerups\\assault_rifle_ammo_pack"] = {},
                ["cmt\\powerups\\human\\ammo_box\\powerups\\rocket_launcher_ammo_box"] = {},
                ["cmt\\powerups\\covenant\\powerup_pack\\powerups\\over_shield"] = {},
                ["cmt\\powerups\\covenant\\powerup_pack\\powerups\\active_camouflage"] = {},
                ["cmt\\powerups\\human\\powerup_pack\\powerups\\health_pack"] = {},
                ["cmt\\weapons\\evolved\\human\\frag_grenade\\_frag_grenade_mp\\frag_grenade_mp"] = {},
                ["cmt\\weapons\\evolved\\covenant\\plasma_grenade\\_plasma_grenade_mp\\plasma_grenade_mp"] = {},
            }
        }
    },

    --
    -- Do not touch unless you know what you're doing:
    --

    --- Projectile tag used by Nuke and explosive bullets (proj):
    -- This projectile will be used for explosive bullets.
    -- This projectile is also used to determine if a player is using a rocket launcher (for the nuke).
    rocket_projectile_tag = 'cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\projectiles\\rocket_launcher_rocket\\rocket_launcher_rocket',

    --- Rocket launcher weapon tag (weap):
    -- Used to assign a rocket launcher to a player (for nuke):
    rocket_launcher_weapon = 'cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher',

    --- Grenade launcher projectile tag (eqip):
    frag_grenade_projectile = 'cmt\\weapons\\evolved\\human\\frag_grenade\\_frag_grenade_mp\\frag_grenade_mp',

    --- Tag addresses used by Nuke feature (proj, jpt):
    -- Nuke explosions are simulated with a tank shell projectile and explosion.
    tank_shell_projectile = 'cmt\\vehicles\\evolved_h1-spirit\\scorpion\\weapons\\scorpion_cannon\\projectiles\\scorpion_cannon_shell',
    tank_shell_jpt_tag = 'cmt\\vehicles\\evolved_h1-spirit\\scorpion\\weapons\\scorpion_cannon\\damage_effects\\scorpion_cannon_shell_explosion',

    --- Overshield tag address (eqip):
    overshield_equipment = 'cmt\\powerups\\covenant\\powerup_pack\\powerups\\over_shield',

    --- Tag addresses of covenant (energy) weapons (weap):
    -- Set to false to ignore.
    _energy_weapons_ = {
        ['cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp'] = true
    }
}