local CFG = {
    safe_zone = {
        center       = { x = 0.902, y = 0.088, z = 1.392 },
        min_size     = 15,
        max_size     = 250,
        shrink_steps = 3,
        game_time    = 3 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 20, -- faster respawns for constant indoor action
        max_spawn_delay = 80, -- shorter max to avoid overstocking corridors
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
                    ['Plasma Pistol']   = 'weapons\\plasma pistol\\plasma pistol',
                    ['Plasma Rifle']    = 'weapons\\plasma rifle\\plasma rifle',
                    ['Assault Rifle']   = 'weapons\\assault rifle\\assault rifle',
                    ['Pistol']          = 'weapons\\pistol\\pistol',
                    ['Needler']         = 'weapons\\needler\\mp_needler',
                    ['Flamethrower']    = 'weapons\\flamethrower\\flamethrower', -- strong indoors
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',           -- dominates corridors
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle', -- mainly upper levels
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.35, 10 }, { 1.45, 15 }, { 1.55, 20 }, { 1.65, 25 } }, -- quick corridor dashes
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                count = { 3, 3 }, -- reduced to prevent spam in tight spaces
            },
            { -- CAMOFLAGE
                enabled = true,
                durations = { 30, 40, 50, 60, 70 }, -- shorter to maintain indoor pacing
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                levels = { 1.3, 1.4, 1.5 }, -- helps survive close-quarters duels
            }
        }
    }
}

return CFG
