--[[
===============================================================================
SCRIPT NAME:      liberty_vehicle_spawner.lua
DESCRIPTION:      On-demand vehicle spawning system with:
                  - Chat command activation
                  - Automatic player entry
                  - Intelligent cleanup system
                  - Multi-map support

FEATURES:
                  - Keyword-based spawning (e.g. "hog", "rhog")
                  - Configurable despawn timer
                  - Occupancy detection
                  - Automatic position adjustment

CONFIGURATION:    Edit map_vehicles table to:
                  - Add vehicle keywords per map
                  - Set vehicle tag paths
                  - Adjust DESPAWN_DELAY_SECONDS

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

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
        ["hog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_green",
    },
    ["camtrack-arena-race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["cliffhanger"] = {
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
    ["gauntlet_race"] = {
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
    ["lostcove_race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["massacre_mountain_race_v2"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["mongoose_point"] = {
        ["hog"] = "vehicles\\m257_multvp\\m257_multvp",
    },
    ["New_Mombasa_Race_v2"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["prime_c3_race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["timberland"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["tlsstronghold"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["islandthunder_race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["mystic_mod"] = {
        ["hog"] = "vehicles\\puma\\puma_lt",
        ["rhog"] = "vehicles\\puma\\rpuma_lt",
    },
    ["Nervous_King"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["cityscape-adrenaline"] = {
        ["hog"] = "vehicles\\g_warthog\\g_warthog",
        ["rhog"] = "vehicles\\rwarthog\\boogerhawg",
    },
    ["wpitest1_race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
}

-- CONFIG ENDS

api_version = "1.12.0.0"

local os_clock = os.clock
local active_vehicles = {}

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_CHAT']] = 'OnChat',
}

local function register_callbacks(enable)
    for event, callback in pairs(sapp_events) do
        if enable then
            register_callback(event, callback)
        else
            unregister_callback(event)
        end
    end
end

local function getTag(class, name)
    if not class or not name then
        error(string.format("[ERROR] Invalid parameter to getTag: class=%s, name=%s", class, name))
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

local function getVehicle(player_index)
    if not player_present(player_index) or not player_alive(player_index) then
        return nil
    end

    local player_obj = get_dynamic_player(player_index)
    if player_obj == 0 then return nil end

    local vehicle_id = read_dword(player_obj + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return nil end

    return get_object_memory(vehicle_id)
end

local function isOccupied(vehicle_object)
    if vehicle_object == 0 then return false end
    for i = 1, 16 do
        local current_vehicle = getVehicle(i)
        if current_vehicle == vehicle_object then return true end
    end
    return false
end

local function getPos(player_index)
    if not player_alive(player_index) then
        say(player_index, "You must be alive to spawn a vehicle")
        return nil
    end

    if getVehicle(player_index) then
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
            local x, y, z = getPos(player)
            if not x then return false end

            local height_offset = 0.3
            local object_id = spawn_object('', '', x, y, z + height_offset, 0, meta_id)

            if object_id == nil or object_id == 0 then
                cprint(string.format("[ERROR] Failed to spawn vehicle: %s", data.path))
                return false
            end

            data.object = object_id
            enter_vehicle(object_id, player, 0)

            return false
        end
    end

    return true
end

-- todo: object.data appears to be nil before the vehicle is destroyed, therefore it never despawns.
function OnTick()
    local now = os_clock()
    for _, data in pairs(active_vehicles) do
        if data.object then
            local object = get_object_memory(data.object)
            if object ~= 0 then
                if not isOccupied(object) then
                    if not data.despawn_time then
                        data.despawn_time = now + DESPAWN_DELAY_SECONDS
                    elseif now >= data.despawn_time then
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

function OnStart()
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
        local meta_id = getTag("vehi", tag_path)
        if not meta_id then
            cprint(string.format("[ERROR] Failed to get meta ID for vehicle: %s (%s)", keyword, tag_path))
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
        register_callbacks(true)
    else
        register_callbacks(false)
    end
end

function OnJoin(player)
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

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnScriptUnload() end
