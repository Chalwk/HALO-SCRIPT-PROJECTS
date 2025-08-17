local MAP = {
    safe_zone = {
        center = { x = 1.250, y = -1.487, z = -21.264 },
        min_size = 40,
        max_size = 400,
        shrink_steps = 5,
        game_time = 6 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 12,
        damage_per_second = 0.027
    },
    sky_spawn_coordinates = {
        -- red base:
        { 13.505,  -50.329, -17.586, 2.189, 35 },
        { 20.976,  -50.308, -17.652, 1.294, 35 },
        { 17.412,  -47.249, -17.932, 1.680, 35 },
        { 7.548,   -42.685, -17.048, 0.834, 35 },
        { 25.585,  -41.356, -16.481, 3.490, 35 },
        { 16.535,  -36.548, -16.950, 4.767, 35 },
        { 17.349,  -43.527, -18.165, 1.936, 35 },
        -- blue base:
        { -12.817, 50.250,  -17.628, 5.320, 35 },
        { -20.055, 50.331,  -17.650, 4.420, 35 },
        { -16.208, 47.301,  -17.832, 4.987, 35 },
        { -5.992,  42.321,  -16.783, 3.749, 35 },
        { -24.433, 43.589,  -16.989, 0.131, 35 },
        { -16.004, 43.543,  -18.188, 5.324, 35 },
        { -16.105, 35.453,  -16.580, 1.598, 35 },
        -- random locations:
        { -5.130,  -34.157, -21.726, 1.094, 35 },
        { 3.287,   -15.268, -22.008, 0.372, 35 },
        { 1.014,   14.968,  -21.893, 2.915, 35 },
        { 6.067,   34.193,  -21.637, 4.393, 35 },
        { -15.863, 12.535,  -20.735, 5.331, 35 },
        { -39.861, 33.584,  -19.582, 5.783, 35 },
        { -33.849, 15.627,  -20.580, 5.779, 35 },
        { -24.759, -13.775, -20.698, 0.027, 35 },
        { -31.055, -32.722, -20.980, 0.403, 35 },
        { -9.381,  -40.382, -20.353, 0.941, 35 },
        { -4.412,  -13.981, -20.763, 6.205, 35 },
        { 9.626,   -15.226, -21.027, 3.092, 35 },
        { 19.146,  -7.242,  -20.933, 3.971, 35 },
        { 42.453,  -27.017, -20.742, 1.961, 35 },
        { 19.655,  -25.953, -20.633, 2.556, 35 },
        { 26.918,  15.004,  -20.954, 3.776, 35 },
        { 33.074,  32.879,  -21.387, 4.166, 35 },
        { 17.004,  20.854,  -16.115, 4.277, 35 },
        { 10.764,  1.191,   -19.139, 3.492, 35 },
        { 31.042,  -21.462, -18.446, 2.918, 35 },
        { -17.024, -24.225, -16.706, 0.155, 35 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 6,
        max_crates = 9,
        min_spawn_delay = 35,
        max_spawn_delay = 115,
        collision_radius = 1.5,
        locations = {
            { 17.310,  -52.052, -14.841 },
            { 16.982,  -64.373, -17.102 },
            { 17.234,  -51.399, -12.702 },
            { -16.391, 51.935,  -15.139 },
            { -16.031, 64.373,  -17.102 },
            { -16.339, 51.359,  -12.702 },
            { 15.876,  24.232,  -15.995 },
            { -16.599, -24.193, -16.028 },
            { -4.740,  -18.035, -20.244 },
            { 10.251,  -20.222, -20.040 },
            { 30.037,  -20.545, -17.970 },
            { -29.447, 20.724,  -17.924 },
            { -15.268, 13.691,  -20.111 },
            { 26.677,  14.758,  -20.307 },
            { 11.645,  3.522,   -18.498 },
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
