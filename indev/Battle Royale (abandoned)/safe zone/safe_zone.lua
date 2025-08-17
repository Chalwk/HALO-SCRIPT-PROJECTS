local SafeZone = {}
local format = string.format

local function getWinner(self)

    local t = {}
    for _, v in pairs(self.players) do
        local id = v.id
        local kills = tonumber(get_var(id, '$kills'))
        local deaths = tonumber(get_var(id, '$deaths'))
        t[id] = kills / deaths
    end

    local winner
    local highest = 0
    for id, v in pairs(t) do
        if (v > highest) then
            highest = v
            winner = id
        end
    end

    return winner
end

local function shrink(self)

    local min, max = self.safe_zone.min, self.safe_zone.max

    self.safe_zone.size = self.safe_zone.size - self.shrink_amount
    self.safe_zone.timer:restart()

    if (self.safe_zone.size <= min) then
        cprint('The Safe Zone has reached its minimum size')

        self.safe_zone.size = min
        self.safe_zone.timer.crunch_time = true
        self.safe_zone.timer:restart()

        for _, v in pairs(self.players) do
            v.lives = 1
        end

        return
    end

    cprint('[ SAFE ZONE SHRUNK ] Radius now (' .. self.safe_zone.size .. '/' .. max .. ') world units')
end

function SafeZone:shrinkSafeZone()

    if (not self.game or not self.game.started) then
        return
    end

    local safe_zone = self.safe_zone
    if (not safe_zone or not safe_zone.timer) then
        return
    end

    local timer = safe_zone.timer
    local time = timer:get()

    if (not timer.crunch_time) then
        local interval = self.duration - time
        if (interval <= 0 and self.safe_zone.size > self.safe_zone.min) then
            shrink(self)
        end
        return
    elseif (time >= self.end_after) then
        execute_command('sv_map_next')
        local winner = getWinner(self)
        if (winner) then
            local name = self.players[winner].name
            self:say(format('[VICTORY] %s has won the game!', name), true)
        end
    end
end

-- This function is not currently being used:
-- Spawns a visible barrier around the safe zone.
function SafeZone:spawnBarrier()

    self.barrier = {}

    local height = 0.3
    local total_flags = 30
    local radius = self.safe_zone.size

    local x, y, z = self.safe_zone.x, self.safe_zone.y, self.safe_zone.z

    local iterations = 0
    for i = 0, 360 do
        if (i > iterations) then
            iterations = iterations + 360 / total_flags
            local angle = i * math.pi / 180
            local x1 = x + radius * math.cos(angle)
            local y1 = y + radius * math.sin(angle)
            local z1 = z + height
            local object = spawn_object('weap', 'weapons\\flag\\flag', x1, y1, z1)
            self.barrier[object] = { x = x1, y = y1, z = z1 }
        end
    end
end

function SafeZone:outsideSafeZone()

    if (not self.game or not self.game.started) then
        return
    end

    for i, v in pairs(self.players) do
        local dyn = get_dynamic_player(i)
        if (dyn ~= 0 and player_alive(i)) then

            local px, py, pz = self:getXYZ(dyn)
            local radius = self.safe_zone.size
            local bX, bY, bZ = self.safe_zone.x, self.safe_zone.y, self.safe_zone.z

            local distance = self:getDistance(px, py, pz, bX, bY, bZ)
            if (distance <= radius) then
                v.hurt_cooldown = nil
                v:setHUD('primary', distance)
            elseif (not v.spectator) then
                self:hurt(v)
            end
        end
    end
end

function SafeZone:setSafeZone()

    local min_size, max_size = self.safe_zone.min, self.safe_zone.max
    local reduction_rate, reduction_amount = self.duration, self.shrink_amount

    self.safe_zone.size = max_size

    return (max_size - min_size) / reduction_amount * reduction_rate
end

return SafeZone