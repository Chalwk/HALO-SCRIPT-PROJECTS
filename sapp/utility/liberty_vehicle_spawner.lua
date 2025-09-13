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

CONFIGURATION:    Edit 'VEHICLES' table to:
                  - Add vehicle keywords per map
                  - Set vehicle tag paths
                  - Adjust DESPAWN_DELAY_SECONDS

LAST UPDATED:     13/9/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

---------------------------------------------------------------
-- CONFIG START
---------------------------------------------------------------

local DESPAWN_DELAY_SECONDS = 30 -- Time (in seconds) before a spawned vehicle despawns
local VEHICLES = {

    -- EXAMPLE MAP CONFIG:
    -- ["map_name"] = {
    --     ["keyword"] = "tag_path",
    --     ["keyword"] = "tag_path",
    --     -- Add more keyword here
    -- }

    ----------------
    -- STOCK MAPS --
    ----------------

    ["bloodgulch"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["sidewinder"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["prisoner"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["gephyrophobia"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["dangercanyon"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["boardingaction"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["chillout"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["wizard"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["hangemhigh"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["timberland"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["damnation"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["ratrace"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["carousel"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["construct"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["longest"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },

    -----------------
    -- CUSTOM MAPS --
    -----------------

    ["bc_raceway_final_mp"] = {
        ["bhog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue",     -- blue
        ["ghog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_green",    -- green
        ["rhog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi1",   -- red and pink
        ["grhog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi2",  -- green and red
        ["brphog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi3", -- blue, red, green, pink
    },
    ["camtrack-arena-race"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["cliffhanger"] = {
        ["hog"] = "vehicles\\warthog\\mp_warthog",
        ["rhog"] = "vehicles\\rwarthog\\rwarthog",
    },
    ["tsce_multiplayerv1"] = {
        ["hog"] = "cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_mp\\warthog_mp",
        ["rhog"] = "cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_rocket\\warthog_rocket",
    },
    ["mercury_falling"] = {
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

---------------------------------------------------------------
-- CONFIG ENDS
---------------------------------------------------------------

api_version = "1.12.0.0"

local map_name
local os_clock = os.clock
local active_vehicles = {}    -- Now keyed by object ID instead of meta_id
local vehicle_meta_cache = {} -- Cache for pre-loaded meta_ids
local height_offset = 0.3     -- Default height offset for vehicle spawning

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_CHAT']] = 'OnChat'
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
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function getVehicle(id)
    if not player_present(id) or not player_alive(id) then return nil end

    local player_obj = get_dynamic_player(id)
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

local function getPos(id)
    if not player_alive(id) then
        rprint(id, "You must be alive to spawn a vehicle")
        return nil
    end

    if getVehicle(id) then
        rprint(id, "You are already in a vehicle")
        return nil
    end

    local player_obj = get_dynamic_player(id)
    if player_obj == 0 then return nil end

    return read_vector3d(player_obj + 0x5C)
end

function OnChat(id, message)
    local input = message:lower():gsub("^%s*(.-)%s*$", "%1")
    local map_config = vehicle_meta_cache[map_name]

    for keyword, data in pairs(map_config) do
        if input == keyword then
            local x, y, z = getPos(id)
            if not x then return false end

            local object_id = spawn_object('', '', x, y, z + height_offset, 0, data.meta_id)

            active_vehicles[object_id] = {
                keyword = keyword,
                path = data.tag_path,
                object = object_id,
                despawn_time = nil
            }

            enter_vehicle(object_id, id, 0)
            return false
        end
    end

    return true
end

function OnTick()
    local now = os_clock()

    -- Iterate through all active vehicles
    for object_id, data in pairs(active_vehicles) do
        local object = get_object_memory(object_id)

        if object == 0 then
            -- Vehicle no longer exists, remove from tracking
            active_vehicles[object_id] = nil
        else
            if not isOccupied(object) then
                if not data.despawn_time then
                    -- Start despawn timer if not already set
                    data.despawn_time = now + DESPAWN_DELAY_SECONDS
                elseif now >= data.despawn_time then
                    -- Destroy vehicle
                    destroy_object(object_id)
                    active_vehicles[object_id] = nil
                end
            else
                -- Vehicle is occupied, reset despawn timer
                if data.despawn_time then
                    data.despawn_time = nil
                end
            end
        end
    end
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end

    map_name = get_var(0, "$map")
    active_vehicles = {}

    local map_config = VEHICLES[map_name]
    if not map_config then
        cprint(string.format("[WARNING] No vehicle configuration found for map: %s", map_name), 12)
        return
    end

    if not vehicle_meta_cache[map_name] then -- not cached yet
        vehicle_meta_cache[map_name] = {}
        for keyword, tag_path in pairs(map_config) do
            local meta_id = getTag("vehi", tag_path)
            if not meta_id then
                register_callbacks(false)
                cprint(string.format("[ERROR] Failed to get meta ID for vehicle: %s (%s)", keyword, tag_path), 12)
                return
            end
            vehicle_meta_cache[map_name][keyword] = {
                tag_path = tag_path,
                meta_id = meta_id
            }
        end
    end
    register_callbacks(true)
end

function OnJoin(player)
    local keywords = vehicle_meta_cache[map_name]

    rprint(player, "Type keywords in chat to spawn vehicles:")
    local message = ""
    for keyword, _ in pairs(keywords) do
        message = message .. " [" .. keyword .. "]"
    end
    rprint(player, message)
end

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    OnStart()
end

function OnScriptUnload()
    for object_id, _ in pairs(active_vehicles) do
        destroy_object(object_id)
    end
    active_vehicles, vehicle_meta_cache = {}, {}
end
