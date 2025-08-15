local CFG = {
    safe_zone = {
        center       = { x = 1.250, y = -1.487, z = -21.264 },
        min_size     = 70,
        max_size     = 1500,
        shrink_steps = 5,
        game_time    = 6 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 35, -- slightly slower to avoid oversaturation in open areas
        max_spawn_delay = 115,
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
                    ['Flamethrower']    = 'weapons\\flamethrower\\flamethrower', -- strong for close forest skirmishes
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',           -- corridors or narrow forest paths
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle', -- for mid- to long-range lines of sight
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.2, 10 }, { 1.3, 15 }, { 1.4, 20 }, { 1.5, 25 } }, -- helps traverse large terrain quickly
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }, -- balanced for forested combat, avoid spam
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 30, 45, 60, 75, 90, 105, 120 }, -- tactical for flanking and ambushes
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.3, 1.4, 1.5 }, -- supports survival in varied terrain engagements
            }
        }
    }
}

return CFG
