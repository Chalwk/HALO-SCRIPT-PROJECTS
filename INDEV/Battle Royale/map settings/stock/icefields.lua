return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = -24.920,
        y = 33.416,
        z = 0.680,
        min = 5, -- default (5 world/units)
        max = 100 -- default (100 world/units)
    },


    --- Reduction rate:
    -- How often the safe zone will shrink (in seconds):
    -- Default (60)
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
        { 20.530, -26.365, 0.756, 5.190, 25 },
        { 29.136, -26.417, 0.734, 4.382, 25 },
        { 28.970, -17.990, 0.737, 1.925, 25 },
        { 24.772, -16.339, 0.761, 2.081, 25 },
        { 24.851, -22.085, 2.100, 6.265, 25 },
        { 14.390, -25.645, 0.783, 0.351, 25 },
        { 28.682, -8.171, 0.826, 4.366, 25 },

        --- blue base:
        { -73.649, 90.773, 0.787, 1.960, 25 },
        { -82.091, 90.775, 0.739, 1.201, 25 },
        { -77.863, 81.133, 0.775, 5.207, 25 },
        { -77.838, 86.560, 2.100, 3.151, 25 },
        { -82.519, 74.541, 0.772, 0.396, 25 },
        { -66.125, 85.180, 0.751, 2.979, 25 },
        { -77.834, 97.242, 1.167, 4.693, 25 },

        --- random locations:
        { -66.672, 70.649, 1.355, 5.643, 25 },
        { -64.324, 56.265, 0.939, 4.329, 25 },
        { -77.568, 53.483, 0.896, 0.690, 25 },
        { -71.054, 44.169, 0.786, 5.662, 25 },
        { -49.053, 28.480, 0.693, 0.381, 25 },
        { -40.017, 46.015, 0.680, 3.890, 25 },
        { -38.218, 22.356, 0.680, 0.680, 25 },
        { -13.385, 43.253, 0.680, 3.989, 25 },
        { -13.139, 18.679, 0.680, 0.589, 25 },
        { 4.520, 27.649, 0.741, 5.938, 25 },
        { 20.553, 19.636, 0.748, 2.663, 25 },
        { 24.900, 10.496, 0.904, 3.595, 25 },
        { 19.774, -2.620, 0.763, 5.417, 25 },
        { 17.437, -10.015, 0.910, 2.457, 25 },
        { -3.592, -4.341, 3.108, 2.937, 25 },
        { -26.051, 26.971, 9.007, 4.711, 25 },
        { -26.050, 37.997, 9.007, 1.576, 25 },
        { -30.354, 48.994, 8.685, 5.657, 25 },
        { -28.036, 68.951, 5.638, 4.906, 25 },
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
                    -- Format: { [type] = {multiplier, label}, ...}
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
                levels = { 2, 3 }, -- 2x, 3x
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

                    { -13.347, 24.438, 4.208, 30 },
                    { -12.433, 37.856, 4.916, 35 },
                    { -38.982, 42.028, 4.879, 40 },
                    { -44.885, 45.870, 10.307, 45 },
                    { -30.758, 48.153, 10.630, 30 },
                    { -31.732, 43.013, 12.687, 35 },
                    { -28.565, 3.513, 8.030, 40 },
                    { -6.863, -7.209, 4.912, 45 },
                    { 15.435, 8.551, 10.328, 30 },
                    { 17.688, -4.564, 8.032, 35 },
                    { 1.149, 5.775, 8.889, 40 },
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
    rocket_explosion_jpt_tag = 'weapons\\rocket launcher\\explosion',
    rocket_projectile_tag = 'weapons\\rocket launcher\\rocket',
    rocket_launcher_weapon = 'weapons\\rocket launcher\\rocket launcher',
    frag_grenade_projectile = 'weapons\\frag grenade\\frag grenade',

    -- Tag addresses of covenant (energy) weapons:
    _energy_weapons_ = {
        ['weapons\\plasma rifle\\plasma rifle'] = true,
        ['weapons\\plasma_cannon\\plasma_cannon'] = true,
        ['weapons\\plasma pistol\\plasma pistol'] = true
    }
}