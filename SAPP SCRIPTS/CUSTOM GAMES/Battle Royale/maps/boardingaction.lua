local CFG = {
    safe_zone = {
        center = { x = 4.374, y = -12.832, z = 7.220 },
        min_size = 15,
        max_size = 120,
        shrink_steps = 4,
        game_time = 4 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 2,
        public_message_interval = 10,
        damage_per_second = 0.0333
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 5,
        max_crates = 7,
        min_spawn_delay = 20,
        max_spawn_delay = 90,
        collision_radius = 1.5,
        locations = {},
        spoils = {
            { -- BONUS LIVES
                enabled = true,
                lives = 1,
            },
            { -- RANDOM WEAPON [label] = tag name
                enabled = true,
                weapons = {
                    ['Plasma Pistol'] = 'weapons\\plasma pistol\\plasma pistol',
                    ['Plasma Rifle'] = 'weapons\\plasma rifle\\plasma rifle',
                    ['Assault Rifle'] = 'weapons\\assault rifle\\assault rifle',
                    ['Pistol'] = 'weapons\\pistol\\pistol',
                    ['Needler'] = 'weapons\\needler\\mp_needler',
                    ['Flamethrower'] = 'weapons\\flamethrower\\flamethrower',
                    ['Shotgun'] = 'weapons\\shotgun\\shotgun',
                    ['Sniper Rifle'] = 'weapons\\sniper rifle\\sniper rifle',
                    ['Plasma Cannon'] = 'weapons\\plasma_cannon\\plasma_cannon',
                    ['Rocket Launcher'] = 'weapons\\rocket launcher\\rocket launcher'
                }
            },
            { -- SPEED BOOST {boost, duration}
                enabled = true,
                multipliers = { { 1.35, 10 }, { 1.45, 15 }, { 1.55, 20 }, { 1.65, 25 } }
            },
            { -- GRENADES {frags, plasmas}
                enabled = true,
                grenades = { 3, 3 }
            },
            { -- CAMOUFLAGE {duration}
                enabled = true,
                camouflage = { 50, 65, 80, 95, 110 }
            },
            { -- FULL OVERSHIELD (multiplier)
                enabled = true,
                overshield = { 2, 3, 4, 5 }
            },
            { -- HEALTH BOOST (1 = full health)
                enabled = true,
                health = { 1.25, 1.35, 1.45 }
            }
        }
    }
}

return CFG
