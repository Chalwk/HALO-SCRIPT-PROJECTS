local MAP = {
    safe_zone = {
        center = { x = 2.051, y = 55.220, z = -2.801 },
        min_size = 50,
        max_size = 550,
        shrink_steps = 6,
        game_time = 6 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 15,
        damage_per_second = 0.025
    },
    sky_spawn_coordinates = {
        -- red base:
        { -28.417, -31.040, -3.842, 1.215, 25 },
        { -35.560, -30.986, -3.842, 2.046, 25 },
        { -32.019, -28.722, -3.842, 1.369, 25 },
        { -31.748, -31.998, 0.558,  1.598, 25 },
        { -50.270, -16.243, -3.842, 5.751, 25 },
        { -19.695, -37.751, -3.842, 2.128, 25 },
        { -35.441, -14.632, -2.856, 4.975, 25 },
        -- blue base:
        { 26.264,  -34.826, -3.842, 1.750, 25 },
        { 34.248,  -34.915, -3.842, 1.373, 25 },
        { 30.374,  -32.048, -3.790, 1.748, 25 },
        { 17.648,  -31.824, -3.842, 0.679, 25 },
        { 45.466,  -23.819, -3.922, 2.986, 25 },
        { 33.489,  -18.948, -3.837, 4.468, 25 },
        { 30.323,  -35.890, 0.558,  1.558, 25 },
        -- random locations:
        { -48.320, -0.772,  -3.922, 0.589, 25 },
        { -48.481, 20.776,  -3.842, 5.765, 25 },
        { -31.778, 33.574,  -3.842, 1.964, 25 },
        { -21.911, 44.985,  -3.842, 0.509, 25 },
        { -25.589, 17.108,  -3.943, 0.392, 25 },
        { -10.295, -1.403,  -3.842, 2.089, 25 },
        { -11.572, -17.346, 0.232,  2.006, 25 },
        { -46.518, 24.581,  0.158,  5.368, 25 },
        { -38.308, 40.470,  0.158,  6.165, 25 },
        { 21.044,  13.195,  -3.729, 5.411, 25 },
        { 52.396,  13.914,  -3.842, 3.833, 25 },
        { 53.210,  28.996,  0.158,  3.250, 25 },
        { 46.166,  42.317,  0.158,  3.901, 25 },
        { 6.576,   2.518,   0.158,  6.245, 25 },
        { 7.809,   -19.889, 0.182,  0.816, 25 },
        { 32.068,  -3.465,  -3.319, 3.398, 25 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 8,
        max_crates = 12,
        min_spawn_delay = 35,
        max_spawn_delay = 110,
        collision_radius = 1.5,
        locations = {
            { 43.090,  41.873,  2.408 },
            { -36.421, 30.705,  0.808 },
            { -17.797, 35.410,  -3.272 },
            { -4.376,  -13.017, 3.208 },
            { -16.528, -25.507, 0.812 },
            { 31.656,  -44.728, -3.192 },
            { 27.739,  -36.209, 1.208 },
            { 34.094,  -13.741, -1.135 },
            { 29.628,  3.224,   -0.817 },
            { 23.325,  25.422,  -3.272 },
            { -32.003, -38.146, -3.192 },
            { -29.610, -32.114, 1.208 },
            { -33.064, -12.991, -0.278 },
            { -25.411, 5.425,   -3.271 },
        },
        spoils = {
            {
                -- Extra lives
                enabled = true,
                bonus_lives = 1
            },
            {
                -- Random weapon rewards: [label] = tag path
                enabled = true,
                random_weapons = {
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
            {
                -- Speed boosts: {multiplier, duration in seconds}
                enabled = true,
                speed_boosts = { { 1.35, 10 }, { 1.45, 15 }, { 1.55, 20 }, { 1.65, 25 } }
            },
            {
                -- Grenade rewards: {frag_count, plasma_count}
                enabled = true,
                grenades = { 3, 3 }
            },
            {
                -- Active camouflage durations (seconds)
                enabled = true,
                camouflage = { 50, 65, 80, 95, 110 }
            },
            {
                -- Overshield multipliers
                enabled = true,
                overshield_boosts = { 2, 3, 4, 5 }
            },
            {
                -- Health multipliers (1 = full health)
                enabled = true,
                health_boosts = { 1.25, 1.35, 1.45 }
            }
        }
    }
}

return MAP
