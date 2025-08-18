--[[
=====================================================================================
SCRIPT NAME:      parkour_timer.lua
DESCRIPTION:      Automated parkour course timing system with:
                  - Zone-based timer activation (start/finish)
                  - Individual player time tracking
                  - Personal best records and announcements
                  - Multi-map configuration support
                  - Custom checkpoint definitions per map

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

-- Define checkpoints (X, Y, Z bounds)
local checkpoints = {
    ["bloodgulch"] = {
        start = { x1 = -5, y1 = -5, z1 = -1, x2 = 5, y2 = 5, z2 = 3 },
        finish = { x1 = 40, y1 = 40, z1 = 0, x2 = 50, y2 = 50, z2 = 5 },
        start_respawn = { x = 0, y = 0, z = 0 }, -- Start respawn location
        checkpoints = {                        -- List of checkpoints (in order)
            { x = 10, y = 10, z = 0 },         -- Checkpoint 1
            { x = 20, y = 20, z = 0 },         -- Checkpoint 2
            -- Add more as needed
        }
    },
    -- more maps here
}

-- Configuration
local CHECKPOINT_RADIUS = 3.0     -- Detection radius around checkpoint
local RESPAWN_HEIGHT_OFFSET = 0.5 -- Z-axis offset to prevent ground sticking

-- Store timers and results
local active_runs = {}
local best_times = {}
local zone_flags = {} -- Tracks whether player was in start zone last tick
local start, finish, map_data
local map

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
    register_callback(cb['EVENT_LEAVE'], "OnLeave")
    register_callback(cb['EVENT_GAME_START'], "OnStart")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_SPAWN'], "OnSpawn")
    register_callback(cb['EVENT_COMMAND'], "OnCommand")
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    map = get_var(0, '$map')
    map_data = checkpoints[map]

    if not map_data then return end -- send error or something

    start = map_data.start
    finish = map_data.finish

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

function OnPlayerDeath(victim)
    local player = tonumber(victim)
    if active_runs[player] then
        local last = active_runs[player].last_checkpoint
        if last == 0 then
            active_runs[player].respawn_location = map_data.start_respawn
        else
            active_runs[player].respawn_location = map_data.checkpoints[last]
        end
    end
end

local function set_position(player, x, y, z)
    local dyn = get_dynamic_player(player)
    if dyn ~= 0 then
        write_vector3d(dyn + 0x5C, x, y, z)
    end
end

function OnSpawn(player)
    if active_runs[player] and active_runs[player].respawn_location then
        local loc = active_runs[player].respawn_location
        set_position(player, loc.x, loc.y, loc.z + RESPAWN_HEIGHT_OFFSET)
        active_runs[player].respawn_location = nil
    end
end

function OnCommand(player, command)
    command = string.lower(command)
    if command == "reset" and active_runs[player] then
        active_runs[player].last_checkpoint = 0
        local loc = map_data.start_respawn
        if player_alive(player) then
            set_position(player, loc.x, loc.y, loc.z + RESPAWN_HEIGHT_OFFSET)
        else
            active_runs[player].respawn_location = loc
            execute_command("kill " .. player)
        end
        say(player, "Run reset to start.")
    end
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

local function distance(x1, y1, z1, x2, y2, z2)
    local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
    return math.sqrt(dx * dx + dy * dy + dz * dz)
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
                    name = get_var(i, "$name"),
                    last_checkpoint = 0,   -- Track last checkpoint
                    respawn_location = nil -- Pending respawn location
                }
                say(i, "🏁 Parkour run started! Go go go!")
            end
            zone_flags[i] = in_start

            -- Checkpoint detection
            if active_runs[i] and map_data.checkpoints then
                local next_index = active_runs[i].last_checkpoint + 1
                if next_index <= #map_data.checkpoints then
                    local cp = map_data.checkpoints[next_index]
                    local dist = distance(x, y, z, cp.x, cp.y, cp.z)
                    if dist <= CHECKPOINT_RADIUS then
                        active_runs[i].last_checkpoint = next_index
                        say(i, "✓ Checkpoint " .. next_index .. " of " .. #map_data.checkpoints .. " reached!")
                    end
                end
            end

            if active_runs[i] and map_data.checkpoints then
                local next_index = active_runs[i].last_checkpoint + 1
                if next_index <= #map_data.checkpoints then
                    local cp = map_data.checkpoints[next_index]
                    local dist = distance(x, y, z, cp.x, cp.y, cp.z)
                    if dist <= CHECKPOINT_RADIUS then
                        -- Prevent skipping checkpoints
                        if next_index == active_runs[i].last_checkpoint + 1 then
                            active_runs[i].last_checkpoint = next_index
                            say(i, "✓ Checkpoint " .. next_index .. " of " .. #map_data.checkpoints .. " reached!")
                        else
                            say(i, "✗ Complete checkpoints in order!")
                        end
                    end
                end
            end

            -- Finish run (requires all checkpoints)
            if active_runs[i] and in_zone(x, y, z, finish) then
                local total_checkpoints = map_data.checkpoints and #map_data.checkpoints or 0
                if active_runs[i].last_checkpoint == total_checkpoints then
                    local elapsed = os.clock() - active_runs[i].start_time
                    local formatted = string.format("%.2f", elapsed)
                    say(i, "🏁 Finished parkour in " .. formatted .. " seconds!")

                    -- Store best time
                    if not best_times[i] or elapsed < best_times[i] then
                        best_times[i] = elapsed
                        say_all("🌟 " .. active_runs[i].name .. " set a new best time: " .. formatted .. "s!")
                    end

                    active_runs[i] = nil
                else
                    say(i, "✗ Complete all checkpoints first! (" .. active_runs[i].last_checkpoint .. "/" .. total_checkpoints .. ")")
                end
            end
        end
        ::continue::
    end
end