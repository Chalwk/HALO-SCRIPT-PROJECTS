local CFG = {
    safe_zone = {
        center       = { x = 65.749, y = -120.409, z = 0.118 }, -- Boundary center position
        min_size     = 20,                                      -- Minimum radius of playable area
        max_size     = 1500,                                    -- Maximum radius (starting size)
        shrink_steps = 5,                                       -- Number of shrink steps to reach min_size
        game_time    = 5 * 60,                                  -- Default game duration in seconds
        bonus_time   = 30                                       -- Bonus period duration in seconds
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 35,   -- Crate min respawn delay (a random value between min_spawn_delay and max_spawn_delay will be used)
        max_spawn_delay = 130,  -- Crate max respawn delay
        collision_radius = 1.5, -- A player must within this many world units to open a crate
        locations = {           -- Crate spawn locations
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
                    ['Plasma Pistol']   = 'weapons\\plasma pistol\\plasma pistol',
                    ['Plasma Rifle']    = 'weapons\\plasma rifle\\plasma rifle',
                    ['Assault Rifle']   = 'weapons\\assault rifle\\assault rifle',
                    ['Pistol']          = 'weapons\\pistol\\pistol',
                    ['Needler']         = 'weapons\\needler\\mp_needler',
                    ['Flamethrower']    = 'weapons\\flamethrower\\flamethrower',
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle',
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST {boost, duration}
                enabled = true,
                multipliers = { { 1.35, 10 }, { 1.45, 15 }, { 1.55, 20 }, { 1.65, 25 } },
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 },
            },
            { -- CAMOUFLAGE {duration}
                enabled = true,
                camouflage = { 50, 65, 80, 95, 110 },
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (1 = full health)
                enabled = true,
                health = { 1.25, 1.35, 1.45 },
            }
        }
    }
}

return CFG
