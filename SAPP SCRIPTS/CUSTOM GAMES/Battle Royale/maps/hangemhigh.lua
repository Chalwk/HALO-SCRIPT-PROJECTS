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
        min_crates = 3,         -- Minimum crates to spawn
        max_crates = 8,         -- Maximum crates to spawn
        min_spawn_delay = 25, -- slightly faster to keep close-quarters action lively
        max_spawn_delay = 100, -- prevent cluttering in small areas
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
                multipliers = { { 1.25, 10 }, { 1.35, 15 }, { 1.45, 20 }, { 1.55, 25 } }, -- helps traverse open areas quickly
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }, -- moderate, balanced for indoor and outdoor fights
            },
            { -- CAMOUFLAGE
                enabled = true,
                camouflage = { 30, 45, 60, 75, 90 }, -- shorter for faster combat pace
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 1, 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (picks a random multiplier)
                enabled = true,
                health = { 1.25, 1.35, 1.45 }, -- balanced for indoor and outdoor survival
            }
        }
    }
}

return CFG
