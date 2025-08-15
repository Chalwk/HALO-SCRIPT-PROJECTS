local CFG = {
    safe_zone = {
        center       = { x = 14.015, y = 14.238, z = -0.911 }, -- Boundary center position
        min_size     = 40,                                     -- Minimum radius of playable area
        max_size     = 600,                                    -- Maximum radius (starting size)
        shrink_steps = 4,                                      -- Number of shrink steps to reach min_size
        game_time    = 4 * 60,                                 -- Default game duration in seconds
        bonus_time   = 30                                      -- Bonus period duration in seconds
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 25,   -- Crate min respawn delay (a random value between min_spawn_delay and max_spawn_delay will be used)
        max_spawn_delay = 100,  -- Crate max respawn delay
        collision_radius = 1.5, -- A player must within this many world units to open a crate
        locations = {},          -- Crate spawn locations
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
                multipliers = { { 1.2, 10 }, { 1.3, 15 }, { 1.4, 20 }, { 1.5, 25 } },
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                count = { 2, 2 },
            },
            { -- CAMOFLAGE {duration}
                enabled = true,
                durations = { 25, 40, 55, 70, 85 },
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (multiplier)
                enabled = true,
                levels = { 1.15, 1.25, 1.35 },
            }
        }
    }
}

return CFG
