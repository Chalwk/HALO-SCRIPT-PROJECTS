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
                 - Accept/reject system for driver approval
                 - Configurable call radius for proximity-based requests

CONFIGURATION OPTIONS:
                 - Customizable chat triggers
                 - Adjustable cooldown timers
                 - Per-game call limits
                 - Vehicle-specific settings
                 - Seat role definitions
                 - Accept/reject command customization
                 - Call radius configuration

LAST UPDATED:     13/9/2025

Copyright (c) 2020-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

---------------------------------------------------------------------------
-- CONFIG START -----------------------------------------------------------
---------------------------------------------------------------------------

-- General settings
local CALL_RADIUS = 0                     -- Radius for calling an Uber (0 to disable)
local CALLS_PER_GAME = 20                 -- Max Uber calls allowed per player per game (0 = unlimited)
local COOLDOWN_PERIOD = 10                -- Cooldown time (seconds) between Uber calls per player
local CROUCH_TO_CALL = false              -- Enable Uber call when player crouches

local BLOCK_OBJECTIVE = true              -- Prevent Uber calls if player is carrying an objective (e.g. flag)

local DRIVER_ONLY_IMMUNE = true           -- Vehicles with only a driver are immune to damage

local EJECT_FROM_DISABLE_VEHICLE = true   -- Eject players from vehicles that aren't enabled for Uber
local EJECT_FROM_DISABLE_VEHICLE_time = 3 -- Delay before ejecting from disabled vehicle (seconds)
local EJECT_WITHOUT_DRIVER = true         -- Eject passengers if vehicle has no driver
local EJECT_WITHOUT_DRIVER_TIME = 5       -- Delay before ejecting without driver (seconds)

-- Chat keywords players can use to call an Uber
local PHRASES = {
    ['uber'] = true,
    ['taxi'] = true,
    ['cab']  = true,
    ['taxo'] = true
}

-- Accept/Reject settings
local ACCEPT_REJECT = false      -- Allow drivers to accept or decline incoming Uber requests
local ACCEPT_REJECT_TIMEOUT = 10 -- Timeout (seconds) for responding

local ACCEPT_COMMAND = 'accept'  -- Command to accept an Uber request
local REJECT_COMMAND = 'reject'  -- Command to reject an Uber request

-- Player-facing messages
local MESSAGES = {
    must_be_alive = "You must be alive to call an uber",
    already_in_vehicle = "You cannot call an uber while in a vehicle",
    carrying_objective = "You cannot call uber while carrying an objective",
    no_calls_left = "You have no more uber calls left",
    cooldown_wait = "Please wait %d seconds",
    entering_vehicle = "Entering %s as %s",
    remaining_calls = "Remaining calls: %d",
    no_vehicles_available = "No available vehicles or seats",
    driver_left = "Driver left the vehicle",
    ejecting_in = "Ejecting in %d seconds...",
    ejected = "Ejected from vehicle",
    vehicle_not_enabled = "This vehicle is not enabled for uber",
    vehicle_no_driver = "Vehicle has no driver",
    ejection_cancelled = "Driver entered, ejection cancelled"
}

--[[

==================================
VEHICLE CONFIGURATION
==================================

STRUCTURE:
    {vehicle_tag, seat_roles, enabled, display_name, insertion_order}

PARAMETERS:
    vehicle_tag (string):   The tag path of the vehicle (e.g., 'vehicles\\warthog\\mp_warthog')
    seat_roles (table):     A table mapping seat indices to their role names
                            Example: {[0] = 'driver', [1] = 'passenger', [2] = 'gunner'}
    enabled (boolean):      Whether this vehicle is enabled for Uber calls
    display_name (string):  The name shown to players when entering this vehicle
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

4. VEHICLE SELECTION SYSTEM:
   - The script prioritizes vehicles with fewer occupants

BEHAVIOR EXAMPLES:
   - If Banshee is NOT in this table: Players can use it normally but can't call Uber to it
   - If Banshee IS listed but enabled=false: Players will be prevented from using it for Uber
   - If a vehicle has no driver: Passengers may be ejected after a delay (if configured)
]]

local VEHICLE_SETTINGS = {

    -- Format: {tag_path, seat_roles, enabled, display_name, insertion_order}

    --================--
    -- STOCK VEHICLES:
    --================--

    { 'vehicles\\warthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Chain Gun Hog', { 0, 2, 1 } },

    { 'vehicles\\rwarthog\\rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rocket Hog', { 0, 2, 1 } },

    --================--
    -- CUSTOM VEHICLES:
    --================--

    -- bc_raceway_final_mp
    { 'levels\\test\\racetrack\\custom_hogs\\mp_warthog_blue', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Warthog', { 0, 1 } },

    -- bc_raceway_final_mp
    { 'levels\\test\\racetrack\\custom_hogs\\mp_warthog_green', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Warthog', { 0, 1 } },

    -- bc_raceway_final_mp
    { 'levels\\test\\racetrack\\custom_hogs\\mp_warthog', {
        [0] = 'driver',
        [2] = 'passenger',
    }, true, 'Warthog', { 0, 2 } },

    -- gauntlet_race
    { 'vehicles\\rwarthog2\\rwarthog2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- Mongoose_Point
    { 'vehicles\\m257_multvp\\m257_multvp', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Mongoose', { 0, 1 } },

    -- Bigass
    { 'bourrin\\halo reach\\vehicles\\warthog\\h2 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', { 0, 2, 1 } },

    -- Bigass
    { 'bourrin\\halo reach\\vehicles\\warthog\\rocket warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rocket Warthog', { 0, 2, 1 } },

    -- Halloween_Gulch_V2
    { 'vehicles\\warthog\\hellhogv2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Hellhog V2', { 0, 2, 1 } },

    -- Halloween_Gulch_V2
    { 'vehicles\\rwarthog\\hellrwarthogv2', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Hell Rocket Warthog V2', { 0, 2, 1 } },

    -- Human_Landscape, Jeep_Cliffs, deathrace
    { 'vehicles\\civihog\\mp_civihog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Hog', { 0, 2, 1 } },

    -- separated, arctic_battleground, artillery_zone, battleforbloodgulch,
    -- bloodground_aco, cold_war, doomsday, esther
    { 'vehicles\\mwarthog\\mwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Missile Warthog', { 0, 2, 1 } },

    -- The-Right-of-Passage_a30
    { 'vehicles\\bm_warthog\\bm_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'BM Warthog', { 0, 2, 1 } },

    -- The-Right-of-Passage_a30
    { 'vehicles\\rwarthog\\hellrwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Hell Rocket Warthog', { 0, 2, 1 } },

    -- [FBI]bloodgulch
    { 'h2\\objects\\vehicles\\warthog\\warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', { 0, 2, 1 } },

    -- []h3[]christmas, celebration_island
    { 'vehicles\\halo3warthog\\h3 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H3 Warthog', { 0, 2, 1 } },

    -- [h3style]containment
    { 'vehicles\\cwarthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'CWarthog', { 0, 2, 1 } },

    -- celebration_island, hornets_nest
    { 'halo3\\vehicles\\warthog\\rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'H3 Rocket Hog', { 0, 2, 1 } },

    -- beryl_rescue, delta_ruined, destiny, grove_final
    { 'vehicles\\warthog\\art_cwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Art CWarthog', { 0, 2, 1 } },

    -- beryl_rescue, casualty_isle__v2, erosion
    { 'vehicles\\rwarthog\\art_rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Art Rocket Warthog', { 0, 2, 1 } },

    -- atomic
    { 'vehicles\\doombuggy\\doombuggy', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Doombuggy', { 0, 1 } },

    -- atomic
    { 'vehicles\\dangermobile\\dangermobile', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Dangermobile', { 0, 1 } },

    -- battle
    { 'vehicles\\civihog\\civihog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Hog', { 0, 2, 1 } },

    -- bob_omb_battlefield, coldsnap, hypothermia_v0.1, hypothermia_v0.2, hypo_v0.3
    -- combat_arena, extinction, frozen-path, hypothermia_race
    { 'vehicles\\g_warthog\\g_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'G Warthog', { 0, 2, 1 } },

    -- bumper_cars_v2
    { 'vehicles\\civvi\\civilian warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civilian Warthog', { 0, 2, 1 } },

    -- bumper_cars_v2
    { 'vehicles\\warthog\\mp_warthogc', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog C', { 0, 2, 1 } },

    -- camden_place
    { 'vehicles\\fwarthog\\mp_fwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Flame Warthog', { 0, 2, 1 } },

    -- cmt_cliffrun
    { 'vehicles\\cmt_warthog\\chaingun_variant', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'CMT Chaingun Hog', { 0, 2, 1 } },

    -- cmt_cliffrun
    { 'vehicles\\cmt_warthog\\rocket_variant', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'CMT Rocket Hog', { 0, 2, 1 } },

    -- cnr_island, desertdunestwo
    { 'vehicles\\rancher\\rancher', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Rancher', { 0, 1 } },

    -- cnr_island
    { 'vehicles\\sultan\\sultan', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Sultan', { 0, 1 } },

    -- cold_war
    { 'vehicles\\warthog\\h2 mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H2 Warthog', { 0, 2, 1 } },

    -- coldsnap
    { 'vehicles\\coldsnap_hogs\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- combat_arena
    { 'vehicles\\gausshog\\gausshog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Gauss Hog', { 0, 2, 1 } },

    -- concealed_custom
    { 'vehicles\\warthog_legend\\warthog_legend', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Legend Warthog', { 0, 2, 1 } },

    -- concealed_custom
    { 'vehicles\\rwarthog_legend\\rwarthog_legend', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Legend Rocket Warthog', { 0, 2, 1 } },

    -- cursed-beavercreek, cursed-bloodgulch, cursed-chillout, cursed-damnation, cursed-deathisland,
    -- cursed-derelict, cursed-hangemhigh, cursed-sidewinder, cursed-wizard
    { 'vehicles\\c warthog\\c warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'C Warthog', { 0, 2, 1 } },

    -- desert_storm_v2
    { 'vehicles\\trans_hog\\trans_hog', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Transport Hog', { 0, 1 } },

    -- desertdunestwo
    { 'vehicles\\walton\\walton', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Walton', { 0, 1 } },

    -- discovery
    { 'vehicles\\warthog\\realistic\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Realistic Warthog', { 0, 2, 1 } },

    -- facing_worldsrx, gladiators_brawl, huh-what_3
    { 'vehicles\\puma\\puma', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Puma', { 0, 1 } },

    -- first
    { 'vehicles\\snow_civ_hog\\snow_civ_hog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Snow Civilian Hog', { 0, 2, 1 } },

    -- fox_island_insane
    { 'vehicles\\ravhog\\ravhog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rav Hog', { 0, 2, 1 } },

    -- gladiators_brawl
    { 'vehicles\\warthog\\flamehog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Flamehog', { 0, 2, 1 } },

    -- glenns_castle, hypo_v0.3, hypothermia_v0.1, hypothermia_v0.2
    { 'vehicles\\civvi\\civvi', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Civvi', { 0, 2, 1 } },

    -- glupo_aco
    { 'vehicles\\sandking\\sandking', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Sandking', { 0, 1 } },

    -- green_canyon
    { 'vehicles\\warthog\\mp_warthogfix', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Fixed Warthog', { 0, 2, 1 } },

    -- green_canyon
    { 'vehicles\\rwarthog\\rwarthogfix', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Fixed Rocket Warthog', { 0, 2, 1 } },

    -- hillbilly mudbog
    { 'vehicles\\rpchog\\rpchog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'RPC Hog', { 0, 2, 1 } },

    -- hogracing_day, hogracing_night
    { 'vehicles\\puma\\puma_xt', {
        [0] = 'driver',
        [1] = 'passenger',
    }, true, 'Puma XT', { 0, 1 } },

    -- hornets_nest
    { 'halo3\\vehicles\\warthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'H3 Warthog', { 0, 2, 1 } },

    -- hq_racetrack
    { 'vehicles\\sporthog\\smileyhog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Smiley Hog', { 0, 2, 1 } },

    -- hydrolysis
    { 'vehicles\\newboathog\\newboathog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'New Boat Hog', { 0, 2, 1 } },

    -- cityscape-adrenaline
    { 'vehicles\\g_warthog\\g_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- cityscape-adrenaline
    { 'vehicles\\rwarthog\\boogerhawg', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- mystic_mod
    { 'vehicles\\puma\\puma_lt', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- mystic_mod
    { 'vehicles\\puma\\rpuma_lt', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Warthog', { 0, 2, 1 } },

    -- Add more vehicles here using the same format
    -- { 'vehicle/tag/path', { [0] = 'driver', [1] = 'passenger' }, true, 'Display Name', { 0, 1 } },
}
---------------------------------------------------------------------------
-- CONFIG END -------------------------------------------------------------
---------------------------------------------------------------------------

api_version = '1.12.0.0'

local players = {}
local vehicle_meta = {}

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
    [cb['EVENT_COMMAND']] = 'OnCommand',
    [cb['EVENT_DIE']] = 'OnPlayerDeath',
    [cb['EVENT_TEAM_SWITCH']] = 'OnTeamSwitch',
    [cb['EVENT_VEHICLE_ENTER']] = 'OnVehicleEnter',
    [cb['EVENT_VEHICLE_EXIT']] = 'OnVehicleExit',
    [cb['EVENT_DAMAGE_APPLICATION']] = 'OnDamageApplication'
}

local function fmt(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function inRange(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= CALL_RADIUS
end

local function getPos(dyn)
    local crouch = read_float(dyn + 0x50C)
    local vehicle_id = read_dword(dyn + 0x11C)
    local vehicle_obj = get_object_memory(vehicle_id)

    local x, y, z
    if vehicle_id == 0xFFFFFFFF then
        x, y, z = read_vector3d(dyn + 0x5C)
    elseif vehicle_obj ~= 0 then
        x, y, z = read_vector3d(vehicle_obj + 0x5C)
    end

    local z_offset = 0.65 - (0.3 * crouch)
    return x, y, z + z_offset
end

local function validateVehicle(object_memory)
    return vehicle_meta[read_dword(object_memory)]
end

local function newEject(player, object, delay)
    local now = os_time()
    return {
        player = player,
        object = object,
        start = now,
        finish = now + delay,
    }
end

local function newCooldown(player, delay, now)
    return {
        player = player,
        start = now,
        finish = now + delay
    }
end

local function send(player, message)
    rprint(player.id, message)
end

local function scheduleEjection(player, object, delay, reason)
    if reason then send(player, reason) end
    send(player, fmt(MESSAGES.ejecting_in, delay))
    player.auto_eject = newEject(player, object, delay)
end

local function scheduleEjectionIfDisabled(player, vehicle_obj, config_entry)
    if EJECT_FROM_DISABLE_VEHICLE and not config_entry.enabled then
        scheduleEjection(
            player,
            vehicle_obj,
            EJECT_FROM_DISABLE_VEHICLE_time,
            fmt(MESSAGES.vehicle_not_enabled)
        )
    end
end

local function hasObjective(dyn_player)
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

local function getVehicleIfDriver(dyn)
    local vehicle_id_offset = 0x11C
    local seat_offset = 0x2F0
    local invalid_vehicle_id = 0xFFFFFFFF

    local vehicle_id = read_dword(dyn + vehicle_id_offset)
    if vehicle_id == invalid_vehicle_id then return nil end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return nil end

    local config_entry = validateVehicle(vehicle_obj)
    if not config_entry then return nil end

    local seat = read_word(dyn + seat_offset)
    if seat ~= 0 then return nil end

    return vehicle_obj, vehicle_id, config_entry
end

local function countOccupants(vehicle_obj)
    local count = 0
    for id = 1, 16 do
        local player = players[id]
        if player and player.current_vehi_obj == vehicle_obj and player_alive(id) then
            count = count + 1
        end
    end
    return count
end

local function doChecks(player, now, dyn)
    if not player_alive(player.id) then
        send(player, fmt(MESSAGES.must_be_alive))
        return false
    end

    if read_dword(dyn + 0x11C) ~= 0xFFFFFFFF then
        send(player, fmt(MESSAGES.already_in_vehicle))
        return false
    end

    if BLOCK_OBJECTIVE and gametype_is_ctf_or_oddball and hasObjective(dyn) then
        send(player, fmt(MESSAGES.carrying_objective))
        return false
    end

    if CALLS_PER_GAME > 0 and player.calls <= 0 then
        send(player, fmt(MESSAGES.no_calls_left))
        return false
    end

    if player.call_cooldown and now < player.call_cooldown.finish then
        local remaining = player.call_cooldown.finish - now
        send(player, fmt(MESSAGES.cooldown_wait, math_floor(remaining)))
        return false
    end

    return true
end

local function isValidPlayer(player, id)
    return player_present(id) and
        player_alive(id) and
        id ~= player.id and
        get_var(id, '$team') == player.team
end

local function getAvailableVehicles(player, caller_x, caller_y, caller_z)
    local available = {}
    local count = 0

    for i = 1, 16 do
        if not isValidPlayer(player, i) then goto continue end
        local dyn = get_dynamic_player(i)
        if not dyn then goto continue end

        local vehicle_obj, vehicle_id, config_entry = getVehicleIfDriver(dyn)
        if vehicle_obj then
            local veh_x, veh_y, veh_z = read_vector3d(vehicle_obj + 0x5C)

            if CALL_RADIUS <= 0 or inRange(caller_x, caller_y, caller_z, veh_x, veh_y, veh_z) then
                count = count + 1
                available[count] = {
                    object = vehicle_obj,
                    id = vehicle_id,
                    meta = config_entry,
                    driver = i,
                    occupants = countOccupants(vehicle_obj)
                }
            end
        end
        ::continue::
    end

    sort(available, function(a, b)
        return a.occupants < b.occupants
    end)

    return available
end

local function findSeat(player, vehicle)
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

local function processPendingRequest(passenger_id, vehicle, seat_id, accepted)
    local passenger = players[passenger_id]
    if not passenger or not passenger.pending_request then return end

    local driver = players[passenger.pending_request.driver_id]
    if driver then
        if accepted then
            enter_vehicle(vehicle.id, passenger_id, seat_id)
            send(passenger, fmt(MESSAGES.entering_vehicle, vehicle.meta.display_name, vehicle.meta.seats[seat_id]))

            if CALLS_PER_GAME > 0 then
                passenger.calls = passenger.calls - 1
                send(passenger, fmt(MESSAGES.remaining_calls, passenger.calls))
            end
        else
            send(passenger, "Your Uber request was declined by the driver.")
        end
    else
        send(passenger, "Driver is no longer available.")
    end

    passenger.pending_request = nil
end

local function callUber(player, dyn)
    local now = os_time()
    dyn = dyn or get_dynamic_player(player.id)

    if not doChecks(player, now, dyn) then return end

    local x, y, z = getPos(dyn)
    if not x then
        send(player, "Unable to determine your position")
        return
    end

    player.call_cooldown = newCooldown(player, COOLDOWN_PERIOD, now)
    local vehicles = getAvailableVehicles(player, x, y, z)

    for _, vehicle in ipairs(vehicles) do
        local seat_id = findSeat(player, vehicle)
        if seat_id then
            if ACCEPT_REJECT then
                local driver = players[vehicle.driver]
                if driver then
                    send(driver,
                        player.name ..
                        " is requesting to join your vehicle. Type '" ..
                        ACCEPT_COMMAND .. "' or '" .. REJECT_COMMAND .. "' to respond.")

                    player.pending_request = {
                        driver_id = vehicle.driver,
                        vehicle_id = vehicle.id,
                        seat_id = seat_id,
                        time_sent = now,
                        timeout = now + ACCEPT_REJECT_TIMEOUT
                    }

                    send(player, "Request sent to driver. Waiting for response...")
                    return
                end
            else
                if CALLS_PER_GAME > 0 then player.calls = player.calls - 1 end
                enter_vehicle(vehicle.id, player.id, seat_id)
                send(player, fmt(MESSAGES.entering_vehicle, vehicle.meta.display_name, vehicle.meta.seats[seat_id]))

                if CALLS_PER_GAME > 0 then
                    send(player, fmt(MESSAGES.remaining_calls, player.calls))
                end
                return
            end
        end
    end

    if CALL_RADIUS > 0 then
        send(player, fmt("No available vehicles within %d units", CALL_RADIUS))
    else
        send(player, fmt(MESSAGES.no_vehicles_available))
    end
end

local function ejectionCheck(player)
    player.auto_eject = nil
    if player.seat ~= 0 then return end

    local dyn = get_dynamic_player(player.id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    for id, other_player in pairs(players) do
        if id ~= player.id and other_player.current_vehi_obj == vehicle_obj then
            scheduleEjection(
                other_player,
                vehicle_obj,
                EJECT_WITHOUT_DRIVER_TIME,
                fmt(MESSAGES.driver_left)
            )
        end
    end
end

local function checkCrouch(player, dyn)
    if not CROUCH_TO_CALL then return end

    local crouching = read_bit(dyn + 0x208, 0)
    if crouching == 1 and player.crouching ~= crouching then callUber(player, dyn) end
    player.crouching = crouching
end

local function processAutoEject(player, now)
    if not player.auto_eject or now < player.auto_eject.finish then return end

    exit_vehicle(player.id)
    send(player, fmt(MESSAGES.ejected))
    player.auto_eject = nil
end

local function processCooldown(player, now)
    if player.call_cooldown and now >= player.call_cooldown.finish then
        player.call_cooldown = nil
    end
end

local function updateVehicleState(player, dyn)
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

local function processPendingRequests(now)
    for _, player in pairs(players) do
        if player and player.pending_request then
            if now > player.pending_request.timeout then
                send(player, "Your Uber request timed out.")
                player.pending_request = nil
            end
        end
    end
end

local function initialize()
    vehicle_meta = {}

    for _, v in ipairs(VEHICLE_SETTINGS) do
        local tag, seats, enabled, label, insertion_order = v[1], v[2], v[3], v[4], v[5]
        local meta_id = getTag('vehi', tag)
        if meta_id then
            vehicle_meta[meta_id] = {
                seats = seats,
                enabled = enabled,
                display_name = label,
                insertion_order = insertion_order
            }
        end
    end

    local game_type = get_var(0, '$gt')
    gametype_is_ctf_or_oddball = game_type == 'ctf' or game_type == 'oddball'
end

local function registerCallbacks(team_game)
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
        registerCallbacks(false)
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

    registerCallbacks(true)
end

function OnJoin(id)
    players[id] = {
        id = id,
        team = get_var(id, '$team'),
        name = get_var(id, '$name'),
        calls = CALLS_PER_GAME,
        crouching = 0,
        auto_eject = nil,
        call_cooldown = nil,
        seat = nil,
        current_vehi_obj = nil,
        pending_request = nil
    }
end

function OnQuit(id)
    local player = players[id]
    if player then
        if player.seat == 0 and player.current_vehi_obj then
            for other_id, other_player in pairs(players) do
                if other_id ~= id and other_player.current_vehi_obj == player.current_vehi_obj then
                    scheduleEjection(
                        other_player,
                        player.current_vehi_obj,
                        EJECT_WITHOUT_DRIVER_TIME,
                        fmt(MESSAGES.driver_left)
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

        processCooldown(player, now)

        local dyn = get_dynamic_player(i)
        if dyn == 0 or not player_alive(i) then goto continue end

        updateVehicleState(player, dyn)
        processAutoEject(player, now)
        checkCrouch(player, dyn)

        ::continue::
    end

    processPendingRequests(now) -- Process pending requests
end

function OnChat(id, msg)
    msg = msg:lower()
    if PHRASES[msg] then
        callUber(players[id])
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
    local config_entry = validateVehicle(vehicle_obj)
    if not config_entry then goto continue end

    scheduleEjectionIfDisabled(player, vehicle_obj, config_entry) -- prevent using disabled vehicles

    ::continue::

    if seat ~= 0 and EJECT_WITHOUT_DRIVER then
        local driver = read_dword(vehicle_obj + 0x324) -- check if the vehicle has a driver
        if driver == 0xFFFFFFFF then
            scheduleEjection(
                player,
                vehicle_obj,
                EJECT_WITHOUT_DRIVER_TIME,
                fmt(MESSAGES.vehicle_no_driver)
            )
        end
    end

    if seat == 0 then
        for _, p in pairs(players) do
            if p.auto_eject and p.auto_eject.object == vehicle_obj then
                p.auto_eject = nil
                send(p, fmt(MESSAGES.ejection_cancelled))
            end
        end
    end
end

function OnVehicleExit(id)
    ejectionCheck(players[id])
end

function OnPlayerDeath(id)
    ejectionCheck(players[id])
end

function OnTeamSwitch(id)
    players[id].team = get_var(id, '$team')
end

-- todo: review this and make sure it works
function OnDamageApplication(id, _, _, damage)
    if not DRIVER_ONLY_IMMUNE then return true end

    local victim_obj = get_object_memory(id)
    if victim_obj == 0 then return true end

    local config_entry = validateVehicle(victim_obj)
    if config_entry then
        local occupants = countOccupants(victim_obj)
        if occupants == 1 then return false end
    end

    return true, damage
end

function OnCommand(id, command)
    local cmd = command:lower()
    local player = players[id]

    if player then
        if (cmd == ACCEPT_COMMAND or cmd == REJECT_COMMAND) and not ACCEPT_REJECT then
            send(player, "Accept/reject system is disabled.")
            return false
        end

        if cmd == ACCEPT_COMMAND then
            -- Check if player is a driver and has pending requests
            local dyn = get_dynamic_player(id)
            if dyn == 0 then return true end

            local vehicle_obj, _, config_entry = getVehicleIfDriver(dyn)
            if not vehicle_obj then
                send(player, "You must be a driver to accept Uber requests.")
                return false
            end

            -- Find pending requests for this driver
            local found_request = false
            for passenger_id, p in pairs(players) do
                if p and p.pending_request and p.pending_request.driver_id == id then
                    found_request = true
                    local vehicle = {
                        id = p.pending_request.vehicle_id,
                        meta = config_entry
                    }
                    processPendingRequest(passenger_id, vehicle, p.pending_request.seat_id, true)
                    send(player, "Accepted " .. p.name .. "'s Uber request.")
                    break
                end
            end

            if not found_request then
                send(player, "No pending Uber requests.")
            end

            return false
        end

        if cmd == REJECT_COMMAND then
            -- Check if player is a driver and has pending requests
            local dyn = get_dynamic_player(id)
            if dyn == 0 then return true end

            local vehicle_obj, _, _ = getVehicleIfDriver(dyn)
            if not vehicle_obj then
                send(player, "You must be a driver to reject Uber requests.")
                return false
            end

            -- Find pending requests for this driver
            local found_request = false
            for passenger_id, p in pairs(players) do
                if p and p.pending_request and p.pending_request.driver_id == id then
                    found_request = true
                    processPendingRequest(passenger_id, nil, nil, false)
                    send(player, "Rejected " .. p.name .. "'s Uber request.")
                    break
                end
            end

            if not found_request then
                send(player, "No pending Uber requests.")
            end

            return false
        end
    end
    return true
end

function OnScriptUnload() end
