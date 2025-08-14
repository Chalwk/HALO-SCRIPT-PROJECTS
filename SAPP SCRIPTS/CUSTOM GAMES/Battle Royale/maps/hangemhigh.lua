local CFG = {
    safe_zone = {
        center       = { x = 21.020, y = -4.632, z = -4.229 },
        min_size     = 25,
        max_size     = 350,
        shrink_steps = 4,
        game_time    = 4 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        collision_radius = 1.5,
        locations = {},
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
