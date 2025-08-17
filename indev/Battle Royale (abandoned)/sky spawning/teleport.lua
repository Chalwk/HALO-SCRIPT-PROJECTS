local player = {}

local cos = math.cos
local sin = math.sin

function player:teleport(god, height)

    local dyn = get_dynamic_player(self.id)
    if (dyn == 0) then
        return
    end

    local x, y, z = self.spawn[1], self.spawn[2], self.spawn[3]

    local rotation = self.spawn[4]
    height = (height and self.spawn[5]) or 0

    write_vector3d(dyn + 0x5C, x, y, z + height)
    write_vector3d(dyn + 0x74, cos(rotation), sin(rotation), 0)
    --print('Spawned: ' .. x .. ', ' .. y .. ', ' .. z, rotation)

    if (god) then
        self.god = self:new() -- god mode timer
    end
end

return player