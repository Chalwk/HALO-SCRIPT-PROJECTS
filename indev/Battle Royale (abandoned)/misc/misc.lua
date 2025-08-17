local misc = {}

local sqrt = math.sqrt
local floor = math.floor
local format = string.format

function misc:meleeButton(dynamic_player)
    return (read_word(dynamic_player + 0x208) == 128)
end

function misc:secondsToTime(s)

    if (s <= 0) then
        return '00', '00', '00';
    end

    local hours = format('%02.f', floor(s / 3600));
    local mins = format('%02.f', floor(s / 60 - (hours * 60)));
    local secs = format('%02.f', floor(s - hours * 3600 - mins * 60));

    return hours, mins, secs
end

function misc:tagsToID(target, class)
    local t = {}
    for tag, value in pairs(target) do
        local id = self:getTag(class, tag)
        if (id) then
            t[id] = value
        end
    end
    return t
end

function misc:cls()
    for _ = 1, 25 do
        rprint(self.id, ' ')
    end
end

function misc:say(message, tick)

    -- global rcon message to all players:
    if (tick) then
        for i, v in pairs(self.players) do
            v:cls(i)
            rprint(i, message)
        end
        return

        -- private rcon message:
    elseif (self.id) then
        self:cls(self.id)
        rprint(self.id, message)
        return
    end

    -- global chat message:
    execute_command('msg_prefix ""')
    say_all(message)
    execute_command('msg_prefix "' .. self.prefix .. '"')
end

-- Sets the player's speed:
function misc:setSpeed()

    local id = self.id
    local weight = self.weight.enabled
    local default = self.default_running_speed

    local game_started = (self.game and self.game.started)
    if (not game_started) then
        return
    end

    local speed_timer = self.speed.timer
    if (speed_timer and speed_timer:get() >= self.speed.duration) then
        self.speed.current = default
        self.speed.timer = nil
    elseif (not speed_timer and weight) then
        local speed = self:getSpeed()
        self.speed.current = speed
    elseif (not player_alive(id)) then
        return
    end

    local player = get_player(id)
    local current_speed = read_float(player + 0x6C)
    if (current_speed == self.speed.current) then
        return
    end
    write_float(player + 0x6C, self.speed.current)
end

-- Gets the player's rotation based on their aim:
-- @dynamic_player (number) | player dynamic memory address
-- @return (number) | rotation in radians
local function getRotation(dynamic_player)

    -- xAim, yAim (aiming coordinates):
    local xAim = read_float(dynamic_player + 0x230)
    local yAim = read_float(dynamic_player + 0x234)

    -- Calculate the rotation:
    local rotation = math.atan2(yAim, xAim) * (180 / math.pi)
    if (rotation < 0) then
        rotation = rotation + 360
    end

    -- Convert to radians:
    rotation = rotation * (math.pi / 180)

    return rotation
end

local function crouchZ(dynamic_player, z)
    local crouch = read_float(dynamic_player + 0x50C)
    if (crouch == 0) then
        z = z + 0.65
    else
        z = z + 0.35
    end
    return z
end

-- Gets the player's current coordinates:
function misc:getXYZ(dynamic_player)

    local x, y, z, r

    local vehicle = read_dword(dynamic_player + 0x11C)
    local object = get_object_memory(vehicle)

    if (vehicle == 0xFFFFFFFF) then
        x, y, z = read_vector3d(dynamic_player + 0x5c)
        r = getRotation(dynamic_player)
    elseif (object ~= 0) then
        x, y, z = read_vector3d(object + 0x5c)
        r = getRotation(object)
    end
    z = crouchZ(dynamic_player, z)

    return x, y, z, r
end

-- Calculates the distance between two sets of coordinates:
function misc:getDistance(x1, y1, z1, x2, y2, z2)

    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2

    return sqrt(dx * dx + dy * dy + dz * dz)
end

--- This is not currently being used:
-- Calculates the distance between the player and the edge of the safe zone.
function misc:edgeCheck(px, py, pz, bx, by, bz)
    local x, y, z = px - bx, py - by, pz - bz
    local distance = sqrt(x ^ 2 + y ^ 2 + z ^ 2)
    return distance - self.safe_zone.size
end

function misc:inVehicle(dynamic_player)
    return (read_dword(dynamic_player + 0x11C) ~= 0xFFFFFFFF)
end

function misc:getTag(class, name)
    local tag = lookup_tag(class, name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

function misc:getWeaponObject(dynamic_player)
    local weapon = read_dword(dynamic_player + 0x118)
    return (weapon ~= 0xFFFFFFFF and get_object_memory(weapon)) or nil
end

function misc:disableDeathMessages()
    safe_write(true)
    write_dword(self.death_message_address, 0x03EB01B1)
    safe_write(false)
end

function misc:enableDeathMessages()
    safe_write(true)
    write_dword(self.death_message_address, self.original_death_message_address)
    safe_write(false)
end

function misc:modifyNuke()
    local tag = self.nuke_tag_data
    write_dword(tag + 0x0, 1084227584)
    write_dword(tag + 0x4, 1084227584)
    write_dword(tag + 0x1d0, 1065353216)
    write_dword(tag + 0x1d4, 1065353216)
    write_dword(tag + 0x1d8, 1065353216)
    write_dword(tag + 0x1f4, 1092616192)
end

function misc:rollbackNuke()
    local tag = self.nuke_tag_data
    write_dword(tag + 0x0, 1056964608)
    write_dword(tag + 0x4, 1073741824)
    write_dword(tag + 0x1d0, 1117782016)
    write_dword(tag + 0x1d4, 1133903872)
    write_dword(tag + 0x1d8, 1134886912)
    write_dword(tag + 0x1f4, 1086324736)
end

-- Checks if a command is enabled/disabled.
-- @param enabled (boolean, -> command file 'enabled' property)
-- @param name (string -> command file name property)
-- @return true/false
--
function misc:commandEnabled(enabled, name)

    if (enabled) then
        return true
    end

    self:addMessage('Sorry, /' .. name .. ' is disabled.')
    return false
end

-- Checks if player has permission to execute a command.
-- @param level (number, -> command file permission level property)
-- @return true/false
--
function misc:hasPermission(level)

    local lvl = tonumber(get_var(self.id, '$lvl'))
    if (lvl >= level) then
        return true
    end

    self:addMessage('Insufficient Permission.')
    return false
end

function misc:pluralize(n)
    return (n > 1 and 's' or '')
end

function misc:threeDecimal(s)
    return format('%.3f', s)
end

return misc