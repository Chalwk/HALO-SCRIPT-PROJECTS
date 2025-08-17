-- One-time load of Coordinates library:
local coordinates = assert(loadfile "Coordinates.lib")()

-- coordinates[map].ffa
-- coordinates[map].red
-- coordinates[map].blue
-- coordinates[map].random

---------------------------------------------------------------
-- EXAMPLE USAGE:

api_version = "1.12.0.0"

local map_table

function OnScriptLoad()
    register_callback(cb["EVENT_PRESPAWN"], "OnPreSpawn")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    OnGameStart()
end

function OnGameStart()
    map_table = nil
    if (get_var(0, "$gt") ~= "n/a") then
        map_table = coordinates[get_var(0, "$map")]
    end
end

function OnPreSpawn(Ply)
    if map_table then
        local DyN = get_dynamic_player(Ply)
        if DyN ~= 0 then
            math.randomseed(os.clock())
            local pos = map_table.red
            local n = math.random(#pos)
            local x, y, z, r = unpack(pos[n])
            write_vector3d(DyN + 0x5C, x, y, z)
            write_vector3d(DyN + 0x74, math.cos(r), math.sin(r), 0)
        end
    end
end