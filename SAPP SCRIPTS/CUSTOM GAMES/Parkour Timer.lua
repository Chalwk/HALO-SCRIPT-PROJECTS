--=====================================================================================--
-- SCRIPT NAME:      Parkour Timer
-- DESCRIPTION:      Automatically tracks a player's time as they complete
--                   a parkour course. Timers start when a player crosses the start line.
--                   Perfect for obstacle maps, jump puzzles, and skill-based events.
--                   Features:
--                   - Auto-start timer when player enters the start zone
--                   - Auto-finish detection at the end zone
--                   - Per-player best time tracking and announcements
--                   - Multi-map support with per-map checkpoint definitions
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT © 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--


api_version = "1.12.0.0"

-- Define checkpoints (X, Y, Z bounds)
local checkpoints = {
    ["bloodgulch"] = {
        start = { x1 = -5, y1 = -5, z1 = -1, x2 = 5, y2 = 5, z2 = 3 },
        finish = { x1 = 40, y1 = 40, z1 = 0, x2 = 50, y2 = 50, z2 = 5 },
    },
    -- more maps here
}

-- Store timers and results
local active_runs = {}
local best_times = {}
local zone_flags = {} -- Tracks whether player was in start zone last tick
local start, finish
local map

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnLeave")
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    map = get_var(0, '$map')

    if not checkpoints[map] then return end -- send error or something

    start = checkpoints[map].start
    finish = checkpoints[map].finish

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnJoin(p)
    active_runs[p] = nil
    zone_flags[p] = false
end

function OnLeave(p)
    active_runs[p] = nil
    zone_flags[p] = nil
end

local function get_player_coords(playerId)
    local dynamic_player = get_dynamic_player(playerId)
    if dynamic_player == 0 then return nil end

    local x, y, z = read_vector3d(dynamic_player + 0x5c)
    local crouch = read_float(dynamic_player + 0x50C)

    return x, y, (crouch == 0 and z + 0.65) or (z + 0.35 * crouch)
end

local function in_zone(x, y, z, zone)
    return x and x >= zone.x1 and x <= zone.x2
        and y >= zone.y1 and y <= zone.y2
        and z >= zone.z1 and z <= zone.z2
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local x, y, z = get_player_coords(i)
            if not x then goto continue end

            -- Start run when entering start zone (from outside)
            local in_start = in_zone(x, y, z, start)
            if in_start and not zone_flags[i] and not active_runs[i] then
                active_runs[i] = {
                    start_time = os.clock(),
                    name = get_var(i, "$name")
                }
                say(i, "🏁 Parkour run started! Go go go!")
            end
            zone_flags[i] = in_start

            -- Finish run
            if active_runs[i] and in_zone(x, y, z, finish) then
                local elapsed = os.clock() - active_runs[i].start_time
                local formatted = string.format("%.2f", elapsed)
                say(i, "🏁 Finished parkour in " .. formatted .. " seconds!")

                -- Store best time
                if not best_times[i] or elapsed < best_times[i] then
                    best_times[i] = elapsed
                    say_all("🌟 " .. active_runs[i].name .. " set a new best time: " .. formatted .. "s!")
                end

                active_runs[i] = nil
            end
        end
        ::continue::
    end
end
