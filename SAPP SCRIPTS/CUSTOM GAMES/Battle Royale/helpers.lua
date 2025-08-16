local HELPERS = {}

local get_object_memory = get_object_memory
local floor, format, random = math.floor, string.format, math.random
local cos, sin = math.cos, math.sin
local player_present, player_alive = player_present, player_alive
local execute_command, say_all, rprint = execute_command, say_all, rprint
local read_float, read_dword, read_vector3d, read_byte, write_vector3d =
    read_float, read_dword, read_vector3d, read_byte, write_vector3d

function HELPERS.get_player_position(dyn_player)
    local in_vehicle = false
    local vehicle = read_dword(dyn_player + 0x11C)
    local x, y, z
    if vehicle ~= 0xFFFFFFFF then
        local obj = get_object_memory(vehicle)
        if obj ~= 0 then
            in_vehicle = true
            x, y, z = read_vector3d(obj + 0x5C)
        end
    else
        x, y, z = read_vector3d(dyn_player + 0x5C)
    end
    if not x then return end
    local crouching = read_float(dyn_player + 0x50C)
    return x, y, z + (crouching ~= 0 and 0.35 * crouching or 0.65), in_vehicle
end

function HELPERS.validate_player(id)
    return player_present(id) and player_alive(id)
end

function HELPERS.get_inventory(dyn_player)
    local inventory = {}
    for i = 0, 3 do
        local weapon = read_dword(dyn_player + 0x2F8 + i * 4)
        local object = get_object_memory(weapon)
        if object ~= 0 then
            inventory[i + 1] = {
                ["id"] = read_dword(object),                -- meta id
                ["ammo"] = read_word(object + 0x2B6),       -- primary weapon ammo
                ["clip"] = read_word(object + 0x2B8),       -- primary weapon clip
                ["ammo2"] = read_word(object + 0x2C6),      -- secondary weapon ammo
                ["clip2"] = read_word(object + 0x2C8),      -- secondary weapon clip
                ["age"] = read_float(object + 0x240),       -- age (energy heat)
                ['frags'] = read_byte(dyn_player + 0x31E),  -- frags
                ['plasmas'] = read_byte(dyn_player + 0x31F) -- plasmas
            }
        end
    end
    return inventory
end

function HELPERS.distance_squared(x1, y1, z1, x2, y2, z2, radius)
    local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end

function HELPERS.seconds_to_time(seconds)
    seconds = floor(seconds)
    return format("%02d:%02d", floor(seconds / 60), seconds % 60)
end

function HELPERS:send(player_id, ...)
    if not player_id then
        execute_command('msg_prefix ""')
        say_all(format(...))
        execute_command('msg_prefix "' .. self.MSG_PREFIX .. '"')
        return
    end
    rprint(player_id, format(...))
end

function HELPERS:debug_print(...)
    if self.DEBUG then
        cprint("[DEBUG] " .. format(...))
    end
end

function HELPERS:cls(player_id)
    for _ = 1, 25 do
        rprint(player_id, " ")
    end
end

function HELPERS.get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function HELPERS:get_crate_respawn_time()
    local min_spawn_delay = self.crates.min_spawn_delay
    local max_spawn_delay = self.crates.max_spawn_delay
    return random(min_spawn_delay, max_spawn_delay)
end

function HELPERS:get_sky_spawns()
    local points = {}
    local locations = self.sky_spawn_coordinates
    for i = 1, #locations do
        points[#points + 1] = locations[i]
    end
    return points
end

function HELPERS.get_random_sky_spawn_point(t)
    local index = random(#t)
    return t[index]
end

function HELPERS.teleport(player, dyn_player)
    local loc = player.sky_spawn_location
    local x, y, z, r, h = loc[1], loc[2], loc[3], loc[4], loc[5]
    write_vector3d(dyn_player + 0x5C, x, y, z + h)
    write_vector3d(dyn_player + 0x74, cos(r), sin(r), 0)
end

return HELPERS
