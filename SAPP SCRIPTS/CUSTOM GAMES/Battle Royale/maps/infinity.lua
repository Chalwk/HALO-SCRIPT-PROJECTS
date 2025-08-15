local CFG = {
    safe_zone = {
        center       = { x = 9.631, y = -64.030, z = 7.776 },
        min_size     = 100,
        max_size     = 2000,
        shrink_steps = 6,
        game_time    = 8 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 35, -- slightly slower to avoid mid-field clutter
        max_spawn_delay = 140, -- spaced out to keep crates meaningful
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
                multipliers = { { 1.3, 10 }, { 1.4, 15 }, { 1.5, 20 }, { 1.6, 25 } }, -- slightly faster for map traversal
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 4, 4 }, -- moderate for open-area engagements
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 40, 55, 70, 85, 100, 115, 130 }, -- longer for flanking and sniping
            },
             { -- FULL OVERSHIELD (multiplier)
                 enabled = true,
                 overshield = { 1, 2, 3, 4, 5 }
             },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45, 1.55 }, -- helps survive long mid-field fights
            }
        }
    }
}

return CFG
