--[[
=====================================================================================
SCRIPT NAME:      uber.lua
DESCRIPTION:      Team-based vehicle transport system that allows players to join
                  teammates' vehicles via chat command or crouch action.

KEY FEATURES:
                 - Configurable vehicle whitelist with seat priority
                 - Smart seat assignment based on insertion order
                 - Cooldown system and call limits
                 - Objective carrier restrictions
                 - Automatic ejection from invalid vehicles
                 - Driver presence verification
                 - Team-based functionality

CONFIGURATION OPTIONS:
                 - Customizable chat triggers
                 - Adjustable cooldown timers
                 - Per-game call limits
                 - Vehicle-specific settings
                 - Seat role definitions

LAST UPDATED:     21/8/2025

Copyright (c) 2020-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

---------------------------------------------------------------------------
-- CONFIG START -----------------------------------------------------------
---------------------------------------------------------------------------

-- Settings controlling Uber script behavior:
local calls_per_game = 20                  -- Max Uber calls allowed per player per game (0 = unlimited)
local block_objective = true               -- Prevent Uber calls if player is carrying an objective (e.g. flag)
local crouch_to_uber = true                -- Enable Uber call when player crouches
local cooldown_period = 10                 -- Cooldown time (seconds) between Uber calls per player
local eject_from_disabled_vehicle = true   -- Eject players from vehicles that aren't enabled for Uber
local eject_from_disabled_vehicle_time = 3 -- Delay before ejecting from disabled vehicle (seconds)
local eject_without_driver = true          -- Eject passengers if vehicle has no driver
local eject_without_driver_time = 5        -- Delay before ejecting without driver (seconds)

-- Chat keywords players can use to call an Uber
local phrases = {
    ['uber'] = true,
    ['taxi'] = true,
    ['cab'] = true,
    ['taxo'] = true
}

-- Player-facing messages for various Uber script events and errors
local messages = {
    must_be_alive         = "You must be alive to call an uber",
    already_in_vehicle    = "You cannot call an uber while in a vehicle",
    carrying_objective    = "You cannot call uber while carrying an objective",
    no_calls_left         = "You have no more uber calls left",
    cooldown_wait         = "Please wait %d seconds",
    entering_vehicle      = "Entering %s as %s",
    remaining_calls       = "Remaining calls: %d",
    no_vehicles_available = "No available vehicles or seats",
    driver_left           = "Driver left the vehicle",
    ejecting_in           = "Ejecting in %d seconds...",
    ejected               = "Ejected from vehicle",
    vehicle_not_enabled   = "This vehicle is not enabled for uber",
    vehicle_no_driver     = "Vehicle has no driver",
    ejection_cancelled    = "Driver entered, ejection cancelled"
}

--[[

==================================
VEHICLE CONFIGURATION
==================================

STRUCTURE:
    {vehicle_tag, seat_roles, enabled, display_name, priority, insertion_order}

PARAMETERS:
    vehicle_tag (string):   The tag path of the vehicle (e.g., 'vehicles\\warthog\\mp_warthog')
    seat_roles (table):     A table mapping seat indices to their role names
                            Example: {[0] = 'driver', [1] = 'passenger', [2] = 'gunner'}
    enabled (boolean):      Whether this vehicle is enabled for Uber calls
    display_name (string):  The name shown to players when entering this vehicle
    priority (number):      Weight used when multiple vehicles are available (higher = chosen first)
    insertion_order (table): The order in which seats should be filled for THIS VEHICLE
                            Example: {0, 2, 1} means try driver first, then gunner, then passenger

IMPORTANT NOTES:

1. VEHICLE WHITELIST:
   - This table defines which vehicles can be called via Uber
   - Vehicles NOT listed here can still be used normally but won't be available for Uber calls
   - Vehicles listed with enabled=false will prevent Uber calls and may eject players (if configured)

2. SEAT ROLES:
   - The script respects the roles defined for each vehicle
   - Even if a seat is listed in insertion_order, only players who can occupy that role will be placed there
   - Example: In a Warthog, seat 2 is the gunner seat - only players who can be gunners will be placed there

3. INSERTION ORDER:
   - Each vehicle can have its own insertion order priority
   - This determines which seats get filled first when multiple seats are available
   - Seats are tried in the order specified until a valid, empty seat is found

4. PRIORITY SYSTEM:
   - When multiple vehicles are available, higher priority vehicles are chosen first
   - This helps ensure players get preferred vehicles (e.g., Rocket Hog over standard Warthog)

BEHAVIOR EXAMPLES:
   - If Banshee is NOT in this table: Players can use it normally but can't call Uber to it
   - If Banshee IS listed but enabled=false: Players will be prevented from using it for Uber
   - If a vehicle has no driver: Passengers may be ejected after a delay (if configured)
]]

local valid_vehicles = {

    -- Format: {tag_path, seat_roles, enabled, display_name, priority, insertion_order}

    --================--
    -- STOCK VEHICLES:
    --================--

    { 'vehicles\\warthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Chain Gun Hog', 3, { 0, 2, 1 } },

    { 'vehicles\\rwarthog\\rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rocket Hog', 2, { 0, 2, 1 } },

    --================--
    -- CUSTOM VEHICLES:
    --================--

    --[[------------------------------------------------------------------------------------------
    THE FOLLOWING POPULAR CUSTOM MAPS USE THE SAME VEHICLE CONFIGURATION AS THE STOCK VEHICLES,
    SO THEY DO NOT NEED TO BE ADDED HERE.
    - massacre_mountain_race_v2
    - equinox_v2
    - dessication_pb1
    - Camtrack-Arena-Race
    - TLSstronghold
    - Prime_C3_Race
    - LostCove_Race
    - New_Mombasa_Race_v2
    - wpitest1_race
    - cliffhanger
    --------------------------------------------------------------------------------------------]]

    -- bc_raceway_final_mp
    { 'levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', 1, { 0, 2, 1 } },

    -- bc_raceway_final_mp
    { 'levels\\test\\racetrack\\custom_hogs\\mp_warthog_green', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', 1, { 0, 2, 1 } },

    -- gauntlet_race
    { 'vehicles\\rwarthog2\\rwarthog2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', 1, { 0, 2, 1 } },

    -- Mongoose_Point
    { 'vehicles\\m257_multvp\\m257_multvp', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Mongoose', 1, { 0, 1 } },

    -- Bigass
    { 'bourrin\\halo reach\\vehicles\\warthog\\h2 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', 1, { 0, 2, 1 } },

    -- Bigass
    { 'bourrin\\halo reach\\vehicles\\warthog\\rocket warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rocket Warthog', 1, { 0, 2, 1 } },

    -- Halloween_Gulch_V2
    { 'vehicles\\warthog\\hellhogv2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Hellhog V2', 1, { 0, 2, 1 } },

    -- Halloween_Gulch_V2
    { 'vehicles\\rwarthog\\hellrwarthogv2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Hell Rocket Warthog V2', 1, { 0, 2, 1 } },

    -- Human_Landscape, Jeep_Cliffs, deathrace
    { 'vehicles\\civihog\\mp_civihog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Hog', 1, { 0, 2, 1 } },

    -- separated, arctic_battleground, artillery_zone, battleforbloodgulch,
    -- bloodground_aco, cold_war, doomsday, esther
    { 'vehicles\\mwarthog\\mwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Missile Warthog', 1, { 0, 2, 1 } },

    -- The-Right-of-Passage_a30
    { 'vehicles\\bm_warthog\\bm_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'BM Warthog', 1, { 0, 2, 1 } },

    -- The-Right-of-Passage_a30
    { 'vehicles\\rwarthog\\hellrwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Hell Rocket Warthog', 1, { 0, 2, 1 } },

    -- [FBI]bloodgulch
    { 'h2\\objects\\vehicles\\warthog\\warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', 1, { 0, 2, 1 } },

    -- []h3[]christmas, celebration_island
    { 'vehicles\\halo3warthog\\h3 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H3 Warthog', 1, { 0, 2, 1 } },

    -- [h3style]containment
    { 'vehicles\\cwarthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'CWarthog', 1, { 0, 2, 1 } },

    -- celebration_island, hornets_nest
    { 'halo3\\vehicles\\warthog\\rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'H3 Rocket Hog', 1, { 0, 2, 1 } },

    -- beryl_rescue, delta_ruined, destiny, grove_final
    { 'vehicles\\warthog\\art_cwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Art CWarthog', 1, { 0, 2, 1 } },

    -- beryl_rescue, casualty_isle__v2, erosion
    { 'vehicles\\rwarthog\\art_rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Art Rocket Warthog', 1, { 0, 2, 1 } },

    -- atomic
    { 'vehicles\\doombuggy\\doombuggy', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Doombuggy', 1, { 0, 1 } },

    -- atomic
    { 'vehicles\\dangermobile\\dangermobile', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Dangermobile', 1, { 0, 1 } },

    -- battle
    { 'vehicles\\civihog\\civihog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Hog', 1, { 0, 2, 1 } },

    -- bob_omb_battlefield, coldsnap, hypothermia_v0.1, hypothermia_v0.2, hypo_v0.3
	-- combat_arena, extinction, frozen-path, hypothermia_race
    { 'vehicles\\g_warthog\\g_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'G Warthog', 1, { 0, 2, 1 } },

    -- bumper_cars_v2
    { 'vehicles\\civvi\\civilian warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Warthog', 1, { 0, 2, 1 } },

    -- bumper_cars_v2
    { 'vehicles\\warthog\\mp_warthogc', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog C', 1, { 0, 2, 1 } },

    -- camden_place
    { 'vehicles\\fwarthog\\mp_fwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Flame Warthog', 1, { 0, 2, 1 } },

    -- cmt_cliffrun
    { 'vehicles\\cmt_warthog\\chaingun_variant', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'CMT Chaingun Hog', 1, { 0, 2, 1 } },

    -- cmt_cliffrun
    { 'vehicles\\cmt_warthog\\rocket_variant', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'CMT Rocket Hog', 1, { 0, 2, 1 } },

    -- cnr_island, desertdunestwo
    { 'vehicles\\rancher\\rancher', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Rancher', 1, { 0, 1 } },

    -- cnr_island
    { 'vehicles\\sultan\\sultan', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Sultan', 2, { 0, 1 } },

    -- cold_war
    { 'vehicles\\warthog\\h2 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', 1, { 0, 2, 1 } },

    -- coldsnap
    { 'vehicles\\coldsnap_hogs\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', 1, { 0, 2, 1 } },

    -- combat_arena
    { 'vehicles\\gausshog\\gausshog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Gauss Hog', 1, { 0, 2, 1 } },

    -- concealed_custom
    { 'vehicles\\warthog_legend\\warthog_legend', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Legend Warthog', 1, { 0, 2, 1 } },

    -- concealed_custom
    { 'vehicles\\rwarthog_legend\\rwarthog_legend', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Legend Rocket Warthog', 1, { 0, 2, 1 } },

    -- cursed-beavercreek, cursed-bloodgulch, cursed-chillout, cursed-damnation, cursed-deathisland,
    -- cursed-derelict, cursed-hangemhigh, cursed-sidewinder, cursed-wizard
    { 'vehicles\\c warthog\\c warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'C Warthog', 1, { 0, 2, 1 } },

    -- desert_storm_v2
    { 'vehicles\\trans_hog\\trans_hog', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Transport Hog', 1, { 0, 1 } },

    -- desertdunestwo
    { 'vehicles\\walton\\walton', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Walton', 1, { 0, 1 } },

    -- discovery
    { 'vehicles\\warthog\\realistic\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Realistic Warthog', 1, { 0, 2, 1 } },

    -- facing_worldsrx, gladiators_brawl, huh-what_3
    { 'vehicles\\puma\\puma', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Puma', 1, { 0, 1 } },

    -- first
    { 'vehicles\\snow_civ_hog\\snow_civ_hog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Snow Civilian Hog', 1, { 0, 2, 1 } },

    -- fox_island_insane
    { 'vehicles\\ravhog\\ravhog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rav Hog', 1, { 0, 2, 1 } },

    -- gladiators_brawl
    { 'vehicles\\warthog\\flamehog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Flamehog', 1, { 0, 2, 1 } },

    -- glenns_castle, hypo_v0.3, hypothermia_v0.1, hypothermia_v0.2
    { 'vehicles\\civvi\\civvi', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civvi', 1, { 0, 2, 1 } },

    -- glupo_aco
    { 'vehicles\\sandking\\sandking', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Sandking', 1, { 0, 1 } },

    -- green_canyon
    { 'vehicles\\warthog\\mp_warthogfix', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Fixed Warthog', 1, { 0, 2, 1 } },

    -- green_canyon
    { 'vehicles\\rwarthog\\rwarthogfix', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Fixed Rocket Warthog', 1, { 0, 2, 1 } },

    -- hillbilly mudbog
    { 'vehicles\\rpchog\\rpchog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'RPC Hog', 1, { 0, 2, 1 } },

    -- hogracing_day, hogracing_night
    { 'vehicles\\puma\\puma_xt', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Puma XT', 1, { 0, 1 } },

    -- hornets_nest
    { 'halo3\\vehicles\\warthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H3 Warthog', 1, { 0, 2, 1 } },

    -- hq_racetrack
    { 'vehicles\\sporthog\\smileyhog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Smiley Hog', 1, { 0, 2, 1 } },

    -- hydrolysis
    { 'vehicles\\newboathog\\newboathog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'New Boat Hog', 1, { 0, 2, 1 } },

    -- Add more vehicles here using the same format
    -- { 'vehicle/tag/path', { [0] = 'driver', [1] = 'passenger' }, true, 'Display Name', 1, { 0, 1 } },
}
---------------------------------------------------------------------------
-- CONFIG END -------------------------------------------------------------
---------------------------------------------------------------------------

api_version = '1.12.0.0'

local players = {}
local valid_vehicles_meta = {}

local base_tag_table = 0x40440000
local tag_entry_size = 0x20
local tag_data_offset = 0x14
local bit_check_offset = 0x308
local bit_index = 3

local gametype_is_ctf_or_oddball = nil

local pairs, ipairs, tonumber, select = pairs, ipairs, tonumber, select
local math_floor = math.floor
local os_time = os.time
local sort = table.sort

local rprint, get_var = rprint, get_var
local player_alive, player_present = player_alive, player_present
local enter_vehicle, exit_vehicle = enter_vehicle, exit_vehicle

local lookup_tag = lookup_tag
local get_object_memory, get_dynamic_player = get_object_memory, get_dynamic_player
local read_dword, read_word, read_byte, read_bit = read_dword, read_word, read_byte, read_bit

local sapp_events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_CHAT']] = 'OnChat',
    [cb['EVENT_VEHICLE_ENTER']] = 'OnVehicleEnter',
    [cb['EVENT_VEHICLE_EXIT']] = 'OnVehicleExit',
    [cb['EVENT_DIE']] = 'OnPlayerDeath',
    [cb['EVENT_TEAM_SWITCH']] = 'OnTeamSwitch'
}

local function fmt(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function validate_vehicle(object_memory)
    local meta_id = read_dword(object_memory)
    return valid_vehicles_meta[meta_id]
end

local function new_eject(player, object, delay)
    local now = os_time()
    return {
        player = player,
        object = object,
        start = now,
        finish = now + delay,
    }
end

local function new_cooldown(player, delay, now)
    return {
        player = player,
        start = now,
        finish = now + delay
    }
end

local function send(player, message, clear)
    if clear then
        for _ = 1, 25 do rprint(player.id, '') end
    end
    rprint(player.id, message)
end

local function schedule_ejection(player, object, delay, reason)
    if reason then send(player, reason) end
    send(player, fmt(messages.ejecting_in, delay))
    player.auto_eject = new_eject(player, object, delay)
end

local function schedule_ejection_if_disabled(player, vehicle_obj, config_entry)
    if eject_from_disabled_vehicle and not config_entry.enabled then
        schedule_ejection(
            player,
            vehicle_obj,
            eject_from_disabled_vehicle_time,
            fmt(messages.vehicle_not_enabled)
        )
    end
end

local function has_objective(dyn_player)
    local weapon_id = read_dword(dyn_player + 0x118)
    if weapon_id == 0xFFFFFFFF then return false end

    local weapon_obj = get_object_memory(weapon_id)
    if weapon_obj == 0 then return false end

    local tag_address = read_word(weapon_obj)
    local tag_data_base = read_dword(base_tag_table)
    local tag_data = read_dword(tag_data_base + tag_address * tag_entry_size + tag_data_offset)

    if read_bit(tag_data + bit_check_offset, bit_index) ~= 1 then return false end

    local obj_byte = read_byte(tag_data + 2)
    return obj_byte == 4 or obj_byte == 0 -- Oddball (4) or Flag (0)
end

local function get_vehicle_if_driver(dyn)
    local vehicle_id_offset = 0x11C
    local seat_offset = 0x2F0
    local invalid_vehicle_id = 0xFFFFFFFF

    local vehicle_id = read_dword(dyn + vehicle_id_offset)
    if vehicle_id == invalid_vehicle_id then return nil end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return nil end

    local config_entry = validate_vehicle(vehicle_obj)
    if not config_entry then return nil end

    local seat = read_word(dyn + seat_offset)
    if seat ~= 0 then return nil end

    return vehicle_obj, vehicle_id, config_entry
end

local function do_checks(player, now)
    local dyn = get_dynamic_player(player.id)
    if dyn == 0 then return false end

    if not player_alive(player.id) then
        send(player, fmt(messages.must_be_alive), true)
        return false
    end

    if read_dword(dyn + 0x11C) ~= 0xFFFFFFFF then
        send(player, fmt(messages.already_in_vehicle), true)
        return false
    end

    if block_objective and gametype_is_ctf_or_oddball and has_objective(dyn) then
        send(player, fmt(messages.carrying_objective), true)
        return false
    end

    if calls_per_game > 0 and player.calls <= 0 then
        send(player, fmt(messages.no_calls_left), true)
        return false
    end

    if player.call_cooldown and now < player.call_cooldown.finish then
        local remaining = player.call_cooldown.finish - now
        send(player, fmt(messages.cooldown_wait, math_floor(remaining)), true)
        return false
    end

    return true
end

local function is_valid_player(player, id)
    return player_present(id) and
        player_alive(id) and
        id ~= player.id and
        get_var(id, '$team') == player.team
end

local function get_available_vehicles(player)
    local available = {}
    local count = 0

    for i = 1, 16 do
        if not is_valid_player(player, i) then goto continue end
        local dyn = get_dynamic_player(i)
        if not dyn then goto continue end

        local vehicle_obj, vehicle_id, config_entry = get_vehicle_if_driver(dyn)
        if vehicle_obj then
            count = count + 1
            available[count] = {
                object = vehicle_obj,
                id = vehicle_id,
                meta = config_entry,
                driver = i
            }
        end
        ::continue::
    end

    sort(available, function(a, b)
        return a.meta.priority > b.meta.priority
    end)

    return available
end

local function find_seat(player, vehicle)
    local vehicle_insertion_order = vehicle.meta.insertion_order

    for _, seat_id in ipairs(vehicle_insertion_order) do
        if not vehicle.meta.seats[seat_id] then goto continue end

        local seat_free = true

        for id = 1, 16 do
            if id ~= player.id then
                local other = players[id]
                if other and other.current_vehi_obj == vehicle.object and player_alive(id) and other.seat == seat_id then
                    seat_free = false
                    break
                end
            end
        end

        if seat_free then
            return seat_id
        end

        ::continue::
    end
end

local function call_uber(player)
    local now = os_time()
    if not do_checks(player, now) then return end

    player.call_cooldown = new_cooldown(player, cooldown_period, now)
    local vehicles = get_available_vehicles(player)

    for _, vehicle in ipairs(vehicles) do
        local seat_id = find_seat(player, vehicle)
        if seat_id then
            if calls_per_game > 0 then player.calls = player.calls - 1 end

            enter_vehicle(vehicle.id, player.id, seat_id)
            send(player, fmt(messages.entering_vehicle, vehicle.meta.display_name, vehicle.meta.seats[seat_id]), true)

            if calls_per_game > 0 then
                send(player, fmt(messages.remaining_calls, player.calls), false)
            end

            return
        end
    end

    send(player, fmt(messages.no_vehicles_available), true)
end

local function ejection_check(player)
    if player.seat ~= 0 then return end

    local dyn = get_dynamic_player(player.id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    for id, other_player in pairs(players) do
        if id ~= player.id and other_player.current_vehi_obj == vehicle_obj then
            schedule_ejection(
                other_player,
                vehicle_obj,
                eject_without_driver_time,
                fmt(messages.driver_left)
            )
        end
    end
end

local function check_crouch(player, dyn)
    if not crouch_to_uber then return end

    local crouching = read_bit(dyn + 0x208, 0)
    if crouching == 1 and player.crouching ~= crouching then call_uber(player) end
    player.crouching = crouching
end

local function process_auto_eject(player, now)
    if not player.auto_eject or now < player.auto_eject.finish then return end

    exit_vehicle(player.id)
    send(player, fmt(messages.ejected))
    player.auto_eject = nil
end

local function process_cooldown(player, now)
    if player.call_cooldown and now >= player.call_cooldown.finish then
        player.call_cooldown = nil
    end
end

local function update_vehicle_state(player, dyn)
    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then
        player.seat = nil
        player.current_vehi_obj = nil
        return
    end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj ~= 0 then
        player.seat = read_word(dyn + 0x2F0)
        player.current_vehi_obj = vehicle_obj
    end
end

local function initialize()
    valid_vehicles_meta = {}

    for _, v in ipairs(valid_vehicles) do
        local tag, seats, enabled, label, priority, insertion_order = v[1], v[2], v[3], v[4], v[5], v[6]
        local meta_id = get_tag('vehi', tag)
        if meta_id then
            valid_vehicles_meta[meta_id] = {
                seats = seats,
                enabled = enabled,
                display_name = label,
                priority = priority,
                insertion_order = insertion_order
            }
        end
    end

    local game_type = get_var(0, '$gt')
    gametype_is_ctf_or_oddball = game_type == 'ctf' or game_type == 'oddball'
end

local function register_callbacks(team_game)
    for event, callback in pairs(sapp_events) do
        if team_game then
            register_callback(event, callback)
        else
            unregister_callback(event)
        end
    end
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    if get_var(0, '$ffa') == '1' then
        register_callbacks(false)
        cprint('====================================', 12)
        cprint('[Uber] Only runs on team-based games', 12)
        cprint('====================================', 12)
        return
    end

    initialize()
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end

    register_callbacks(true)
end

function OnJoin(id)
    players[id] = {
        id = id,
        team = get_var(id, '$team'),
        name = get_var(id, '$name'),
        calls = calls_per_game,
        crouching = 0,
        auto_eject = nil,
        call_cooldown = nil,
        seat = nil,
        current_vehi_obj = nil
    }
end

function OnQuit(id)
    local player = players[id]
    if player then
        if player.seat == 0 and player.current_vehi_obj then
            for other_id, other_player in pairs(players) do
                if other_id ~= id and other_player.current_vehi_obj == player.current_vehi_obj then
                    schedule_ejection(
                        other_player,
                        player.current_vehi_obj,
                        eject_without_driver_time,
                        fmt(messages.driver_left)
                    )
                end
            end
        end
        players[id] = nil
    end
end

function OnTick()
    local now = os_time()
    for i = 1, 16 do
        local player = players[i]
        if not player or not player_present(i) then goto continue end

        process_cooldown(player, now)

        local dyn = get_dynamic_player(i)
        if dyn == 0 or not player_alive(i) then goto continue end

        update_vehicle_state(player, dyn)
        process_auto_eject(player, now)
        check_crouch(player, dyn)

        ::continue::
    end
end

function OnChat(id, msg)
    msg = msg:lower()
    if phrases[msg] then
        call_uber(players[id])
        return false
    end
end

function OnVehicleEnter(id, seat)
    seat = tonumber(seat)

    local player = players[id]
    local dyn = get_dynamic_player(id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return end

    -- Get vehicle config | If it isn't configured allow the player to enter
    local config_entry = validate_vehicle(vehicle_obj)
    if not config_entry then goto continue end

    schedule_ejection_if_disabled(player, vehicle_obj, config_entry) -- prevent using disabled vehicles

    ::continue::

    if seat ~= 0 and eject_without_driver then
        local driver = read_dword(vehicle_obj + 0x324) -- check if the vehicle has a driver
        if driver == 0xFFFFFFFF then
            schedule_ejection(
                player,
                vehicle_obj,
                eject_without_driver_time,
                fmt(messages.vehicle_no_driver)
            )
        end
    end

    if seat == 0 then
        for _, p in pairs(players) do
            if p.auto_eject and p.auto_eject.object == vehicle_obj then
                p.auto_eject = nil
                send(p, fmt(messages.ejection_cancelled))
            end
        end
    end
end

function OnVehicleExit(id)
    ejection_check(players[id])
end

function OnPlayerDeath(id)
    players[id].auto_eject = nil
    ejection_check(players[id])
end

function OnTeamSwitch(id)
    players[id].team = get_var(id, '$team')
end

function OnScriptUnload() end
