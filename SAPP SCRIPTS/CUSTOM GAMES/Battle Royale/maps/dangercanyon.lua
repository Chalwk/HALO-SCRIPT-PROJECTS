local CFG = {
    safe_zone = {
        center = { x = 0.477, y = 55.331, z = 0.239 },
        min_size = 20,
        max_size = 280,
        shrink_steps = 6,
        game_time = 7 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 12,
        damage_per_second = 0.0271
    },
    sky_spawn_coordinates = {
        -- red base:
        { -9.007,  -4.607,  -4.032,  5.632, 20 },
        { -9.007,  -2.296,  -4.032,  0.716, 20 },
        { -4.103,  -3.552,  -4.024,  3.114, 20 },
        { -6.053,  -12.038, -4.124,  2.176, 20 },
        { -13.317, -6.507,  -4.033,  3.635, 20 },
        { -15.207, -2.296,  -4.032,  2.656, 20 },
        { -19.392, -12.193, -4.156,  1.026, 20 },
        -- blue base:
        { 8.904,   -2.296,  -4.032,  2.504, 20 },
        { 8.904,   -4.607,  -4.032,  4.212, 20 },
        { 6.309,   -14.432, -4.202,  0.361, 20 },
        { 13.214,  -6.507,  -4.033,  5.651, 20 },
        { 15.104,  -2.296,  -4.032,  0.871, 20 },
        { 11.984,  -3.497,  -2.243,  0.043, 20 },
        -- random locations:
        { -40.147, -7.830,  -1.147,  1.280, 20 },
        { -46.153, -4.121,  -2.209,  1.337, 20 },
        { -54.402, 8.693,   -5.434,  0.956, 20 },
        { -42.424, 19.730,  -8.794,  1.294, 20 },
        { -57.197, 26.878,  -11.470, 6.069, 20 },
        { -31.376, 30.477,  -6.331,  0.720, 20 },
        { -20.903, 32.484,  -6.109,  1.422, 20 },
        { -26.550, 45.467,  -9.825,  6.147, 20 },
        { -18.792, 54.519,  -9.228,  4.938, 20 },
        { -15.699, 38.317,  -7.734,  1.795, 20 },
        { -1.257,  48.413,  -8.366,  2.545, 20 },
        { 1.950,   37.907,  -8.366,  6.268, 20 },
        { -1.580,  42.009,  -8.366,  2.690, 20 },
        { 20.544,  54.181,  -9.317,  5.111, 20 },
        { 18.405,  37.870,  -7.512,  2.327, 20 },
        { 26.524,  29.264,  -5.532,  1.564, 20 },
        { 42.711,  34.299,  -8.204,  4.881, 20 },
        { 53.730,  26.437,  -10.704, 3.456, 20 },
        { 42.855,  20.599,  -8.497,  0.180, 20 },
        { 52.234,  5.204,   -4.658,  2.227, 20 },
        { 45.252,  -4.204,  -2.208,  2.114, 20 },
        { 32.526,  2.839,   -2.240,  4.310, 20 },
        { 39.350,  -7.237,  -1.143,  2.406, 20 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 5,
        max_crates = 7,
        min_spawn_delay = 30,
        max_spawn_delay = 120,
        collision_radius = 1.5,
        locations = {
            { -28.146, 42.605, -8.721 },
            { -0.076,  45.466, -3.858 },
            { -0.041,  45.470, -7.716 },
            { 18.036,  36.373, -6.676 },
            { 17.290,  17.799, 1.226 },
            { -0.116,  14.709, -0.000 },
            { -0.084,  35.239, 0.923 },
            { -7.125,  53.230, 0.917 },
        },
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
