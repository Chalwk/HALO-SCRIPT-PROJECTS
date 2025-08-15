local CFG = {
    safe_zone = {
        center       = { x = 1.392, y = 4.700, z = 3.108 },
        min_size     = 20,
        max_size     = 300,
        shrink_steps = 4,
        game_time    = 4 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 20,
        max_spawn_delay = 90,
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
                multipliers = { { 1.25, 10 }, { 1.35, 15 }, { 1.45, 20 }, { 1.55, 25 } }, -- toned down for slippery floors
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }, -- balanced for corridor combat
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 25, 40, 55, 70, 85 }, -- slightly shorter to keep fights fast-paced
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45 }, -- slightly lighter for balanced trades indoors
            }
        }
    }
}

return CFG
