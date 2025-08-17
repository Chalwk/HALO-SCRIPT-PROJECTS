-- Warthog ceiling bug fix for the map Bigass
-- Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>

-- DESCRIPTION:
-- Automatically respawns a glitched warthog at its starting position (w/ proper rotation).

local vehicles = {

    -- config starts --

    { type = 'vehi', -- red base
      name = 'vehicles\\warthog\\mp_warthog',
      pos = { -130.70628356934, -71.420822143555, -0.1817033290863, --[[6.6630392247964e-37]] } },

    { type = 'vehi', -- red base
      name = 'bourrin\\halo reach\\vehicles\\warthog\\h2 mp_warthog',
      pos = { -128.29972839355, -70.520156860352, -0.16934883594513, --[[-6.4093676162253e+14]] } },

    { type = 'vehi', -- blue base
      name = 'bourrin\\halo reach\\vehicles\\warthog\\h2 mp_warthog',
      pos = { 149.50099182129, 40.949256896973, -0.80388098955154, --[[3.5092477183271e+25]] } },

    { type = 'vehi', -- blue base
      name = 'bourrin\\halo reach\\vehicles\\warthog\\reach gauss hog',
      pos = { 152.07675170898, 40.980716705322, -0.75395542383194, --[[8.9575530326513e-10]] } }

    -- config ends --
}

----------------------------------------------------
-- IMPORTANT --
-- do not touch unless you know what you're doing --
--
local delay = 2
local unregister, game_started
----------------------------------------------------

api_version = "1.12.0.0"

function Init()

    game_started = false
    unregister = true

    if (get_var(0, "$gt") ~= "n/a") then

        game_started = true

        for _, v in pairs(vehicles) do
            v.object = 0
        end

        timer(1000 * delay, "CheckVehicles")
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_GAME_START'], "OnGameStart")
    register_callback(cb['EVENT_OBJECT_SPAWN'], "OnObjectSpawn")
    Init()
end

function OnGameStart()
    Init()
end

function OnGameEnd()
    game_started = false
end

-- Distance function using pythagoras theorem:
--
local function GetDistance(x1, y1, z1, x2, y2, z2, r)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2) <= r
end

function CheckVehicles()

    for _, v in pairs(vehicles) do

        local object = v.object
        if (object ~= 0 and object ~= 0xFFFFFFFF) then

            -- Where it currently is: vx,vy,vz
            --
            local vx, vy, vz = read_vector3d(object + 0x5C)

            -- Where it should be: x,y,z,r
            --
            local x = v.pos[1]
            local y = v.pos[2]
            local z = v.pos[3]
            local r = v.pos[4]

            -- Check if the vehicle is near its starting location (+/- 1 w/unit):
            --
            if (GetDistance(vx, vy, vz, x, y, z, 1)) then

                -- Check if its floating above the ground (z+0.2 w/units):
                --
                local height_offset = (vz - z) / vz * 100
                if (height_offset > 0.10) then

                    -- Respawn this vehicle:
                    --
                    destroy_object(v.mem)
                    local vehicle = spawn_object(v.type, v.name, x, y, z, r)
                    v.object = get_object_memory(vehicle)
                    v.mem = vehicle
                end
            end
        end
    end
    return game_started
end

local function GetTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return (Tag ~= 0 and read_dword(Tag + 0xC)) or nil
end

function OnObjectSpawn(_, MapID, _, ObjectID)
    for _, v in pairs(vehicles) do
        if (MapID == GetTag(v.type, v.name)) then
		print('got vehicle')

            timer(0, "SaveObjectID", ObjectID)

            -- Technical note:
            --
            -- If we don't delay the logic in SaveObjectID(),
            -- get_object_memory(ObjectID) will return 0.
            --

            if (unregister) then
                unregister = false
                timer(0, "UnregisterFunction")
            end
        end
    end
end

function SaveObjectID(ObjectID)
    local object = get_object_memory(ObjectID)
    if (object ~= 0) then
        for _, v in pairs(vehicles) do
            local vx, vy, vz = read_vector3d(object + 0x5C)
            local x, y, z = v.pos[1], v.pos[2], v.pos[3]
            local in_range = GetDistance(vx, vy, vz, x, y, z, 0.1)
            if (in_range) then
                v.object = object
                v.mem = ObjectID
                v.pos[4] = read_float(object + 0x82) -- rotation
            end
        end
    end
end

function UnregisterFunction()
    unregister_callback(cb["EVENT_OBJECT_SPAWN"])
end

function OnScriptUnload()
    -- N/A
end