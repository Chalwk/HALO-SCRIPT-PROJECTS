local MAP = {
    safe_zone = {
        center = { x = -26.032, y = 32.365, z = 9.007 },
        min_size = 35,
        max_size = 350,
        shrink_steps = 6,
        game_time = 7 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 15,
        damage_per_second = 0.025
    },
    sky_spawn_coordinates = {
        -- red base:
        { 20.530,  -26.365, 0.756, 5.190, 25 },
        { 29.136,  -26.417, 0.734, 4.382, 25 },
        { 28.970,  -17.990, 0.737, 1.925, 25 },
        { 24.772,  -16.339, 0.761, 2.081, 25 },
        { 24.851,  -22.085, 2.100, 6.265, 25 },
        { 14.390,  -25.645, 0.783, 0.351, 25 },
        { 28.682,  -8.171,  0.826, 4.366, 25 },
        -- blue base:
        { -73.649, 90.773,  0.787, 1.960, 25 },
        { -82.091, 90.775,  0.739, 1.201, 25 },
        { -77.863, 81.133,  0.775, 5.207, 25 },
        { -77.838, 86.560,  2.100, 3.151, 25 },
        { -82.519, 74.541,  0.772, 0.396, 25 },
        { -66.125, 85.180,  0.751, 2.979, 25 },
        { -77.834, 97.242,  1.167, 4.693, 25 },
        -- random locations:
        { -66.672, 70.649,  1.355, 5.643, 25 },
        { -64.324, 56.265,  0.939, 4.329, 25 },
        { -77.568, 53.483,  0.896, 0.690, 25 },
        { -71.054, 44.169,  0.786, 5.662, 25 },
        { -49.053, 28.480,  0.693, 0.381, 25 },
        { -40.017, 46.015,  0.680, 3.890, 25 },
        { -38.218, 22.356,  0.680, 0.680, 25 },
        { -13.385, 43.253,  0.680, 3.989, 25 },
        { -13.139, 18.679,  0.680, 0.589, 25 },
        { 4.520,   27.649,  0.741, 5.938, 25 },
        { 20.553,  19.636,  0.748, 2.663, 25 },
        { 24.900,  10.496,  0.904, 3.595, 25 },
        { 19.774,  -2.620,  0.763, 5.417, 25 },
        { 17.437,  -10.015, 0.910, 2.457, 25 },
        { -3.592,  -4.341,  3.108, 2.937, 25 },
        { -26.051, 26.971,  9.007, 4.711, 25 },
        { -26.050, 37.997,  9.007, 1.576, 25 },
        { -30.354, 48.994,  8.685, 5.657, 25 },
        { -28.036, 68.951,  5.638, 4.906, 25 },
    },
    crates = {
        crate_tag = { 'eqip', 'powerups\\full-spectrum vision' },
        min_crates = 6,
        max_crates = 9,
        min_spawn_delay = 30,
        max_spawn_delay = 120,
        collision_radius = 1.5,
        locations = {
            { -13.347, 24.438, 4.208 },
            { -12.433, 37.856, 4.916 },
            { -38.982, 42.028, 4.879 },
            { -44.885, 45.870, 10.307 },
            { -30.758, 48.153, 10.630 },
            { -31.732, 43.013, 12.687 },
            { -28.565, 3.513,  8.030 },
            { -6.863,  -7.209, 4.912 },
            { 15.435,  8.551,  10.328 },
            { 17.688,  -4.564, 8.032 },
            { 1.149,   5.775,  8.889 },
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
