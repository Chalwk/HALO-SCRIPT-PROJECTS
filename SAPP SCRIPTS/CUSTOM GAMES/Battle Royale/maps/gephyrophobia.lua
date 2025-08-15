local CFG = {
    safe_zone = {
        center       = { x = 63.513, y = -74.088, z = -1.062 },
        min_size     = 80,
        max_size     = 1600,
        shrink_steps = 6,
        game_time    = 7 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 30,
        max_spawn_delay = 120,
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
                multipliers = { { 1.25, 10 }, { 1.35, 15 }, { 1.45, 20 }, { 1.55, 25 } }, -- increased slightly for bridge crossing
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 4, 4 }, -- enough for base skirmishes without cluttering bridges
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 40, 55, 70, 85, 100, 115, 130 }, -- longer for mid-field and vertical flanking
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45, 1.55 }, -- slightly increased for survival in open areas
            }
        }
    }
}

return CFG
