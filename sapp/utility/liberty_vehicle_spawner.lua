--[[
===============================================================================
SCRIPT NAME:      liberty_vehicle_spawner.lua
DESCRIPTION:      On-demand vehicle spawning system with:
                  - Chat command activation
                  - Automatic player entry
                  - Multi-map support

LAST UPDATED:     6/10/2025

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

-- CONFIG START ----------------------------------------------------------------

local DESPAWN_DELAY_SECONDS = 7 -- Time (in seconds) before a spawned vehicle despawns
local COOLDOWN_PERIOD = 7       -- Cooldown time (seconds) between vehicle spawns per player

-- DEFAULT_TAGS: Fallback vehicle definitions used when a map isn't listed in CUSTOM_TAGS
-- Format: ["keyword"] = "tag_path"
--  - keyword: What players type in chat to spawn the vehicle
--  - tag_path: The internal path to the vehicle tag name
local DEFAULT_TAGS = {
    ["hog"] = "vehicles\\warthog\\mp_warthog",
    ["rhog"] = "vehicles\\rwarthog\\rwarthog"
}

-- CUSTOM_TAGS: Map-specific vehicle definitions (overrides DEFAULT_TAGS for listed maps)
-- Format: ["map_name"] = {["keyword"] = "tag_path", ...}
--  - map_name: The exact name of the map as it appears in $map (case-sensitive)
--  - keyword: What players type in chat to spawn the vehicle
--  - tag_path: The internal path to the vehicle tag name
local CUSTOM_TAGS = {
    ["[h3]_sandtrap"] = {
        ["hog"] = "halo3\\vehicles\\warthog\\mp_warthog",
        ["mon"] = "halo3\\vehicles\\mongoose\\mongoose"
    },
    ["bc_raceway_final_mp"] = {
        ["hog"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_green",   -- green
        ["hog2"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue",   -- blue
        ["hog3"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi1", -- red and pink
        ["hog4"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi2", -- green and red
        ["hog5"] = "levels\\test\\racetrack\\custom_hogs\\mp_warthog_multi3"  -- blue, red, green, pink
    },
    ["cityscape-adrenaline"] = {
        ["hog"] = "vehicles\\g_warthog\\g_warthog",
        ["rhog"] = "vehicles\\rwarthog\\boogerhawg"
    },
    ["hypothermia_race"] = {
        ["hog"] = "vehicles\\g_warthog\\g_warthog"
    },
    ["mongoose_point"] = {
        ["hog"] = "vehicles\\m257_multvp\\m257_multvp"
    },
    ["mystic_mod"] = {
        ["hog"] = "vehicles\\puma\\puma_lt",
        ["rhog"] = "vehicles\\puma\\rpuma_lt"
    },
    ["tsce_multiplayerv1"] = {
        ["hog"] = "cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_mp\\warthog_mp",
        ["rhog"] = "cmt\\vehicles\\evolved_h1-spirit\\warthog\\_warthog_rocket\\warthog_rocket"
    },
    ["hornets_nest"] = {
        ["hog"] = "halo3\\vehicles\\warthog\\mp_warthog",
        ["rhog"] = "halo3\\vehicles\\warthog\\rwarthog"
    },
    ["grove_final"] = {
        ["hog"] = "vehicles\\warthog\\art_cwarthog",
        ["rhog"] = "vehicles\\rwarthog\\art_rwarthog_shiny"
    },
}
-- CONFIG ENDS ----------------------------------------------------------------

api_version = "1.12.0.0"

local map_name
local height_offset = 0.3
local game_over
local active_vehicles, vehicle_meta_cache, player_cooldowns = {}, {}, {}

local os_time = os.time
local string_format, os_clock, pairs = string.format, os.clock, pairs

local rprint, cprint, get_var = rprint, cprint, get_var
local read_dword, read_vector3d = read_dword, read_vector3d
local lookup_tag, enter_vehicle = lookup_tag, enter_vehicle
local player_present, player_alive = player_present, player_alive
local spawn_object, destroy_object = spawn_object, destroy_object
local get_dynamic_player, get_object_memory = get_dynamic_player, get_object_memory

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_CHAT']] = 'OnChat',
    [cb['EVENT_SPAWN']] = 'OnSpawn',
    [cb['EVENT_GAME_END']] = 'OnEnd',
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
        if getVehicle(i) == vehicle_object then return true end
    end
    return false
end

local function atan2(y, x)
    return math.atan(y / x) + ((x < 0) and math.pi or 0)
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

    local player_dyn = get_dynamic_player(id)
    if player_dyn == 0 then return nil end

    local x, y, z = read_vector3d(player_dyn + 0x5C)

    local cam_x = read_float(player_dyn + 0x230)
    local cam_y = read_float(player_dyn + 0x234)
    local yaw = atan2(cam_y, cam_x)

    return x, y, z, yaw
end

local function canSpawnVehicle(id)
    local now = os_time()
    local player_cooldown = player_cooldowns[id]

    if player_cooldown and now < player_cooldown then
        local remaining = player_cooldown - now
        rprint(id, string.format("Please wait %d seconds before spawning another vehicle.", math.floor(remaining)))
        return false
    end

    return true
end

local function showKeyWords(id)
    rprint(id, "Type keywords in chat to spawn vehicles:")
    rprint(id, vehicle_meta_cache[map_name].hud)
end

local function mapNamesToLower()
    local custom_tags_lower = {}
    for map, vehicles in pairs(CUSTOM_TAGS) do
        custom_tags_lower[map:lower()] = vehicles
    end
    return custom_tags_lower
end

function OnScriptLoad()
    CUSTOM_TAGS = mapNamesToLower()
    register_callback(cb["EVENT_GAME_START"], "OnStart")

    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end

    map_name = get_var(0, "$map"):lower()
    active_vehicles = {}

    local cfg = CUSTOM_TAGS[map_name] or DEFAULT_TAGS
    if not vehicle_meta_cache[map_name] then -- not cached yet
        vehicle_meta_cache[map_name] = { hud = "" }
        for keyword, tag_path in pairs(cfg) do
            local meta_id = getTag("vehi", tag_path)
            if not meta_id then
                register_callbacks(false)
                cprint(string_format("[ERROR] Failed to get meta ID for vehicle: %s (%s)", keyword, tag_path), 12)
                vehicle_meta_cache[map_name] = nil
                return
            end
            vehicle_meta_cache[map_name][keyword] = meta_id
            vehicle_meta_cache[map_name].hud = vehicle_meta_cache[map_name].hud .. " [" .. keyword .. "]"
        end
    end

    register_callbacks(true)
    game_over = false

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    game_over = true
    player_cooldowns = {}
end

function OnChat(id, message)
    local input = message:lower():gsub("^%s*(.-)%s*$", "%1")
    if game_over or input == "hud" then return end

    local map_config = vehicle_meta_cache[map_name]
    for keyword, meta_id in pairs(map_config) do
        if input == keyword then
            if not canSpawnVehicle(id) then return false end

            local x, y, z, yaw = getPos(id)
            if not x then return false end

            local object_id = spawn_object('', '', x, y, z + height_offset, yaw, meta_id)
            if object_id == 0 then
                rprint(id, "Failed to spawn vehicle.")
                return false
            end

            player_cooldowns[id] = os_time() + COOLDOWN_PERIOD
            active_vehicles[object_id] = { object = object_id, despawn_time = nil }
            enter_vehicle(object_id, id, 0)
            return false
        end
    end

    return true
end

function OnTick()
    if game_over then return end
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
                if data.despawn_time then data.despawn_time = nil end
            end
        end
    end
end

function OnJoin(id)
    player_cooldowns[id] = nil
end

function OnSpawn(id)
    if game_over then return end
    showKeyWords(id)
end

function OnScriptUnload()
    for object_id, _ in pairs(active_vehicles) do
        destroy_object(object_id)
    end
    active_vehicles, vehicle_meta_cache = {}, {}
end
