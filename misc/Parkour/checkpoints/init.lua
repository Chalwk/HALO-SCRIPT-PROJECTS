local checkpoint = {}

local function spawnOddball(x, y, z)
    return spawn_object('weap', 'weapons\\ball\\ball', x, y, z)
end

function checkpoint:createCheckpoints()

    local checkpoints = self[self.map].checkpoints
    local z_off = 0.3

    if checkpoints then

        for _, coord in ipairs(checkpoints) do
            local x, y, z = coord[1], coord[2], coord[3]
            local object = spawnOddball(x, y, z + z_off)
            self.oddballs[object] = {
                x = x,
                y = y,
                z = z + z_off
            }
        end
    end
end

-- Return the 'checkpoint' table.
return checkpoint