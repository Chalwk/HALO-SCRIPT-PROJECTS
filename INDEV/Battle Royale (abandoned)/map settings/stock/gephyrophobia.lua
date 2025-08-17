return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = 26.819,
        y = -72.275,
        z = -20.316,
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
        { 31.780, -111.427, -15.633, 3.125, 20 },
        { 21.657, -111.231, -15.633, 0.005, 20 },
        { 21.722, -117.521, -17.043, 0.007, 20 },
        { 32.126, -117.580, -17.043, 3.139, 20 },
        { 33.505, -124.130, -15.895, 1.606, 20 },
        { 19.627, -124.203, -15.897, 1.596, 20 },
        { 24.595, -124.873, -15.628, 1.165, 20 },
        { 29.636, -124.496, -15.629, 2.155, 20 },

        --- blue base:
        { 34.464, -20.380, -15.900, 4.726, 20 },
        { 20.190, -20.291, -15.894, 4.711, 20 },
        { 24.557, -19.543, -15.627, 5.089, 20 },
        { 29.374, -19.382, -15.628, 4.340, 20 },
        { 31.809, -27.241, -17.043, 3.102, 20 },
        { 21.372, -26.969, -17.043, 0.021, 20 },
        { 30.479, -25.007, -15.633, 4.083, 20 },
        { 22.868, -24.569, -15.633, 5.543, 20 },

        --- random locations:
        { 19.181, -101.108, -14.474, 2.156, 20 },
        { 10.133, -93.645, -14.474, 5.600, 20 },
        { 18.369, -93.752, -14.474, 4.122, 20 },
        { 14.212, -85.903, -14.323, 1.579, 20 },
        { 18.357, -79.251, -12.712, 2.121, 20 },
        { 14.433, -67.856, -12.712, 1.596, 20 },
        { 14.381, -53.961, -14.474, 1.559, 20 },
        { 17.405, -45.012, -14.474, 4.352, 20 },
        { 31.085, -52.186, -18.326, 4.254, 20 },
        { 23.111, -52.379, -18.326, 5.387, 20 },
        { 26.875, -66.208, -20.316, 4.711, 20 },
        { 26.809, -79.500, -20.316, 1.555, 20 },
        { 30.815, -92.317, -18.326, 2.283, 20 },
        { 22.764, -92.206, -18.326, 0.900, 20 },
        { -19.448, -107.245, -1.255, 0.721, 20 },
        { -22.418, -99.292, -1.255, 1.583, 20 },
        { -21.760, -70.852, -1.255, 0.323, 20 },
        { -22.887, -59.808, -1.255, 0.130, 20 },
        { -26.136, -49.140, -1.255, 6.125, 20 },
        { -23.419, -38.092, -1.255, 5.715, 20 },
        { -18.068, -31.218, -1.255, 5.620, 20 },
        { 67.612, -39.931, -1.062, 3.837, 20 },
        { 71.014, -51.578, -1.062, 4.781, 20 },
        { 70.861, -65.220, -1.062, 4.479, 20 },
        { 67.505, -72.440, -1.062, 2.461, 20 },
        { 67.438, -76.000, -1.062, 3.954, 20 },
        { 70.393, -81.104, -1.062, 4.900, 20 },
        { 71.472, -91.717, -1.062, 2.416, 20 },
        { 70.117, -102.430, -1.062, 2.276, 20 },
        { 67.340, -109.405, -1.062, 2.513, 20 },
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

                    { 26.906, -72.088, -10.067, 30 },
                    { 26.807, -93.023, -17.676, 35 },
                    { 26.934, -51.887, -17.676, 40 },
                    { 72.973, -70.886, 8.093, 45 },
                    { 31.099, -118.227, -17.676, 30 },
                    { 22.520, -116.893, -17.676, 35 },
                    { 26.819, -72.095, -16.346, 40 },
                    { 22.520, -26.311, -17.676, 45 },
                    { 31.099, -27.640, -17.676, 30 },
                    { 31.125, -72.305, 11.672, 35 },
                    { 22.408, -72.293, 11.672, 40 },
                    { -24.028, -84.697, -0.605, 45 },
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