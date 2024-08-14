-- Vector class to handle positions and velocities
local Vector = {}
Vector.__index = Vector

-- Constructor function to create a new Vector object
function Vector:new(x, y, z)
    local self = setmetatable({}, Vector)
    self.x = x
    self.y = y
    self.z = z
    return self
end

-- Function to spawn oddballs with proper anchoring behavior
function Vector:createAnchor()

    -- Iterate over the oddballs table
    for object, v in pairs(self.oddballs) do
        local memory = get_object_memory(object)
        if memory ~= 0 then

            -- Create a new Vector object for the checkpoint position
            local target = Vector:new(v.x, v.y, v.z) -- checkpoint position

            -- Retrieve current position and velocity from memory
            local position, velocity = self:getCurrentPositionAndVelocity(memory)

            -- Calculate desired velocity to move towards the checkpoint
            local desired_velocity_x = target.x - position.x
            local desired_velocity_y = target.y - position.y
            local desired_velocity_z = target.z - position.z

            -- Apply smoothing factor for smoother movement
            local smoothing_factor = 0.1
            local new_velocity = Vector:new(
                    (desired_velocity_x - velocity.x) * smoothing_factor + velocity.x,
                    (desired_velocity_y - velocity.y) * smoothing_factor + velocity.y,
                    (desired_velocity_z - velocity.z) * smoothing_factor + velocity.z
            )

            -- Update position, velocity, and rotation in memory
            self:updatePositionAndRotation(memory, target, new_velocity)
        end
    end
end

-- Function to update position, velocity, and rotation in memory
function Vector:updatePositionAndRotation(memory, target, new_velocity)
    -- Update position in memory
    write_float(memory + 0x5C, target.x)
    write_float(memory + 0x60, target.y)
    write_float(memory + 0x64, target.z)

    -- Update velocity in memory
    write_float(memory + 0x68, new_velocity.x)
    write_float(memory + 0x6C, new_velocity.y)
    write_float(memory + 0x70, new_velocity.z)

    -- Reset yaw, pitch, and roll
    write_float(memory + 0x90, 0) -- yaw
    write_float(memory + 0x8C, 0) -- pitch
    write_float(memory + 0x94, 0) -- roll
end

-- Function to retrieve position from memory
function Vector:getPosition(memory)
    local x = read_float(memory + 0x5C)
    local y = read_float(memory + 0x60)
    local z = read_float(memory + 0x64)
    return Vector:new(x, y, z)
end

-- Function to retrieve velocity from memory
function Vector:getVelocity(memory)
    local x = read_float(memory + 0x68)
    local y = read_float(memory + 0x6C)

    local z = read_float(memory + 0x70)
    return Vector:new(x, y, z)
end

-- Function to retrieve current position and velocity from memory
function Vector:getCurrentPositionAndVelocity(memory)
    local position = self:getPosition(memory)
    local velocity = self:getVelocity(memory)
    return position, velocity
end

-- Return the Vector class
return Vector
