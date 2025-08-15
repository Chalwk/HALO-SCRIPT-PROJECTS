local CFG = {
    safe_zone = {
        center       = { x = 4.374, y = -12.832, z = 7.220 }, -- Boundary center position
        min_size     = 30,                                     -- Minimum radius of playable area
        max_size     = 500,                                    -- Maximum radius (starting size)
        shrink_steps = 4,                                      -- Number of shrink steps to reach min_size
        game_time    = 4 * 60,                                 -- Default game duration in seconds
        bonus_time   = 30                                      -- Bonus period duration in seconds
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 20,   -- Crate min respawn delay (a random value between min_spawn_delay and max_spawn_delay will be used)
        max_spawn_delay = 90,   -- Crate max respawn delay
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
                multipliers = { { 1.25, 10 }, { 1.35, 15 }, { 1.45, 20 }, { 1.55, 25 } },
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 4, 4 },
            },
            { -- CAMOUFLAGE {duration}
                enabled = true,
                camouflage = { 25, 40, 55, 70, 85 },
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45 },
            }
        }
    }
}

return CFG
