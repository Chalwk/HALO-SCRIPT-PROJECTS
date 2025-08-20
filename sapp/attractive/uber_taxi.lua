--[[
=====================================================================================
SCRIPT NAME:      uber_taxi.lua
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

LAST UPDATED:     20/8/2025

Copyright (c) 2020-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

---------------------------------------------------------------------------
-- CONFIG START -----------------------------------------------------------
---------------------------------------------------------------------------

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

-- Priority order for seat assignment when entering vehicles
-- *    When adding a custom vehicle to 'valid_vehicles', check its total seat count.
--      If the vehicle has more than 5 seats, extend the 'insertion_order' table to include all seat indices.
local insertion_order = { 0, 1, 2, 3, 4 }

-- Each entry describes a vehicle allowed for Uber calls:
-- { vehicle tag path, seat roles by seat index, enabled flag, display name, priority }
local valid_vehicles = {
    { 'vehicles\\rwarthog\\rwarthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner'
    }, true, 'Rocket Hog', 3 },

    { 'vehicles\\warthog\\mp_warthog', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'gunner',
    }, true, 'Chain Gun Hog', 2 },

    { 'vehicles\\scorpion\\scorpion_mp', {
        [0] = 'driver',
        [1] = 'passenger',
        [2] = 'passenger',
        [3] = 'passenger',
        [4] = 'passenger'
    }, false, 'Tank', 1 },     -- Disabled by default

    -- Add more vehicle entries here
}

-- Settings controlling Uber script behavior:
local calls_per_game = 20                  -- Max Uber calls allowed per player per game (0 = unlimited)
local block_objective = true               -- Prevent Uber calls if player is carrying an objective (e.g. flag)
local crouch_to_uber = true                -- Enable Uber call when player crouches
local cooldown_period = 10                 -- Cooldown time (seconds) between Uber calls per player
local eject_from_disabled_vehicle = true   -- Eject players from vehicles that aren't enabled for Uber
local eject_from_disabled_vehicle_time = 3 -- Delay before ejecting from disabled vehicle (seconds)
local eject_without_driver = true          -- Eject passengers if vehicle has no driver
local eject_without_driver_time = 5        -- Delay before ejecting without driver (seconds)

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
    for _, seat_id in ipairs(insertion_order) do
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
            send(player, fmt(messages.entering_vehicle, vehicle.meta.label, vehicle.meta.seats[seat_id]), true)

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
        local meta_id = get_tag('vehi', v[1])
        if meta_id then
            if v[3] then -- check enabled
                valid_vehicles_meta[meta_id] = {
                    enabled = v[3],
                    seats = v[2],
                    label = v[4],
                    priority = v[5]
                }
            end
        end
    end

    local game_type = get_var(0, '$gt')
    gametype_is_ctf_or_oddball = game_type == 'ctf' or game_type == 'oddball'
end

local function register_callbacks(enable)
    for event, callback in pairs(sapp_events) do
        if enable then
            register_callback(event, callback)
        else
            unregister_callback(event, callback)
        end
    end
    if not enable then
        cprint('====================================', 12)
        cprint('[Uber] Only runs on team-based games', 12)
        cprint('====================================', 12)
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
