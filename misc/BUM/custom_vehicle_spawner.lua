--[[
=====================================================================================
SCRIPT NAME:      custom_vehicle_spawner.lua
DESCRIPTION:      Manages persistent vehicle spawns with position enforcement.

                  Key Features:
                  - Pre-defined spawn coordinates
                  - Automatic position reset for unused vehicles
                  - Configurable reset delay
                  - Occupancy detection

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

local VehicleSpawner = {

    --
    -- EXAMPLE FOR BLOODGULCH:
    --
    ['bloodgulch'] = {

        -- Replace 'example_game_mode' with your own game mode name:
        ['example_game_mode'] = {

            --
            -- format: {class, name, x,y,z, rotation, respawn_time, respawn_radius}
            --

            -- These two example vehicles will be moved back to their original position after 30 seconds if
            -- they have moved from their original position by more than 1 world/unit and aren't occupied.

            -- Vehicle #1: (middle map):
            { 'vehi', 'vehicles\\warthog\\mp_warthog', 66.580, -120.474, 0.064, 6.588, 30, 1 },

            -- Vehicle #2 (just forward of red hill)
            { 'vehi', 'vehicles\\banshee\\banshee_mp', 78.099, -131.189, -0.035, 0.300, 30, 1 },

            --
            -- repeat the structure to add more vehicle entries.
            --
        },

        --
        -- repeat the structure to add more game modes.
        --
    },

    ['deathisland'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['icefields'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['infinity'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['sidewinder'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['timberland'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['dangercanyon'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['beavercreek'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['boardingaction'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['carousel'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['chillout'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['damnation'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['gephyrophobia'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['hangemhigh'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['longest'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['prisoner'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['putput'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['ratrace'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    },

    ['wizard'] = {
        ['example_game_mode'] = {
            { '', '', 0, 0, 0, 0, 30, 1 },
        },
    }
}

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    OnStart()
end

--
-- Constructor function for each vehicle:
--
function VehicleSpawner:NewVehicle(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--
-- Spawns a vehicle at the specified coordinates:
--
function VehicleSpawner:SpawnVehicle()

    if (self.object) then
        destroy_object(self.object)
    end

    local object_id = self.meta_id
    local x, y, z, r = self.x, self.y, self.z, self.rotation

    self.object = spawn_object('', '', x, y, z, r, object_id)
end

--
-- Checks if a vehicle is occupied:
--
local function Occupied(obj)
    for i = 1, 16 do
        local dyn = get_dynamic_player(i)
        if (player_present(i) and player_alive(i) and dyn ~= 0) then
            local vehicle = read_dword(dyn + 0x11C)
            local object = get_object_memory(vehicle)
            return (object ~= 0 and vehicle ~= 0xFFFFFFFF and object == obj)
        end
    end
    return false
end

--
-- Returns the tag address using a tags class and name:
--
local function GetTag(Class, Name)
    local tag = lookup_tag(Class, Name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

--
-- Set up function that runs when the map loads:
--
local objects = {}
function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then

        objects = {}
        local vs = VehicleSpawner
        local map = get_var(0, '$map')
        local mode = get_var(0, '$mode')

        local reg

        -- Check if the current map has any vehicles:
        if (vs[map] and vs[map][mode]) then

            -- Loop through all vehicles for this map:
            for i, v in ipairs(vs[map][mode]) do
                local class, name, x, y, z, rotation, respawn_time, respawn_radius = unpack(v)
                local tag = GetTag(class, name)
                if (tag) then
                    reg = true
                    objects[i] = vs:NewVehicle({
                        x = x,
                        y = y,
                        z = z,
                        meta_id = tag,
                        rotation = rotation,
                        respawn_time = respawn_time,
                        respawn_radius = respawn_radius
                    })
                    objects[i]:SpawnVehicle()
                    --cprint('Spawning ' .. class .. ' ' .. name .. ' at ' .. x .. ', ' .. y .. ', ' .. z, 10)
                end
            end
            if (reg) then
                register_callback(cb['EVENT_TICK'], 'OnTick')
            else
                unregister_callback(cb['EVENT_TICK'])
            end
        end
    end
end

--
-- Unregister the tick callback when the map ends:
-- No need to keep checking for vehicles if the map is over.
--
function OnEnd()
    unregister_callback(cb['EVENT_TICK'])
end

--
-- Checks if we need to respawn a vehicle:
--
local sqrt = math.sqrt
local clock = os.clock
function OnTick()
    for _, v in pairs(objects) do

        local object = get_object_memory(v.object)
        if (object ~= 0) then

            -- Get the object's current position:
            local x, y, z = read_vector3d(object + 0x5C)

            -- Check if it's occupied:
            if (not Occupied(object)) then

                -- Check if vehicle has moved from its original position:
                local distance = sqrt((v.x - x) ^ 2 + (v.y - y) ^ 2 + (v.z - z) ^ 2)
                if (distance > v.respawn_radius) then
                    if (not v.delay) then
                        v.delay = clock() + v.respawn_time

                        -- Move vehicle back to its original position after a delay:
                    elseif (clock() >= v.delay) then
                        v.delay = nil
                        v:SpawnVehicle()
                    --else
                        --print('Respawning vehicle in ' .. v.delay - clock() .. ' seconds.', 10)
                    end

                elseif (v.timer) then
                    v.delay = nil
                end
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end