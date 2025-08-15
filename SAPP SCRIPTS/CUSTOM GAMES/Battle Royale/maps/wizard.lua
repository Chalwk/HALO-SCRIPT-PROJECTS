local CFG = {
    safe_zone = {
        center       = { x = -5.035, y = -5.064, z = -2.750 },
        min_size     = 20,
        max_size     = 300,
        shrink_steps = 3,
        game_time    = 3 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 20, -- faster spawns to keep indoor fights lively
        max_spawn_delay = 90, -- shorter max to avoid overstocking small corridors
        collision_radius = 1.5,
        locations = {},
        spoils = {
            { -- BONUS LIVES
                enabled = true,
                lives = 1, -- helps offset high-risk indoor duels
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
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',         -- key for corridors
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle', -- secondary, for balcony sightlines
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.3, 10 }, { 1.4, 15 }, { 1.5, 20 }, { 1.6, 25 } }, -- helps vertical mobility indoors
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }, -- enough for close-quarters skirmishes
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 30, 45, 60, 75, 90 }, -- short enough to stay tactical indoors
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.3, 1.4, 1.5 }, -- supports survival in tight trades
            }
        }
    }
}

return CFG
