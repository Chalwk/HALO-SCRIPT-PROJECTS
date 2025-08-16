local CFG = {
    safe_zone = {
        center = { x = 65.749, y = -120.409, z = 0.118 }, -- Boundary center position
        min_size = 25,                                    -- Minimum radius of playable area
        max_size = 300,                                   -- Maximum radius (starting size)
        shrink_steps = 5,                                 -- Number of shrink steps to reach min_size
        game_time = 5 * 60,                               -- Default game duration in seconds
        bonus_time = 30,                                  -- Bonus period duration in seconds
        max_deaths_until_spectate = 3,                    -- Maximum number of deaths until spectators are allowed
        public_message_interval = 15,                     -- Time in seconds between public messages
        damage_per_second = 0.025                         -- Player damage per second (while outside boundary)
    },
    sky_spawn_coordinates = {
        -- red base:
        { 111.08, -176.01, 0.83,  2.336, 35 },
        { 108.50, -168.04, 0.05,  2.469, 35 },
        { 109.78, -160.53, 0.03,  2.490, 35 },
        { 104.16, -151.83, 0.09,  2.911, 35 },
        { 94.60,  -149.44, 0.06,  1.736, 35 },
        { 83.13,  -155.03, -0.14, 2.293, 35 },
        { 83.46,  -164.04, 0.09,  0.983, 35 },
        -- blue base:
        { 49.21,  -88.68,  0.11,  2.283, 35 },
        { 56.00,  -84.74,  0.09,  2.790, 35 },
        { 62.52,  -72.11,  1.02,  3.539, 35 },
        { 54.81,  -66.20,  0.92,  4.616, 35 },
        { 42.03,  -66.88,  0.71,  5.146, 35 },
        { 30.66,  -68.10,  0.35,  5.517, 35 },
        { 28.36,  -78.37,  0.23,  5.587, 35 },
        { 37.12,  -93.44,  0.04,  5.470, 35 },
        -- random locations:
        { 84.03,  -144.51, 0.08,  5.294, 35 },
        { 66.19,  -144.16, 1.04,  5.735, 35 },
        { 74.93,  -132.26, -0.17, 0.694, 35 },
        { 84.63,  -126.30, 0.54,  4.089, 35 },
        { 105.81, -133.12, 1.13,  2.980, 35 },
        { 111.04, -132.92, 0.52,  3.099, 35 },
        { 111.51, -145.59, 0.24,  3.450, 35 },
        { 79.14,  -117.54, 0.22,  4.351, 35 },
        { 88.40,  -105.56, 1.54,  3.600, 35 },
        { 82.43,  -93.98,  1.78,  4.401, 35 },
        { 66.53,  -99.43,  1.33,  4.739, 35 },
        { 64.98,  -120.74, 0.16,  0.275, 35 },
        { 47.84,  -124.63, -0.32, 0.008, 35 },
        { 51.95,  -108.22, 0.22,  1.509, 35 },
        { 65.34,  -109.34, 2.02,  4.047, 35 },
        { 42.26,  -144.77, 2.76,  0.917, 35 }
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 7,
        max_crates = 10,
        min_spawn_delay = 35,   -- Crate min/max respawn delays (a random value between min/max will be used)
        max_spawn_delay = 130,
        collision_radius = 1.5, -- A player must within this many world units to open a crate
        locations = {
            { 63.427,  -177.249, 4.756 },
            { 63.874,  -155.632, 7.398 },
            { 44.685,  -151.848, 4.660 },
            { 118.143, -185.154, 7.170 },
            { 112.120, -138.996, 0.911 },
            { 98.765,  -108.723, 4.971 },
            { 109.798, -110.394, 2.791 },
            { 79.092,  -90.719,  5.246 },
            { 70.556,  -84.854,  6.341 },
            { 79.578,  -64.590,  5.311 },
            { 21.884,  -108.882, 2.846 },
            { 68.947,  -92.482,  2.702 },
            { 76.069,  -132.263, 0.543 },
            { 95.687,  -159.449, -0.100 },
            { 40.240,  -79.123,  -0.100 },
        },
        spoils = {
            { -- BONUS LIVES
                enabled = true,
                lives = 1,
            },
            { -- RANDOM WEAPON [label] = tag name
                enabled = true,
                weapons = {
                    ['Plasma Pistol'] = 'weapons\\plasma pistol\\plasma pistol',
                    ['Plasma Rifle'] = 'weapons\\plasma rifle\\plasma rifle',
                    ['Assault Rifle'] = 'weapons\\assault rifle\\assault rifle',
                    ['Pistol'] = 'weapons\\pistol\\pistol',
                    ['Needler'] = 'weapons\\needler\\mp_needler',
                    ['Flamethrower'] = 'weapons\\flamethrower\\flamethrower',
                    ['Shotgun'] = 'weapons\\shotgun\\shotgun',
                    ['Sniper Rifle'] = 'weapons\\sniper rifle\\sniper rifle',
                    ['Plasma Cannon'] = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST {boost, duration}
                enabled = true,
                multipliers = { { 1.35, 10 }, { 1.45, 15 }, { 1.55, 20 }, { 1.65, 25 } }
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }
            },
            { -- CAMOUFLAGE {duration}
                enabled = true,
                camouflage = { 50, 65, 80, 95, 110 }
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (1 = full health)
                enabled = true,
                health = { 1.25, 1.35, 1.45 }
            }
        }
    }
}

return CFG
