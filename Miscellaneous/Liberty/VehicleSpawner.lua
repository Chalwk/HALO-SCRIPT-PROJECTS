--=====================================================================================--
-- SCRIPT NAME:      Liberty Vehicle Spawner
-- DESCRIPTION:      Allows players to spawn and instantly enter a vehicle
--                   at their current location using keywords.
--                   Vehicles automatically despawn after a configurable
--                   timeout if left unoccupied. Its respawn timer will reset
--                   if the player re-enters the vehicle.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT © 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE: MIT License
--          See: https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

--========================= CONFIGURATION ====================================--

local DESPAWN_DELAY_SECONDS = 30

local map_vehicles = {

    -- EXAMPLE MAP CONFIG:
    -- ["map_name"] = {
    --     ["keyword"] = "tag_path",
    --     ["keyword"] = "tag_path",
    --     -- Add more keyword here
    -- }

    ["bc_raceway_final_mp"] = {
        ["hog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue",
    },
    ["Camtrack-Arena-Race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["ciffhanger"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["dessication_pb1"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["equinox_v2"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["Gauntlet_Race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["hornets_nest"] = {
        ["hog"] = "halo3\\vehicles\\warthog\\mp_warthog",
        ["rhog"] = "halo3\\vehicles\\warthog\\rwarthog",
    },
    ["hypothermia_race"] = {
        ["hog"] = "vehicles\\g_warthog\\g_warthog",
    },
    ["LostCove_Race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["massacre_mountain_race_v2"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["Mongoose_Point"] = {
        ["hog"] = "vehicles\\m257_multvp\\m257_multvp",
    },
    ["New_Mombasa_Race_v2"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["Prime_C3_Race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["timberland"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["TLSstronghold"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["wpitest1_race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
}

-- CONFIG ENDS

local active_vehicles = {}
api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb["EVENT_CHAT"], "OnChat")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
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

    if get_var(0, "$gt") == "n/a" then return end

    local map_name = get_var(0, "$map")
    active_vehicles = {}

    local map_config = map_vehicles[map_name]
    if not map_config then
        cprint(string.format("[WARNING] No vehicle configuration found for map: %s", map_name), 12)
        return
    end

    local valid_vehicles = 0
    for keyword, tag_path in pairs(map_config) do

        local meta_id = GetTag("vehi", tag_path)
        if not meta_id then
            error(string.format("[ERROR] Failed to get meta ID for vehicle: %s (%s)", keyword, tag_path))
            goto next
        end

        active_vehicles[meta_id] = {
            keyword = keyword,
            path = tag_path,
            object = nil,
            despawn_time = nil
        }
        valid_vehicles = valid_vehicles + 1
        :: next ::
    end

    if valid_vehicles > 0 then
        register_callback(cb["EVENT_TICK"], "OnTick")
    else
        cprint("[WARNING] No valid vehicles registered - tick callback disabled", 12)
    end
end

function OnPlayerJoin(player)
    local map_name = get_var(0, "$map")
    local keywords = map_vehicles[map_name]

    if keywords then
        local message = "Welcome! Type the following keywords in chat to spawn vehicles:"

        for keyword, _ in pairs(keywords) do
            message = message .. " [" .. keyword .. "]"
        end

        rprint(player, message)
    end
end

function OnGameEnd()
    unregister_callback(cb["EVENT_TICK"])
end

local function GetPlayerVehicle(player_index)
    if not player_present(player_index) or not player_alive(player_index) then
        return nil
    end

    local player_obj = get_dynamic_player(player_index)
    if player_obj == 0 then return nil end

    local vehicle_id = read_dword(player_obj + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return nil end

    return get_object_memory(vehicle_id)
end

local function IsVehicleOccupied(vehicle_object)
    if vehicle_object == 0 then  return false end
    for i = 1, 16 do
        local current_vehicle = GetPlayerVehicle(i)
        if current_vehicle == vehicle_object then return true end
    end
    return false
end

local function GetPlayerPosition(player_index)
    if not player_alive(player_index) then
        say(player_index, "You must be alive to spawn a vehicle")
        return nil
    end

    if GetPlayerVehicle(player_index) then
        say(player_index, "You are already in a vehicle")
        return nil
    end

    local player_obj = get_dynamic_player(player_index)
    if player_obj == 0 then
        error(string.format("[ERROR] Failed to get dynamic player for ID: %s", player_index))
        return nil
    end

    local x, y, z = read_vector3d(player_obj + 0x5C)
    if not x or not y or not z then
        error(string.format("[ERROR] Invalid position for player %s", player_index))
        return nil
    end

    return x, y, z
end

function OnChat(player, message)
    local input = message:lower():gsub("^%s*(.-)%s*$", "%1")

    for meta_id, data in pairs(active_vehicles) do
        if data.keyword == input then

            local x, y, z = GetPlayerPosition(player)
            if not x then return false end

            local height_offset = 0.3
            local object_id = spawn_object('', '', x, y, z + height_offset, 0, meta_id)

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

function OnTick()
    for _, data in pairs(active_vehicles) do
        if data.object then
            local object = get_object_memory(data.object)
            if object ~= 0 then
                if not IsVehicleOccupied(object) then
                    if not data.despawn_time then
                        data.despawn_time = os.clock() + DESPAWN_DELAY_SECONDS
                    elseif os.clock() >= data.despawn_time then
                        destroy_object(data.object)
                        data.object = nil
                        data.despawn_time = nil
                    end
                elseif data.despawn_time then
                    data.despawn_time = nil
                end
            else
                data.object = nil
                data.despawn_time = nil
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end