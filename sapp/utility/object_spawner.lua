--[[
=====================================================================================
SCRIPT NAME:      object_spawner.lua
DESCRIPTION:      Custom object placement system with rotation control.

                  Features:
                  - Precise coordinate positioning
                  - Customizable object rotation
                  - Multi-object spawning
                  - Persistent spawn configurations

Copyright (c) 2021-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

local objects = {

    -- Objects will be spawned on a per-map basis.

    ["bloodgulch"] = {
        --
        -- Format as follows: tag type, tag name, x, y, z, rotation
        -- Make sure object rotation coordinates are in radians not degrees.
        --
        -- This weapon will spawn on top of Red Base by the ramp
        { "weap", "weapons\\sniper rifle\\sniper rifle", 90.899, -159.633, 1.704, 1.587 },
    },

    -- Repeat the structure to add more entries:
    ["example map"] = {
        { "tag type", "tag name", 0, 0, 0, 0 },
        { "tag type", "tag name", 0, 0, 0, 0 },
        { "tag type", "tag name", 0, 0, 0, 0 },
        { "tag type", "tag name", 0, 0, 0, 0 },
    },
}

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
end

function OnGameStart()
    local map = get_var(0, "$map")
    if get_var(0, "$gt") ~= "n/a" and objects[map] then
        for _, v in pairs(objects[map]) do
            spawn_object(v[1], v[2], v[3], v[4], v[5], v[6])
        end
    end
end
