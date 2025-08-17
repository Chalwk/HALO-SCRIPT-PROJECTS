return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = -30.237,
        y = 30.534,
        z = 14.270,
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
        { -30.272, -2.461, 9.416, 3.938, 35 },
        { -28.694, -11.998, 9.416, 2.567, 35 },
        { -37.937, -18.749, 9.160, 2.540, 35 },
        { -38.029, -9.644, 9.416, 4.336, 35 },
        { -38.125, -4.243, 9.416, 4.071, 35 },
        { -38.600, 2.089, 10.299, 4.119, 35 },
        { -35.211, -14.059, 4.861, 2.871, 35 },

        --- blue base:
        { 31.801, 23.153, 8.049, 5.371, 35 },
        { 36.878, 10.895, 8.049, 0.491, 35 },
        { 40.399, 19.095, 8.049, 1.398, 35 },
        { 40.767, 13.450, 8.049, 5.033, 35 },
        { 37.321, 32.209, 4.348, 5.437, 35 },
        { 41.885, 15.947, 4.813, 0.043, 35 },
        { 39.993, 7.351, 4.592, 0.640, 35 },

        --- random locations:
        { 55.978, 9.804, 1.607, 4.208, 35 },
        { 40.924, 45.187, 2.996, 0.598, 35 },
        { 28.536, 43.808, 3.737, 2.424, 35 },
        { 15.036, 53.079, 3.862, 4.173, 35 },
        { 11.130, 61.929, 1.881, 0.333, 35 },
        { 6.437, 57.963, 6.602, 1.758, 35 },
        { -30.108, 64.228, 3.085, 0.102, 35 },
        { -44.438, 45.171, 5.145, 2.327, 35 },
        { -57.438, 51.166, 2.886, 3.821, 35 },
        { -92.187, 10.471, 5.364, 6.005, 35 },
        { -73.362, 12.881, 1.538, 5.549, 35 },
        { -53.736, 7.222, 3.939, 3.581, 35 },
        { -46.247, 14.455, 7.926, 4.554, 35 },
        { -48.578, -23.611, 2.882, 2.799, 35 },
        { -16.357, -49.983, 1.949, 5.006, 35 },
        { -15.114, -33.192, 4.389, 5.985, 35 },
        { 16.200, -35.229, 5.599, 4.503, 35 },
        { 47.586, -36.576, 2.036, 5.257, 35 },
        { 41.308, -17.279, 3.130, 0.569, 35 },
        { 34.658, -6.568, 6.437, 5.187, 35 },
        { 5.278, 8.365, 12.207, 2.264, 35 },
        { -8.524, 12.696, 13.293, 0.887, 35 },
        { -30.730, 39.630, 16.619, 4.754, 35 },
        { -33.141, 44.392, 12.614, 0.965, 35 },
        { -29.962, 42.304, 21.139, 4.813, 35 },
        { -42.326, 19.422, 22.086, 0.279, 35 },
        { -11.136, 9.218, 21.979, 0.372, 35 },
        { -24.359, -1.028, 21.278, 1.443, 35 },
        { -24.626, -19.870, 20.251, 2.008, 35 },
        { -25.565, -32.904, 19.889, 0.885, 35 },
        { 7.823, -15.020, 17.045, 0.208, 35 },
        { 14.597, -0.313, 20.270, 1.291, 35 },
        { 20.571, -24.003, 17.676, 0.370, 35 },
        { 47.432, -37.421, 13.934, 3.208, 35 },
        { 27.242, 31.269, 17.936, 2.658, 35 },
        { 14.220, 41.215, 16.244, 0.998, 35 },
        { -69.204, 18.944, 15.270, 5.727, 35 },
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
            -- Format: { { multiplier, duration (in seconds) } }
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
            -- Format: { [type] = {multiplier, label}, ...}
            --
            -- Placeholders: $ammo
            [35] = {
                types = {
                    [1] = { 0, '$ammoX normal bullets' },
                    [2] = { 1.5, '$ammoX armour piercing bullets' },
                    [3] = { 5, '$ammoX explosive bullets' },
                    [4] = { 100, '$ammoX golden bullets' }
                },
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
        -- Format: ['tag class'] = { ['tag name'] = { x, y, z, respawn time (in seconds) } }
        --
        crates = {
            ['eqip'] = {
                ['powerups\\full-spectrum vision'] = {
                    { -21.088, -6.966, 17.378, 30 },
                    { -76.244, 16.314, 8.105, 35 },
                    { -37.292, -42.132, 12.418, 40 },
                    { -13.733, -45.822, 9.333, 45 },
                    { 15.173, -30.069, 6.024, 30 },
                    { 4.839, -18.583, 3.447, 35 },
                    { -7.879, 10.950, 13.559, 40 },
                    { 8.573, 39.876, 9.319, 45 },
                    { 22.377, 34.333, 8.673, 30 },
                    { -30.284, 31.036, 17.252, 35 },
                    { -28.903, -3.468, 20.470, 40 },
                    { -27.855, -37.635, 18.186, 45 },
                    { 11.113, -15.421, 20.747, 30 },
                    { 45.789, -39.973, 12.689, 35 },
                    { 25.811, -23.153, 17.754, 40 },
                    { 29.885, 19.551, 17.979, 45 },
                    { 11.680, 44.461, 15.431, 30 },
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