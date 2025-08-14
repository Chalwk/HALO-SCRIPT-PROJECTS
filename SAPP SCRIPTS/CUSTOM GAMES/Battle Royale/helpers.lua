local HELPERS = {}

local get_object_memory = get_object_memory
local floor, format = math.floor, string.format
local player_present, player_alive = player_present, player_alive
local execute_command, say_all, rprint = execute_command, say_all, rprint
local read_float, read_dword, read_vector3d = read_float, read_dword, read_vector3d

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

function HELPERS.distance_squared(x1, y1, z1, x2, y2, z2, radius)
    local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
    return (dx * dx + dy * dy + dz * dz) <= (radius * radius)
end

function HELPERS.validate_player(id)
    return player_present(id) and player_alive(id)
end

function HELPERS:send(player_id, ...)
    if not player_id then
        execute_command('msg_prefix ""')                          -- temporarily remove (means we canfit more characters in the message)
        say_all(format(...))
        execute_command('msg_prefix "' .. self.MSG_PREFIX .. '"') -- restore
        return
    end
    rprint(player_id, format(...)) -- rprint prints to the player's console
end

function HELPERS.secondsToTime(seconds)
    seconds = floor(seconds)
    return format("%02d:%02d", floor(seconds / 60), seconds % 60)
end

function HELPERS.get_tag(class, name)
    local tag = lookup_tag(class, name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function HELPERS:debug_print(...)
    if self.DEBUG then
        cprint("[DEBUG] " .. format(...))
    end
end

return HELPERS
