return {

    --- Safe zone coordinates and size:
    -- The safe zone is a sphere that players cannot leave.
    -- The safe zone will shrink over time, forcing players to fight in a tight space.
    -- When the safe zone is at its minimum size, players will have an extra 2 minutes (end_after) to fight.
    -- The x,y,z coordinates are the center of the sphere.
    -- [note]: 1 world unit is 10 feet or ~3.048 meters.
    --
    safe_zone = {
        x = 1.245,
        y = -1.028,
        z = -21.186,
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
        { 13.505, -50.329, -17.586, 2.189, 35 },
        { 20.976, -50.308, -17.652, 1.294, 35 },
        { 17.412, -47.249, -17.932, 1.680, 35 },
        { 7.548, -42.685, -17.048, 0.834, 35 },
        { 25.585, -41.356, -16.481, 3.490, 35 },
        { 16.535, -36.548, -16.950, 4.767, 35 },
        { 17.349, -43.527, -18.165, 1.936, 35 },

        --- blue base:
        { -12.817, 50.250, -17.628, 5.320, 35 },
        { -20.055, 50.331, -17.650, 4.420, 35 },
        { -16.208, 47.301, -17.832, 4.987, 35 },
        { -5.992, 42.321, -16.783, 3.749, 35 },
        { -24.433, 43.589, -16.989, 0.131, 35 },
        { -16.004, 43.543, -18.188, 5.324, 35 },
        { -16.105, 35.453, -16.580, 1.598, 35 },

        --- random locations:
        { -5.130, -34.157, -21.726, 1.094, 35 },
        { 3.287, -15.268, -22.008, 0.372, 35 },
        { 1.014, 14.968, -21.893, 2.915, 35 },
        { 6.067, 34.193, -21.637, 4.393, 35 },
        { -15.863, 12.535, -20.735, 5.331, 35 },
        { -39.861, 33.584, -19.582, 5.783, 35 },
        { -33.849, 15.627, -20.580, 5.779, 35 },
        { -24.759, -13.775, -20.698, 0.027, 35 },
        { -31.055, -32.722, -20.980, 0.403, 35 },
        { -9.381, -40.382, -20.353, 0.941, 35 },
        { -4.412, -13.981, -20.763, 6.205, 35 },
        { 9.626, -15.226, -21.027, 3.092, 35 },
        { 19.146, -7.242, -20.933, 3.971, 35 },
        { 42.453, -27.017, -20.742, 1.961, 35 },
        { 19.655, -25.953, -20.633, 2.556, 35 },
        { 26.918, 15.004, -20.954, 3.776, 35 },
        { 33.074, 32.879, -21.387, 4.166, 35 },
        { 17.004, 20.854, -16.115, 4.277, 35 },
        { 10.764, 1.191, -19.139, 3.492, 35 },
        { 31.042, -21.462, -18.446, 2.918, 35 },
        { -17.024, -24.225, -16.706, 0.155, 35 },
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

                    { 17.310, -52.052, -14.841, 30 },
                    { 16.982, -64.373, -17.102, 35 },
                    { 17.234, -51.399, -12.702, 40 },
                    { -16.391, 51.935, -15.139, 45 },
                    { -16.031, 64.373, -17.102, 30 },
                    { -16.339, 51.359, -12.702, 35 },
                    { 15.876, 24.232, -15.995, 40 },
                    { -16.599, -24.193, -16.028, 45 },
                    { -4.740, -18.035, -20.244, 30 },
                    { 10.251, -20.222, -20.040, 35 },
                    { 30.037, -20.545, -17.970, 40 },
                    { -29.447, 20.724, -17.924, 45 },
                    { -15.268, 13.691, -20.111, 30 },
                    { 26.677, 14.758, -20.307, 35 },
                    { 11.645, 3.522, -18.498, 40 },
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