--=====================================================================================--
-- SCRIPT NAME:      Uber
-- DESCRIPTION:      Allows players to call an Uber to join teammates vehicles
--                   by injecting themselves into available seats according to
--                   configurable priority and cooldown settings. Supports vehicle
--                   validation, auto ejection from unauthorized vehicles, crouch
--                   to uber activation, and call limits per player per game.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2020-2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

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
        must_be_alive             = "You must be alive to call an uber",
        already_in_vehicle        = "You cannot call an uber while in a vehicle",
        carrying_objective        = "You cannot call uber while carrying an objective",
        no_calls_left             = "You have no more uber calls left",
        cooldown_wait             = "Please wait %d seconds",
        entering_vehicle          = "Entering %s as %s",
        remaining_calls           = "Remaining calls: %d",
        no_vehicles_available     = "No available vehicles or seats",
        driver_left               = "Driver left the vehicle",
        ejecting_in               = "Ejecting in %d seconds...",
        ejected                   = "Ejected from vehicle",
        vehicle_not_enabled       = "This vehicle is not enabled for uber",
        vehicle_no_driver         = "Vehicle has no driver",
        ejection_cancelled        = "Driver entered, ejection cancelled"
    },

    insertion_order = { 0, 1, 2, 3, 4 }, -- Priority order for seat assignment when entering vehicles (0 = driver seat)

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
    },

    -- Settings controlling Uber script behavior:

    calls_per_game = 20,                    -- Max Uber calls allowed per player per game (0 = unlimited)
    block_objective = true,                 -- Prevent Uber calls if player is carrying an objective (e.g. flag)
    crouch_to_uber = true,                  -- Enable Uber call when player crouches
    cooldown_period = 10,                   -- Cooldown time (seconds) between Uber calls per player
    eject_from_disabled_vehicle = true,     -- Eject players from vehicles that aren't enabled for Uber
    eject_from_disabled_vehicle_time = 3,   -- Delay before ejecting from disabled vehicle (seconds)
    eject_without_driver = true,            -- Eject passengers if vehicle has no driver
    eject_without_driver_time = 5,          -- Delay before ejecting without driver (seconds)

    ---------------------------------------------------------------------------
    -- CONFIG END -------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- Player methods table
    player_mt = {},

    -- Vehicle cache
    vehicles = {},
    valid_vehicles_meta = {},

    -- Game state
    objective = nil,

    -- Utility references
    time = os.time,
    floor = math.floor
}

-- Helper local function to format messages cleanly
local function fmt(message, ...)
    if select('#', ...) > 0 then
        return message:format(...)
    else
        return message
    end
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

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

function Uber.NewEject(player, object, delay)
    return {
        player = player,
        object = object,
        start = Uber.time(),
        finish = Uber.time() + delay,
    }
end

function Uber.NewCooldown(player, delay)
    return {
        player = player,
        start = Uber.time(),
        finish = Uber.time() + delay
    }
end

-- Player methods
function Uber.player_mt:Tell(message, clear)
    if clear then
        for _ = 1, 25 do rprint(self.id, '') end
    end
    rprint(self.id, message)
end

function Uber.player_mt:ValidateVehicle(object)
    local meta_id = read_dword(object)
    return Uber.vehicles[meta_id]
end

function Uber.player_mt:DoChecks()
    local dyn = get_dynamic_player(self.id)
    if dyn == 0 then
        return false
    end

    if not player_alive(self.id) then
        self:Tell(fmt(Uber.messages.must_be_alive), true)
        return false
    end

    if read_dword(dyn + 0x11C) ~= 0xFFFFFFFF then
        self:Tell(fmt(Uber.messages.already_in_vehicle), true)
        return false
    end

    if Uber.block_objective and Uber.objective and self:HasObjective(dyn) then
        self:Tell(fmt(Uber.messages.carrying_objective), true)
        return false
    end

    if Uber.calls_per_game > 0 and self.calls <= 0 then
        self:Tell(fmt(Uber.messages.no_calls_left), true)
        return false
    end

    if self.call_cooldown and Uber.time() < self.call_cooldown.finish then
        local remaining = self.call_cooldown.finish - Uber.time()
        self:Tell(fmt(Uber.messages.cooldown_wait, Uber.floor(remaining)), true)
        return false
    end

    return true
end

function Uber.player_mt:HasObjective(dyn)
    local base_tag_table = read_dword(0x40440000)
    local weapon_offset = 0x2F8
    local slot_size = 4
    local tag_entry_size = 0x20
    local tag_data_offset = 0x14
    local bit_check_offset = 0x308
    local bit_index = 3

    for i = 0, 3 do
        local weapon_ptr = read_dword(dyn + weapon_offset + slot_size * i)
        if weapon_ptr ~= 0xFFFFFFFF then
            local obj = get_object_memory(weapon_ptr)
            if obj ~= 0 then
                local tag_address = read_word(obj)
                local tag_entry = base_tag_table + tag_address * tag_entry_size + tag_data_offset
                local tag_data = read_dword(tag_entry)
                if read_bit(tag_data + bit_check_offset, bit_index) == 1 then
                    return true
                end
            end
        end
    end
    return false
end

-- Helper: check if player is valid for the current player (self)
function Uber.player_mt:_isValidPlayer(id)
    return player_present(id) and
        player_alive(id) and
        id ~= self.id and
        get_var(id, '$team') == self.team
end

-- Helper: get dynamic player pointer or nil
function Uber.player_mt:_getPlayerDyn(i)
    local dyn = get_dynamic_player(i)
    return dyn ~= 0 and dyn or nil
end

-- Helper: get vehicle info if player in driver seat, else nil
function Uber.player_mt:_getVehicleIfDriver(dyn)
    local vehicle_id_offset = 0x11C
    local seat_offset = 0x2F0
    local invalid_vehicle_id = 0xFFFFFFFF

    local vehicle_id = read_dword(dyn + vehicle_id_offset)
    if vehicle_id == invalid_vehicle_id then return nil end

    local vehicle_obj = get_object_memory(vehicle_id)
    if vehicle_obj == 0 then return nil end

    local meta_id = read_dword(vehicle_obj)
    local vehicle = Uber.vehicles[meta_id]
    if not vehicle then return nil end

    local seat = read_word(dyn + seat_offset)
    if seat ~= 0 then return nil end

    return vehicle_obj, vehicle_id, vehicle
end

-- Main function uses those helpers:
function Uber.player_mt:GetAvailableVehicles()
    local available = {}
    local count = 0

    for i = 1, 16 do
        if self:_isValidPlayer(i) then
            local dyn = self:_getPlayerDyn(i)
            if dyn then
                local vehicle_obj, vehicle_id, vehicle = self:_getVehicleIfDriver(dyn)
                if vehicle_obj then
                    count = count + 1
                    available[count] = {
                        object = vehicle_obj,
                        id = vehicle_id,
                        meta = vehicle,
                        driver = i
                    }
                end
            end
        end
    end

    table.sort(available, function(a, b)
        return a.meta.priority > b.meta.priority
    end)

    return available
end

function Uber.player_mt:FindSeat(vehicle)
    for _, seat_id in ipairs(Uber.insertion_order) do
        if not vehicle.meta.seats[seat_id] then
            goto continue
        end

        local seat_free = true
        for i = 1, 16 do
            if not player_present(i) then goto next_player end

            local dyn = get_dynamic_player(i)
            if dyn == 0 then goto next_player end

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

function Uber.player_mt:CallUber()
    if not self:DoChecks() then return end

    self.call_cooldown = Uber.NewCooldown(self, Uber.cooldown_period)
    local vehicles = self:GetAvailableVehicles()

    for _, vehicle in ipairs(vehicles) do
        local seat_id = self:FindSeat(vehicle)
        if seat_id then
            if Uber.calls_per_game > 0 then
                self.calls = self.calls - 1
            end

            enter_vehicle(vehicle.id, self.id, seat_id)
            self:Tell(fmt(Uber.messages.entering_vehicle, vehicle.meta.label, vehicle.meta.seats[seat_id]), true)

            if Uber.calls_per_game > 0 then
                self:Tell(fmt(Uber.messages.remaining_calls, self.calls), false)
            end

            return
        end
    end

    self:Tell(fmt(Uber.messages.no_vehicles_available), true)
end

function Uber.player_mt:EjectionCheck()
    if self.seat ~= 0 then return end

    local dyn = get_dynamic_player(self.id)
    if dyn == 0 then return end

    local vehicle_id = read_dword(dyn + 0x11C)
    if vehicle_id == 0xFFFFFFFF then return end

    local vehicle_obj = get_object_memory(vehicle_id)
    for id, player in pairs(Uber.players) do
        if id ~= self.id and player.current_vehi_obj == vehicle_obj then
            player:ScheduleEjection(
                vehicle_obj,
                Uber.eject_without_driver_time,
                fmt(Uber.messages.driver_left)
            )
        end
    end
end

function Uber.player_mt:ScheduleEjection(object, delay, reason)
    if reason then self:Tell(reason) end
    self:Tell(fmt(Uber.messages.ejecting_in, delay))
    self.auto_eject = Uber.NewEject(self, object, delay)
end

function Uber.player_mt:CheckCrouch(dyn)
    if not Uber.crouch_to_uber then return end

    local crouching = read_bit(dyn + 0x208, 0)
    if crouching == 1 and self.crouching ~= crouching then
        self:CallUber()
    end
    self.crouching = crouching
end

function Uber.player_mt:ProcessAutoEject()
    if not self.auto_eject or Uber.time() < self.auto_eject.finish then return end

    exit_vehicle(self.id)
    self:Tell(fmt(Uber.messages.ejected))
    self.auto_eject = nil
end

function Uber.player_mt:ProcessCooldown()
    if self.call_cooldown and Uber.time() >= self.call_cooldown.finish then
        self.call_cooldown = nil
    end
end

function Uber.player_mt:UpdateVehicleState(dyn)
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

-- Event Handlers
function OnScriptLoad()
    Uber:Initialize()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_CHAT'], 'OnChat')
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnVehicleEnter')
    register_callback(cb['EVENT_VEHICLE_EXIT'], 'OnVehicleExit')
    register_callback(cb['EVENT_DIE'], 'OnPlayerDeath')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnTeamSwitch')
end

function Uber:Initialize()
    self.vehicles = {}
    self.valid_vehicles_meta = {}

    for _, v in ipairs(self.valid_vehicles) do
        local tag = getTag('vehi', v[1])
        if tag then
            local entry = {
                enabled = v[3],
                seats = v[2],
                label = v[4],
                priority = v[5]
            }
            self.valid_vehicles_meta[tag] = entry

            if v[3] then
                self.vehicles[tag] = entry
            end
        end
    end

    local game_type = get_var(0, '$gt')
    self.objective = (game_type == 'ctf' or game_type == 'oddball')
end

function OnStart()
    Uber:Initialize()
    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
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
                    other_player:ScheduleEjection(
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
        if player_present(id) then
            local dyn = get_dynamic_player(id)
            if dyn ~= 0 then
                player:UpdateVehicleState(dyn)
                player:ProcessCooldown()
                player:ProcessAutoEject()

                if player_alive(id) then
                    player:CheckCrouch(dyn)
                end
            end
        end
    end
end

function OnChat(id, msg)
    msg = msg:lower()
    if Uber.phrases[msg] then
        Uber.players[id]:CallUber()
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

    local meta_id = read_dword(vehicle_obj)
    local config_entry = Uber.valid_vehicles_meta[meta_id]

    if config_entry then
        if not config_entry.enabled then
            if Uber.eject_from_disabled_vehicle then
                player:ScheduleEjection(
                    vehicle_obj,
                    Uber.eject_from_disabled_vehicle_time,
                    fmt(Uber.messages.vehicle_not_enabled)
                )
            end
            return
        end
    else
        return
    end

    if seat ~= 0 and Uber.eject_without_driver then
        local driver = read_dword(vehicle_obj + 0x324)
        if driver == 0xFFFFFFFF then
            player:ScheduleEjection(
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
                p:Tell(fmt(Uber.messages.ejection_cancelled))
            end
        end
    end
end

function OnVehicleExit(id)
    Uber.players[id]:EjectionCheck()
end

function OnPlayerDeath(id)
    Uber.players[id].auto_eject = nil
    Uber.players[id]:EjectionCheck()
end

function OnTeamSwitch(id)
    Uber.players[id].team = get_var(id, '$team')
end

function OnScriptUnload() end