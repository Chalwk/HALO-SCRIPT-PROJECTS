--[[
--=====================================================================================================--
Script Name: Object Spawner, for SAPP (PC & CE)
Description: Easily define custom object spawns /w rotation 

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local objects = {

    -- Objects will be spawned on a per-map basis.

    ["bloodgulch"] = {
        --
        -- Format as follows: tag type, tag name, x, y, z, rotation
        -- Make sure the object rotation is in RADIANS not DEGREES
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
    if (get_var(0, "$gt") ~= "n/a") then
        local map = get_var(0, "$map")
        if (objects[map]) then
            for _, v in pairs(objects[map]) do
                spawn_object(v[1], v[2], v[3], v[4], v[5], v[6])
            end
        end
    end
end
