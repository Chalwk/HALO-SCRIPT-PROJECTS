--[[
=====================================================================================
SCRIPT NAME:      flag_circle_spawner.lua
DESCRIPTION:      Spawns flags in a perfect circle around a center point.

                  Configuration:
                  - Adjustable flag count (16 by default)
                  - Customizable circle radius (3 world units)
                  - Precise center point coordinates
                  - Uniform height placement (2 units above ground)

                  Technical Notes:
                  - Uses radians for precise angular distribution
                  - Automatically executes on game start
                  - Supports all SAPP-supported Halo versions

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

-- Constants
local TOTAL_FLAGS = 16
local HEIGHT = 2
local RADIUS = 3
local CENTER_X, CENTER_Y, CENTER_Z = 79.48, -118.68, 0.24
local ANGLE_STEP = 360 / TOTAL_FLAGS

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
end

function OnGameStart()
    -- Loop through the number of flags and spawn them in a circle
    for i = 0, TOTAL_FLAGS - 1 do
        local angle = i * ANGLE_STEP * math.pi / 180  -- Convert angle to radians

        -- Calculate the x, y, and z coordinates for the flag:
        local x = CENTER_X + RADIUS * math.cos(angle)
        local y = CENTER_Y + RADIUS * math.sin(angle)
        local z = CENTER_Z + HEIGHT

        -- Spawn the flag:
        spawn_object('weap', 'weapons\\flag\\flag', x, y, z)
    end
end

function OnScriptUnload()
    -- N/A
end
