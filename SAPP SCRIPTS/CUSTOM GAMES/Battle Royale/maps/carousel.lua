local CFG = {
    safe_zone = {
        center       = { x = 0.033, y = 0.003, z = -0.856 },
        min_size     = 20,
        max_size     = 300,
        shrink_steps = 3,
        game_time    = 3 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 3,         -- Minimum crates to spawn
        max_crates = 8,         -- Maximum crates to spawn
        min_spawn_delay = 25,
        max_spawn_delay = 100,
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
                    ['Flamethrower']    = 'weapons\\flamethrower\\flamethrower',
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle',
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.25, 10 }, { 1.35, 15 }, { 1.45, 20 }, { 1.55, 25 } }, -- slightly lower to avoid overshooting ramps
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }, -- keeps corridor fights controlled
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 25, 40, 55, 70, 85 }, -- shorter max to keep fights fast-paced
            },
             { -- FULL OVERSHIELD (multiplier)
                 enabled = true,
                 overshield = { 1, 2, 3, 4, 5 }
             },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45 }, -- balanced for multi-level duels
            }
        }
    }
}

return CFG
