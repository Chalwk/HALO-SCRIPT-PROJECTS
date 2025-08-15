local CFG = {
    safe_zone = {
        center       = { x = 2.051, y = 55.220, z = -2.801 },
        min_size     = 60,
        max_size     = 1400,
        shrink_steps = 6,
        game_time    = 6 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 35, -- slightly slower to avoid oversaturation in open areas
        max_spawn_delay = 110,
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
                    ['Flamethrower']    = 'weapons\\flamethrower\\flamethrower', -- close-range stronghold fights
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',           -- key in tight base corridors
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle', -- mid- to long-range control
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.2, 10 }, { 1.3, 15 }, { 1.4, 20 }, { 1.5, 25 } }, -- traverse large map efficiently
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                count = { 3, 3 }, -- moderate to limit spam across open sightlines
            },
            { -- CAMOFLAGE
                enabled = true,
                durations = { 30, 45, 60, 75, 90, 105, 120 }, -- strategic for flanking and base assaults
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                levels = { 1.3, 1.4, 1.5 }, -- helps survival in mixed-range engagements
            }
        }
    }
}

return CFG
