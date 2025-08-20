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

local Uber = {

    ---------------------------------------------------------------------------
    -- CONFIG START -----------------------------------------------------------
    ---------------------------------------------------------------------------

    phrases = {
        -- Chat keywords players can use to call an Uber
        ['uber'] = true,
        ['taxi'] = true,
        ['cab'] = true,
        ['taxo'] = true
    },

    messages = {
        -- Player-facing messages for various Uber script events and errors
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
    },

    insertion_order = { 0, 1, 2, 3, 4 }, -- Priority order for seat assignment when entering vehicles

    valid_vehicles = {
        -- Each entry describes a vehicle allowed for Uber calls:
        -- { vehicle tag path, seat roles by seat index, enabled flag, display name, priority }
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
        }, false, 'Tank', 1 }, -- Disabled by default

        -- Add more vehicle entries here
    },

    -- Settings controlling Uber script behavior:

    calls_per_game = 20,                  -- Max Uber calls allowed per player per game (0 = unlimited)
    block_objective = true,               -- Prevent Uber calls if player is carrying an objective (e.g. flag)
    crouch_to_uber = true,                -- Enable Uber call when player crouches
    cooldown_period = 10,                 -- Cooldown time (seconds) between Uber calls per player
    eject_from_disabled_vehicle = true,   -- Eject players from vehicles that aren't enabled for Uber
    eject_from_disabled_vehicle_time = 3, -- Delay before ejecting from disabled vehicle (seconds)
    eject_without_driver = true,          -- Eject passengers if vehicle has no driver
    eject_without_driver_time = 5,        -- Delay before ejecting without driver (seconds)

    ---------------------------------------------------------------------------
    -- CONFIG END -------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- Player methods table
    player_mt = {},

    -- Vehicle cache
    valid_vehicles_meta = {},
}

-- Localized frequently used variables/functions
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

-- Helper local function to format messages cleanly
local function fmt(message, ...)
    if select('#', ...) > 0 then return message:format(...) end
    return message
end

-- Create the players table with metatable *after* Uber is fully defined
Uber.players = setmetatable({}, {
    __index = function(t, id)
        local new = {
            id = id,
            team = get_var(id, '$team'),
            name = get_var(id, '$name'),
            calls = Uber.calls_per_game,
            crouching = 0,
            auto_eject = nil,
            call_cooldown = nil,
            seat = nil,
            current_vehi_obj = nil
        }
        setmetatable(new, { __index = Uber.player_mt })
        t[id] = new
        return new
    end
})

api_version = '1.12.0.0'

local function get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function validate_vehicle(object_memory)
    local meta_id = read_dword(object_memory)
    return Uber.valid_vehicles_meta[meta_id]
end

local function schedule_ejection_if_disabled(player, vehicle_obj, config_entry)
    if Uber.eject_from_disabled_vehicle and not config_entry.enabled then
        player:schedule_ejection(
            vehicle_obj,
            Uber.eject_from_disabled_vehicle_time,
            fmt(Uber.messages.vehicle_not_enabled)
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

-- Helper: get vehicle info if player in driver seat, else nil
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

local function new_eject(player, object, delay)
    return {
        player = player,
        object = object,
        start = os_time(),
        finish = os_time() + delay,
    }
end

local function new_cooldown(player, delay)
    return {
        player = player,
        start = os_time(),
        finish = os_time() + delay
    }
end

-- Player methods
function Uber.player_mt:send(message, clear)
    if clear then
        for _ = 1, 25 do rprint(self.id, '') end
    end
    rprint(self.id, message)
end

function Uber.player_mt:do_checks()
    local dyn = get_dynamic_player(self.id)
    if dyn == 0 then return false end

    if not player_alive(self.id) then
        self:send(fmt(Uber.messages.must_be_alive), true)
        return false
    end

    if read_dword(dyn + 0x11C) ~= 0xFFFFFFFF then
        self:send(fmt(Uber.messages.already_in_vehicle), true)
        return false
    end

    if Uber.block_objective and gametype_is_ctf_or_oddball and has_objective(dyn) then
        self:send(fmt(Uber.messages.carrying_objective), true)
        return false
    end

    if Uber.calls_per_game > 0 and self.calls <= 0 then
        self:send(fmt(Uber.messages.no_calls_left), true)
        return false
    end

    if self.call_cooldown and os_time() < self.call_cooldown.finish then
        local remaining = self.call_cooldown.finish - os_time()
        self:send(fmt(Uber.messages.cooldown_wait, math_floor(remaining)), true)
        return false
    end

    return true
end

-- Helper: check if player is valid for the current player (self)
function Uber.player_mt:is_valid_player(id)
    return player_present(id) and
        player_alive(id) and
        id ~= self.id and
        get_var(id, '$team') == self.team
end

-- Main function uses those helpers:
function Uber.player_mt:get_available_vehicles()
    local available = {}
    local count = 0

    for i = 1, 16 do
        if not self:is_valid_player(i) then goto continue end
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

function Uber.player_mt:find_seat(vehicle)
    for _, seat_id in ipairs(Uber.insertion_order) do
        if not vehicle.meta.seats[seat_id] then goto continue end

        local seat_free = true
        for i = 1, 16 do
            if not player_present(i) then goto next_player end

            local dyn = get_dynamic_player(i)
            if dyn == 0 or not player_alive(i) then goto next_player end

            local veh_id = read_dword(dyn + 0x11C)
            if veh_id == 0xFFFFFFFF then goto next_player end

            local veh_obj = get_object_memory(veh_id)
            if veh_obj ~= vehicle.object then goto next_player end

            if read_word(dyn + 0x2F0) == seat_id then
                seat_free = false
                break
            end

            ::next_player::
        end

        if seat_free then
            return seat_id
        end

        ::continue::
    end
end

function Uber.player_mt:call_uber()
    if not self:do_checks() then return end

    self.call_cooldown = new_cooldown(self, Uber.cooldown_period)
    local vehicles = self:get_available_vehicles()

    for _, vehicle in ipairs(vehicles) do
        local seat_id = self:find_seat(vehicle)
        if seat_id then
            if Uber.calls_per_game > 0 then self.calls = self.calls - 1 end

            enter_vehicle(vehicle.id, self.id, seat_id)
            self:send(fmt(Uber.messages.entering_vehicle, vehicle.meta.label, vehicle.meta.seats[seat_id]), true)

            if Uber.calls_per_game > 0 then
                self:send(fmt(Uber.messages.remaining_calls, self.calls), false)
            end

            return
        end
    end

    self:send(fmt(Uber.messages.no_vehicles_available), true)
end

function Uber.player_mt:ejection_check()
    if self.seat ~= 0 then return end

    local dyn = get_dynamic_player(self.id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    for id, player in pairs(Uber.players) do
        if id ~= self.id and player.current_vehi_obj == vehicle_obj then
            player:schedule_ejection(
                vehicle_obj,
                Uber.eject_without_driver_time,
                fmt(Uber.messages.driver_left)
            )
        end
    end
end

function Uber.player_mt:schedule_ejection(object, delay, reason)
    if reason then self:send(reason) end
    self:send(fmt(Uber.messages.ejecting_in, delay))
    self.auto_eject = new_eject(self, object, delay)
end

function Uber.player_mt:check_crouch(dyn)
    if not Uber.crouch_to_uber then return end

    local crouching = read_bit(dyn + 0x208, 0)
    if crouching == 1 and self.crouching ~= crouching then self:call_uber() end
    self.crouching = crouching
end

function Uber.player_mt:process_auto_eject()
    if not self.auto_eject or os_time() < self.auto_eject.finish then return end

    exit_vehicle(self.id)
    self:send(fmt(Uber.messages.ejected))
    self.auto_eject = nil
end

function Uber.player_mt:process_cooldown()
    if self.call_cooldown and os_time() >= self.call_cooldown.finish then
        self.call_cooldown = nil
    end
end

function Uber.player_mt:update_vehicle_state(dyn)
    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then
        self.seat = nil
        self.current_vehi_obj = nil
        return
    end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj ~= 0 then
        self.seat = read_word(dyn + 0x2F0)
        self.current_vehi_obj = vehicle_obj
    end
end

function Uber:initialize()
    self.valid_vehicles_meta = {}

    for _, v in ipairs(self.valid_vehicles) do
        local meta_id = get_tag('vehi', v[1])
        if meta_id then
            if v[3] then -- check enabled
                self.valid_vehicles_meta[meta_id] = {
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

local events = {
    [cb['EVENT_TICK']] = 'OnTick',
    [cb['EVENT_JOIN']] = 'OnJoin',
    [cb['EVENT_LEAVE']] = 'OnQuit',
    [cb['EVENT_CHAT']] = 'OnChat',
    [cb['EVENT_VEHICLE_ENTER']] = 'OnVehicleEnter',
    [cb['EVENT_VEHICLE_EXIT']] = 'OnVehicleExit',
    [cb['EVENT_DIE']] = 'OnPlayerDeath',
    [cb['EVENT_TEAM_SWITCH']] = 'OnTeamSwitch'
}

-- Event Handlers
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function register_callbacks(enable)
    for event, callback in pairs(events) do
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

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end
    if get_var(0, '$ffa') == '1' then
        register_callbacks(false)
        return
    end

    Uber:initialize()
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end

    register_callbacks(true)
end

function OnJoin(id)
    Uber.players[id] = Uber.players[id]
end

function OnQuit(id)
    local player = Uber.players[id]
    if player then
        if player.seat == 0 and player.current_vehi_obj then
            for other_id, other_player in pairs(Uber.players) do
                if other_id ~= id and other_player.current_vehi_obj == player.current_vehi_obj then
                    other_player:schedule_ejection(
                        player.current_vehi_obj,
                        Uber.eject_without_driver_time,
                        fmt(Uber.messages.driver_left)
                    )
                end
            end
        end
        Uber.players[id] = nil
    end
end

function OnTick()
    for id, player in pairs(Uber.players) do
        if not player_present(id) then goto continue end

        player:process_cooldown()

        local dyn = get_dynamic_player(id)
        if dyn == 0 or not player_alive(id) then goto continue end

        player:update_vehicle_state(dyn)
        player:process_auto_eject()
        player:check_crouch(dyn)

        ::continue::
    end
end

function OnChat(id, msg)
    msg = msg:lower()
    if Uber.phrases[msg] then
        Uber.players[id]:call_uber()
        return false
    end
end

function OnVehicleEnter(id, seat)
    seat = tonumber(seat)

    local player = Uber.players[id]
    local dyn = get_dynamic_player(id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return end

    local config_entry = validate_vehicle(vehicle_obj)
    if not config_entry then goto continue end

    schedule_ejection_if_disabled(player, vehicle_obj, config_entry)

    ::continue::

    if seat ~= 0 and Uber.eject_without_driver then
        local driver = read_dword(vehicle_obj + 0x324)
        if driver == 0xFFFFFFFF then
            player:schedule_ejection(
                vehicle_obj,
                Uber.eject_without_driver_time,
                fmt(Uber.messages.vehicle_no_driver)
            )
        end
    end

    if seat == 0 then
        for _, p in pairs(Uber.players) do
            if p.auto_eject and p.auto_eject.object == vehicle_obj then
                p.auto_eject = nil
                p:send(fmt(Uber.messages.ejection_cancelled))
            end
        end
    end
end

function OnVehicleExit(id)
    Uber.players[id]:ejection_check()
end

function OnPlayerDeath(id)
    Uber.players[id].auto_eject = nil
    Uber.players[id]:ejection_check()
end

function OnTeamSwitch(id)
    Uber.players[id].team = get_var(id, '$team')
end

function OnScriptUnload() end
