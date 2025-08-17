local MAP = {
    safe_zone = {
        center = { x = 7.261, y = -19.631, z = -162.233 },
        min_size = 5,
        max_size = 180,
        shrink_steps = 5,
        game_time = 5 * 60,
        bonus_time = 30,
        max_deaths_until_spectate = 3,
        public_message_interval = 15,
        damage_per_second = 0.025
    },
    sky_spawn_coordinates = {
        -- red base:
        { -77.675,  -6.244,   13.695 },
        { -103.628, -15.827,  13.676 },
        { -77.810,  -26.053,  13.695 },
        { -89.377,  -3.657,   0.178 },
        { -84.937,  -27.452,  0.153 },
        -- blue base:
        { 144.170,  -25.646,  25.504 },
        { 144.306,  -14.896,  25.504 },
        { 136.788,  -36.380,  20.153 },
        { 136.751,  -7.535,   20.136 },
        { 126.851,  -16.115,  20.133 },
        { 126.582,  -24.417,  20.133 },
        -- random locations:
        { 134.330,  -32.701,  15.344 },
        { 132.329,  -20.330,  14.035 },
        { 134.539,  -7.473,   14.737 },
        { 108.956,  -28.441,  13.449 },
        { 98.991,   -10.425,  15.257 },
        { 99.191,   -0.754,   20.909 },
        { 102.264,  -20.573,  23.475 },
        { 116.074,  -39.340,  24.623 },
        { 63.159,   -25.815,  13.585 },
        { 40.699,   -30.475,  13.220 },
        { 62.182,   -48.633,  10.276 },
        { 35.652,   -71.148,  7.599 },
        { 53.457,   -93.681,  0.847 },
        { 15.307,   -103.340, 2.145 },
        { -20.704,  -58.845,  4.039 },
        { -61.322,  -68.757,  1.240 },
        { -57.683,  -58.814,  6.000 },
        { -37.537,  -68.410,  8.248 },
        { -69.359,  7.105,    5.362 },
        { -79.311,  25.592,   0.817 },
        { -49.095,  20.836,   2.997 },
    },
    crates = {
        crate_tag = { 'eqip', 'cmt\\powerups\\human\\ammo_box\\powerups\\rocket_launcher_ammo_box' },
        min_crates = 3,
        max_crates = 10,
        min_spawn_delay = 35,
        max_spawn_delay = 130,
        collision_radius = 1.5,
        locations = {
            { -14.110, -64.008, 2.868 },
            { 5.792,   -60.481, 5.350 },
            { -80.016, -49.869, 1.103 },
            { -75.188, -15.920, 1.938 },
            { -73.318, -0.299,  3.382 },
            { -55.399, 2.519,   8.831 },
            { -55.969, 15.841,  5.187 },
            { -10.380, 0.674,   11.208 },
            { 5.453,   -29.187, 12.710 },
            { 13.498,  -15.646, 10.905 },
            { -8.923,  -35.221, 8.991 },
            { 64.416,  -19.975, 19.624 },
            { 155.752, 12.054,  24.061 },
            { 44.747,  -94.189, 1.419 },
            { 142.604, -18.447, 13.633 },
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
                    ['Needler'] = 'cmt\\weapons\\evolved_h1-spirit\\needler\\_needler_mp\\needler_mp',
                    ['Battle Rifle (SpecOps)'] = 'cmt\\weapons\\evolved\\human\\battle_rifle\\_battle_rifle_specops\\battle_rifle_specops',
                    ['Plasma Rifle'] = 'cmt\\weapons\\evolved_h1-spirit\\plasma_rifle\\_plasma_rifle_mp\\plasma_rifle_mp',
                    ['Pistol'] = 'cmt\\weapons\\evolved_h1-spirit\\pistol\\_pistol_mp\\pistol_mp',
                    ['Brute Plasma Rifle'] = 'cmt\\weapons\\covenant\\brute_plasma_rifle\\reload\\brute plasma rifle',
                    ['Shotgun'] = 'cmt\\weapons\\evolved_h1-spirit\\shotgun\\shotgun',
                    ['Sniper Rifle'] = 'cmt\\weapons\\evolved_h1-spirit\\sniper_rifle\\sniper_rifle',
                    ['DMR'] = 'cmt\\weapons\\evolved\\human\\dmr\\dmr',
                    ['Assault Rifle'] = 'cmt\\weapons\\evolved_h1-spirit\\assault_rifle\\assault_rifle',
                    ['Rocket Launcher'] = 'cmt\\weapons\\evolved_h1-spirit\\rocket_launcher\\rocket_launcher',
                    ['Battle Rifle (H2A)'] = 'dreamweb\\weapons\\human\\battle_rifle\\_h2a\\battle_rifle',
                    ['Carbine'] = 'cmt\\weapons\\evolved\\covenant\\carbine\\carbine',
                    ['Battle Rifle'] = 'cmt\\weapons\\evolved\\human\\battle_rifle\\battle_rifle'
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
