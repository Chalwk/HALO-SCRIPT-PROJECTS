local CFG = {
    safe_zone = {
        center       = { x = 8.662, y = -11.159, z = 0.221 },
        min_size     = 20,
        max_size     = 300,
        shrink_steps = 3,
        game_time    = 3 * 60,
        bonus_time   = 30
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_spawn_delay = 25, -- faster respawns to keep pace high
        max_spawn_delay = 90, -- shorter max to avoid mid-field overcrowding
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
                    ['Shotgun']         = 'weapons\\shotgun\\shotgun',         -- strong in tight spots
                    ['Sniper Rifle']    = 'weapons\\sniper rifle\\sniper rifle', -- for mid-field control
                    ['Plasma Cannon']   = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST
                enabled = true,
                multipliers = { { 1.3, 10 }, { 1.4, 15 }, { 1.5, 20 }, { 1.6, 25 } }, -- faster traversal for open-mid fights
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                count = { 3, 3 }, -- moderate to avoid spam in narrow corridors
            },
            { -- CAMOFLAGE
                enabled = true,
                durations = { 30, 40, 50, 60, 70, 80 }, -- balanced for strategic flanking
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                levels = { 1.3, 1.4, 1.5 }, -- survival in quick skirmishes
            }
        }
    }
}

return CFG
