--[[
===============================================================================
SCRIPT NAME:      custom_vehicle_spawner.lua
DESCRIPTION:      Manages persistent vehicle spawns with:
                  - Automatic respawning of moved vehicles
                  - Map-specific vehicle configurations
                  - Occupancy detection
                  - Configurable respawn timers
                  - Movement threshold detection
                  - Multi-map support
                  - Gametype-specific setups

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = '1.12.0.0'

local VEHICLES = {
    bloodgulch = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         23.598,  -102.343, 2.163,  -0.000, 30, 1.5 },
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         38.119,  -64.898,  0.617,  -2.260, 30, 1.5 },
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         51.349,  -61.517,  1.759,  -1.611, 30, 1.5 },
            { "vehi", "vehicles\\warthog\\mp_warthog",           28.854,  -90.193,  0.434,  -0.848, 30, 1.5 },
            { "vehi", "vehicles\\warthog\\mp_warthog",           43.559,  -64.809,  1.113,  5.524,  30, 1.5 },
            { "vehi", "vehicles\\rwarthog\\rwarthog",            50.655,  -87.787,  0.079,  -1.936, 30, 1.5 },
            { "vehi", "vehicles\\rwarthog\\rwarthog",            62.745,  -72.406,  1.031,  3.657,  30, 1.5 },
            { "vehi", "vehicles\\banshee\\banshee_mp",           70.078,  -62.626,  3.758,  4.011,  30, 1.5 },
            { "vehi", "vehicles\\c gun turret\\c gun turret_mp", 29.537,  -53.667,  2.945,  5.110,  30, 1.5 },
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         104.017, -129.761, 1.665,  -3.595, 30, 1.5 },
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         81.150,  -169.359, 0.158,  1.571,  30, 1.5 },
            { "vehi", "vehicles\\scorpion\\scorpion_mp",         97.117,  -173.132, 0.744,  1.532,  30, 1.5 },
            { "vehi", "vehicles\\warthog\\mp_warthog",           102.312, -144.626, 0.580,  1.895,  30, 1.5 },
            { "vehi", "vehicles\\warthog\\mp_warthog",           67.961,  -171.002, 1.428,  0.524,  30, 1.5 },
            { "vehi", "vehicles\\rwarthog\\rwarthog",            106.885, -169.245, 0.091,  2.494,  30, 1.5 },
            { "vehi", "vehicles\\banshee\\banshee_mp",           64.178,  -176.802, 3.960,  0.785,  30, 1.5 },
            { "vehi", "vehicles\\c gun turret\\c gun turret_mp", 118.084, -185.346, 6.563,  2.411,  30, 1.5 },
            { "vehi", "vehicles\\ghost\\ghost_mp",               59.765,  -116.449, 1.801,  0.524,  30, 1.5 },
            { "vehi", "vehicles\\c gun turret\\c gun turret_mp", 51.315,  -154.075, 21.561, 1.346,  30, 1.5 },
            { "vehi", "vehicles\\rwarthog\\rwarthog",            78.124,  -131.192, -0.027, 2.112,  30, 1.5 },
            -- Add more vehicles here...
        }
    },

    dangercanyon = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   18.586,  -5.642,  -3.475, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       15.865,  -0.159,  -3.630, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    18.575,  -1.180,  -3.477, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    12.101,  -10.948, -3.551, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -18.490, -1.154,  -3.477, 2.6,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   5.520,   -3.654,  -3.476, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', 22.390,  -3.442,  -2.921, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       15.848,  -6.848,  -3.629, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', -22.264, -3.420,  -2.921, 2.5,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -18.496, -5.703,  -3.476, 2.7,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -16.040, 0.106,   -3.631, 2.4,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -16.126, -6.968,  -3.629, 2.6,   30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -12.197, -10.752, -3.544, 3.0,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -5.702,  -3.555,  -3.476, 0.000, 30, 1 },
        }
    },

    icefields = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -80.623, 79.708,  1.152, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -83.659, 80.909,  1.075, 4.5,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       30.469,  -31.389, 1.259, 2,     30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', 24.763,  -12.718, 1.626, 2,     30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       27.739,  -15.089, 0.976, 2.5,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', 24.851,  -30.584, 1.918, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -72.503, 92.652,  1.369, 1.5,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -72.411, 81.143,  1.079, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    31.567,  -17.016, 1.543, 2.6,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', -77.981, 77.600,  1.847, 1,     30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -85.397, 91.727,  1.260, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -84.105, 94.894,  1.206, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   29.880,  -28.860, 1.206, 2.5,   30, 1 },
        }
    },

    deathisland = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            -41.818, -14.457, 4.666,  90,    30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         40.534,  16.246,  6.021,  0.000, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           22.309,  13.483,  21.673, 90,    30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               47.736,  12.864,  3.989,  0.000, 30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           40.333,  29.279,  4.409,  0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               -47.161, -11.053, 4.436,  90,    30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           -33.348, -19.829, 10.187, 3,     30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            -36.463, -19.537, 9.851,  35,    30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               35.274,  16.026,  22.881, 450,   30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 46.879,  -34.247, 14.541, 45,    30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -67.956, 16.244,  15.860, 20,    30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           -42.249, -0.521,  5.901,  3,     30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         -44.822, -2.815,  5.672,  10,    30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               47.439,  20.963,  3.738,  5.524, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            43.864,  7.471,   5.052,  5.524, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           -19.246, -9.643,  23.063, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         46.443,  10.253,  5.029,  0.000, 30, 1 },
        }

    },

    infinity = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           -0.267, -152.319, 13.281, -1.6,  30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               5.700,  24.364,   11.133, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            1.083,  -152.162, 13.262, -1.6,  30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -1.697, 35.371,   15.508, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           2.690,  -152.440, 13.305, -1.6,  30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            -2.332, 34.917,   11.294, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               7.544,  -145.018, 13.114, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               7.703,  25.368,   11.054, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           -2.827, 35.320,   20.467, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           1.589,  -152.236, 22.351, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               -8.678, 25.505,   11.341, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           -0.755, 35.351,   20.468, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            1.226,  34.386,   11.148, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 0.450,  -152.256, 17.391, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            -1.644, -152.491, 13.309, -1.6,  30, 1 },
        }

    },

    sidewinder = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           -29.066, -26.052, -3.291, 1.3,   30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            -35.241, -26.310, -3.158, 1.3,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         -38.041, -21.039, -2.325, 1.3,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               -38.252, -25.522, -3.159, 1.4,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           -33.374, -24.858, -3.200, 1.3,   30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 2.089,   56.595,  -1.559, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           -49.187, -8.474,  -3.221, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         35.495,  -23.929, -2.642, 2.1,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               26.244,  -30.624, -3.167, 2.1,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           32.224,  -27.150, -3.004, 1.9,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           28.197,  -30.157, -3.065, 1.9,   30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            33.426,  -30.138, -3.178, 2.4,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp',         30.649,  -22.840, -2.444, 2.2,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               22.657,  -33.542, -3.441, 2.1,   30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           48.954,  -10.019, -3.221, 1.5,   30, 1 },
        }

    },

    timberland = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   19.884,  -42.670, -17.340, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', -27.299, -38.046, -19.175, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   12.150,  -45.322, -17.196, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -13.882, 45.684,  -17.536, -1.23, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       13.609,  -39.875, -17.469, 1.2,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', -16.103, 37.974,  -16.268, -1.23, 30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -11.713, 46.014,  -17.173, -1.2,  30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',   -18.142, 43.397,  -17.480, -1.2,  30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', 16.682,  -37.446, -16.190, 1.2,   30, 1 },
            { 'vehi', 'vehicles\\scorpion\\scorpion_mp', 31.865,  38.323,  -20.098, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -13.430, 43.247,  -17.612, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    -21.908, 45.914,  -17.042, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',       -13.329, 40.472,  -17.684, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',    21.796,  -45.015, -17.220, 0.000, 30, 1 },
        }

    },

    gephyrophobia = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            28.866,  -34.415,  -15.082, -1.5,   30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           -17.485, -29.305,  -0.554,  -1.5,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               25.586,  -112.666, -15.232, 1.5,    30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           67.982,  -36.012,  -0.361,  -1.5,   30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 17.201,  -77.868,  -12.211, 0.000,  30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               25.599,  -23.829,  -17.925, -1.5,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           24.428,  -109.774, -15.082, 1.50,   30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            16.568,  -41.623,  -13.923, -1.5,   30, 1 },
            { 'vehi', 'vehicles\\rwarthog\\rwarthog',            16.599,  -102.772, -13.923, -1.0,   30, 1 },
            { 'vehi', 'vehicles\\warthog\\mp_warthog',           36.975,  -102.973, -13.923, 1.5,    30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               28.033,  -120.659, -17.925, 1.5,    30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp',           67.910,  -113.410, -0.361,  -1.5,   30, 1 },
            { 'vehi', 'vehicles\\ghost\\ghost_mp',               25.637,  -120.816, -17.925, 1.5,    30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 64.754,  -73.950,  -0.859,  -0.999, 30, 1 },
        }

    },

    beavercreek = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 22.457, 13.712, 3.225, 3.1, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 5.517,  13.818, 1.725, 6.1, 30, 1 },
        }

    },

    boardingaction = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 16.053, 3.722,   0.400, -2.7,  30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 3.970,  3.561,   0.400, 0.000, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 18.759, -21.075, 5.400, -2.7,  30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 1.168,  21.073,  5.400, 0.000, 30, 1 },
        }

    },

    carousel = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 0.034, 0.036, -0.470, 1.000, 30, 1 },
        }

    },

    chillout = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -1.392, 5.885, 0.999, 0.645, 30, 1 },
        }

    },

    damnation = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 10.216, -3.921, 6.925, -2.8,  30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -7.760, 7.258,  3.650, -1.20, 30, 1 },
        }

    },

    hangemhigh = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 20.972, -6.249, -3.900, 0.031, 30, 1 },
        }

    },

    longest = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -14.757, -12.095, 0.300, 0.060, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 13.026,  -17.045, 0.300, 2.800, 30, 1 },
        }

    },

    prisoner = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 0.828, -2.409, 1.600, 1.610, 30, 1 },
        }

    },

    putput = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -18.864, -20.195, 2.500, 1.000, 30, 1 },
        }

    },

    ratrace = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 8.310, -11.076, 0.400, 0.041, 30, 1 },
        }

    },

    wizard = {
        ['CE_SNIPERS_DREAM_TEAM'] = {
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 4.568,  4.335,  -4.100, 0.466,  30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', 4.399,  -4.581, -4.100, -0.636, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -4.550, -4.381, -4.100, -0.651, 30, 1 },
            { 'vehi', 'vehicles\\c gun turret\\c gun turret_mp', -4.404, 4.553,  -4.100, 0.599,  30, 1 },
        }
    }
    -- Add more maps here...
}

local os_time = os.time
local table_insert = table.insert
local vehicles = {} -- Active vehicle instances
local Vehicle = {}  -- Vehicle metatable

local get_object_memory, destroy_object, spawn_object, lookup_tag, read_dword =
    get_object_memory, destroy_object, spawn_object, lookup_tag, read_dword

local player_present, player_alive, get_dynamic_player, read_vector3d = player_present, player_alive, get_dynamic_player,
    read_vector3d

function Vehicle:new(data)
    setmetatable(data, self)
    self.__index = self
    return data
end

function Vehicle:spawn()
    if self.object then
        destroy_object(self.object)
    end
    self.object = spawn_object('', '', self.x, self.y, self.z, self.yaw, self.meta_id)
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function isOccupied(vehicleObj)
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local dyn = get_dynamic_player(i)
            if dyn ~= 0 then
                local v_id = read_dword(dyn + 0x11C)
                if v_id ~= 0xFFFFFFFF then
                    local v_obj = get_object_memory(v_id)
                    if v_obj ~= 0 and v_obj == vehicleObj then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function hasMoved(v, obj)
    local cx, cy, cz = read_vector3d(obj + 0x5C)
    local dx, dy, dz = v.x - cx, v.y - cy, v.z - cz
    local dist2 = dx * dx + dy * dy + dz * dz
    return dist2 > (v.respawn_radius * v.respawn_radius)
end

function CheckVehicles()
    local now = os_time()
    for _, v in pairs(vehicles) do
        local obj = get_object_memory(v.object)
        if obj == 0 then
            v:spawn()
            goto continue
        end
        if isOccupied(obj) then
            v.delay = nil
            goto continue
        end

        if hasMoved(v, obj) then
            v.delay = v.delay or (now + v.respawn_time)
            if now >= v.delay then
                v:spawn()
                v.delay = nil
            end
        else
            v.delay = nil
        end

        ::continue::
    end
end

local function initVehicles()
    vehicles   = {}

    local map  = get_var(0, '$map')
    local mode = get_var(0, '$mode')
    local cfg  = VEHICLES[map] and VEHICLES[map][mode]

    if not cfg then return end

    for _, entry in ipairs(cfg) do
        local class, tag, x, y, z, yaw, respawn_time, radius = unpack(entry)
        local meta_id = getTag(class, tag)
        if meta_id then
            local v = Vehicle:new({
                x = x,
                y = y,
                z = z,
                yaw = yaw,
                meta_id = meta_id,
                respawn_time = respawn_time,
                respawn_radius = radius
            })
            v:spawn()
            table_insert(vehicles, v)
        end
    end

    register_callback(cb['EVENT_TICK'], 'CheckVehicles')
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    OnGameStart()
end

function OnGameStart()
    if get_var(0, '$gt') ~= 'n/a' then
        initVehicles()
    end
end

function OnGameEnd()
    unregister_callback(cb['EVENT_TICK'])
end

function OnScriptUnload() end
