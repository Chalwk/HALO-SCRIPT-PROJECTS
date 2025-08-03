--=====================================================================================--
-- SCRIPT NAME:      Liberty Vehicle Spawner
-- DESCRIPTION:      Allows players to spawn and instantly enter a vehicle
--                   at their current location using a command.
--                   Vehicles automatically despawn after a configurable
--                   timeout if left unoccupied.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
-- NOTICE:           You may use this script subject to the following license:
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--========================= CONFIGURATION ====================================--

local DESPAWN_DELAY_SECONDS = 30

-- Define per-map vehicle commands
local map_vehicles = {

    ["bloodgulch"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
        -- Add more commands here
    },
    -- Add additional maps here
}

-- CONFIG ENDS

local active_vehicles = {}
api_version = "1.12.0.0"

function OnScriptLoad()
    cprint("[Vehicle Spawner] Script loaded successfully", 10)
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    OnGameStart()
end

local function GetTag(class, name)
    if not class or not name then
        error(string.format("[ERROR] Invalid parameter to GetTag: class=%s, name=%s", class, name))
        return nil
    end

    local tag = lookup_tag(class, name)
    if tag == 0 then
        error(string.format("[ERROR] Tag not found: %s (%s)", name, class))
        return nil
    end

    local meta_id = read_dword(tag + 0xC)
    if meta_id == 0 then
        error(string.format("[ERROR] Invalid meta ID for tag: %s (%s)", name, class))
        return nil
    end

    return meta_id
end

function OnGameStart()

    if get_var(0, "$gt") == "n/a" then
        return
    end

    local map_name = get_var(0, "$map")
    active_vehicles = {}

    local map_config = map_vehicles[map_name]
    if not map_config then
        cprint(string.format("[WARNING] No vehicle configuration found for map: %s", map_name), 12)
        return
    end

    local valid_vehicles = 0
    for command, tag_path in pairs(map_config) do

        local meta_id = GetTag("vehi", tag_path)
        if not meta_id then
            error(string.format("[ERROR] Failed to get meta ID for vehicle: %s (%s)", command, tag_path))
        else
            active_vehicles[meta_id] = {
                command = command,
                path = tag_path,
                object = nil,
                despawn_time = nil
            }
            valid_vehicles = valid_vehicles + 1
            --cprint(string.format("Registered vehicle: %s (%s)", command, tag_path), 10)
        end
    end

    if valid_vehicles > 0 then
        register_callback(cb["EVENT_TICK"], "OnTick")
        --cprint(string.format("%d vehicles registered - tick callback enabled", valid_vehicles), 10)
    else
        cprint("[WARNING] No valid vehicles registered - tick callback disabled", 12)
    end
end

function OnGameEnd()
    unregister_callback(cb["EVENT_TICK"])
end

local function GetPlayerPosition(player)
    if not player_alive(player) then
        say(player, "You must be alive to spawn a vehicle")
        return nil
    end

    local player_obj = get_dynamic_player(player)
    if player_obj == 0 then
        error(string.format("[ERROR] Failed to get dynamic player for ID: %s", player))
        return nil
    end

    local vehicle_id = read_dword(player_obj + 0x11C)
    if vehicle_id ~= 0xFFFFFFFF then
        say(player, "You are already in a vehicle")
        return nil
    end

    local x, y, z = read_vector3d(player_obj + 0x5C)
    if not x or not y or not z then
        error(string.format("[ERROR] Invalid position for player %s", player))
        return nil
    end

    return x, y, z
end

function OnCommand(player, command)
    for meta_id, data in pairs(active_vehicles) do
        if data.command == command then

            local x, y, z = GetPlayerPosition(player)
            if not x then
                return false
            end

            local height_offset = 0.3
            local object_id = spawn_object("", "", x, y, z + height_offset, meta_id)

            if object_id == nil or object_id == 0 then
                error(string.format("[ERROR] Failed to spawn vehicle: %s", data.path))
                return false
            end

            data.object = object_id
            enter_vehicle(object_id, player, 0)

            return false
        end
    end

    return true
end

local function IsVehicleOccupied(vehicle_object)
    if vehicle_object == 0 then
        return false
    end

    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local player = get_dynamic_player(i)
            if player ~= 0 then
                local vehicle_id = read_dword(player + 0x11C)
                if vehicle_id ~= 0xFFFFFFFF then
                    local object = get_object_memory(vehicle_id)
                    if object == vehicle_object then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function OnTick()
    for _, data in pairs(active_vehicles) do
        if data.object then
            local object = get_object_memory(data.object)
            if object ~= 0 then
                if not IsVehicleOccupied(object) then
                    if not data.despawn_time then
                        data.despawn_time = os.clock() + DESPAWN_DELAY_SECONDS
                        -- cprint(string.format("Despawn timer started for vehicle %08X", data.object))
                    elseif os.clock() >= data.despawn_time then
                        -- cprint(string.format("Despawning vehicle %08X (%s)", data.object, data.path))
                        destroy_object(data.object)
                        data.object = nil
                        data.despawn_time = nil
                    end
                elseif data.despawn_time then
                    -- cprint(string.format("Resetting despawn timer for vehicle %08X", data.object))
                    data.despawn_time = nil
                end
            else
                -- Vehicle object is invalid (probably already destroyed)
                data.object = nil
                data.despawn_time = nil
            end
        end
    end
end

function OnScriptUnload()
    cprint("[Vehicle Spawner] Script unloaded")
end