return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = 65.749,
        y = -120.409,
        z = 0.118,
        min = 6, -- default (6 world/units)
        max = 206 -- default (206 world/units)
    },

    --- Reduction rate:
    -- How often the safe zone will shrink (in seconds):
    -- Default (60)
    --
    duration = 60,


    --- Reduction amount:
    -- How much the safe zone will shrink by (in world units):
    -- Default (5)
    --
    shrink_amount = 15,


    --- End after:
    -- The game will end this many minutes after
    -- the safe zone has shrunk to its minimum size:
    -- Default (2)
    --
    end_after = 2,


    --- Required players:
    -- The minimum amount of players required to start the game:
    -- Default: (2)
    --
    required_players = 1,


    --- Game start delay:
    -- The amount of time (in seconds) to wait before starting the game:
    -- The start delay will not begin until the required players have joined.
    -- Default (30)
    --
    start_delay = 1,


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
        { 111.08, -176.01, 0.83, 2.336, 35 },
        { 108.50, -168.04, 0.05, 2.469, 35 },
        { 109.78, -160.53, 0.03, 2.490, 35 },
        { 104.16, -151.83, 0.09, 2.911, 35 },
        { 94.60, -149.44, 0.06, 1.736, 35 },
        { 83.13, -155.03, -0.14, 2.293, 35 },
        { 83.46, -164.04, 0.09, 0.983, 35 },

        --- blue base:
        { 49.21, -88.68, 0.11, 2.283, 35 },
        { 56.00, -84.74, 0.09, 2.790, 35 },
        { 62.52, -72.11, 1.02, 3.539, 35 },
        { 54.81, -66.20, 0.92, 4.616, 35 },
        { 42.03, -66.88, 0.71, 5.146, 35 },
        { 30.66, -68.10, 0.35, 5.517, 35 },
        { 28.36, -78.37, 0.23, 5.587, 35 },
        { 37.12, -93.44, 0.04, 5.470, 35 },

        --- random locations:
        { 84.03, -144.51, 0.08, 5.294, 35 },
        { 66.19, -144.16, 1.04, 5.735, 35 },
        { 74.93, -132.26, -0.17, 0.694, 35 },
        { 84.63, -126.30, 0.54, 4.089, 35 },
        { 105.81, -133.12, 1.13, 2.980, 35 },
        { 111.04, -132.92, 0.52, 3.099, 35 },
        { 111.51, -145.59, 0.24, 3.450, 35 },
        { 79.14, -117.54, 0.22, 4.351, 35 },
        { 88.40, -105.56, 1.54, 3.600, 35 },
        { 82.43, -93.98, 1.78, 4.401, 35 },
        { 66.53, -99.43, 1.33, 4.739, 35 },
        { 64.98, -120.74, 0.16, 0.275, 35 },
        { 47.84, -124.63, -0.32, 0.008, 35 },
        { 51.95, -108.22, 0.22, 1.509, 35 },
        { 65.34, -109.34, 2.02, 4.047, 35 },
        { 42.26, -144.77, 2.76, 0.917, 35 }
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

            --- NUKE:
            [1000000] = {
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
        -- Format: ['tag class'] = { ['tag name'] = { x, y, z, respawn time (in seconds) } }
        --
        crates = {
            ['eqip'] = {
                ['powerups\\full-spectrum vision'] = {
                    { 98.77, -108.72, 4.32, 30 },
                    { 109.81, -110.36, 2.14, 30 },
                    { 91.30, -92.90, 5.12, 30 },
                    { 67.95, -88.94, 5.54, 30 },
                    { 47.35, -150.79, 4.38, 30 },
                    { 61.78, -155.34, 5.94, 30 },
                    { 63.43, -177.53, 4.13, 30 },
                    { 113.13, -178.85, 1.44, 30 },
                    { 119.99, -181.58, 6.98, 30 },
                    { 75.90, -132.88, -0.08, 30 },
                    { 68.61, -93.09, 2.06, 30 },
                    { 80.07, -64.62, 4.56, 30 },
                    { 17.62, -60.62, 4.83, 30 },
                    { 21.82, -107.29, 2.25, 30 },
                }
            }
        },

        --- Random Loot weapon/power up spawns:
        -- These objects will spawn on the map!
        objects = {

            ['weap'] = {
                ['weapons\\assault rifle\\assault rifle'] = {
                },
                ['weapons\\flamethrower\\flamethrower'] = {
                },
                ['weapons\\pistol\\pistol'] = {
                },
                ['weapons\\plasma pistol\\plasma pistol'] = {
                },
                ['weapons\\needler\\mp_needler'] = {
                },
                ['weapons\\plasma rifle\\plasma rifle'] = {
                },
                ['weapons\\shotgun\\shotgun'] = {
                },
                ['weapons\\sniper rifle\\sniper rifle'] = {
                },
                ['weapons\\plasma_cannon\\plasma_cannon'] = {
                },
                ['weapons\\rocket launcher\\rocket launcher'] = {
                },
                ['weapons\\sniper rifle\\sniper rifle'] = {
                },
            },

            ['eqip'] = {
                ['powerups\\flamethrower ammo\\flamethrower ammo'] = {
                },
                ['powerups\\shotgun ammo\\shotgun ammo'] = {
                },
                ['powerups\\sniper rifle ammo\\sniper rifle ammo'] = {
                },
                ['powerups\\active camouflage'] = {
                },
                ['powerups\\health pack'] = {
                },
                ['powerups\\over shield'] = {
                },
                ['powerups\\assault rifle ammo\\assault rifle ammo'] = {
                },
                ['powerups\\needler ammo\\needler ammo'] = {
                },
                ['powerups\\rocket launcher ammo\\rocket launcher ammo'] = {
                },
                ['weapons\\frag grenade\\frag grenade'] = {
                },
                ['weapons\\plasma grenade\\plasma grenade'] = {
                },
            }
        }
    }
}