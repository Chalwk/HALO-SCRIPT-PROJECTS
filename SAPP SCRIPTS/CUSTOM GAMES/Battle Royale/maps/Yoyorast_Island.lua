local MAP = {
    safe_zone = {
        center = { x = 7.261, y = -19.631, z = -162.233 },
        min_size = 5,
        max_size = 130,
        shrink_steps = 5,
        game_time = 5 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 15,
        damage_per_second = 0.025
    },
    sky_spawn_coordinates = {
        -- red base:
        { -2.523, 16.420,  -173.225 },
        { -2.439, 21.751,  -170.703 },
        { -0.730, 20.987,  -166.434 },
        { 0.606,  21.131,  -165.022 },
        -- blue base:
        { 14.737, 16.765,  -170.704 },
        { 16.710, 21.734,  -170.703 },
        { 14.881, 20.771,  -166.434 },
        { 13.638, 21.154,  -165.022 },
        -- random locations:
        { 7.256,  33.341,  -167.361 },
        { 7.139,  13.976,  -169.743 },
        { -0.373, -1.655,  -178.011 },
        { 14.841, -1.918,  -178.012 },
        { 0.093,  -8.924,  -178.849 },
        { 9.604,  -13.375, -184.268 },
        { 11.779, -7.435,  -188.094 },
        { 2.857,  -6.943,  -188.098 },
        { 4.712,  4.473,   -182.831 },
        { 9.725,  4.368,   -182.831 },
        { 29.919, -5.228,  -180.573 },
        { 25.034, 3.765,   -184.189 },
        { 21.656, -27.147, -181.647 },
        { 12.173, -35.189, -180.775 },
        { 38.463, -29.934, -187.181 },
        { 29.268, -30.501, -178.169 },
        { 34.138, -20.803, -194.971 },
        { 70.544, -20.923, -199.465 },
        { 54.387, -9.167,  -200.114 },
        { 56.681, -31.857, -200.621 },
        { 36.559, -37.147, -198.793 },
        { 36.478, -24.763, -184.052 },
        { 20.856, -25.603, -186.439 },
        { 36.677, -11.893, -186.731 },
        { 16.326, 1.377,   -195.233 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 3,
        max_crates = 10,
        min_spawn_delay = 35,
        max_spawn_delay = 130,
        collision_radius = 1.5,
        locations = {
            { 29.124,  -23.755, -191.366 },
            { 39.223,  -18.573, -193.936 },
            { 39.027,  -23.133, -193.901 },
            { 57.220,  -20.877, -198.820 },
            { 70.795,  -20.903, -199.465 },
            { 105.625, -20.935, -183.045 },
            { 39.466,  -30.429, -193.466 },
            { 18.391,  -21.290, -186.819 },
            { 36.363,  -25.797, -181.504 },
            { 39.472,  -8.763,  -186.310 },
            { 34.488,  3.291,   -200.767 },
            { -2.608,  -8.741,  -187.779 },
            { -3.744,  -12.136, -180.807 },
            { 21.547,  -0.166,  -182.350 },
            { 27.223,  -5.802,  -178.733 },
            { 13.082,  3.520,   -180.452 },
            { 18.871,  -8.163,  -174.336 },
            { -3.372,  -5.666,  -174.988 },
            { -0.908,  -21.041, -166.947 },
            { 16.245,  -20.635, -170.580 },
            { 7.135,   -6.789,  -170.567 },
            { 1.761,   20.467,  -166.734 },
            { 12.571,  20.467,  -166.734 },
            { 7.224,   14.187,  -177.406 },
            { 9.097,   33.324,  -169.426 },
            { 5.113,   33.318,  -169.426 },
            { 105.092, -20.980, -181.278 },
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
