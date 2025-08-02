--============================================================================--
-- SCRIPT NAME:      Custom Vehicle Spawner
-- DESCRIPTION:      Allows players to spawn and instantly enter a vehicle
--                   at their current location using a command. Vehicles
--                   automatically despawn after a configurable timeout
--                   if unoccupied.
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--============================================================================--

--========================= CONFIGURATION ====================================--

local DESPAWN_DELAY_SECONDS = 30

-- Define per-map vehicle commands
local map_vehicles = {
    ["bloodgulch"] = {
        ["hog1"] = { path = "vehicles\\warthog\\mp_warthog", seat = 0 },
        -- Add more commands here
    },
    -- Add additional maps here
}

--======================== INTERNAL STATE ====================================--

local active_vehicles = {}
api_version = "1.12.0.0"

--======================= SCRIPT CALLBACKS ===================================--

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], OnGameStart)
    register_callback(cb["EVENT_GAME_END"], OnGameEnd)
    register_callback(cb["EVENT_COMMAND"], OnCommand)
    OnGameStart()
end

function OnScriptUnload()
    -- Optional: clean up state if needed
end

function OnGameStart()
    if get_var(0, "$gt") == "n/a" then return end

    local map_name = get_var(0, "$map")
    active_vehicles = {}

    local map_config = map_vehicles[map_name]
    if not map_config then return end

    local proceed = false

    for command, data in pairs(map_config) do
        local meta_id = GetTag("vehi", data.path)
        if meta_id then
            active_vehicles[meta_id] = {
                command = command,
                path = data.path,
                seat = data.seat,
                object = nil,
                despawn_time = nil
            }
            proceed = true
        end
    end

    if proceed then
        register_callback(cb["EVENT_TICK"], OnTick)
    end
end

function OnGameEnd()
    unregister_callback(cb["EVENT_TICK"])
end

--========================== EVENT HANDLERS =================================--

function OnCommand(player, command)
    for meta_id, data in pairs(active_vehicles) do
        if data.command == command then
            local x, y, z = GetPlayerPosition(player)
            if not x then return false end

            local height_offset = 0.3
            local object_id = spawn_object("", "", x, y, z + height_offset, meta_id)
            data.object = object_id

            if tonumber(data.seat) == 7 then
                enter_vehicle(object_id, player, 0)
                enter_vehicle(object_id, player, 2)
            else
                enter_vehicle(object_id, player, tonumber(data.seat) or 0)
            end
            return false
        end
    end
    return true
end

function OnTick()
    for meta_id, data in pairs(active_vehicles) do
        local object = get_object_memory(data.object)
        if object ~= 0 and not IsVehicleOccupied(object) then
            if not data.despawn_time then
                data.despawn_time = os.clock() + DESPAWN_DELAY_SECONDS
            elseif os.clock() >= data.despawn_time then
                destroy_object(data.object)
                data.object = nil
                data.despawn_time = nil
            end
        elseif object ~= 0 then
            data.despawn_time = nil
        end
    end
end

--========================== HELPER FUNCTIONS ================================--

-- Returns the memory address of the specified tag
function GetTag(class, name)
    local tag = lookup_tag(class, name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

-- Returns true if any player is occupying the given vehicle
function IsVehicleOccupied(vehicle_object)
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local player = get_dynamic_player(i)
            if player ~= 0 then
                local vehicle_id = read_dword(player + 0x11C)
                local object = get_object_memory(vehicle_id)
                if object ~= 0 and object == vehicle_object then
                    return true
                end
            end
        end
    end
    return false
end

-- Gets a player's position or returns nil if unavailable
function GetPlayerPosition(player)
    local player_obj = get_dynamic_player(player)
    if player_alive(player) and player_obj ~= 0 then
        local vehicle_id = read_dword(player_obj + 0x11C)
        local in_vehicle = get_object_memory(vehicle_id)
        if in_vehicle == 0xFFFFFFFF then
            return read_vector3d(player_obj + 0x5C)
        else
            say(player, "You are already in a vehicle.")
        end
    else
        say(player, "Unable to spawn vehicle.")
    end
    return nil
end