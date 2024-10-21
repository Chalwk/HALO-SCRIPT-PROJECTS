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
