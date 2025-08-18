--[[
--=====================================================================================================--
Script Name: Custom Vehicle Spawner, for SAPP (PC & CE)
Description: This script will spawn vehicles at pre-defined coordinates.
             If a vehicle has moved from its original position and isn't occupied,
             it will be moved back to its original position after a delay.

Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local VehicleSpawner = {
    vehicles = {},
    maps = {
        ['bloodgulch'] = {
            ['Race'] = {
                { 'vehi', 'vehicles\\warthog\\mp_warthog', 66.580, -120.474, 0.064, 6.588, 30, 1 },
                { 'vehi', 'vehicles\\banshee\\banshee_mp', 78.099, -131.189, -0.035, 0.300, 30, 1 },
            },
        },
        -- Add other maps and game modes here...
    }
}

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    OnStart()
end

function OnScriptUnload()
    -- N/A
end

function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        VehicleSpawner:Initialize()
    end
end

function OnEnd()
    unregister_callback(cb['EVENT_TICK'])
end

local function IsOccupied(obj)
    for i = 1, 16 do
        local dyn = get_dynamic_player(i)
        if player_present(i) and player_alive(i) and dyn ~= 0 then
            local vehicle = read_dword(dyn + 0x11C)
            local object = get_object_memory(vehicle)
            if object ~= 0 and vehicle ~= 0xFFFFFFFF and object == obj then
                return true
            end
        end
    end
    return false
end

local function CalculateDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
end

function CheckVehicles()
    for _, v in pairs(VehicleSpawner.vehicles) do
        local object = get_object_memory(v.object)
        if object ~= 0 and not IsOccupied(object) then
            local x, y, z = read_vector3d(object + 0x5C)
            local distance = CalculateDistance(v.x, v.y, v.z, x, y, z)
            if distance > v.respawn_radius then
                if not v.delay then
                    v.delay = os.clock() + v.respawn_time
                elseif os.clock() >= v.delay then
                    v.delay = nil
                    v:Spawn()
                end
            else
                v.delay = nil
            end
        end
    end
end

local function GetTag(Class, Name)
    local tag = lookup_tag(Class, Name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

function VehicleSpawner:Initialize()
    self.vehicles = {}

    local map = get_var(0, '$map')
    local mode = get_var(0, '$mode')

    if self.maps[map] and self.maps[map][mode] then
        for _, v in ipairs(self.maps[map][mode]) do
            local class, name, x, y, z, rotation, respawn_time, respawn_radius = unpack(v)
            local tag = GetTag(class, name)
            if tag then
                table.insert(self.vehicles, self:NewVehicle({
                    x = x, y = y, z = z, rotation = rotation,
                    meta_id = tag, respawn_time = respawn_time, respawn_radius = respawn_radius
                }))
            end
        end
        register_callback(cb['EVENT_TICK'], 'CheckVehicles')
    end
end

function VehicleSpawner:NewVehicle(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o:Spawn()
    return o
end

function VehicleSpawner:Spawn()
    if self.object then
        destroy_object(self.object)
    end
    self.object = spawn_object('', '', self.x, self.y, self.z, self.rotation, self.meta_id)
end
