--[[
===============================================================================
SCRIPT NAME:      custom_vehicle_spawner.lua
DESCRIPTION:      Manages persistent vehicle spawns with:
                  - Automatic respawning of moved vehicles
                  - Map-specific vehicle configurations
                  - Occupancy detection
                  - Configurable respawn timers
                  - Movement threshold detection
                  - Multi-map support
                  - Gametype-specific setups

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
===============================================================================
]]

api_version = '1.12.0.0'

-- Config start ----------------------------------------
local VEHICLES = {
    bloodgulch = {
        ['Race'] = {
            { 'vehi', 'vehicles\\warthog\\mp_warthog', 66.580, -120.474, 0.064, 6.588, 30, 1 },
            { 'vehi', 'vehicles\\banshee\\banshee_mp', 78.099, -131.189, -0.035, 0.300, 30, 1 },
            -- Add more vehicles here...
        }
    }
    -- Add more maps here...
}
-- Config end ------------------------------------------

local os_time = os.time
local table_insert = table.insert
local vehicles = {} -- Active vehicle instances
local Vehicle = {}  -- Vehicle metatable

local get_object_memory, destroy_object, spawn_object, lookup_tag, read_dword =
    get_object_memory, destroy_object, spawn_object, lookup_tag, read_dword

local player_present, player_alive, get_dynamic_player, read_vector3d = player_present, player_alive, get_dynamic_player,
    read_vector3d

function Vehicle:new(data)
    setmetatable(data, self)
    self.__index = self
    return data
end

function Vehicle:spawn()
    if self.object then
        destroy_object(self.object)
    end
    self.object = spawn_object('', '', self.x, self.y, self.z, self.yaw, self.meta_id)
end

local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

local function isOccupied(vehicleObj)
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local dyn = get_dynamic_player(i)
            if dyn ~= 0 then
                local v_id = read_dword(dyn + 0x11C)
                if v_id ~= 0xFFFFFFFF then
                    local v_obj = get_object_memory(v_id)
                    if v_obj ~= 0 and v_obj == vehicleObj then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function hasMoved(v, obj)
    local cx, cy, cz = read_vector3d(obj + 0x5C)
    local dx, dy, dz = v.x - cx, v.y - cy, v.z - cz
    local dist2 = dx * dx + dy * dy + dz * dz
    return dist2 > (v.respawn_radius * v.respawn_radius)
end

function CheckVehicles()
    local now = os_time()
    for _, v in pairs(vehicles) do
        local obj = get_object_memory(v.object)
        if obj == 0 then
            v:spawn()
            goto continue
        end
        if isOccupied(obj) then
            v.delay = nil
            goto continue
        end

        if hasMoved(v, obj) then
            v.delay = v.delay or (now + v.respawn_time)
            if now >= v.delay then
                v:spawn()
                v.delay = nil
            end
        else
            v.delay = nil
        end

        ::continue::
    end
end

local function initVehicles()
    vehicles   = {}

    local map  = get_var(0, '$map')
    local mode = get_var(0, '$mode')
    local cfg  = VEHICLES[map] and VEHICLES[map][mode]

    if not cfg then return end

    for _, entry in ipairs(cfg) do
        local class, tag, x, y, z, yaw, respawn_time, radius = unpack(entry)
        local meta_id = getTag(class, tag)
        if meta_id then
            local v = Vehicle:new({
                x = x,
                y = y,
                z = z,
                yaw = yaw,
                meta_id = meta_id,
                respawn_time = respawn_time,
                respawn_radius = radius
            })
            v:spawn()
            table_insert(vehicles, v)
        end
    end

    register_callback(cb['EVENT_TICK'], 'CheckVehicles')
end

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    OnGameStart()
end

function OnGameStart()
    if get_var(0, '$gt') ~= 'n/a' then
        initVehicles()
    end
end

function OnGameEnd()
    unregister_callback(cb['EVENT_TICK'])
end

function OnScriptUnload() end
