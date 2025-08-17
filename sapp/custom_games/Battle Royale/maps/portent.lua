local MAP = {
    safe_zone = {
        center = { x = 0.165, y = -0.032, z = 0.650 },
        min_size = 5,
        max_size = 100,
        shrink_steps = 5,
        game_time = 5 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 15,
        damage_per_second = 0.025
    },
    sky_spawn_coordinates = {
        -- red base:
        { 47.826,  20.071, -3.807 },
        { 46.060,  14.201, -3.886 },
        { 23.837,  9.859,  -4.650 },
        { 20.294,  15.857, -4.650 },
        { 49.895,  15.770, -1.127 },
        -- blue base:
        { -46.961, 19.766, -3.899 },
        { -45.938, 13.916, -3.864 },
        { -23.760, 9.668,  -4.650 },
        { -20.683, 15.951, -4.650 },
        { -50.184, 15.705, -0.978 },
        -- random locations:
        { -35.229, 9.511,  -6.300 },
        { -39.567, 43.439, -6.300 },
        { -22.486, 50.704, -5.450 },
        { 22.526,  50.533, -5.450 },
        { 35.757,  47.298, -5.055 },
        { 36.368,  3.793,  -6.300 },
        { 1.594,   27.893, 1.450 },
        { -1.829,  24.975, 1.450 },
        { 29.944,  32.433, -5.192 },
        { 7.642,   37.178, -6.300 },
        { -16.184, 34.589, -6.300 },
        { -33.536, 33.305, -5.580 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 3,
        max_crates = 10,
        min_spawn_delay = 35,
        max_spawn_delay = 130,
        collision_radius = 1.5,
        locations = {
            { -59.467, 13.242, -4.350 },
            { -69.333, 10.547, -2.050 },
            { -72.210, 9.798,  0.350 },
            { -58.108, 13.580, 0.350 },
            { 59.457,  13.203, -4.350 },
            { 58.105,  13.570, 0.350 },
            { 72.206,  9.783,  0.350 },
            { 68.969,  10.660, -2.050 },
            { 6.339,   3.624,  1.350 },
            { -6.241,  3.612,  1.350 },
            { -9.388,  16.037, 3.650 },
            { 9.226,   15.926, 3.650 },
            { -0.011,  46.374, 0.605 },
            { 42.599,  39.585, -5.609 },
            { -36.029, 52.862, -6.300 },
            { -48.080, 32.325, -6.300 },
            { -17.633, 30.546, 5.850 },
            { 18.006,  31.111, 5.850 },
            { 5.664,   10.089, 5.850 },
            { -5.950,  10.213, 5.850 },

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
