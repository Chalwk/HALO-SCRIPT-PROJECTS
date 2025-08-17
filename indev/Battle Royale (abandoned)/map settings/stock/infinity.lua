return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = 9.308,
        y = -64.082,
        z = 7.787,
        min = 5, -- default (5 world/units)
        max = 100 -- default (100 world/units)
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
        { 4.081, -167.821, 12.448, 0.501, 35 },
        { -12.391, -164.378, 12.624, 0.907, 35 },
        { -10.904, -146.458, 12.821, 5.708, 35 },
        { -5.572, -124.067, 11.877, 5.121, 35 },
        { 11.375, -126.077, 11.551, 4.294, 35 },
        { 16.243, -148.273, 12.625, 2.744, 35 },
        { 2.336, -166.235, 14.947, 2.353, 35 },
        { 5.383, -136.617, 14.843, 4.212, 35 },
        { -1.335, -132.617, 15.970, 5.278, 35 },
        { 2.459, -155.217, 15.970, 2.166, 35 },
        { -0.795, -153.062, 21.651, 0.473, 35 },

        --- blue base:
        { 4.507, 51.192, 9.504, 4.275, 35 },
        { -10.545, 51.815, 10.018, 5.276, 35 },
        { -15.739, 36.659, 11.093, 2.498, 35 },
        { 14.669, 31.260, 9.996, 2.216, 35 },
        { 12.045, 20.483, 10.188, 2.313, 35 },
        { 8.287, 6.652, 10.050, 2.188, 35 },
        { -7.629, 7.226, 10.195, 0.886, 35 },
        { -12.258, 28.809, 10.942, 0.623, 35 },
        { -6.592, 19.711, 12.959, 1.046, 35 },
        { 0.084, 38.310, 14.086, 4.263, 35 },
        { -3.669, 38.311, 14.086, 5.197, 35 },
        { -3.069, 36.074, 19.767, 5.883, 35 },

        --- random locations:
        { -28.774, -145.962, 11.885, 2.425, 35 },
        { -42.319, -125.947, 11.699, 2.911, 35 },
        { -53.721, -122.606, 12.815, 1.780, 35 },
        { -58.222, -98.258, 12.937, 0.307, 35 },
        { -41.114, -75.362, 12.272, 4.787, 35 },
        { -42.359, -96.192, 14.220, 4.077, 35 },
        { -35.843, -71.771, 12.267, 0.208, 35 },
        { -24.512, -60.284, 11.970, 5.541, 35 },
        { -6.793, -51.785, 11.552, 5.990, 35 },
        { 9.384, -56.822, 8.251, 0.769, 35 },
        { 10.682, -73.342, 8.369, 5.902, 35 },
        { 28.429, -67.261, 11.065, 2.905, 35 },
        { 15.024, -68.514, 14.585, 2.372, 35 },
        { 13.921, -60.486, 14.510, 4.562, 35 },
        { 52.061, -83.814, 10.829, 3.638, 35 },
        { 63.414, -101.292, 12.831, 2.879, 35 },
        { 46.126, -113.208, 9.981, 4.741, 35 },
        { 44.396, -133.372, 11.150, 4.064, 35 },
        { 28.519, -152.769, 12.366, 1.096, 35 },
        { -36.669, -42.490, 11.311, 4.953, 35 },
        { -52.389, -32.298, 11.052, 2.093, 35 },
        { -43.956, -19.641, 6.967, 1.601, 35 },
        { -42.300, 1.042, 10.652, 4.395, 35 },
        { -60.690, -15.756, 11.671, 1.435, 35 },
        { -33.376, 27.249, 9.210, 1.135, 35 },
        { 39.697, 34.121, 9.824, 4.828, 35 },
        { 51.777, -2.901, 9.846, 2.406, 35 },
        { 55.892, -14.275, 10.076, 3.141, 35 },
        { 58.041, -6.148, 10.015, 0.009, 35 },
        { 65.438, -26.025, 11.293, 2.950, 35 },
        { 46.318, -23.587, 10.324, 1.236, 35 },
        { 48.839, -46.622, 10.536, 3.303, 35 },
        { 33.791, -48.477, 12.070, 3.424, 35 },
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
            ['weapons\\flag\\flag'] = 0.028,
            ['weapons\\ball\\ball'] = 0.028,
            ['weapons\\pistol\\pistol'] = 0.036,
            ['weapons\\plasma pistol\\plasma pistol'] = 0.036,
            ['weapons\\needler\\mp_needler'] = 0.042,
            ['weapons\\plasma rifle\\plasma rifle'] = 0.042,
            ['weapons\\shotgun\\shotgun'] = 0.047,
            ['weapons\\assault rifle\\assault rifle'] = 0.061,
            ['weapons\\flamethrower\\flamethrower'] = 0.073,
            ['weapons\\sniper rifle\\sniper rifle'] = 0.075,
            ['weapons\\plasma_cannon\\plasma_cannon'] = 0.098,
            ['weapons\\rocket launcher\\rocket launcher'] = 0.104
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
            ['weapons\\plasma pistol\\plasma pistol'] = 1.0,
            ['weapons\\plasma rifle\\plasma rifle'] = 1.2,
            ['weapons\\assault rifle\\assault rifle'] = 1.4,
            ['weapons\\pistol\\pistol'] = 4.10,
            ['weapons\\needler\\mp_needler'] = 4.20,
            ['weapons\\flamethrower\\flamethrower'] = 7.05,
            ['weapons\\shotgun\\shotgun'] = 8.0,
            ['weapons\\sniper rifle\\sniper rifle'] = 23.0,
            ['weapons\\plasma_cannon\\plasma_cannon'] = 25.0,
            ['weapons\\rocket launcher\\rocket launcher'] = 40.0,
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
            [2] = {
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
                    ['weapons\\frag grenade\\explosion'] = { 5, 0.5 },
                    ['weapons\\plasma grenade\\explosion'] = { 5, 0.5 },
                    ['weapons\\plasma grenade\\attached'] = { 10, 0.5 }
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
                    ['weapons\\plasma pistol\\plasma pistol'] = { 100 },
                    ['weapons\\plasma rifle\\plasma rifle'] = { 100 },
                    ['weapons\\assault rifle\\assault rifle'] = { 60, 180 },
                    ['weapons\\pistol\\pistol'] = { 12, 48 },
                    ['weapons\\needler\\mp_needler'] = { 20, 60 },
                    ['weapons\\flamethrower\\flamethrower'] = { 100, 200 },
                    ['weapons\\shotgun\\shotgun'] = { 12, 12 },
                    ['weapons\\sniper rifle\\sniper rifle'] = { 4, 8 },
                    ['weapons\\plasma_cannon\\plasma_cannon'] = { 100 },
                    ['weapons\\rocket launcher\\rocket launcher'] = { 2, 2 }
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
                    -- Format: { [type] = {damage multiplier, label}, ...}
                    -- Placeholders: $ammo
                    [1] = { 0, '$ammoX normal bullets' },
                    [2] = { 1.5, '$ammoX armour piercing bullets' },
                    [3] = { 5, '$ammoX explosive bullets' },
                    [4] = { 100, '$ammoX golden bullets' }
                },
                -- Format: [tag name] = clip size
                clip_sizes = {
                    ['weapons\\plasma pistol\\plasma pistol'] = 100,
                    ['weapons\\plasma rifle\\plasma rifle'] = 100,
                    ['weapons\\assault rifle\\assault rifle'] = 60,
                    ['weapons\\pistol\\pistol'] = 12,
                    ['weapons\\needler\\mp_needler'] = 20,
                    ['weapons\\flamethrower\\flamethrower'] = 100,
                    ['weapons\\shotgun\\shotgun'] = 12,
                    ['weapons\\sniper rifle\\sniper rifle'] = 4,
                    ['weapons\\plasma_cannon\\plasma_cannon'] = 100,
                    ['weapons\\rocket launcher\\rocket launcher'] = 2
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
                ['powerups\\full-spectrum vision'] = {

                    -- Format: { x, y, z, respawn time (in seconds) }
                    -- example locations:
                    -- {0,0,0,0},
                    -- {0,0,0,0}

                    { 12.513, 39.392, 12.669, 30 },
                    { 0.229, 28.190, 24.594, 35 },
                    { 6.364, 8.504, 10.471, 40 },
                    { 20.229, -83.012, 29.118, 45 },
                    { -16.745, -46.700, 29.120, 30 },
                    { 10.142, -50.649, 9.477, 35 },
                    { 10.047, -75.187, 8.952, 40 },
                    { -44.981, -91.199, 15.785, 45 },
                    { -58.241, -100.572, 14.999, 30 },
                    { -47.338, -138.324, 14.053, 35 },
                    { -6.790, -159.883, 15.671, 40 },
                    { -1.331, -145.152, 26.547, 45 },
                    { 36.080, -143.517, 12.011, 30 },
                    { 56.147, -141.789, 27.003, 35 },
                }
            }
        },

        --- Random weapon/power up spawns:
        -- Format: ['tag class'] = { ['tag name'] = { { x, y, z, respawn time (in seconds)}, ... } }
        objects = {

            ['weap'] = {
                ['weapons\\assault rifle\\assault rifle'] = {
                    -- example locations:
                    -- {0,0,0,0},
                    -- {0,0,0,0}
                },
                ['weapons\\flamethrower\\flamethrower'] = {},
                ['weapons\\pistol\\pistol'] = {},
                ['weapons\\plasma pistol\\plasma pistol'] = {},
                ['weapons\\needler\\mp_needler'] = {},
                ['weapons\\plasma rifle\\plasma rifle'] = {},
                ['weapons\\shotgun\\shotgun'] = {},
                ['weapons\\sniper rifle\\sniper rifle'] = {},
                ['weapons\\plasma_cannon\\plasma_cannon'] = {},
                ['weapons\\rocket launcher\\rocket launcher'] = {},
                ['weapons\\sniper rifle\\sniper rifle'] = {},
            },

            ['eqip'] = {
                ['powerups\\flamethrower ammo\\flamethrower ammo'] = {},
                ['powerups\\shotgun ammo\\shotgun ammo'] = {},
                ['powerups\\sniper rifle ammo\\sniper rifle ammo'] = {},
                ['powerups\\active camouflage'] = {},
                ['powerups\\health pack'] = {},
                ['powerups\\over shield'] = {},
                ['powerups\\assault rifle ammo\\assault rifle ammo'] = {},
                ['powerups\\needler ammo\\needler ammo'] = {},
                ['powerups\\rocket launcher ammo\\rocket launcher ammo'] = {},
                ['weapons\\frag grenade\\frag grenade'] = {},
                ['weapons\\plasma grenade\\plasma grenade'] = {},
            }
        }
    },

    --
    -- Do not touch unless you know what you're doing:
    --

    --- Projectile tag used by Nuke and explosive bullets (proj):
    -- This projectile will be used for explosive bullets.
    -- This projectile is also used to determine if a player is using a rocket launcher (for the nuke).
    rocket_projectile_tag = 'weapons\\rocket launcher\\rocket',

    --- Rocket launcher weapon tag (weap):
    -- Used to assign a rocket launcher to a player (for nuke):
    rocket_launcher_weapon = 'weapons\\rocket launcher\\rocket launcher',

    --- Grenade launcher projectile tag (eqip):
    -- Used by Grenade Launcher feature.
    frag_grenade_projectile = 'weapons\\frag grenade\\frag grenade',

    --- Tag addresses used by Nuke feature (proj, jpt):
    -- Nuke explosions are simulated with a tank shell projectile and explosion.
    tank_shell_projectile = 'vehicles\\scorpion\\tank shell',
    tank_shell_jpt_tag = 'vehicles\\scorpion\\shell explosion',

    --- Overshield tag address (eqip):
    overshield_equipment = 'powerups\\over shield',

    --- Tag addresses of covenant (energy) weapons (weap):
    -- Set to false to ignore.
    _energy_weapons_ = {
        ['weapons\\plasma rifle\\plasma rifle'] = true,
        ['weapons\\plasma_cannon\\plasma_cannon'] = true,
        ['weapons\\plasma pistol\\plasma pistol'] = true
    }
}