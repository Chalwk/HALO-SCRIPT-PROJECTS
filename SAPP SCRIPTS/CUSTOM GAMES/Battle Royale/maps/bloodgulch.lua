local CFG = {
    safe_zone = {
        center       = { x = 65.749, y = -120.409, z = 0.118 }, -- Boundary center position
        min_size     = 1,                                       -- Minimum radius of playable area
        max_size     = 5,                                       -- Maximum radius (starting size)
        shrink_steps = 2,                                       -- Number of shrink steps to reach min_size
        game_time    = 60,                                      -- Default game duration in seconds
        bonus_time   = 30                                       -- Bonus period duration in seconds
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        collision_radius = 1.5, -- Player-crate collision radius
        locations = {
            { 63.427,  -177.249, 4.756,  30 },
            { 63.874,  -155.632, 7.398,  35 },
            { 44.685,  -151.848, 4.660,  40 },
            { 118.143, -185.154, 7.170,  45 },
            { 112.120, -138.996, 0.911,  30 },
            { 98.765,  -108.723, 4.971,  35 },
            { 109.798, -110.394, 2.791,  40 },
            { 79.092,  -90.719,  5.246,  45 },
            { 70.556,  -84.854,  6.341,  30 },
            { 79.578,  -64.590,  5.311,  35 },
            { 21.884,  -108.882, 2.846,  40 },
            { 68.947,  -92.482,  2.702,  45 },
            { 76.069,  -132.263, 0.543,  30 },
            { 95.687,  -159.449, -0.100, 35 },
            { 40.240,  -79.123,  -0.100, 40 }
        },
        spoils = {
            { -- BONUS LIVES
                enabled = true,
                lives = 1,
            },
            { -- RANDOM WEAPON
                enabled = true,
                weapons = {
                    'weapons\\plasma pistol\\plasma pistol',
                    'weapons\\plasma rifle\\plasma rifle',
                    'weapons\\assault rifle\\assault rifle',
                    'weapons\\pistol\\pistol',
                    'weapons\\needler\\mp_needler',
                    'weapons\\flamethrower\\flamethrower',
                    'weapons\\shotgun\\shotgun',
                    'weapons\\sniper rifle\\sniper rifle',
                    'weapons\\plasma_cannon\\plasma_cannon',
                    'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.2, 10 }, { 1.3, 15 }, { 1.4, 20 }, { 1.5, 25 } },
            },

            { -- GRENADES {frags, plasmas}
                enabled = true,
                count = { 4, 4 },
            },
            { -- CAMOFLAGE
                enabled = true,
                durations = { 30, 45, 60, 75, 90, 105, 120 },
            },
            { -- FULL OVERSHIELD
                enabled = true,
            },
            { -- HEALTH BOOST
                enabled = true,
                levels = { 1.2, 1.3, 1.4, 1.5 },
            }
        }
    }
}

return CFG
